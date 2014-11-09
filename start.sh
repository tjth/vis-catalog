#!/bin/bash

# Create a new folder to mount on container VM on Docker
# (Docker runs server & create log files and directories on the mounted folder
#   with root priviledges, which will break when developers switch back to
#   develop locally)
sudo mkdir -p $(pwd)/../vis-catalog-docker

# Remove the (new folder)/tmp directory to avoid multiple running server clash
#  error on RVM
sudo rm -rf $(pwd)/../vis-catalog-docker/tmp

# Copy all migrations to /data (persistent data storage)
#  - would not affect existing .sqlite3 files as it is not checked in on git
# Copy all source files to (new folder) - for mounting
sudo cp -r db/. /data
sudo cp -r ./* $(pwd)/../vis-catalog-docker

# Start and run a docker container:
# - In background
# - With (new folder) mounted as /src folder in container VM
# - With /data (persistent storage) mounted as /src/db in container VM
# - Routing port 3123 within the container VM to host machine's port 3123
# - With name rails-app
# - Based on the rails image
sudo docker run -itd \
                -v $(pwd)/../vis-catalog-docker:/src \
                -v /data:/src/db \
                -p 3123:3123 \
                --name rails-app \
                rails

# Output the logs for the app
sudo docker logs rails-app
