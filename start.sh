#!/bin/bash

# Remove tmp folder generated due to mounting
sudo rm -rf tmp

sudo cp -r db/. /data

sudo docker run -itd \
                -v $(pwd):/src \
                -v /data:/src/db \
                -p 3123:3123 \
                --name rails-app \
                rails

sudo docker logs rails-app
