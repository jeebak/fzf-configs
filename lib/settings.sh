#!/usr/bin/env bash
# shellcheck disable=SC2178

export PATH="${PLUGIN_D}/bin:${PATH}"

FZF_DEFAULT_OPTS="$(
  bindings=(
    # Preview
    alt-j:preview-down
    alt-k:preview-up
    ctrl-f:preview-page-down
    ctrl-b:preview-page-up
    alt-v:toggle-preview
    alt-w:toggle-preview-wrap
    # Select all
    alt-a:toggle-all
    # This is for safety, but can be overridden w/ --bind="ctrl-z:..." option
    ctrl-z:clear-screen
  )
  bindings="${bindings[*]}"

  color_theme=""
  # Respect https://no-color.org/
  if [[ -z "${NO_COLOR}" ]]; then
    # https://github.com/junegunn/fzf/wiki/Color-schemes
    #   https://github.com/junegunn/fzf/issues/4243
    #     Built-in themes
    # Select a theme by setting FZF_THEME (default: seoul256-dusk).
    # 256-color themes: red molokai jellybeans jellyx
    #                   seoul256-dusk seoul256-night
    #                   solarized-dark solarized-light
    # Truecolor themes: papercolor one-dark nord dracula
    #                   ayu-mirage gruvbox-dark spacecamp
    #                   termschool zenwritten tomorrow-night

    case "${FZF_THEME:-seoul256-dusk}" in
      red)
        color_theme="
          --color fg:124,bg:16,hl:202,fg+:214,bg+:52,hl+:231
          --color info:52,prompt:196,spinner:208,pointer:196,marker:208
        "
        ;;
      molokai)
        color_theme="
          --color fg:252,bg:233,hl:67,fg+:252,bg+:235,hl+:81
          --color info:144,prompt:161,spinner:135,pointer:135,marker:118
        "
        ;;
      jellybeans)
        color_theme="
          --color fg:188,bg:233,hl:103,fg+:222,bg+:234,hl+:104
          --color info:183,prompt:110,spinner:107,pointer:167,marker:215
        "
        ;;
      jellyx)
        color_theme="
          --color fg:-1,bg:-1,hl:230,fg+:3,bg+:233,hl+:229
          --color info:150,prompt:110,spinner:150,pointer:167,marker:174
        "
        ;;
      seoul256-night)
        color_theme="
          --color fg:242,bg:233,hl:65,fg+:15,bg+:234,hl+:108
          --color info:108,prompt:109,spinner:108,pointer:168,marker:168
        "
        ;;
      solarized-dark)
        color_theme="
          --color dark,hl:33,hl+:37,fg+:235,bg+:136,fg+:254
          --color info:254,prompt:37,spinner:108,pointer:235,marker:235
        "
        ;;
      solarized-light)
        color_theme="
          --color fg:240,bg:230,hl:33,fg+:241,bg+:221,hl+:33
          --color info:33,prompt:33,pointer:166,marker:166,spinner:33
        "
        ;;
      papercolor)
        color_theme="
          --color=fg:#4d4d4c,bg:#eeeeee,hl:#d7005f
          --color=fg+:#4d4d4c,bg+:#e8e8e8,hl+:#d7005f
          --color=info:#4271ae,prompt:#8959a8,pointer:#d7005f
          --color=marker:#4271ae,spinner:#4271ae,header:#4271ae
        "
        ;;
      one-dark)
        color_theme="
          --color=dark
          --color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe
          --color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef
        "
        ;;
      nord)
        color_theme="
          --color fg:#D8DEE9,bg:#2E3440,hl:#A3BE8C,fg+:#D8DEE9,bg+:#434C5E,hl+:#A3BE8C
          --color pointer:#BF616A,info:#4C566A,spinner:#4C566A,header:#4C566A,prompt:#81A1C1,marker:#EBCB8B
        "
        ;;
      dracula)
        color_theme="
          --color=dark
          --color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
          --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
        "
        ;;
      ayu-mirage)
        color_theme="
          --color=fg:#cbccc6,bg:#1f2430,hl:#707a8c
          --color=fg+:#707a8c,bg+:#191e2a,hl+:#ffcc66
          --color=info:#73d0ff,prompt:#707a8c,pointer:#cbccc6
          --color=marker:#73d0ff,spinner:#73d0ff,header:#d4bfff
        "
        ;;
      gruvbox-dark)
        color_theme="
          --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
          --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54
        "
        ;;
      spacecamp)
        color_theme="
          --color=fg:#dedede,bg:#121212,hl:#666666
          --color=fg+:#eeeeee,bg+:#282828,hl+:#cf73e6
          --color=info:#cf73e6,prompt:#FF0000,pointer:#cf73e6
          --color=marker:#f0d50c,spinner:#cf73e6,header:#91aadf
        "
        ;;
      termschool)
        color_theme="
          --color=fg:#f0f0f0,bg:#252c31,bg+:#005f5f,hl:#87d75f,gutter:#252c31
          --color=query:#ffffff,prompt:#f0f0f0,pointer:#dfaf00,marker:#00d7d7
        "
        ;;
      zenwritten)
        color_theme="
          --color=fg:#353535,bg:#eeeeee,hl:#353535
          --color=fg+:#353535,bg+:#e8e8e8,hl+:#353535
          --color=info:#353535,prompt:#353535,pointer:#353535
          --color=marker:#353535,spinner:#353535,header:#353535
        "
        ;;
      tomorrow-night)
        color_theme="
          --color=fg:#c5c8c6,bg:#1d1f21,hl:#b294bb,fg+:#c5c8c6,bg+:#373b41,hl+:#b294bb
          --color=info:#969896,marker:#f0c674,prompt:#b5bd68,spinner:#8abeb7,pointer:#81a2be,header:#81a2be
        "
        ;;
      seoul256-dusk|*)
        color_theme="
          --color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108
          --color info:108,prompt:109,spinner:108,pointer:168,marker:168
        "
        ;;
    esac
  fi

  echo "
    # Keybindings
    --bind=${bindings// /,}
    --bind='?:execute($PLUGIN_D/libexec/key-bindings-help | ${PAGER:-less} > /dev/tty)'

    $color_theme
    # Misc
    --inline-info # Display finder info inline with the query
    --preview-window='up:70%'
    # I hate meeses to pieces... in fzf
    --no-mouse
  " | sed '/^ *#/d;s/[[:space:]]#.*//;s/  */ /g;/^ *$/d'
)"

