#!/bin/bash

cd $HOME/verification-pages/
. ./script/functions.sh

# These version match what is being used on Wikimedia Toolforge
export RUBY_VERSION='2.4.1'
export NODE_VERSION='8.11.2'

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y build-essential curl git

. ./script/provision/ruby.sh
. ./script/provision/node.sh
. ./script/provision/mysql.sh

bundle install
yarn install

bundle exec rails db:setup

add_to_rc 'cd $HOME/verification-pages'
add_to_rc 'export PATH="./bin:$PATH"'
