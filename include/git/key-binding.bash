bind '"\er": redraw-current-line'
bind '"\C-g\C-f": "$(fzf-git gf)\e\C-e\er"'
bind '"\C-g\C-b": "$(fzf-git gb)\e\C-e\er"'
bind '"\C-g\C-t": "$(fzf-git gt)\e\C-e\er"'
bind '"\C-g\C-h": "$(fzf-git gh)\e\C-e\er"'
bind '"\C-gh":    "$(fzf-git gh)\e\C-e\er"'
bind '"\C-g\C-r": "$(fzf-git gr)\e\C-e\er"'

bind '"\C-g\C-s": "$(fzf-git gs)\e\C-e\er"'
bind '"\C-g\C-_": "fzf-git\n"'
bind '"\C-g\C-d": "git diff\n"'
bind '"\C-g\C-e": "fzf-git edit-modified\n"'
bind '"\C-g\C-g": "git status\n"'