export FZF_DEFAULT_OPTS

# CTRL-T - Paste the selected files and directories onto the command-line
#   Set FZF_CTRL_T_COMMAND to override the default command
#   Set FZF_CTRL_T_OPTS to pass additional options
# export FZF_CTRL_T_COMMAND='git ls-files'

header="📝: ^e:edit,alt-y:yank-contents,alt-p:copy-path"
prompt="  👀: ^c:copy,^v:view,?:help: "

# Lines of "preview"
LINES=1000

# Try bat, highlight, coderay, rougify in turn, then fall back to cat
export FZF_CTRL_T_OPTS="
  --header='$header'
  --prompt='$prompt'
  --bind 'ctrl-c:execute(echo {} > /dev/tty)'
  --bind 'ctrl-e:execute(${EDITOR:-vim} {} > /dev/tty)'
  --bind 'ctrl-v:execute(${PAGER:-less} {} > /dev/tty)'
  --bind 'alt-y:execute($PLUGIN_D/libexec/copy-file-contents {+f})'
  --bind 'alt-p:execute($PLUGIN_D/libexec/copy-abspath {+f})'
  --preview '$PLUGIN_D/libexec/preview {} $LINES'
"

# CTRL-R - Paste the selected command from history onto the command-line
#   If you want to see the commands in chronological order, press CTRL-R again
#   which toggles sorting by relevance
#   Set FZF_CTRL_R_OPTS to pass additional options
# ALT-C - cd into the selected directory
#   Set FZF_ALT_C_COMMAND to override the default command
#   Set FZF_ALT_C_OPTS to pass additional options
prompt="  👀: ^v:view: "
export FZF_ALT_C_OPTS="
  --prompt='$prompt'
  --bind 'ctrl-v:execute(${PAGER:-less} {} > /dev/tty)'
  --preview '$PLUGIN_D/libexec/preview {} $LINES'
"

export FZF_TMUX_HEIGHT='70%'

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
    local tokens cmd fzf matches query
    setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

    # shellcheck disable=SC2206
    tokens=(${(z)LBUFFER})
    if [ ${#tokens} -lt 1 ]; then
      zle expand-or-complete
      return
    fi

    cmd=${tokens[1]}

    if [[ -f "$HOME/.config/fzf-configs/completions/${cmd}.zsh" ]]; then
      [[ ${#tokens} -gt 1 ]] && query=${tokens[-1]}
      # shellcheck disable=SC2034
      fzf="$(__fzfcmd_complete)"
      # shellcheck disable=SC1090
      source "$HOME/.config/fzf-configs/completions/${cmd}.zsh"
      # See README.md for more info on how to use this.
      if [ -n "$matches" ]; then
        LBUFFER="${LBUFFER%$query}$matches"
      fi
      zle reset-prompt
    else
      zle expand-or-complete
    fi
  }
  zle -N  _fzf-configs-completion

  export fzf_default_completion=_fzf-configs-completion
fi
