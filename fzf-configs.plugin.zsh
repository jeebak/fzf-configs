#!/usr/bin/env ksh
# shellcheck disable=SC1090
# NOTE: the "ksh" is just to make shellcheck happy

PLUGIN_D="${0:a:h}"

source "$PLUGIN_D/lib/ensure.sh"

source "$PLUGIN_D/lib/settings.sh"
source "$PLUGIN_D/lib/bindings.zsh"

# fzf-git
bindkey -r "^G"
source "$PLUGIN_D/lib/git/key-binding.zsh"
