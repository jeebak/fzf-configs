#!/usr/bin/env bash
# shellcheck disable=SC1090

PLUGIN_D="$(dirname "${BASH_SOURCE[0]}")"

source "$PLUGIN_D/lib/ensure.sh"

source "$PLUGIN_D/lib/settings.sh"
source "$PLUGIN_D/lib/key-bindings.bash"

# fzf-git
bind -r "\C-g"
source "$PLUGIN_D/lib/git/key-bindings.bash"

# fzf-man
source "$PLUGIN_D/lib/man/key-bindings.bash"
