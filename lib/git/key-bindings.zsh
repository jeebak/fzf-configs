#!/usr/bin/env ksh
# NOTE: the "ksh" is just to make shellcheck happy

bind-git-helper() {
  local c
  for c in "$@"; do
    eval "__fzf-configs::g$c-widget() {
      # shellcheck disable=SC2154
      local result=\$(fzf-git g$c | while read -r item; do echo -n \"\${(q)item} \"; done)
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
    zle -N __fzf-configs::g$c-widget
    [[ \$FZF_CONFIGS_NO_CONTROL = true ]] &&
      bindkey '^g$c'  __fzf-configs::g$c-widget ||
      bindkey '^g^$c' __fzf-configs::g$c-widget"
  done
}

bind-git-helper f b t r h l a w
# For tmux users that have ^{h,j,k,l} mapped to "select-pane -{L,D,U,R}"
FZF_CONFIGS_NO_CONTROL=true bind-git-helper h j k l

bind-git-helper-no-join() {
  local c
  for c in "$@"; do
    eval "__fzf-configs::g$c-widget() {
      fzf-git g$c
      zle accept-line
    }
    zle -N __fzf-configs::g$c-widget
    bindkey '^g^$c' __fzf-configs::g$c-widget"
  done
}

bind-git-helper-no-join s

__fzf-configs::grl-widget() {
  local result
  # shellcheck disable=SC2034,SC2296
  result=$(fzf-git grl | while read -r item; do echo -n "${(q)item} "; done)
  # shellcheck disable=SC2153
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
zle -N __fzf-configs::grl-widget
bindkey '^g^v' __fzf-configs::grl-widget

unset -f bind-git-helper bind-git-helper-no-join

__fzf-configs::git-pull-widget() {
  if command -v gum > /dev/null; then
    local askpass="$PLUGIN_D/libexec/git-askpass"
    SSH_ASKPASS="$askpass" SSH_ASKPASS_REQUIRE=prefer \
    GIT_ASKPASS="$askpass" \
    gum spin --spinner dot --spinner.foreground=109 \
      --title "Git Pulling..." --title.foreground=240 \
      --show-stdout --show-stderr \
      -- git pull
  else
    git pull
  fi
  # Run precmd hooks so git-aware prompts (vcs_info, p10k, starship, etc.) refresh
  local f
  for f in "${precmd_functions[@]}"; do
    (( ${+functions[$f]} )) && "$f"
  done
  zle reset-prompt
}
zle -N __fzf-configs::git-pull-widget

__fzf-configs::git-push-widget() {
  if command -v gum > /dev/null; then
    gum spin --spinner dot --spinner.foreground=109 \
      --title "Git Pushing..." --title.foreground=240 \
      --show-stdout --show-stderr \
      -- git push
  else
    git push
  fi
  # Run precmd hooks so git-aware prompts (vcs_info, p10k, starship, etc.) refresh
  local f
  for f in "${precmd_functions[@]}"; do
    (( ${+functions[$f]} )) && "$f"
  done
  zle reset-prompt
}
zle -N __fzf-configs::git-push-widget

# Avail.   '^g^q'
# Worktrees'^g^w'
bindkey -s '^g^e' " ^ufzf-git edit-modified\n^y^h"
# Remotes  '^g^r'
# Tags     '^g^t'
# Avail.   '^g^y'
#   "      '^g^u'
#   "      '^g^i'
#   "      '^g^o'
bindkey    '^g^p' __fzf-configs::git-pull-widget
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

bindkey    '^g\ep' __fzf-configs::git-push-widget
bindkey -s '^g?'   " ^ufzf-git g?\n^y^h"
