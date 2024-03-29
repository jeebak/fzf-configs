#!/usr/bin/env bash

# GIT heart FZF
# -------------

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

_pager() {
  if [[ $# -eq 0 ]]; then
    cat -    | less -Rc > /dev/tty
  else
    reo "$@" | less -Rc > /dev/tty
  fi
}

# Export the above functions, making them available to fzf's bind execute
export SHELL=bash
eval "$(declare -F | sed -e 's/-f /-fx /')"

# Lines of "preview"
LINES=1000

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% "$@" --border
}

fzf-git-confirm() {
  local yn

  if qt command -v whiptail; then
    whiptail --yesno --defaultno "$1" 0 0 > /dev/tty
  else
    yn="$(fzf-git-inputbox "$1 [y|n] ")"
    [[ $yn == [yY]* ]]
  fi

  return $?
}

fzf-git-inputbox() {
  # Prompt text as $1, w/ optional additional options
  # shellcheck disable=SC2005
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

# -----------------------------------------------------------------------------

gf() {
  is_in_git_repo || return

  # Return right away if index is clean
  if git diff --quiet && ! qte git status --porcelain | qt grep "^??"; then
    return
  fi

  local header prompt expect out pane_id file fileslist joined

  header="📝: ^a:add,^r:revert,^s:stash,^x:rm,^t:wip,^y:amend-no-edit"
  prompt="  👀: ^d:diff,^w:word-diff,^h:history {},^n:log --n-s,^l:log -p:alt-t:toggle-all: "
  expect="ctrl-a,ctrl-r,ctrl-s,ctrl-x,ctrl-t,ctrl-y"

  if [[ -n "$TMUX" ]]; then
    header="$header,^u:amend,^e:edit,^o:commit,^p:add -p"
    expect="$expect,ctrl-u,ctrl-e,ctrl-o,ctrl-p"
  fi

  # shellcheck disable=SC2207
  while out=($(
    git -c color.status=always status --short |
    fzf -m --ansi --nth 2..,.. \
      --header="$header" \
      --prompt="$prompt" \
      --expect="$expect" \
      --bind="alt-t:toggle-all" \
      --bind="ctrl-d:execute: _pager git diff --color=always \
        --stat -p -- '{-1}'" \
      --bind="ctrl-w:execute: _pager git diff --color=always \
        -w --word-diff -- '{-1}'" \
      --bind="ctrl-h:execute: _pager git log  --color=always \
        -p '{-1}'" \
      --bind="ctrl-n:execute: _pager git log  --color=always \
        --name-status" \
      --bind="ctrl-l:execute: _pager git log  --color=always \
        -p" \
      --preview="(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) |
        head -$LINES" |
    sed 's/^\(ctrl-.\)/    \1/' | cut -c4- | sed 's/.* -> //'
  )); do
    if [[ ${#out[@]} -eq 1 && ${out[0]} == ctrl-* ]]; then
      continue
    fi
    fileslist="\n$(printf '  %s\n' "${out[@]:1}")\n"
    case ${out[0]} in
      ctrl-a)
        git add "${out[@]:1}"
        ;;
      ctrl-r)
        if fzf-git-confirm "Really revert: ${fileslist}?"; then
          for file in "${out[@]:1}"; do
            if qt git ls-files --error-unmatch "$file"; then
              git checkout -- "${out[@]:1}"
            fi
          done
          _pager git status
        fi
        ;;
      ctrl-s)
        qt git stash push "${out[@]:1}"
        _pager git stash show --color=always --stat
        ;;
      ctrl-x)
        if fzf-git-confirm "Really rm: ${fileslist}?"; then
          for file in "${out[@]:1}"; do
            if qt git ls-files --error-unmatch "$file"; then
              git checkout -- "${out[@]:1}"
              git rm -f "$file"
            else
              rm -rf "$file"
            fi
          done
          _pager git status
        fi
        ;;
      ctrl-t)
        if fzf-git-confirm "Really add and commit as \"[WIP] ...\": ${fileslist}?"; then
          printf -v joined "%s, " "${out[@]:1}"
          qt git commit -m "[WIP] ${joined%, }" "${out[@]:1}"
        fi
        ;;
      ctrl-y)
        if fzf-git-confirm "Really add and amend --no-edit: ${fileslist}?"; then
          git add "${out[@]:1}"
          qt git commit --amend --no-edit
        fi
        ;;
      ctrl-u)
        if fzf-git-confirm "Really add and amend: ${fileslist}?"; then
          git add "${out[@]:1}"
          pane_id=$(tmux split-window -v -P -F "#{pane_id}")
          tmux send-keys -t "$pane_id" \
            "git commit --amend ${out[*]:1}; tmux wait-for -S amend-done; exit" \
              C-m\; wait-for amend-done
        fi
        ;;
      ctrl-e)
        pane_id=$(tmux split-window -v -P -F "#{pane_id}")
        tmux send-keys -t "$pane_id" \
          "${EDITOR:-vim} ${out[*]:1}; tmux wait-for -S edit-done; exit" \
            C-m\; wait-for edit-done
        ;;
      ctrl-o)
        if fzf-git-confirm "Really add and commit: ${fileslist}?"; then
          git add "${out[@]:1}"
          pane_id=$(tmux split-window -v -P -F "#{pane_id}")
          tmux send-keys -t "$pane_id" \
            "git commit ${out[*]:1}; tmux wait-for -S commit-done; exit" \
              C-m\; wait-for commit-done
        fi
        ;;
      ctrl-p)
        pane_id=$(tmux split-window -v -P -F "#{pane_id}")
        tmux send-keys -t "$pane_id" \
          "git add -p ${out[*]:1}; tmux wait-for -S add-p-done; exit" \
            C-m\; wait-for add-p-done
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
  local header prompt expect out branch yn msg branchlist parts

  header="📝: ^r:rename,^w:new,^o:checkout,^x:delete,alt-m:merge"
  prompt="  👀: ^s:log ..b,^d:diff,^f:log b..,^n:log --n-s,^p:log -p: "
  expect="ctrl-r,ctrl-w,ctrl-o,ctrl-x,alt-m"

  # shellcheck disable=SC2207
  out=($(
    git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf --ansi --multi --tac \
      --header="$header" \
      --prompt="$prompt" \
      --expect="$expect" \
      --bind="ctrl-s:execute: _pager git log --color=always --stat \
        -p ..\$(sed s'/* //' <<< {1})" \
      --bind="ctrl-d:execute: _pager git diff --color=always --stat \
        -p \$(sed s'/* //' <<< {1})" \
      --bind="ctrl-f:execute: _pager git log --color=always --stat \
        -p \$(sed s'/* //' <<< {1}).." \
      --bind="ctrl-n:execute: _pager git log --color=always --stat \
        --name-status \$(sed s'/* //' <<< {})" \
      --bind="ctrl-p:execute: _pager git log --color=always --stat \
        -p \$(sed s'/* //' <<< {})" \
      --preview="git log --color=always --oneline --graph --date=short \
        --pretty='format:%C(auto)%cd %h%d %s' \
        \$(sed s/^..// <<< {} | cut -d' ' -f1) | head -$LINES" |
    sed 's/^\(alt-.\)/  \1/;s/^\(ctrl-.\)/  \1/' |
      sed 's/^..//' | cut -d' ' -f1
  ))
  k=${out[0]}
  branch=${out[1]}
  if [[ $k == ctrl-* || $k == alt-* ]]; then
    [[ -z "$branch" ]] && return
    branchlist="\n$(printf '  %s\n' "${out[@]:1}")\n"
    case "$k" in
      ctrl-r)
        msg="$(
          reo git branch -m "$branch" \
            "$(fzf-git-inputbox 'Enter a branchname: ' -q "$branch")"
        )"
        ;;
      ctrl-w)
        msg="$(
          reo git checkout -b "$(fzf-git-inputbox 'Enter a branchname: ')" \
            "$branch"
        )"
        ;;
      ctrl-o)
        msg="$(reo git stash)"
        # shellcheck disable=SC2001
        branch="$(sed 's#^remotes/[^/][^/]*/##' <<< "$branch")"
        if git show-ref --verify --quiet "refs/heads/$branch"; then
          msg="${msg}\n\n$(reo git checkout    "$branch")"
        else
          msg="${msg}\n\n$(reo git checkout -b "$branch")"
        fi
        ;;
      ctrl-x)
        if fzf-git-confirm "Really delete: ${branchlist}?"; then
          for branch in "${out[@]:1}"; do
            if [[ $branch == remotes/* ]]; then
              IFS='/' read -r -a parts <<< "$branch"
              # shellcheck disable=SC2030,2124
              branch="${parts[@]:2}" # Branch names with /'s
              msg="${msg}\n$(
                reo git push "${parts[1]}" --delete "${branch// //}"
              )"
            else
              msg="${msg}\n$(
                reo git branch -D "$branch"
              )"
            fi
          done
        fi
        ;;
      alt-m)
        # shellcheck disable=SC2031
        if fzf-git-confirm "Really merge: ${branch}?"; then
          msg="${msg}\n$(reo git merge --stat "$branch")"
        fi
        ;;
    esac
    [[ -n "$msg" ]] && echo -e "$msg" | _pager
    return
  fi
  if [[ ${#out[@]} -gt 0 ]]; then
    printf '%s\n' "${out[@]}" | sed 's#^remotes/##'
  fi
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi \
    --preview="git show --color=always {} | head -$LINES"
}

gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" \
    --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi \
    --header 'Press CTRL-S to toggle sort' \
    --bind='ctrl-s:toggle-sort' \
    --preview='grep -o "[a-f0-9]\{7,\}" <<< {} |
                xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  local header prompt expect out remote yn msg remoteslist r

  header="📝: ^x:remove,^f:fetch,^p:pull,alt-p:prune"
  expect="alt-p"

  # shellcheck disable=SC2207
  out=($(
    git remote -v | awk '{print $1 "\t" $2}' | uniq |
    fzf-down --tac \
      --header="$header" \
      --expect="$expect" \
      --bind="ctrl-x:execute: _pager git remote remove {1}" \
      --bind="ctrl-f:execute: _pager git fetch {1}" \
      --bind="ctrl-p:execute: _pager git pull {1}" \
      --preview="
        git log --oneline --graph --date=short --pretty='format:%C(auto)%cd %h%d %s' {1} |
        head -$LINES
    " |
    cut -d$'\t' -f1
  ))
  k=${out[0]}
  remote=${out[1]}
  if [[ $k == ctrl-* || $k == alt-* ]]; then
    [[ -z "$remote" ]] && return
    remoteslist="\n$(printf '  %s\n' "${out[@]:1}")\n"
    case "$k" in
      alt-p)
        # shellcheck disable=SC2031
        if fzf-git-confirm "Really prune: ${remoteslist}?"; then
          for r in "${out[@]:1}"; do
            msg="${msg}\n$(reo git remote prune "$r")"
          done
        fi
        ;;
    esac
    [[ -n "$msg" ]] && echo -e "$msg" | _pager
    return
  fi
  if [[ ${#out[@]} -gt 0 ]]; then
    printf '%s\n' "${out[@]}" | sed 's#^remotes/##'
  fi
}

# -----------------------------------------------------------------------------

# WIP
ga() {
  git config --get-regexp 'alias.*' |
    sed 's/^alias\.\([^ ]*\) \(.*\)/ \1#=> \2/' | column -s'#' -t | sort |
  fzf-down | awk '{ print $1; }'
}

gl() {
  is_in_git_repo || return
  local prompt

  prompt="  👀: ^d:diff,^w:show word-diff,<enter>:show: "

  # http://junegunn.kr/2015/03/browsing-git-commits-with-fzf/
  #   Based on: https://gist.github.com/junegunn/f4fca918e937e6bf5bad
  # fshow - git commit browser (enter for show, ctrl-d for diff, ` toggles sort)
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort=\` \
      --prompt="$prompt" \
      --bind="ctrl-d:execute:echo {} | grep -Eo '[a-f0-9]+' | head -1 |
        xargs -I % bash -c 'git diff --color=always -p % |
        _pager'" \
      --bind="ctrl-w:execute:echo {} | grep -Eo '[a-f0-9]+' | head -1 |
        xargs -I % bash -c 'git show --color=always -w --word-diff % |
        _pager'" \
      --bind="ctrl-m:execute:echo {} | grep -Eo '[a-f0-9]+' | head -1 |
        xargs -I % bash -c 'git show --color=always % |
        _pager'" \
      --preview="echo {} | grep -Eo '[a-f0-9]+' | head -1 |
        xargs -I% git show --color=always --stat -p %"
}

gs() {
  # Based on:
  #   https://gist.github.com/junegunn/a563d9e3e07fd721d618562762ec619d
  is_in_git_repo || return
  local header prompt expect yn msg out k reflog branch

  header="📝: alt-b:branch,^o:pop,^y:apply,^x:drop"
  prompt="  👀: enter:show,^d:diff: "
  expect="alt-b,ctrl-o,ctrl-y,ctrl-x"

  # Stash, if dirty
  if git diff --quiet || yn=$(
    fzf-git-inputbox "Should I stash this? [y for all|s for some] " \
      --preview='git diff --color=always'
  ); then
    if [[ $yn == [yY]* ]]; then
      msg="$(git stash)"
    elif [[ $yn == [sS]* ]]; then
      out=$(
        git -c color.status=always status --short |
        fzf -m --ansi \
          --header="Select files to stash (toggle with [tab] key)" \
          --preview="git diff --color=always -- {-1} | head -$LINES" |
        cut -c4- | sed 's/.* -> //'
      )
      # shellcheck disable=SC2086
      [[ -n $out ]] && msg="$(git stash push $out)"
    fi
    [[ -n "$msg" ]] && echo -e "$msg" | _pager
  fi
  if [[ -s "$(git rev-parse --git-dir)/refs/stash" ]]; then
    # shellcheck disable=SC2207
    out=($(
      git stash list --pretty='%C(yellow)%gd %>(14)%Cgreen%cr %C(blue)%gs' |
      fzf --ansi --no-sort --border --reverse \
        --header="$header" \
        --prompt="$prompt" \
        --expect="$expect" \
        --bind="enter:execute(
          _pager git stash show --color=always -p \$(cut -d' ' -f1 <<< {})
        )" \
        --bind="ctrl-d:execute(
          _pager git diff --color=always --stat -p \$(cut -d' ' -f1 <<< {})
        )" \
        --preview="git stash show --color=always \
          -p \$(cut -d' ' -f1 <<< {}) | head -$LINES"
    ))
    k=${out[0]}
    reflog=${out[1]}
    if [ -n "$reflog" ]; then
      case "$k" in
        alt-b)
          branch="$(fzf-git-inputbox 'Enter a branchname: ')"
          msg="$(git stash branch "$branch" "$reflog")"
          ;;
        ctrl-o)
          msg="$(git stash pop "$reflog")"
          ;;
        ctrl-y)
          msg="$(git stash apply "$reflog")"
          ;;
        ctrl-x)
          if fzf-git-confirm "Really drop this stash?"; then
            msg="$(git stash drop "$reflog")"
          fi
          ;;
      esac
      [[ -n "$msg" ]] && echo -e "$msg" | _pager
    fi
  else
    echo -n "$(tput bold)$(tput setaf 7)No stashes found!$(tput sgr0)"
  fi
}

edit-modified() {
  is_in_git_repo || { echo "Not in a git repo." && exit 1; }
  # shellcheck disable=SC2207
  local files=(
    $(command git status -s | sed -ne 's/^ *MM* //p')
  )
  "${EDITOR:-vim}" "${files[@]}"
}

# vim: set ft=bash:
