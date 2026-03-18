#!/usr/bin/env bash
# shellcheck disable=SC1090

# GIT heart FZF
# -------------

source "$PLUGIN_D/lib/utils.sh"

# shellcheck disable=SC2120
_pager() {
  # shellcheck disable=SC2086
  local pager
  pager="${FZF_GIT_PAGER:-${GIT_PAGER:-$(git config core.pager 2>/dev/null)}}"
  pager="${pager:-less -Rc}"
  if [[ $# -eq 0 ]]; then
    cat -    | $pager > /dev/tty
  else
    reo "$@" | $pager > /dev/tty
  fi
}

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
  # mdp displays blank page :/
  # mdv throws unichr error
# command -v mdp   &>/dev/null && { mdp   "$PLUGIN_D/README.md" < /dev/tty > /dev/tty; return; }
# command -v mdv   &>/dev/null && { mdv   "$PLUGIN_D/README.md" < /dev/tty > /dev/tty; return; }
  command -v glow   &>/dev/null && { glow -p "$PLUGIN_D/README.md" < /dev/tty > /dev/tty; return; }
  command -v mdless &>/dev/null && { mdless  "$PLUGIN_D/README.md" < /dev/tty > /dev/tty; return; }
  command -v bat    &>/dev/null && { bat     "$PLUGIN_D/README.md" < /dev/tty > /dev/tty; return; }
  command -v less   &>/dev/null && { less    "$PLUGIN_D/README.md" < /dev/tty > /dev/tty; return; }
  cat "$PLUGIN_D/README.md" < /dev/tty > /dev/tty
}

# -----------------------------------------------------------------------------

gf() {
  is_in_git_repo || return

  # Return right away if index is clean
  if git diff --quiet && ! qte git status --porcelain | qt grep "^??"; then
    return
  fi

  local header prompt reload_cmd xf
  local -a fzf_opts

  header="📝: ^a:add,^r:revert,^s:stash,^x:rm,^t:wip,^y:amend-no-edit"
  prompt="  👀: ^d:diff,^w:word-diff,^h:history {},^n:log --n-s,^l:log -p,alt-t:toggle-all,?:help: "
  reload_cmd="git -c color.status=always status --short"
  # Helper: extract null-delimited filenames from a git status {+f} temp file,
  # write newline-delimited copy to a scratch file, and echo that scratch path.
  xf="$PLUGIN_D/libexec/git-status-files"

  if [[ -n "$TMUX" ]]; then
    header="$header,^u:amend,^e:edit,^o:commit,^p:add -p"
  fi

  fzf_opts=(
    -m --ansi "--nth=2..,.." --border --border-label=" git status "
    --header="$header"
    --prompt="$prompt"
    --bind="alt-t:toggle-all"
    --bind="ctrl-d:execute(_pager git diff --color=always --stat -p -- '{-1}')"
    --bind="ctrl-w:execute(_pager git diff --color=always -w --word-diff -- '{-1}')"
    --bind="ctrl-h:execute(_pager git log --color=always -p '{-1}')"
    --bind="ctrl-n:execute(_pager git log --color=always --name-status)"
    --bind="ctrl-l:execute(_pager git log --color=always -p)"
    --bind="ctrl-a:execute-silent($xf {+f} | xargs -0 git add --)+reload($reload_cmd)"
    --bind="ctrl-r:execute(
      files=\$($xf {+f} | tr '\0' '\n')
      fzf-git-confirm \"Really revert: \$(echo \"\$files\" | sed 's/^/  /')?\" &&
        echo \"\$files\" | while IFS= read -r f; do
          qt git ls-files --error-unmatch \"\$f\" && git checkout -- \"\$f\"
        done
    )+reload($reload_cmd)"
    --bind="ctrl-s:execute-silent($xf {+f} | xargs -0 git stash push --)+reload($reload_cmd)"
    --bind="ctrl-x:execute(
      files=\$($xf {+f} | tr '\0' '\n')
      fzf-git-confirm \"Really rm: \$(echo \"\$files\" | sed 's/^/  /')?\" &&
        echo \"\$files\" | while IFS= read -r f; do
          if qt git ls-files --error-unmatch \"\$f\"; then
            git checkout -- \"\$f\"; git rm -f \"\$f\"
          else
            rm -rf \"\$f\"
          fi
        done
    )+reload($reload_cmd)"
    --bind="ctrl-t:execute(
      files=\$($xf {+f} | tr '\0' '\n')
      joined=\$(echo \"\$files\" | paste -sd, | sed 's/,/, /g')
      fzf-git-confirm \"Really commit as [WIP] \$joined?\" &&
        { echo \"\$files\" | xargs -d '\n' git add -- && git commit -m \"[WIP] \$joined\" ; }
    )+reload($reload_cmd)"
    --bind="ctrl-y:execute(
      files=\$($xf {+f} | tr '\0' '\n')
      fzf-git-confirm \"Really add+amend --no-edit: \$(echo \"\$files\" | sed 's/^/  /')?\" &&
        { echo \"\$files\" | xargs -d '\n' git add -- && qt git commit --amend --no-edit; }
    )+reload($reload_cmd)"
    --preview="(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -$LINES"
  )

  if [[ -n "$TMUX" ]]; then
    fzf_opts+=(
      --bind="ctrl-u:execute(
        files=\$($xf {+f} | tr '\0' '\n')
        fzf-git-confirm \"Really add+amend: \$(echo \"\$files\" | sed 's/^/  /')?\" && {
          echo \"\$files\" | xargs -d '\n' git add --
          pane_id=\$(tmux split-window -v -P -F '#{pane_id}')
          tmux send-keys -t \"\$pane_id\" 'git commit --amend; tmux wait-for -S amend-done; exit' C-m
          tmux wait-for amend-done
        }
      )+reload($reload_cmd)"
      --bind="ctrl-e:execute(
        files=\$($xf {+f} | tr '\0' '\n')
        pane_id=\$(tmux split-window -v -P -F '#{pane_id}')
        tmux send-keys -t \"\$pane_id\" \"\${EDITOR:-vim} \$(echo \"\$files\" | xargs); tmux wait-for -S edit-done; exit\" C-m
        tmux wait-for edit-done
      )+reload($reload_cmd)"
      --bind="ctrl-o:execute(
        files=\$($xf {+f} | tr '\0' '\n')
        fzf-git-confirm \"Really add+commit: \$(echo \"\$files\" | sed 's/^/  /')?\" && {
          echo \"\$files\" | xargs -d '\n' git add --
          pane_id=\$(tmux split-window -v -P -F '#{pane_id}')
          tmux send-keys -t \"\$pane_id\" 'git commit; tmux wait-for -S commit-done; exit' C-m
          tmux wait-for commit-done
        }
      )+reload($reload_cmd)"
      --bind="ctrl-p:execute(
        files=\$($xf {+f} | tr '\0' '\n')
        pane_id=\$(tmux split-window -v -P -F '#{pane_id}')
        tmux send-keys -t \"\$pane_id\" \"git add -p \$(echo \"\$files\" | xargs); tmux wait-for -S add-p-done; exit\" C-m
        tmux wait-for add-p-done
      )+reload($reload_cmd)"
    )
  fi

  git -c color.status=always status --short |
  fzf "${fzf_opts[@]}" |
  cut -c4- | sed 's/.* -> //;s/^"//;s/"$//'
}

