#!/usr/bin/env bash

export PATH="${PLUGIN_D}/bin:${PATH}"

FZF_DEFAULT_OPTS="$(
  bindings=(
    # Preview
    alt-j:preview-down
    alt-k:preview-up
    ctrl-f:preview-page-down
    ctrl-b:preview-page-up
    \?:toggle-preview
    alt-w:toggle-preview-wrap
    # Select all
    alt-a:toggle-all
  )
  # shellcheck disable=SC2178
  bindings="${bindings[*]}"

  echo "
# Keybindings
    --bind=${bindings// /,}

# https://github.com/junegunn/fzf/wiki/Color-schemes#seoul256-dusk
# Seoul256 Dusk
    --color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108
    --color info:108,prompt:109,spinner:108,pointer:168,marker:168
# Seoul256 Night
#   --color fg:242,bg:233,hl:65,fg+:15,bg+:234,hl+:108
#   --color info:108,prompt:109,spinner:108,pointer:168,marker:168

# Misc
    --inline-info # Display finder info inline with the query
    --preview-window='up:70%'
# I hate meeses to pieces... in fzf
    --no-mouse
  " | sed 's/#.*//;s/  */ /g;/^ *$/d'
)"

export FZF_DEFAULT_OPTS

# CTRL-T - Paste the selected files and directories onto the command-line
#   Set FZF_CTRL_T_COMMAND to override the default command
#   Set FZF_CTRL_T_OPTS to pass additional options
# export FZF_CTRL_T_COMMAND='git ls-files'

# Try bat, highlight, coderay, rougify in turn, then fall back to cat
export FZF_CTRL_T_OPTS="\
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
  --bind 'ctrl-o:execute(less {} > /dev/tty)' \
  --preview '(exa --color=always -Ta {} || tree -Ca {}) 2> /dev/null | head -1000'"

# If you're on a tmux session, you can start fzf in a split pane by setting
#   FZF_TMUX to 1, and change the height of the pane with
#   FZF_TMUX_HEIGHT (e.g. 20, 50%).

# https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings

# -----------------------------------------------------------------------------
# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
if command -v fd > /dev/null; then
  _fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
  }

  # Use fd to generate the list for directory completion
  _fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
  }
fi

# -----------------------------------------------------------------------------
# This is zsh only

if command -v zle > /dev/null; then
  # Custom fuzzy completion for user configured commands

  # Based on: fzf-completion
  _fzf-configs-completion() {
    local tokens cmd fzf matches
    setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

    tokens=(${(z)LBUFFER})
    if [ ${#tokens} -lt 1 ]; then
      zle expand-or-complete
      return
    fi

    cmd=${tokens[1]}

    if [ -f  "$HOME/.config/fzf-configs/completions/${cmd}.zsh" -a ${LBUFFER[-1]} = ' ' ]; then
      fzf="$(__fzfcmd_complete)"
      source "$HOME/.config/fzf-configs/completions/${cmd}.zsh"
      # See README.md for more info on how to use this.
      if [ -n "$matches" ]; then
        LBUFFER="$LBUFFER$matches"
      fi
      zle reset-prompt
    else
      zle expand-or-complete
    fi
  }
  zle -N  _fzf-configs-completion

  export fzf_default_completion=_fzf-configs-completion
fi
