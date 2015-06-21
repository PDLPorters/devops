#!/bin/sh

apt-get update
apt-get install -y build-essential

cd /vagrant && su -c ./provision-user.sh vagrant