gb() {
  is_in_git_repo || return
  local header prompt expect out branch yn msg branchlist parts

  header="📝: ^r:rename,^w:new,^o:checkout,^x:delete,alt-m:merge,alt-o:open"
  prompt="  👀: ^s:log ..b,^d:diff,^f:log b..,^n:log --n-s,^p:log -p,?:help: "
  expect="ctrl-r,ctrl-w,ctrl-o,ctrl-x,alt-m"

  # shellcheck disable=SC2207
  out=($(
    git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf --ansi --multi --tac --border --border-label=" git branches " \
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
      --bind="alt-o:execute-silent(
        branch=\$(sed 's/\x1b\[[0-9;]*m//g' <<< {-1} | sed 's|^remotes/[^/]*/||')
        remote=\$(git config \"branch.\$branch.remote\" 2>/dev/null || echo origin)
        remote_url=\$(git remote get-url \"\$remote\" 2>/dev/null ||
          git remote get-url origin 2>/dev/null)
        [[ -z \"\$remote_url\" ]] && exit 0
        url=\${remote_url%.git}; url=\${url#git@}; url=https://\${url/://}
        xdg-open \"\$url/tree/\$branch\" 2>/dev/null ||
          open \"\$url/tree/\$branch\" 2>/dev/null
      )" \
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
    --border-label=" git tags " \
    --preview="git show --color=always {} | head -$LINES"
}

gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" \
    --graph --color=always |
  local prompt
  prompt="  👀: ^s:toggle-sort,?:help: "

  fzf-down --ansi --no-sort --reverse --multi \
    --border-label=" git hashes " \
    --header 'Press CTRL-S to toggle sort' \
    --prompt="$prompt" \
    --bind='ctrl-s:toggle-sort' \
    --preview='grep -o "[a-f0-9]\{7,\}" <<< {} |
                xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  local header prompt expect out remote yn msg remoteslist r

  header="📝: ^x:remove,^f:fetch,^p:pull,alt-p:prune"
  prompt="  👀: ^x:remove,^f:fetch,^p:pull,?:help: "
  expect="alt-p"

  # shellcheck disable=SC2207
  out=($(
    git remote -v | awk '{print $1 "\t" $2}' | uniq |
    fzf-down --tac \
      --border-label=" git remotes " \
      --header="$header" \
      --prompt="$prompt" \
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
  fzf-down --border-label=" git aliases " | awk '{ print $1; }'
}

gl() {
  is_in_git_repo || return
  local prompt

  prompt="  👀: ^d:diff,^w:show word-diff,<enter>:show,?:help: "

  # http://junegunn.kr/2015/03/browsing-git-commits-with-fzf/
  #   Based on: https://gist.github.com/junegunn/f4fca918e937e6bf5bad
  # fshow - git commit browser (enter for show, ctrl-d for diff, ` toggles sort)
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort=\` \
      --border --border-label=" git log " \
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
  local header prompt reload_cmd yn msg out

  header="📝: alt-b:branch,^o:pop,^y:apply,^x:drop"
  prompt="  👀: enter:show,^d:diff,?:help: "
  reload_cmd='git stash list --pretty=format:"%C(yellow)%gd %>(14)%Cgreen%cr %C(blue)%gs"'

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
    # shellcheck disable=SC2016
    git stash list --pretty='%C(yellow)%gd %>(14)%Cgreen%cr %C(blue)%gs' |
    fzf --ansi --no-sort --border --border-label=" git stashes " --reverse \
      --header="$header" \
      --prompt="$prompt" \
      --bind="enter:execute(_pager git stash show --color=always -p \$(cut -d' ' -f1 <<< {}))" \
      --bind="ctrl-d:execute(_pager git diff --color=always --stat -p \$(cut -d' ' -f1 <<< {}))" \
      --bind="ctrl-x:execute-silent(git stash drop \$(cut -d' ' -f1 <<< {}))+reload($reload_cmd)" \
      --bind="ctrl-o:execute(git stash pop \$(cut -d' ' -f1 <<< {}) | _pager)+reload($reload_cmd)" \
      --bind="ctrl-y:execute-silent(git stash apply \$(cut -d' ' -f1 <<< {}))" \
      --bind="alt-b:execute(
        branch=\$(fzf-git-inputbox 'Enter a branchname: ')
        [[ -n \"\$branch\" ]] && git stash branch \"\$branch\" \"\$(cut -d' ' -f1 <<< {})\" | _pager
      )+reload($reload_cmd)" \
      --preview="git stash show --color=always -p \$(cut -d' ' -f1 <<< {}) | head -$LINES"
  else
    echo -n "$(tput bold)$(tput setaf 7)No stashes found!$(tput sgr0)"
  fi
}

gw() {
  is_in_git_repo || return
  local reload_cmd
  reload_cmd="git worktree list"

  git worktree list |
  fzf --border --border-label=" git worktrees " \
    --header="📝: ^x:remove" \
    --prompt="  👀: ?:help: " \
    --bind="ctrl-x:execute-silent(git worktree remove {1})+reload($reload_cmd)" \
    --preview="git -C {1} log --color=always --oneline --graph --date=short \
      --pretty='format:%C(auto)%cd %h%d %s' | head -$LINES" |
  awk '{print $1}'
}

grl() {
  is_in_git_repo || return

  git reflog --color=always \
    --format="%C(yellow)%gd %C(green)%cd %C(auto)%h%d %C(blue)%gs" \
    --date=short |
  fzf --ansi --no-sort --reverse \
    --border --border-label=" git reflog " \
    --prompt="  👀: ?:help: " \
    --preview="grep -o '[a-f0-9]\{7,\}' <<< {} | head -1 |
      xargs -I% git show --color=always --stat -p % | head -$LINES" |
  grep -o "[a-f0-9]\{7,\}" | head -1
}

edit-modified() {
  is_in_git_repo || { echo "Not in a git repo." && exit 1; }
  # shellcheck disable=SC2207
  local files=(
    $(command git status -s | sed -ne 's/^ *MM* //p')
  )
  "${EDITOR:-vim}" "${files[@]}"
}

# Export all functions above, making them available to fzf's bind execute
export SHELL=bash
eval "$(declare -F | sed -e 's/-f /-fx /')"

# vim: set ft=bash:
