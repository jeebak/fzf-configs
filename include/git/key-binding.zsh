join-lines() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

bind-git-helper() {
  local c
  for c in $@; do
    eval "fzf-g$c-widget() {
      local result=\$(fzf-git g$c | join-lines)
      zle reset-prompt
      LBUFFER+=\$result
    }
    zle -N fzf-g$c-widget
    [[ \$FZF_CONFIGS_NO_CONTROL = true ]] &&
      bindkey '^g$c'  fzf-g$c-widget ||
      bindkey '^g^$c' fzf-g$c-widget"
  done
}

bind-git-helper f b t r h l
# For tmux users that have ^{h,j,k,l} mapped to "select-pane -{L,D,U,R}"
FZF_CONFIGS_NO_CONTROL=true bind-git-helper h j k l

bind-git-helper-no-join() {
  local c
  for c in $@; do
    eval "fzf-g$c-widget() {
      fzf-git g$c
      zle accept-line
    }
    zle -N fzf-g$c-widget
    bindkey '^g^$c' fzf-g$c-widget"
  done
}

bind-git-helper-no-join s

unset -f bind-git-helper bind-git-helper-no-join

bindkey -s '^g^_' "^ufzf-git\n^y"
bindkey -s '^g^d' "^ugit diff\n^y"
bindkey -s '^g^e' "^ufzf-git edit-modified\n^y"
bindkey -s '^g^g' "^ugit status\n^y"
bindkey -s '^g^p' "^ugit pull\n^y"
# NOTE: no "\n^y" like the others; both to allow to add extra params, and as a
# safguard
bindkey -s '^g^[p' "^ugit push "
