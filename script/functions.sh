#!/bin/bash

add_to_file () {
  touch "$2"
  grep -q -F "$1" "$2" || echo "$1" | sudo tee -a "$2" > /dev/null
}

add_to_rc () {
  add_to_file "$1" "$HOME/.bashrc"
  eval $1
}
