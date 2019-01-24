#!/bin/bash

. ./script/functions.sh

RBENV_DIR="$HOME/.rbenv"
RUBY_BUILD_DIR="$RBENV_DIR/plugins/ruby-build"

if [ ! -d "$HOME/.rbenv" ]; then
  echo 'Installing rbenv and ruby-build'
  git clone https://github.com/rbenv/rbenv.git $RBENV_DIR
  git clone https://github.com/rbenv/ruby-build.git $RUBY_BUILD_DIR
else
  echo 'Updating rbenv'
  pushd $RBENV_DIR > /dev/null
  git pull && popd > /dev/null

  echo 'Updating ruby-build'
  pushd $RUBY_BUILD_DIR > /dev/null
  git pull && popd > /dev/null
fi

add_to_rc 'export PATH="$HOME/.rbenv/bin:$PATH"'
add_to_rc 'eval "$(rbenv init -)"'

sudo apt-get install -y libssl-dev libreadline-dev zlib1g-dev

if [ ! -d "$HOME/.rbenv/versions/$RUBY_VERSION" ]; then
  echo 'Installing ruby and bundler'
  rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION

  add_to_file 'gem: --no-ri --no-rdoc' "$HOME/.gemrc"
  gem update --system > /dev/null
  gem install -f bundler > /dev/null
  bundle config path "$HOME/.bundle"
fi

add_to_rc 'export DISABLE_SPRING=1'
