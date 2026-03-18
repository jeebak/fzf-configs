#!/usr/bin/env ksh
# NOTE: the "ksh" is just to make shellcheck happy

join-lines() {
  local item
  # shellcheck disable=SC2034
  while read -r item; do
    # shellcheck disable=SC2154
    echo -n "${(q)item} "
  done
}

bind-git-helper() {
  local c
  for c in "$@"; do
    eval "fzf-g$c-widget() {
      local result=\$(fzf-git g$c | join-lines)
      local buffer=\$BUFFER
      zle reset-prompt
      if [[ -n \$result ]]; then
        LBUFFER+=\$result
      else
        zle kill-whole-line
        zle accept-line
        print -z \"\$buffer\"
      fi
    }
    zle -N fzf-g$c-widget
    [[ \$FZF_CONFIGS_NO_CONTROL = true ]] &&
      bindkey '^g$c'  fzf-g$c-widget ||
      bindkey '^g^$c' fzf-g$c-widget"
  done
}

bind-git-helper f b t r h l a w
# For tmux users that have ^{h,j,k,l} mapped to "select-pane -{L,D,U,R}"
FZF_CONFIGS_NO_CONTROL=true bind-git-helper h j k l

bind-git-helper-no-join() {
  local c
  for c in "$@"; do
    eval "fzf-g$c-widget() {
      fzf-git g$c
      zle accept-line
    }
    zle -N fzf-g$c-widget
    bindkey '^g^$c' fzf-g$c-widget"
  done
}

bind-git-helper-no-join s

fzf-grl-widget() {
  local result
  result=$(fzf-git grl | join-lines)
  local buffer=$BUFFER
  zle reset-prompt
  if [[ -n $result ]]; then
    LBUFFER+=$result
  else
    zle kill-whole-line
    zle accept-line
    print -z "$buffer"
  fi
}
zle -N fzf-grl-widget
bindkey '^g^v' fzf-grl-widget

unset -f bind-git-helper bind-git-helper-no-join

fzf-git-pull() {
  if command -v gum > /dev/null; then
    gum spin --spinner dot --spinner.foreground=109 \
      --title "Git Pulling..." --title.foreground=240 \
      -- git pull
  else
    git pull
  fi
}

fzf-git-push() {
  if command -v gum > /dev/null; then
    gum spin --spinner dot --spinner.foreground=109 \
      --title "Git Pushing..." --title.foreground=240 \
      -- git push
  else
    git push
  fi
}

# Avail.   '^g^q'
# Worktrees'^g^w'
bindkey -s '^g^e' " ^ufzf-git edit-modified\n^y^h"
# Remotes  '^g^r'
# Tags     '^g^t'
# Avail.   '^g^y'
#   "      '^g^u'
#   "      '^g^i'
#   "      '^g^o'
bindkey -s '^g^p' " ^ufzf-git-pull\n^y^h"
# Avail.   '^g^['
#   "      '^g^]'
# N/A      '^g^\'

# Aliases  '^g^a'
# Stashes  '^g^s'
bindkey -s '^g^d' " ^ugit diff\n^y^h"
# Files    '^g^f'
bindkey -s '^g^g' " ^ugit status\n^y^h"
# Hashes   '^g^h'
# Avail.   '^g^j'
#   "      '^g^k'
# Logs     '^g^l'
# N/A      '^g^;'
# N/A      '^g^''

# Avail.   '^g^z'
#   "      '^g^x'
# N/A      '^g^c'
# Reflogs  '^g^v'
# Branches '^g^b'
# Avail.   '^g^n'
#   "      '^g^m'
# N/A      '^g^,'
# N/A      '^g^.'
bindkey -s '^g^_' " ^ufzf-git\n^y^h"

# NOTE: no "\n^y" like the others; both to allow to add extra params, and as a
# safguard
bindkey -s '^g\ep' " ^ufzf-git-push "
