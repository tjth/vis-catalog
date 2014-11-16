#!/bin/bash

# Install docker
echo "== Installing Docker =="
sudo apt-get --yes --force-yes update &&
sudo apt-get --yes --force-yes install docker.io &&
sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker &&
sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io &&
source /etc/bash_completion.d/docker.io

# Build the rails image based on Dockerfile on same directory
echo "== Building Rails Image =="
sudo docker build -t rails .

# Create data directory (if not exist) for persistent data storage
sudo mkdir -p /data
