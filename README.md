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

## fzf-git
- https://junegunn.kr/2016/07/fzf-git/
  - https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236
- https://github.com/zulu-zsh/plugin-fzf-git
- https://github.com/junegunn/fzf/wiki/Examples
- https://github.com/wfxr/forgit

```
FZF_PREVIEW_BINDINGS="alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up"
# Use: --bind="$FZF_PREVIEW_BINDINGS" everywhere there's --preview

# fzf's -m, --multi option ("Enable multi-select with tab/shift-tab") is used
# whenever appropriate

CTRL-G CTRL-F for files
  CTRL-A: git add ...
  CTRL-D: git diff ...
  CTRL-R: git checkout -- ...
  CTRL-X: git rm -f ...
  CTRL-Y: git add ...; git  commit --amend --no-edit ...
  # NOTE: if $TMUX is set, split-window and...
  CTRL-E: "${EDITOR:-vim}" ...
  CTRL-O: git add ...; git  commit --amend ...
  CTRL-P: git add -p ...

CTRL-G CTRL-B for branches
  CTRL-N: git log --name-status
  CTRL-P: git log -p
  CTRL-R: git checkout -b new-branch-name
  CTRL-O: git checkout ...  # NOTE: this WILL stash first, if dirty
  CTRL-D: git branch -D ...
  ALT-M:  git merge ...

CTRL-G CTRL-T for tags
CTRL-G CTRL-R for remotes

CTRL-G CTRL-H for commit hashes
CTRL-G h        ""

CTRL-G CTRL-L for log
CTRL-G L        ""
  CTRL-D: git diff ...
  CTRL-L: git log  -p ...
  CTRL-N: git show --name-status ...
  CTRL-W: git show -w --word-diff ...
  Enter:  git show ...

CTRL-G CTRL-S for stashes # NOTE: this will offer to "en-stash" when invoked
  CTRL-B: git stash branch <branchname>
  CTRL-O: git stash pop
  CTRL-Y: git stash apply
  CTRL-X: git stash drop

CTRL-G CTRL-/ for fzf-git help
CTRL-G CTRL-D for git diff
CTRL-G CTRL-E for edit modified files
CTRL-G CTRL-G for git status

AVAILABLE:
CTRL-G CTRL-V

CTRL-G CTRL-W
CTRL-G CTRL-S
CTRL-G CTRL-X

CTRL-G CTRL-Q
CTRL-G CTRL-A
CTRL-G CTRL-Z

CTRL-G CTRL-Y
CTRL-G CTRL-N

CTRL-G CTRL-U
CTRL-G CTRL-J
CTRL-G CTRL-M

CTRL-G CTRL-I
CTRL-G CTRL-K

CTRL-G CTRL-O
CTRL-G CTRL-L

CTRL-G CTRL-P
```
