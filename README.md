# fzf-configs

A shell plugin that configures [fzf](https://github.com/junegunn/fzf) with git-aware keybindings and fuzzy utilities for both zsh and bash.

## Dependencies

**Auto-installed:** [`fzf`](https://github.com/junegunn/fzf) (via `brew` or `git clone`), [`whiptail`](https://linux.die.net/man/1/whiptail) (via `brew`)

**Optional — enhanced experience:**
- [`bat`](https://github.com/sharkdp/bat) — syntax-highlighted file previews
- [`lsd`](https://github.com/lsd-rs/lsd) — directory tree previews (falls back to `tree`)
- [`fd`](https://github.com/sharkdp/fd) — faster path/directory completion
- [`ghq`](https://github.com/x-motemen/ghq) — repo switcher (`ESC-s`, zsh only)

**Required by bin scripts:**
- `fzlp` — [`lpass`](https://github.com/lastpass/lastpass-cli)
- `fzbw` — [`bw`](https://bitwarden.com/help/cli/), [`jq`](https://jqlang.github.io/jq/)
- `fz1p` — [`op`](https://developer.1password.com/docs/cli/), [`jq`](https://jqlang.github.io/jq/)
- Clipboard (for `fzlp`, `fzbw`, `fz1p`): OSC52 is used unconditionally (works locally and over SSH); native tools used as additional fallbacks: `pbcopy` (macOS), `wl-copy` (Wayland), `xclip`/`xsel` (X11), `clip.exe` (Cygwin/MSYS), `win32yank`, `termux-clipboard-set`, `lemonade`, `doitclient`

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
zgen load jeebak/fzf-configs
zgen save
```

#### Using [zgenom](https://github.com/jandamm/zgenom)
```shell
zgenom load jeebak/fzf-configs
zgenom save
```

#### Manually
```shell
git clone --depth 1 https://github.com/jeebak/fzf-configs ~/some/path/fzf-configs
echo "source ~/some/path/fzf-configs/fzf-configs.plugin.zsh" >> ~/.zshrc
```

</details>

<details>
  <summary>Bash</summary>

#### Manually
```shell
git clone --depth 1 https://github.com/jeebak/fzf-configs ~/some/path/fzf-configs
echo "source ~/some/path/fzf-configs/fzf-configs.plugin.bash" >> ~/.bashrc
```

</details>

Automatically [installs fzf](https://github.com/junegunn/fzf#installation) if `brew` (or `git`) is available.

## Simple Completion for Custom Commands/Scripts (zsh only)

`lib/settings.sh` registers `_fzf-configs-completion()` as `fzf_default_completion`. To add fuzzy completion for a custom command named `doge`, create:

- `$HOME/.config/fzf-configs/completions/doge.zsh`

The file must use `$fzf` and set `$matches`:

```zsh
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

## Fuzzy Credential Managers

| Script | Backend | Description |
|--------|---------|-------------|
| `fzlp` | [LastPass CLI](https://github.com/lastpass/lastpass-cli) (`lpass`) | Fuzzy LastPass browser |
| `fzbw` | [Bitwarden CLI](https://bitwarden.com/help/cli/) (`bw`) | Fuzzy Bitwarden browser |
| `fz1p` | [1Password CLI](https://developer.1password.com/docs/cli/) (`op`) | Fuzzy 1Password browser |

All three support:

| Key | Action |
|-----|--------|
| `Enter` | View full item |
| `CTRL-P` | Copy password to clipboard |
| `CTRL-O` | Copy username to clipboard |

## Global fzf Keybindings

These are set via `FZF_DEFAULT_OPTS` and apply to every fzf instance.

### Preview

| Key | Action |
|-----|--------|
| `ALT-J` | Scroll preview down |
| `ALT-K` | Scroll preview up |
| `CTRL-F` | Scroll preview page down |
| `CTRL-B` | Scroll preview page up |
| `ALT-V` | Toggle preview pane |
| `ALT-W` | Toggle preview wrap |

### Other

| Key | Action |
|-----|--------|
| `ALT-A` | Toggle select all |
| `CTRL-Z` | Clear screen |

### `CTRL-T` (file picker)

| Key | Action |
|-----|--------|
| `CTRL-C` | Copy filename |
| `CTRL-E` | Open in `$EDITOR` |
| `CTRL-V` | Open in `$PAGER` |
| `ALT-Y`  | Copy file contents to clipboard (single file only; errors on multiple selection or directory) |
| `ALT-P`  | Copy absolute path(s) of all selected items to clipboard |
| `?`      | Show all preview keybindings |

### Key Scope Reference

| Scope | Keys claimed |
|-------|------|
| `FZF_DEFAULT_OPTS` | `alt-j`, `alt-k`, `ctrl-f`, `ctrl-b`, `alt-v`, `alt-w`, `alt-a`, `ctrl-z`, `?` |
| `FZF_CTRL_T/ALT_C_OPTS` | `ctrl-c`, `ctrl-e`, `ctrl-v`, `alt-y`, `alt-p` |
| `gf()` | `ctrl-a/d/h/l/n/r/s/t/w/x/y`, `alt-t`, tmux: `ctrl-e/o/p/u` |
| `gb()` | `ctrl-d/f/n/p/r/s/w/o/x`, `alt-m/o` |
| `gw()` | `ctrl-x` |
| `grl()` | *(none — Enter outputs hash)* |
| `gr()` | `ctrl-f/p/x`, `alt-p` |
| `gs()` | `ctrl-d/o/x/y`, `alt-b`, `enter` |
| `gl()` | `ctrl-d/m/w` |
| `gh()` | `ctrl-s` |

---

## fzf-git Keybindings

Inspired by [junegunn's fzf-git post](https://junegunn.kr/2016/07/fzf-git/) and [gist](https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236). See also: [fzf examples](https://github.com/junegunn/fzf/wiki/Examples), [forgit](https://github.com/wfxr/forgit).

Multi-select with `Tab`/`Shift-Tab` is enabled wherever it makes sense.

### `CTRL-G CTRL-F` — Files (git status)

| Key | Action |
|-----|--------|
| `CTRL-D` | `git diff` |
| `CTRL-W` | `git diff -w --word-diff` |
| `CTRL-H` | `git log -p` |
| `CTRL-A` | `git add` |
| `CTRL-R` | `git checkout --` (revert) |
| `CTRL-S` | `git stash push` |
| `CTRL-X` | `git rm -f` |
| `CTRL-T` | `git commit -m "[WIP] <list of files>"` |
| `CTRL-Y` | `git add` + `git commit --amend --no-edit` |
| `CTRL-U` | `git add` + `git commit --amend` *(tmux only)* |
| `CTRL-E` | `$EDITOR` *(tmux only)* |
| `CTRL-O` | `git add` + `git commit` *(tmux only)* |
| `CTRL-P` | `git add -p` *(tmux only)* |

### `CTRL-G CTRL-B` — Branches

| Key | Action |
|-----|--------|
| `CTRL-S` | `git log -p ..<branch>` |
| `CTRL-D` | `git diff <branch>` |
| `CTRL-F` | `git log -p <branch>..` |
| `CTRL-N` | `git log --name-status` |
| `CTRL-P` | `git log -p` |
| `CTRL-R` | `git branch -m <old> <new>` (renames branch under cursor) |
| `CTRL-W` | `git checkout -b <new> <start>` (new branch from cursor) |
| `CTRL-O` | `git checkout` (stashes first if dirty) |
| `CTRL-X` | `git branch -D` (also removes remote references) |
| `ALT-M`  | `git merge` |
| `ALT-O`  | Open branch in browser (converts remote URL to HTTPS) |

### `CTRL-G CTRL-T` — Tags

### `CTRL-G CTRL-R` — Remotes

| Key | Action |
|-----|--------|
| `CTRL-X` | `git remote remove` |
| `CTRL-F` | `git fetch` |
| `CTRL-P` | `git pull` |
| `ALT-P`  | `git remote prune` |

### `CTRL-G CTRL-H` / `CTRL-G h` — Commit hashes

| Key | Action |
|-----|--------|
| `CTRL-S` | Toggle sort |

### `CTRL-G CTRL-A` — Aliases

### `CTRL-G CTRL-V` — Reflogs

| Key | Action |
|-----|--------|
| `Enter` | Output hash to command line |

### `CTRL-G CTRL-W` — Worktrees

| Key | Action |
|-----|--------|
| `CTRL-X` | `git worktree remove` |

### `CTRL-G CTRL-L` / `CTRL-G L` — Log

| Key | Action |
|-----|--------|
| `CTRL-D` | `git diff` |
| `CTRL-W` | `git show -w --word-diff` |
| `Enter`  | `git show` |

### `CTRL-G CTRL-S` — Stashes

Offers to stash uncommitted changes when invoked.

| Key | Action |
|-----|--------|
| `ALT-B`  | `git stash branch <branchname>` |
| `CTRL-O` | `git stash pop` |
| `CTRL-Y` | `git stash apply` |
| `CTRL-X` | `git stash drop` |

### Other bindings

| Key | Action |
|-----|--------|
| `CTRL-G CTRL-_` | Open fzf-git help |
| `CTRL-G CTRL-D` | `git diff` |
| `CTRL-G CTRL-E` | Edit modified files |
| `CTRL-G CTRL-G` | `git status` |
| `CTRL-G CTRL-P` | `git pull` |
| `CTRL-G CTRL-V` | Reflog browser |
| `CTRL-G CTRL-W` | Worktrees browser |
| `CTRL-G ALT-P`  | `git push` |
