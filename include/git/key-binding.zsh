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
    bindkey '^g^$c' fzf-g$c-widget"
  done
}

bind-git-helper f b t r h

# Add 2nd widget/binding
# For example, for tmux users that have ^h mapped to "select-pane -L"
fzf-gh2-widget() {
  local result=$(fzf-git gh | join-lines)
  zle reset-prompt
  LBUFFER+=$result
}
zle -N fzf-gh2-widget
bindkey '^gh' fzf-gh2-widget

unset -f bind-git-helper