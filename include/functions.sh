# GIT heart FZF
# -------------

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% "$@" --border
}

fzf-git-help() {
  local cmd
  # mdp throws unichr error
  # mdv displays blank page :/
  [[ -z "$cmd" ]] && cmd="$(command -v mdless)"
  [[ -z "$cmd" ]] && cmd="$(command -v bat)"
  [[ -z "$cmd" ]] && cmd="$(command -v cat)"
  "$cmd" "$PLUGIN_D/README.md"
}

gf() {
  # TODO: Explore possibilty of using a tmux pane (test if $TMUX is set,) to
  # start an $EDITOR session to edit files, or for "git commit"
  is_in_git_repo || return
  local header bind expect out yn

  header="Pick multi-files w/ tab/shift-tab,^a:add,^d:diff,^p:add -p,^r:revert,^x:rm"
  bind="alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up"
  expect="ctrl-a,ctrl-d,ctrl-p,ctrl-r,ctrl-x"

  while out=(
    $(git -c color.status=always status --short |
      fzf -m --ansi --nth 2..,.. \
        --header="$header" --bind="$bind" --expect="$expect" \
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
        read -n1 -p "Really revert: ${out[*]:1}? " yn < /dev/tty
        if [[ $yn == y ]]; then
          git checkout -- "${out[@]:1}"
          git status | less -r > /dev/tty
        fi
        ;;
      ctrl-x)
        read -n1 -p "Really rm: ${out[*]:1}? " yn < /dev/tty
        if [[ $yn == y ]]; then
          git checkout -- "${out[@]:1}"
          git rm -f "${out[@]:1}"
          git status | less -r > /dev/tty
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
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
}

gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

# -----------------------------------------------------------------------------

gs() {
  # Based on:
  #   https://gist.githubusercontent.com/junegunn/a563d9e3e07fd721d618562762ec619d/raw/5f318ec2a620243800f45caf25aa61d43f46a547/gstash.sh
  is_in_git_repo || return
  local out k reflog operation
  # Stash, if dirty
  git diff --quiet || git stash
  if [[ -s "$(git rev-parse --git-dir)/refs/stash" ]]; then
    out=(
      $(git stash list --pretty='%C(yellow)%gd %>(14)%Cgreen%cr %C(blue)%gs' |
        fzf --ansi --no-sort \
            --border \
            --header='enter:show, ctrl-d:diff, ctrl-o:pop, ctrl-y:apply, ctrl-x:drop' \
            --preview='git stash show --color=always -p $(cut -d" " -f1 <<< {}) | head -'$LINES \
            --preview-window=down:70% --reverse \
            --bind='enter:execute(git stash show --color=always -p $(cut -d" " -f1 <<< {}) | less -r > /dev/tty)' \
            --bind='ctrl-d:execute(git diff --color=always $(cut -d" " -f1 <<< {}) | less -r > /dev/tty)' \
            --bind='alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up' \
            --expect=ctrl-o,ctrl-y,ctrl-x
      )
    )
    k=${out[0]}
    reflog=${out[1]}
    if [ -n "$reflog" ]; then
      case "$k" in
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
