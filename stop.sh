#!/bin/bash

# Stop all running Docker containers and remove them from Docker
# (frees up space)
sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)
