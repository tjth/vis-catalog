#!/bin/bash

# Stop all running docker containers and remove them (free up space)
sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)
