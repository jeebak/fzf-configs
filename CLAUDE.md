# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A shell plugin (`fzf-configs`) that configures [fzf](https://github.com/junegunn/fzf) with git-aware keybindings for both zsh and bash. Distributed as a zsh plugin (compatible with zplug, zgen, zgenom, etc.) or sourced manually.

## Linting

```bash
shellcheck <file>
```

The codebase uses several intentional shellcheck disables:
- `SC2178` — array-to-string assignment pattern used for `FZF_DEFAULT_OPTS` construction
- `SC1090` — dynamic source paths
- Files use `#!/usr/bin/env ksh` shebang (not actually ksh) purely to satisfy shellcheck's zsh syntax parsing

## Architecture

**Entry points:**
- `fzf-configs.plugin.zsh` — zsh loader: sources `ensure.sh`, `settings.sh`, `key-bindings.zsh`, then `lib/git/key-bindings.zsh`
- `fzf-configs.plugin.bash` — bash loader: sources `ensure.sh`, `settings.sh`, `key-bindings.bash`, then `lib/git/key-bindings.bash`

**`lib/` files:**
- `ensure.sh` — installs fzf (via brew or git clone) and gum (via brew; falls back to whiptail if already present) if missing; runs `hash` to refresh PATH cache
- `settings.sh` — sets `FZF_DEFAULT_OPTS`, `FZF_CTRL_T_OPTS`, `FZF_ALT_C_OPTS`, `FZF_TMUX_HEIGHT`; defines `_fzf_compgen_path`/`_fzf_compgen_dir` (fd-based if available); defines `_fzf-configs-completion` (zsh only) for per-command custom completions loaded from `~/.config/fzf-configs/completions/<cmd>.zsh`
- `key-bindings.zsh` — defines `__fzf-configs::src` (ESC-s, ghq-based repo switcher), `__fzf-configs::edit-file` (CTRL-O / ESC-o)
- `key-bindings.bash` — (currently empty, reserved)
- `git/commands.sh` — sources `lib/utils.sh`; defines `fzf-git-base()` helper (adds `--ansi --border --border-label` and `--tmux` when `$TMUX` is set); defines all git functions: `gf` (files/status), `gb` (branches), `gt` (tags), `gh` (hashes/log), `gr` (remotes), `ga` (aliases), `gl` (log browser), `gs` (stashes), `gw` (worktrees), `grl` (reflog), `edit-modified`, `g?` (interactive `git help -a` browser); exports all functions to subshells via `eval "$(declare -F | sed -e 's/-f /-fx /')"`
- `git/key-bindings.zsh` — binds `^G^F/B/T/R/H/L/A/W` via `bind-git-helper` (output inserted on command line) and `^G^S` via `bind-git-helper-no-join` (interactive browser, no output); `^G^V` (reflog) bound via a manually defined widget; also binds `^G^D` (git diff), `^G^G` (git status), `^G^P` (git pull), `^G^[P` (git push), `^G^E` (edit-modified), `^G^_` (fzf-git menu), `^G?` (git commands browser via `g?()`); `^GH`/`^GL` provide alternate bindings for tmux users who map `^{h,l}` to pane navigation; pull/push widgets run `precmd_functions` before `zle reset-prompt` so git-aware prompts refresh; all persistent shell functions use the `__fzf-configs::` namespace prefix (e.g. `__fzf-configs::git-pull-widget`, `__fzf-configs::gf-widget`)
- `git/key-bindings.bash` — mirrors `key-bindings.zsh` using readline `bind` commands; output-producing functions use `"$(fzf-git gX)\e\C-e\er"`, interactive-only functions (gs, edit-modified, pull, git diff/status) use `" \C-ufzf-git gX\n\C-y\C-h"`; pull/push functions print a trailing `echo` so readline redraw doesn't overwrite `gum spin` output

**`libexec/` scripts** (internal helpers, not added to PATH):
- `key-bindings-help` — prints the keybindings from `FZF_DEFAULT_OPTS`; invoked via full path (`$PLUGIN_D/libexec/key-bindings-help`) in `--bind` execute strings
- `copy-abspath` — copies absolute path(s) of selected files to clipboard; bound to `alt-p` in `FZF_CTRL_T_OPTS`
- `copy-file-contents` — copies file contents of selected file to clipboard; bound to `alt-y` in `FZF_CTRL_T_OPTS`
- `git-askpass` — credential helper for `^G^P` git pull; set as `SSH_ASKPASS`/`GIT_ASKPASS` so credential prompts appear as a `gum input --password` dialog before the `gum spin` starts
- `git-status-files` — extracts null-delimited filenames from a git status `{+f}` temp file; used by `gf()` execute bindings
- `preview` — file preview helper: dispatches by mime type (via `file --mime-type -b`); dirs use `lsd`/`tree`; video/audio use `ffprobe`; images use `chafa`; pdf uses `pdftotext`/`mutool`; archives (zip/tar/7z/rar) list contents; sqlite3 shows `.tables`; json uses `jq`; iso uses `isoinfo`; Office (docx/xlsx/pptx) extracts XML via `xmllint`; other text falls back to `bat`/`highlight`/`coderay`/`rougify`/`cat`; invoked via full path (`$PLUGIN_D/libexec/preview`) in `--preview` strings

**`bin/` scripts** (added to PATH by `settings.sh`):
- `fzf-git` — CLI dispatcher that sources `git/commands.sh` and calls subcommands by name (e.g., `fzf-git gf`, `fzf-git gb`, `fzf-git g?`)
- `fzlp` — fuzzy LastPass credential browser using `lpass` CLI + `pbcopy`

**Custom completions** (zsh only): drop a file at `~/.config/fzf-configs/completions/<cmd>.zsh`; it must use `$fzf` variable and set `$matches`. The `$query` variable holds the current token.

**TMUX-aware popup:** `fzf-git-base()` adds `--tmux "WxH"` when `$TMUX` is set, opening all git browsers as tmux popups (inspired by junegunn/fzf-git.sh). Width and height are computed from `#{client_width}`/`#{client_height}` at 90%, capped at 180 cols × 60 rows. The `gf()` ctrl-u/ctrl-e/ctrl-o/ctrl-p bindings are always available regardless of tmux.
