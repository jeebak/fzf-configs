export PATH="${PLUGIN_D}/bin:${PATH}"

export FZF_PREVIEW_BIND="alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up"

# CTRL-T - Paste the selected files and directories onto the command-line
#   Set FZF_CTRL_T_COMMAND to override the default command
#   Set FZF_CTRL_T_OPTS to pass additional options
# export FZF_CTRL_T_COMMAND='git ls-files'

# Try bat, highlight, coderay, rougify in turn, then fall back to cat
export FZF_CTRL_T_OPTS="\
  --bind='$FZF_PREVIEW_BIND' \
  --bind 'ctrl-o:execute(less {} > /dev/tty)' \
  --preview '[[ \$(file --mime {}) =~ binary ]] \
      && ([[ -d {} ]] && exa --color=always -Ta {} || tree -Ca {} || echo Binary: {}) 2> /dev/null \
      || (bat --style=changes,grid,numbers --color=always {} \
      || highlight -O ansi -l {} \
      || coderay {} \
      || rougify {} \
      || cat {}) 2> /dev/null | head -1000'"

# CTRL-R - Paste the selected command from history onto the command-line
#   If you want to see the commands in chronological order, press CTRL-R again
#   which toggles sorting by relevance
#   Set FZF_CTRL_R_OPTS to pass additional options
# ALT-C - cd into the selected directory
#   Set FZF_ALT_C_COMMAND to override the default command
#   Set FZF_ALT_C_OPTS to pass additional options
export FZF_ALT_C_OPTS="\
  --bind='$FZF_PREVIEW_BIND' \
  --bind 'ctrl-o:execute(less {} > /dev/tty)' \
  --preview '(exa --color=always -Ta {} || tree -Ca {}) 2> /dev/null | head -1000'"

# If you're on a tmux session, you can start fzf in a split pane by setting
#   FZF_TMUX to 1, and change the height of the pane with
#   FZF_TMUX_HEIGHT (e.g. 20, 50%).

# https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings

# -----------------------------------------------------------------------------
