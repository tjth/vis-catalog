#!/bin/bash

# Script for installing Rails on local VM (i.e. not on Docker)

# Update packages and install git, curl and libkrb5-dev
sudo apt-get update &&
sudo apt-get --yes --force-yes install git &&
sudo apt-get --yes --force-yes install curl &&
sudo apt-get --yes install libkrb5-dev &&

# No root priviledge from now on ---

# Obtain public key for RVM, then pull and install RVM via curl
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 &&
curl -SL1 https://get.rvm.io | bash -s stable --ruby &&

# Use RVM by specifying the source address (suggested by RVM install msg)
source /home/guest/.rvm/scripts/rvm &&

# Install gems for rails and bundler (save time by not installing ri and rdoc)
gem install --no-ri --no-rdoc rails &&
gem install --no-ri --no-rdoc bundler &&

# Install the rest of the gems specified in Gemfile
bundle install

