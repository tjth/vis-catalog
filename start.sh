#!/bin/bash

sudo docker run -itd \
                -p 3123:3123 \
                --name rails-app \
                rails

sudo docker logs rails-app
