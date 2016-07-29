#!/bin/bash
if [ $# -lt 3 ]
then
  echo Usage $0 clients_amount config_file save_dir
  exit
fi

export IS_LOCAL_CONFIG=true
export HOME_DIR=$3
export CHROMEDRIVER_LOCATION='./chromedriver'

rabbitmq-server &


sleep 8 # waiting the end of rmq server launching

../network_testing-server/app/__init__.py -f $2 &

sleep 2

for (( i = 0; i < $1; i++ )); do
  ../network_testing-client/app/setup.py &
done
