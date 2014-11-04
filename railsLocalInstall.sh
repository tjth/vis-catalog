#!/bin/bash

sudo apt-get update
sudo apt-get --yes --force-yes install git
sudo apt-get --yes --force-yes install curl

sudo apt-get --yes install libkrb5-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

curl -SL1 https://get.rvm.io | bash -s stable --ruby
source /home/guest/.rvm/scripts/rvm

gem install --no-ri --no-rdoc rails
gem install --no-ri --no-rdoc bundler

bundle install

