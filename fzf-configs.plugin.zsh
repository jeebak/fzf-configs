PLUGIN_D="${0:a:h}"
export PATH="${PLUGIN_D}/bin:${PATH}"

source "$PLUGIN_D/include/bindings.zsh"

# fzf-git
bindkey -r "^G"
source "$PLUGIN_D/include/key-binding.zsh"
