#!/bin/bash

. ./script/functions.sh

NVM_DIR="$HOME/.nvm"

if [ ! -d $NVM_DIR ]; then
  echo 'Installing nvm and node'
  # This also installs node due to $NODE_VERSION being set
  curl -o- -sL "https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh" | bash
fi

add_to_rc "export NVM_DIR=\"${NVM_DIR}\""
add_to_rc "[ -s \"${NVM_DIR}/nvm.sh\" ] && \\. \"${NVM_DIR}/nvm.sh\""

if [ ! -d "$HOME/.yarn" ]; then
  curl -o- -sL https://yarnpkg.com/install.sh | bash
fi

add_to_rc 'export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"'
