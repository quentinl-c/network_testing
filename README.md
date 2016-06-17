# network_testing
> Real time measurement of collaborative editors based on p2p networks. In order to test the effects of network topologies on user experience and clients resources

# Introduction
The project is organized and developed in order to be deployed over grid5000 (for further information : https://www.grid5000.fr/mediawiki/index.php/Grid5000:Home)
Some choices have been made to render the experimentation scripts compliant with Grid5000's tools.

However, you can build your own image and deploy it on other computers grid (a tutorial will explain in details the deployment process and will be the purpose of a future work)
If you want to see the progress of the project, you can consult the TODO file.
Don't hesitate to bring your contributions, I'll be happy to integrate them into the project

# How to use deployment script

## Settings

### Infrastructure
In order to modify parameters related to the infrastructure (system and network) you can to change the following values

You can change :
* The path toward rabbit-mq image
* The path toward server image
* The port on which server is listening
* The path toward client image
* The gateway (if you don't work on Nancy site, you must change it !)
* All the informations related to the targeted application (MUTEHOST DOCID)



```ruby
FSRABBITMQ = 'file:///home/qlaportechabasse/rabbimq-lxc.tar.gz'
FSSERVER = 'file:///home/qlaportechabasse/server-lxc.tar.gz'
FSCLIENT = 'file:///home/qlaportechabasse/client-lxc.tar.gz'
GATEWAY  = '10.147.255.254' # Default gateway of Nancy's sites
DOCID = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
MUTEHOST = 'http://mute-collabedition.rhcloud.com/peer/doc/'
SERVER_PORT = 5000
```

### Experience
If you want to modify parameters related to the experimentation, you can change the following values

You can change :
* The duration of the experimentation
* The number of writers and readers
* The typing speed of writers

```ruby
# Experimentation's settings
writers = 1
readers = 1
typing_speed = 5 # unit word/sec
duration = 240 # time unit : seconde
```
