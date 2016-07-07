#!/bin/bash

DOCKER_VERSION=`docker version --format '{{.Server.Version}}'`

verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

verlte $DOCKER_VERSION 1.10.0 && echo "Please upgrade to docker 1.10.2 or better" && exit -1

exit 0
