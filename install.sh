#!/usr/bin/env bash

OMP_HOME="/home/coder/.local/bin/oh-my-posh"
if [ ! -d "$OMP_HOME" ]; then
  curl --silent --output /dev/null https://ohmyposh.dev/install.sh
fi

eval "$(/home/coder/.local/bin/oh-my-posh init zsh --config "https://raw.githubusercontent.com/gormanstock/coderdotfiles/refs/heads/main/omp.toml")"
