#!/usr/bin/env bash
# shellcheck disable=SC1090

PLUGIN_D="$(dirname "${BASH_SOURCE[0]}")"

source "$PLUGIN_D/include/ensure.sh"

source "$PLUGIN_D/include/settings.sh"
source "$PLUGIN_D/include/bindings.bash"

# fzf-git
bind -r "\C-g"
source "$PLUGIN_D/include/git/key-binding.bash"
