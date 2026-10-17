---
name: dotfiles-sync
version: 0.1.0
description: these configs are symlinked from the vimrc repo - change them here and reload
metadata:
  opencode/slash: "true"
---

# Dotfiles sync

## Task

Keep in mind that active configs are symlinks into this repo.

## Layout

- `tmux.conf` -> `~/.config/tmux/tmux.conf`
- `init.vim` -> `~/.config/nvim/init.vim`

## Rules

- Never edit the file in `~/.config` directly; edit the repo file (the
  symlink points here anyway, but keep the repo as the source of truth).
- After editing, reload:
  - tmux: `prefix r` (runs `source-file ~/.config/tmux/tmux.conf`) or
    `tmux source-file ~/.config/tmux/tmux.conf`
  - nvim: `:source $MYVIMRC` or restart
- Document new settings/bindings in `readme.md` when pushing to main.
- AI skills live in `skills/<name>/SKILL.md` with the standard frontmatter.
