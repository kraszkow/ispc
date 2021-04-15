#!/bin/bash -xe
echo PATH=$PATH
rm -rf /tmp/ispc_copy && rm -rf ./ispc_copy
mkdir /tmp/ispc_copy && cp -r ./. /tmp/ispc_copy/ && mv /tmp/ispc_copy .
docker build --tag ispc/centos7 -f docker/centos7/xpu_ispc_build/Dockerfile --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy .

docker run ispc/centos7
export CONTAINER=`docker ps --all |head -2 |tail -1 |awk '//{print $1}'`
mkdir build
docker cp $CONTAINER:/usr/local/src/ispc/build/bin ./build/
docker cp $CONTAINER:/usr/local/src/ispc/build/ispc-trunk-linux.tar.gz ./build/ispc-trunk-linux.tar.gz
