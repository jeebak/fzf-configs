#!/usr/bin/env bash

# GIT heart FZF
# -------------

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% "$@" --border
}

fzf-git-confirm() {
  local yn

  if command -v whiptail > /dev/null; then
    whiptail --yesno --defaultno "$1" 0 0 > /dev/tty
  elif command -v dialog > /dev/null; then
    dialog --defaultno --yesno "$1" 0 0 > /dev/tty
  else
    yn="$(fzf-git-inputbox "$1 [y|n] ")"
    [[ $yn =~ [yY] ]]
  fi

  return $?
}

fzf-git-inputbox() {
  # Prompt text as $1, w/ optional additional options
  echo "$(fzf --prompt "$@" --print-query <<< '')"
}

fzf-git-help() {
  local cmd
  # mdp displays blank page :/
  # mdv throws unichr error
# [[ -z "$cmd" ]] && cmd="$(command -v mdp)"
# [[ -z "$cmd" ]] && cmd="$(command -v mdv)"
  [[ -z "$cmd" ]] && cmd="$(command -v mdless)"
  [[ -z "$cmd" ]] && cmd="$(command -v bat)"
  [[ -z "$cmd" ]] && cmd="$(command -v less)"
  [[ -z "$cmd" ]] && cmd="$(command -v cat)"
  "$cmd" "$PLUGIN_D/README.md" < /dev/tty > /dev/tty
}

gf() {
  is_in_git_repo || return
  local header expect out pane_id file

  header="Ops:^a:add,^d:diff,^p:add -p,^r:revert,^x:rm,^y:amend-no-edit"
  expect="ctrl-a,ctrl-d,ctrl-p,ctrl-r,ctrl-x,ctrl-y"

  if [[ -n "$TMUX" ]]; then
    header="$header,^e:edit,^o:commit"
    expect="$expect,ctrl-e,ctrl-o"
  fi

  while out=(
    $(git -c color.status=always status --short |
      fzf -m --ansi --nth 2..,.. \
        --header="$header" --bind="$FZF_PREVIEW_BIND" --expect="$expect" \
        --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) |
      head -500' | sed 's/^\(ctrl-.\)/    \1/' | cut -c4- | sed 's/.* -> //'
    )
  ); do
    case ${out[0]} in
      ctrl-a)
        git add "${out[@]:1}"
        ;;
      ctrl-d)
        git diff --color=always -- "${out[@]:1}" | less -r > /dev/tty
        ;;
      ctrl-p)
        git add -p "${out[@]:1}"
        ;;
      ctrl-r)
        if fzf-git-confirm "Really revert: ${out[*]:1}?"; then
          git checkout -- "${out[@]:1}"
          git status | less -r > /dev/tty
        fi
        ;;
      ctrl-x)
        if fzf-git-confirm "Really rm: ${out[*]:1}?"; then
          for file in "${out[@]:1}"; do
            if git ls-files --error-unmatch "$file" > /dev/null; then
              git checkout -- "${out[@]:1}"
              git rm -f "$file"
            else
              rm -rf "$file"
            fi
          done
          git status | less -r > /dev/tty
        fi
        ;;
      ctrl-y)
        if fzf-git-confirm "Really amend --no-edit: ${out[*]:1}?"; then
          git add "${out[@]:1}"
          git commit --amend --no-edit > /dev/null
        fi
        ;;
      ctrl-e)
        pane_id=$(tmux split-window -v -P -F "#{pane_id}")
        tmux send-keys -t "$pane_id" "${EDITOR:-vim} ${out[*]:1}; tmux wait-for -S edit-done; exit" C-m\; wait-for edit-done
        ;;
      ctrl-o)
        if fzf-git-confirm "Really add and commit: ${out[*]:1}?"; then
          git add "${out[@]:1}"
          pane_id=$(tmux split-window -v -P -F "#{pane_id}")
          tmux send-keys -t "$pane_id" "git commit ${out[*]:1}; tmux wait-for -S commit-done; exit" C-m\; wait-for commit-done
        fi
        ;;
      *)
        if [[ ${#out[@]} -gt 0 ]]; then
          printf '%s\n' "${out[@]}"
        fi
        break
        ;;
    esac
  done
}

gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --bind="$FZF_PREVIEW_BIND" \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --bind="$FZF_PREVIEW_BIND" \
    --preview 'git show --color=always {} | head -'$LINES
}

gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --bind="$FZF_PREVIEW_BIND" \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --bind="$FZF_PREVIEW_BIND" \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

# -----------------------------------------------------------------------------

gl() {
  is_in_git_repo || return
  # http://junegunn.kr/2015/03/browsing-git-commits-with-fzf/
  #   Based on: https://gist.github.com/junegunn/f4fca918e937e6bf5bad
  # fshow - git commit browser (enter for show, ctrl-d for diff, ` toggles sort)
  git log --graph --color=always \
          --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort=\` \
      --bind="$FZF_PREVIEW_BIND" \
      --preview "printf %q {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git diff --color=always %'" \
      --preview-window down:70% \
      --prompt="^d:diff,^l:log -p,^n:show --name-status,^w:word-diff,<enter>:show: " \
      --bind "ctrl-d:execute:
                printf %q {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git diff --color=always % |
                less -Rc > /dev/tty'" \
      --bind "ctrl-l:execute:
                printf %q {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git log -p --color=always %.. |
                less -Rc > /dev/tty'" \
      --bind "ctrl-n:execute:
                printf %q {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --name-status --color=always %.. |
                less -Rc > /dev/tty'" \
      --bind "ctrl-w:execute:
                printf %q {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always -w --word-diff % |
                less -Rc > /dev/tty'" \
      --bind "ctrl-m:execute:
                printf %q {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % |
                less -Rc > /dev/tty'"
}

gs() {
  # Based on:
  #   https://gist.githubusercontent.com/junegunn/a563d9e3e07fd721d618562762ec619d/raw/5f318ec2a620243800f45caf25aa61d43f46a547/gstash.sh
  is_in_git_repo || return
  local yn out k reflog operation
  # Stash, if dirty
  if git diff --quiet || yn=$(fzf-git-inputbox "Should I stash this? [y|n] " \
      --bind="$FZF_PREVIEW_BIND" \
      --preview 'git diff --color=always' \
      --preview-window down:70%); then
    [[ $yn =~ [yY] ]] && git stash
  fi
  if [[ -s "$(git rev-parse --git-dir)/refs/stash" ]]; then
    out=(
      $(git stash list --pretty='%C(yellow)%gd %>(14)%Cgreen%cr %C(blue)%gs' |
        fzf --ansi --no-sort \
            --border \
            --header='enter:show,^b:branch,^d:diff,^o:pop,^y:apply,^x:drop' \
            --preview='git stash show --color=always -p $(cut -d" " -f1 <<< {}) | head -'$LINES \
            --preview-window=down:70% --reverse \
            --bind='enter:execute(git stash show --color=always -p $(cut -d" " -f1 <<< {}) | less -r > /dev/tty)' \
            --bind='ctrl-d:execute(git diff --color=always $(cut -d" " -f1 <<< {}) | less -r > /dev/tty)' \
            --bind='alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up' \
            --expect=ctrl-b,ctrl-o,ctrl-y,ctrl-x
      )
    )
    k=${out[0]}
    reflog=${out[1]}
    if [ -n "$reflog" ]; then
      case "$k" in
        ctrl-b)
          git stash branch "$(fzf-git-inputbox 'Enter a branchname: ')" "$reflog"
          return
          ;;
        ctrl-o) operation=pop;;
        ctrl-y) operation=apply;;
        ctrl-x) operation=drop;;
      esac
      git stash "$operation" "$reflog"
    fi
  else
    echo -n "$(tput bold)$(tput setaf 7)No stashes found!$(tput sgr0)"
  fi
}

edit-modified() {
  is_in_git_repo || { echo "Not in a git repo." && exit 1; }
  "${EDITOR:-vim}" $(command git status -s | sed -ne 's/^ *MM* //p')
}

# vim: set ft=bash:
