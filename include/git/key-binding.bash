bind '"\er": redraw-current-line'
bind '"\C-g\C-f": "$(fzf-git gf)\e\C-e\er"'
bind '"\C-g\C-b": "$(fzf-git gb)\e\C-e\er"'
bind '"\C-g\C-t": "$(fzf-git gt)\e\C-e\er"'
bind '"\C-g\C-h": "$(fzf-git gh)\e\C-e\er"'
bind '"\C-gh":    "$(fzf-git gh)\e\C-e\er"'
bind '"\C-g\C-r": "$(fzf-git gr)\e\C-e\er"'

bind '"\C-g\C-l": "$(fzf-git gl)\e\C-e\er"'
bind '"\C-gl":    "$(fzf-git gl)\e\C-e\er"'

bind '"\C-g\C-s": "$(fzf-git gs)\e\C-e\er"'
bind '"\C-g\C-_": "\C-ufzf-git\n\C-y"'
bind '"\C-g\C-d": "\C-ugit diff\n\C-y"'
bind '"\C-g\C-e": "\C-ufzf-git edit-modified\n\C-y"'
bind '"\C-g\C-g": "\C-ugit status\n\C-y"'
bind '"\C-g\C-p": "\C-ugit pull\n\C-y"'
# NOTE: no "\n^y" like the others; both to allow to add extra params, and as a
# safguard
bind '"\C-g\ep": "\C-ugit push "'
