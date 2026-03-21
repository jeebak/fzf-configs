#!/usr/bin/env bash
# shellcheck disable=SC2016

bind '"\er": redraw-current-line'

# Avail.  '"\C-g\C-q"'
# Worktrees'"\C-g\C-w"'
bind      '"\C-g\C-w": "$(fzf-git gw)\e\C-e\er"'
bind      '"\C-g\C-e": " \C-ufzf-git edit-modified\n\C-y\C-h"'
bind      '"\C-g\C-r": "$(fzf-git gr)\e\C-e\er"'
bind      '"\C-g\C-t": "$(fzf-git gt)\e\C-e\er"'
# Avail.  '"\C-g\C-y"'
#   "     '"\C-g\C-u"'
#   "     '"\C-g\C-i"'
#   "     '"\C-g\C-o"'
__fzf-configs::git-pull() {
  if command -v gum > /dev/null; then
    gum spin --spinner dot --spinner.foreground=109 \
      --title "Git Pulling..." --title.foreground=240 \
      -- git pull
  else
    git pull
  fi
}

__fzf-configs::git-push() {
  if command -v gum > /dev/null; then
    gum spin --spinner dot --spinner.foreground=109 \
      --title "Git Pushing..." --title.foreground=240 \
      -- git push
  else
    git push
  fi
}

bind -x   '"\C-g\C-p": __fzf-configs::git-pull'
# Avail.  '"\C-g\C-["'
#   "     '"\C-g\C-]"'
# N/A     '"\C-g\C-\"'

bind      '"\C-g\C-a": "$(fzf-git ga)\e\C-e\er"'
bind      '"\C-g\C-s": " \C-ufzf-git gs\n\C-y\C-h"'
bind      '"\C-g\C-d": " \C-ugit diff\n\C-y\C-h"'
bind      '"\C-g\C-f": "$(fzf-git gf)\e\C-e\er"'
bind      '"\C-g\C-g": " \C-ugit status\n\C-y\C-h"'
bind      '"\C-g\C-h": "$(fzf-git gh)\e\C-e\er"'
bind      '"\C-gh":    "$(fzf-git gh)\e\C-e\er"'
# Avail.  '"\C-g\C-j"'
#   "     '"\C-g\C-k"'
bind      '"\C-g\C-l": "$(fzf-git gl)\e\C-e\er"'
bind      '"\C-gl":    "$(fzf-git gl)\e\C-e\er"'
# N/A     '"\C-g\C-;"'
# N/A     '"\C-g\C-'"'

# Avail.  '"\C-g\C-z"'
#   "     '"\C-g\C-x"'
# N/A     '"\C-g\C-c"'
# Reflogs '"\C-g\C-v"'
bind      '"\C-g\C-v": "$(fzf-git grl)\e\C-e\er"'
bind      '"\C-g\C-b": "$(fzf-git gb)\e\C-e\er"'
# Avail.  '"\C-g\C-n"'
#   "     '"\C-g\C-m"'
# N/A     '"\C-g\C-,"'
# N/A     '"\C-g\C-."'
bind      '"\C-g\C-_": " \C-ufzf-git\n\C-y\C-h"'

bind -x   '"\C-g\ep": __fzf-configs::git-push'
