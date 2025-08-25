#!/bin/bash
echo "build frontend app ..."
./app_front_build.sh
sudo rm -r ~/.docker/config.json
docker login
export TOOLCHAINS=org.swift.5101202403041a
echo "build docker image ..."
sudo docker compose build 
echo "save docker image to .tar ..."
sudo docker save -o app_srv.tar app_kudo
echo "copy docker image to local host ..."
sudo scp -P 777 app_srv.tar als-srv1@192.168.2.79:~/docker_app/app_docker 
echo "finish transfer docker image to local host ..."
