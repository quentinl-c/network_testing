#!/usr/bin/ruby
require 'distem'
require 'net/http'
require 'json'

FSRABBITMQ = 'file:///home/qlaportechabasse/rabbimq-lxc.tar.gz'
FSSERVER = 'file:///home/qlaportechabasse/server-lxc.tar.gz'
FSCLIENT = 'file:///home/qlaportechabasse/client-lxc.tar.gz'
GATEWAY  = '10.147.255.254' # Default gateway of Nancy's sites
DOCID = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
MUTEHOST = 'http://mute-collabedition.rhcloud.com/peer/doc/'
SERVER_PORT = 5000
SAVE_DIR = '/tmp/'

vnet = {
  'name' => 'expnet',
  'address' => ARGV[0]
}

private_key = IO.readlines('/root/.ssh/id_rsa').join
public_key = IO.readlines('/root/.ssh/id_rsa.pub').join

sshkeys = {
  'private' => private_key,
  'public' => public_key,
}

server = {
    'name' => 'server',
    'address' => nil
}

rabbitmq = {
    'name' => 'rabbit-mq',
    'address' => nil
}


ifname = 'if0'

# Experimentation's settings
writers = 1
readers = 1
typing_speed = 5 # unit word/sec
duration = 10 # time unit : seconde
nbr_clients = writers + readers
clients = []

Distem.client do |cl|
    pnodes = cl.pnodes_info
    pnodes_list = pnodes.map{ |p| p[0]}

    puts "=== Pnodes ==="
    puts pnodes_list

    puts "=== Network ==="
    cl.vnetwork_create(vnet['name'], vnet['address'])

    puts "=== Rabbit-mq server is being lauched ==="
    cl.vnode_create(rabbitmq['name'],  { 'host' => pnodes_list[0] }, sshkeys)
    cl.vfilesystem_create(rabbitmq['name'], { 'image' => FSRABBITMQ })
    cl.viface_create(rabbitmq['name'], ifname, { 'vnetwork' => vnet['name'], 'default' => 'true' })

    cl.vnode_start(rabbitmq['name'])

    cl.wait_vnodes('vnodes'=>[rabbitmq['name']])

    rabbitmq['address'] = cl.viface_info(rabbitmq['name'], ifname)['address'].split('/')[0]
    puts rabbitmq['address']

    cl.vnode_execute(rabbitmq['name'], "ifconfig if0 #{rabbitmq['address']} netmask 255.252.0.0")
    cl.vnode_execute(rabbitmq['name'], "route add default gw #{GATEWAY} dev #{ifname}")

    puts "=== Server is being lauched ==="
    cl.vnode_create(server['name'],  { 'host' => pnodes_list[1] }, sshkeys)
    cl.vfilesystem_create(server['name'], { 'image' => FSSERVER })
    cl.viface_create(server['name'], ifname, { 'vnetwork' => vnet['name'], 'default' => 'true' })
    cl.vnode_start(server['name'])
    cl.wait_vnodes('vnodes'=>[server['name']])

    server['address'] = cl.viface_info(server['name'], ifname)['address'].split('/')[0]
    puts server['address']

    cl.vnode_execute(server['name'], "ifconfig if0 #{server['address']} netmask 255.252.0.0")
    cl.vnode_execute(server['name'], "route add default gw #{GATEWAY} dev #{ifname}")

    cl.vnode_execute(server['name'], "export SERVER_ADDRESS='#{server['address']}' && \
            export RABBITMQ_ADDRESS='#{rabbitmq['address']}' && \
            export TARGET='#{MUTEHOST}#{DOCID}' && \
            export WRITERS=#{writers} && \
            export READERS=#{readers} && \
            export TYPING_SPEED=#{typing_speed} && \
            export DURATION=#{duration} && \
            /etc/init.d/server start") # Launch the server
    puts "=== Deployment of the server is ended ==="

    # Intialisation of clients list
    (1..nbr_clients).each do |i|
        client = {
            'name' => "client-#{i}",
            'address' => nil
        }
        clients.push(client)
    end

    # Compute the number of clients per physical machine
    ratio = nbr_clients.to_f / pnodes_list.length
    ratio = ratio > 1 ? ratio.ceil : 1
    puts ratio
    # Deployment of clients
    pnodes_index = 0
    clients.each_with_index do |client, index|
        if index != 0 && (index + 1) % ratio == 0 && pnodes_index < pnodes_list.length then
            pnodes_index = pnodes_index + 1
        end

        puts "=== #{client['name']} is being launched on #{pnodes_list[pnodes_index]} ==="

        cl.vnode_create(client['name'], { 'host' => pnodes_list[pnodes_index] }, sshkeys)
        cl.vfilesystem_create(client['name'], { 'image' => FSCLIENT })
        cl.viface_create(client['name'], ifname, { 'vnetwork' => vnet['name'], 'default' => 'true' })
        cl.vnode_start(client['name'])
        cl.wait_vnodes('vnodes'=>[client['name']])

        client['address'] = cl.viface_info(client['name'], ifname)['address'].split('/')[0]
        puts "=== #{client['name']} is hosted by vnode : #{client['address']} ==="

        cl.vnode_execute(client['name'], "ifconfig if0 #{client['address']} netmask 255.252.0.0")
        cl.vnode_execute(client['name'], "route add default gw #{GATEWAY} dev #{ifname}")
        cl.vnode_execute(client['name'], "rm /etc/resolv.conf && cp /home/resolv.conf /etc/")
        cl.vnode_execute(client['name'], "echo \"127.0.0.1 localhost\" >> /etc/hosts")
        cl.vnode_execute(client['name'], "export SERVER_ADDRESS=#{server['address']} && \
                export RABBITMQ_ADDRESS=#{rabbitmq['address']} && \
                /etc/init.d/client start")

    end
    puts "=== Deployment completed ==="

    uri = URI("http://#{server['address']}:#{SERVER_PORT}/status")
    is_exp_started = false

    puts "=== Waiting for the beginning of the experimentation ==="

    while !is_exp_started
        sleep(1)
        puts "=== Query the server ==="
        res = Net::HTTP.get_response(uri)
        content = JSON.parse(res.body)
        is_exp_started = content['details']['is_exp_started']
        puts "=== Status of the experimentation : #{is_exp_started} ==="
        puts content
    end

    puts "=== The expreimentation should last #{duration} secondes"
    sleep(duration)
    is_exp_ended = false

    puts "=== Waiting for the end of the experimentation ==="

    while !is_exp_ended
        sleep(1)
        puts "=== Query the server ==="
        res = Net::HTTP.get_response(uri)
        content = JSON.parse(res.body)
        is_exp_ended = content['details']['is_exp_ended']
        puts "=== Status of the experimentation : #{is_exp_ended} ==="
        puts content
    end

    puts "=== Recovering of results ==="
    `scp root@#{server['address']}:/home/* #{SAVE_DIR}`
    puts "=== Results are saved in #{SAVE_DIR} ==="
end
