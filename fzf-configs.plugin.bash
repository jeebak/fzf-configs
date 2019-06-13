PLUGIN_D="$(dirname "${BASH_SOURCE[0]}")"
export PATH="${PLUGIN_D}/bin:${PATH}"

source "$PLUGIN_D/include/bindings.bash"

# fzf-git
bind -r "\C-g"
source "$PLUGIN_D/include/key-binding.bash"
