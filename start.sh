#!/bin/bash

sudo docker run -itd \
                -v /data:/src/db \
                -p 3123:3123 \
                --name rails-app \
                rails

sudo docker logs rails-app
