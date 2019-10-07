PLUGIN_D="${0:a:h}"

source "$PLUGIN_D/include/ensure.sh"

source "$PLUGIN_D/include/settings.sh"
source "$PLUGIN_D/include/bindings.zsh"

# fzf-git
bindkey -r "^G"
source "$PLUGIN_D/include/git/key-binding.zsh"
