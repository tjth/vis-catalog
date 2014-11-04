#!/bin/bash

mkdir -p $(pwd)/../vis-catalog-docker
rm -rf $(pwd)/../vis-catalog-docker/tmp

sudo cp -r db/. /data
sudo cp -r ./* $(pwd)/../vis-catalog-docker

sudo docker run -itd \
                -v $(pwd)/../vis-catalog-docker:/src \
                -v /data:/src/db \
                -p 3123:3123 \
                --name rails-app \
                rails

sudo docker logs rails-app
