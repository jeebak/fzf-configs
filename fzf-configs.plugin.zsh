PLUGIN_D="${0:a:h}"

source "$PLUGIN_D/include/env.sh"
source "$PLUGIN_D/include/bindings.zsh"

# fzf-git
bindkey -r "^G"
source "$PLUGIN_D/include/key-binding.zsh"
