#!/usr/bin/env ksh
# NOTE: the "ksh" is just to make shellcheck happy

__fzf-configs::man-widget() {
  fzf-man man_fzf
  zle accept-line
}
zle -N __fzf-configs::man-widget
bindkey '\eM' __fzf-configs::man-widget
