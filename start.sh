#!/bin/bash

sudo rm -rf tmp

sudo docker run -itd \
                -v $(pwd):/src \
                -v /data:/src/db \
                -p 3123:3123 \
                --name rails-app \
                rails

sudo docker logs rails-app
