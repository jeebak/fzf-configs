PLUGIN_D="$(dirname "${BASH_SOURCE[0]}")"

source "$PLUGIN_D/include/ensure.sh"

source "$PLUGIN_D/include/env.sh"
source "$PLUGIN_D/include/bindings.bash"

# fzf-git
bind -r "\C-g"
source "$PLUGIN_D/include/git/key-binding.bash"
