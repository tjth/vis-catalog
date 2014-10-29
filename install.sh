#!/bin/bash

echo "== Installing Docker =="
sudo apt-get --yes --force-yes update &&
sudo apt-get --yes --force-yes install docker.io &&
sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker &&
sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io &&
source /etc/bash_completion.d/docker.io

sudo docker build -t rails ./docker
