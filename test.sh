#!/bin/bash

mkdir -p $(pwd)/../vis-catalog-docker
sudo rm -rf $(pwd)/../vis-catalog-docker

sudo cp -r db/. /data
sudo cp -r ./* $(pwd)/../vis-catalog-docker

sudo docker run -it \
                -v $(pwd)/../vis-catalog-docker:/src \
                -v /data:/src/db \
                -p 3123:3123 \
                --name rails-test \
                rails \
                '/bin/bash' \
                '-c' '-l' 'rake spec'

