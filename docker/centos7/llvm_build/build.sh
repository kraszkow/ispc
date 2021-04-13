#!/bin/bash -xe
img_name=ispc/centos7
docker build --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy --build-arg no_proxy=$no_proxy -t $img_name .
