#!/bin/bash

docker stop frontend_xos_synchronizer_globalxos_1
docker rm frontend_xos_synchronizer_globalxos_1
docker rmi xosproject/xos-synchronizer-globalxos
pushd /vagrant/xos_services/globalxos; git pull
popd; make rebuild
