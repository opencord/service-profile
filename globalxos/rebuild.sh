#!/bin/bash

docker stop globalxos_xos_synchronizer_globalxos_1
docker rm globalxos_xos_synchronizer_globalxos_1
docker rmi xosproject/xos-synchronizer-globalxos
pushd ~/xos_services/globalxos; git pull
popd; make rebuild
