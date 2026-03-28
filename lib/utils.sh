#!/usr/bin/env bash

# Base fzf wrapper: adds --ansi --border --border-label and --tmux when inside tmux.
# Inspired by junegunn/fzf-git.sh. Usage: fzf-base "Label" [fzf-opts...]
fzf-base() {
  local label="$1"; shift
  local -a tmux_opt=()
  if [[ -n "$TMUX" ]]; then
    local w h max_w max_h
    max_w=180
    max_h=60
    w=$(( $(tmux display-message -p '#{client_width}') * 9 / 10 ))
    h=$(( $(tmux display-message -p '#{client_height}') * 9 / 10 ))
    (( w > max_w )) && w=$max_w
    (( h > max_h )) && h=$max_h
    tmux_opt=(--tmux "$w,$h")
  fi
  fzf --ansi --border --border-label=" $label " "${tmux_opt[@]}" "$@"
}

# Quiet everything
qt() {
  "$@" > /dev/null 2>&1
}

# Quiet stderr
qte() {
  "$@" 2> /dev/null
}

# Redirect error to out
reo() {
  "$@" 2>&1
}

# Check if a command exists on PATH
cmd_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Echo to stderr
errcho() {
  >&2 echo "$@"
}

# Print error message and exit; optional second arg sets exit code (default 1)
die() {
  local exit_code

  [[ -z "$2" ]] && exit_code=1 || exit_code="$2"
  errcho "$1"
  exit "$exit_code"
}

# Copy stdin to clipboard via OSC52 and native fallbacks
clip() {
  local data encoded
  data=$(cat)
  encoded=$(printf '%s' "$data" | base64 | tr -d '\n')

  # OSC52: terminal emulator writes to its clipboard — works locally and over SSH.
  # Send plain OSC52 in all cases; tmux with set-clipboard on/external intercepts
  # it from the pane directly (DCS passthrough requires allow-passthrough on).
  # Also load into tmux paste buffer so ^] / prefix-] paste works too.
  printf '\e]52;c;%s\a' "$encoded" > /dev/tty
  [[ -n "$TMUX" ]] && printf '%s' "$data" | tmux load-buffer -

  # Native fallbacks for terminals that don't support OSC52, inspired by
  # ohmyzsh's clipboard.zsh patterns.
  # Order: macOS/Cygwin (OSTYPE) → Wayland → X11 → generic/remote tools.
  if   [[ "$OSTYPE" == darwin* ]] && cmd_exists pbcopy; then
    printf '%s' "$data" | pbcopy
  elif [[ "$OSTYPE" == cygwin* || "$OSTYPE" == msys* ]]; then
    if   cmd_exists clip.exe;      then printf '%s' "$data" | clip.exe
    elif [[ -e /dev/clipboard ]];  then printf '%s' "$data" > /dev/clipboard
    fi
  elif [[ -n "$WAYLAND_DISPLAY" ]] && cmd_exists wl-copy; then
    printf '%s' "$data" | wl-copy &>/dev/null &
  elif [[ -n "$DISPLAY" ]]; then
    if   cmd_exists xclip; then printf '%s' "$data" | xclip -selection clipboard
    elif cmd_exists xsel;  then printf '%s' "$data" | xsel --clipboard --input
    fi
  elif cmd_exists win32yank;             then printf '%s' "$data" | win32yank -i --crlf
  elif cmd_exists termux-clipboard-set;  then printf '%s' "$data" | termux-clipboard-set
  elif cmd_exists lemonade;              then printf '%s' "$data" | lemonade copy
  elif cmd_exists doitclient;            then printf '%s' "$data" | doitclient wclip
  fi
}
