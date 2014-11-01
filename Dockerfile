FROM ubuntu:14.04

# Update stuffs
RUN apt-get update

# Install requirements for Rails app
RUN apt-get --yes --force-yes install git
RUN apt-get --yes --force-yes install curl

RUN apt-get --yes --force-yes install libkrb5-dev
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

RUN curl -SL1 https://get.rvm.io | bash -s stable --ruby
RUN /bin/bash -c -l 'source /usr/local/rvm/scripts/rvm'

RUN /bin/bash -c -l 'gem install --no-ri --no-rdoc rails'
RUN /bin/bash -c -l 'gem install --no-ri --no-rdoc bundler'

ADD . /src
WORKDIR /src
RUN /bin/bash -c -l 'bundle install'

EXPOSE 3123
CMD /bin/bash -c -l 'rake db:migrate && rails server -p 3123' 
