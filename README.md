# WIP

# fzf-configs

## Installation

<details>
  <summary>Zsh</summary>

Add to your `.zshrc`.

#### Using [zplug](https://github.com/zplug/zplug)
```shell
zplug jeebak/fzf-configs
```

#### Using [zgen](https://github.com/tarjoilija/zgen)
```shell
zgen jeebak/fzf-configs
zgen save
```
etc. etc.

#### Manually
```
git clone --depth 1 https://github.com/jeebak/fzf-configs ~/some/path/fzf-configs
echo "source ~/some/path/fzf-configs/fzf-configs.plugin.zsh" >> ~/.zshrc
```

</details>

<details>
  <summary>Bash</summary>

#### Manually
```
git clone --depth 1 https://github.com/jeebak/fzf-configs ~/some/path/fzf-configs
echo "source ~/some/path/fzf-configs/fzf-configs.plugin.bash" >> ~/.bashrc
```

</details>

Automatically [installs fzf](https://github.com/junegunn/fzf#installation) if
`brew` (or `git`) is available.

## Simple Completion for Custom commands/scripts (`zsh` only)

The `include/settings.sh` file contains `_fzf-configs-completion()` that we're
using for `fzf_default_completion`. For example, to add your own completions
for a custom script named `doge`, create a file named:

- `$HOME/.config/fzf-configs/completions/doge.zsh`

and add something like:

```
 # keep "$query" pristine, use "$q" to form --query arg
 [[ -n $query ]] && q="--query=$query"
 matches=$(
   echo "
     option-1
     option-2
     option-3
   " | sed 's/#.*//;s/  */ /g;/^ *$/d' | ${fzf} $q
 )
```

This file **has** to contain something that uses `$fzf` and sets `$matches`.

## fzf-git
- https://junegunn.kr/2016/07/fzf-git/
  - https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236
- https://github.com/zulu-zsh/plugin-fzf-git
- https://github.com/junegunn/fzf/wiki/Examples
- https://github.com/wfxr/forgit

```
# Default keybindings, etc. are assigned to FZF_DEFAULT_OPTS

# fzf's -m, --multi option ("Enable multi-select with tab/shift-tab") is used
# whenever appropriate

CTRL-G CTRL-F for files
  CTRL-D: git diff ...
  CTRL-W: git diff -w --word-diff...
  CTRL-H: git log -p ...
  CTRL-A: git add ...
  CTRL-R: git checkout -- ...
  CTRL-S: git stash push ...
  CTRL-X: git rm -f ...
  CTRL-Y: git add ...; git  commit --amend --no-edit ...
  CTRL-U: git add ...; git  commit --amend ...
  # NOTE: if $TMUX is set, split-window and...
  CTRL-E: "${EDITOR:-vim}" ...
  CTRL-O: git add ...; git  commit --amend ...
  CTRL-P: git add -p ...

CTRL-G CTRL-B for branches
  CTRL-S: git log  -p ..<selected_branch>
  CTRL-D: git diff -p <selected_branch> # current branch
  CTRL-F: git log  -p <selected_branch>..
  CTRL-N: git log --name-status
  CTRL-P: git log -p
  CTRL-R: git branch   -m <oldbranch>  <newbranch>   # NOTE: <oldbranch>   is the current branch under the cursor
  CTRL-W: git checkout -b <new_branch> <start_point> # NOTE: <start_point> is the current branch under the cursor
  CTRL-O: git checkout ...  # NOTE: this WILL stash first, if dirty
  CTRL-X: git branch -D ... # NOTE: this WILL delete remote references too
  ALT-M:  git merge ...

CTRL-G CTRL-T for tags

CTRL-G CTRL-R for remotes
  CTRL-X: git remote remove ...
  CTRL-F: git fetch ...
  CTRL-P: git pull ...
  ALT-P:  git remote prune ...

CTRL-G CTRL-H for commit hashes
CTRL-G h        ""

CTRL-G CTRL-A for Aliases

CTRL-G CTRL-L for log
CTRL-G L        ""
  CTRL-D: git diff ...
  CTRL-W: git show -w --word-diff ...
  Enter:  git show ...

CTRL-G CTRL-S for stashes # NOTE: this will offer to "en-stash" some or all files when invoked
  ALT-B:  git stash branch <branchname>
  CTRL-O: git stash pop
  CTRL-Y: git stash apply
  CTRL-X: git stash drop

CTRL-G CTRL-/ for fzf-git help
CTRL-G CTRL-D for git diff
CTRL-G CTRL-E for edit modified files
CTRL-G CTRL-G for git status
CTRL-G CTRL-P for git pull
CTRL-G ALT-P  for git push
```
