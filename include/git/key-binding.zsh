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
      local buffer=\$BUFFER
      zle reset-prompt
      if [[ -n \$result ]]; then
        LBUFFER+=\$result
      else
        zle kill-whole-line
        zle accept-line
        print -z "\$buffer"
      fi
    }
    zle -N fzf-g$c-widget
    [[ \$FZF_CONFIGS_NO_CONTROL = true ]] &&
      bindkey '^g$c'  fzf-g$c-widget ||
      bindkey '^g^$c' fzf-g$c-widget"
  done
}

bind-git-helper f b t r h l a
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

# Avail.   '^g^q'
#   "      '^g^w'
bindkey -s '^g^e' " ^ufzf-git edit-modified\n^y^h"
# Remotes  '^g^r'
# Tags     '^g^t'
# Avail.   '^g^y'
#   "      '^g^u'
#   "      '^g^i'
#   "      '^g^o'
bindkey -s '^g^p' " ^ugit pull\n^y^h"
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
# Avail.   '^g^v'
# Branches '^g^b'
# Avail.   '^g^n'
#   "      '^g^m'
# N/A      '^g^,'
# N/A      '^g^.'
bindkey -s '^g^_' " ^ufzf-git\n^y^h"

# NOTE: no "\n^y" like the others; both to allow to add extra params, and as a
# safguard
bindkey -s '^g^[p' " ^ugit push ^h"
