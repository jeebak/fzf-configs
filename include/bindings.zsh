#!/usr/bin/env ksh
# NOTE: the "ksh" is just to make shellcheck happy

# Keybindings to trigger scripts.
# Attempt to restore cmdline. Not perfect but OK for now :/.
bindkey -s '\em' " ^ufzlp\n^y"

# Based on: http://weblog.bulknews.net/post/89635306479/ghq-peco-percol
#      and: https://gist.github.com/junegunn/f4fca918e937e6bf5bad
fzf-src () {
  local out selected_dir

  echo "Gathering list..."
  out="$(
    ghq list --full-path |
    fzf --reverse --tiebreak=index --toggle-sort=\` --query="$LBUFFER" \
        --prompt="Search for a local git clone: " \
        --print-query
  )"

  selected_dir="$(head -2 <<< "$out" | tail -1)"

  if [[ -n "$selected_dir" ]]; then
    # shellcheck disable=SC2034
    BUFFER="cd ${selected_dir} && git status"
    zle accept-line
  fi
  zle clear-screen
}

zle -N fzf-src
bindkey '\es' fzf-src

# Inspired by fzf docs
fzf-edit-file() {
  local out

  echo "Gathering list..."
  out="$(
    ( git ls-tree -r --name-only HEAD ||
      find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
        sed s/^..//
    ) 2> /dev/null |
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --tiebreak=index $FZF_CTRL_T_OPTS --preview-window up:70%" fzf
  )"

  [[ -n "$out" ]] && LBUFFER="${EDITOR:-vim} \"$out\""
  zle redisplay
}

zle     -N   fzf-edit-file
bindkey '^o' fzf-edit-file
bindkey '\eo' fzf-edit-file

# vim: set ft=zsh:
