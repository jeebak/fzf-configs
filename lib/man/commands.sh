#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2016

source "$PLUGIN_D/lib/utils.sh"

man_fzf() {
  local cyan yellow reset
  cyan="$(tput setaf 6)"; yellow="$(tput setaf 3)"; reset="$(tput sgr0)"

  # Single sed expression: colorize name (cyan) and section in parens (yellow).
  # Computed once so escape codes are expanded before streaming into fzf.
  local sed_expr="s/^\([^ (]*\)\( *([^)]*)\)/${cyan}\1${reset} ${yellow}\2${reset}/"

  local result
  while result=$(
    man -k . 2>/dev/null | sort -u | sed "$sed_expr" |
    fzf-base "📖 Man Pages" --reverse --cycle \
      --header="Preview: alt-j:↓,alt-k:↑,^f:pg↓,^b:pg↑" \
      --bind "alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up" \
      --preview-window=right:60% \
      --preview='
        line=$(sed "s/\x1b\[[0-9;]*m//g" <<< {})
        name=$(awk "{print \$1}" <<< "$line")
        sec=$(awk "{gsub(/[()]/,\"\",\$2); print \$2}" <<< "$line")
        MANWIDTH=$FZF_PREVIEW_COLUMNS man -P cat "$sec" "$name" 2>/dev/null |
          (bat --language=man --color=always --style=plain 2>/dev/null || col -bx)
      '
  ); do
    [[ -n "$result" ]] || break
    local name sec
    local clean_result
    # shellcheck disable=SC2001
    clean_result=$(sed 's/\x1b\[[0-9;]*m//g' <<< "$result")
    name=$(awk '{print $1}' <<< "$clean_result")
    sec=$(awk '{gsub(/[()]/,"",$2); print $2}' <<< "$clean_result")
    man "$sec" "$name"
  done
}

# Export all functions above, making them available to fzf's bind execute
export SHELL=bash
eval "$(declare -F | sed -e 's/-f /-fx /')"

# vim: set ft=bash:
