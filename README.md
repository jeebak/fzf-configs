# WIP

# fzf-configs

## fzf-git
- https://junegunn.kr/2016/07/fzf-git/
  - https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236
- https://github.com/zulu-zsh/plugin-fzf-git
- https://github.com/junegunn/fzf/wiki/Examples
- https://github.com/wfxr/forgit

Automatically [installs fzf](https://github.com/junegunn/fzf#installation) if
`brew` (or `git`) is available.

```
FZF_PREVIEW_BIND="alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up"
# Use: --bind="$FZF_PREVIEW_BIND" everywhere there's --preview

CTRL-G CTRL-F for files
CTRL-G CTRL-B for branches
CTRL-G CTRL-T for tags
CTRL-G CTRL-R for remotes
CTRL-G CTRL-H for commit hashes

CTRL-G h      for commit hashes
CTRL-G CTRL-S for stashes

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
