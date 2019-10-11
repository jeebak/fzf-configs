#!/usr/bin/env bash

if ! command -v fzf  > /dev/null; then
  if command -v brew > /dev/null; then
    brew install fzf
    # To install useful key bindings and fuzzy completion:
    "$(brew --prefix)/opt/fzf/install"
  else
    [[ -d "$HOME/.fzf" ]] ||
      git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    [[ -x "$HOME/.fzf/install" ]] && "$HOME/.fzf/install"
  fi
fi

if ! command -v whiptail  > /dev/null; then
  if command -v brew      > /dev/null; then
    brew install newt
  fi
fi

hash > /dev/null 2>&1
