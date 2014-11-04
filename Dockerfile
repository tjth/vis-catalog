FROM ubuntu:14.04

# Update stuffs
RUN apt-get update
RUN ln -sf /bin/bash /bin/sh

# Install requirements for Rails app
RUN apt-get --yes --force-yes install git
RUN apt-get --yes --force-yes install curl

RUN apt-get --yes install libkrb5-dev
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

RUN curl -SL1 https://get.rvm.io | bash -s stable --ruby
RUN source /usr/local/rvm/scripts/rvm

RUN gem install rails
RUN gem install bundler

ADD . /tmp/rails
WORKDIR /tmp/rails

RUN bundle install

WORKDIR /src

EXPOSE 3123
CMD rake db:migrate && rails server -p 3123 
