---
name: tmux-nvim
version: 0.1.0
description: drive nvim in a tmux pane remotely - open files, jump to lines, save
metadata:
  opencode/slash: "true"
---

# Interacting with nvim over tmux

## Task

Edit code in the nvim pane without leaving the agent workflow.

## Find the nvim pane

```
tmux list-panes -a -F '#{pane_id} #{@name}'
```

Prefer a pane named "nvim"/"vim" if present.

## Read the editor state

```
tmux capture-pane -p -t %<id>
```

This shows the current viewport (visible file content, cursor line, status
line). Use `-S -N` to include scrollback.

## Send commands to nvim

```
tmux send-keys -t %<id> "<keys>" Enter
```

Useful sequences (entered as vim commands after `:`):

- open a file: `:e path/to/file` + Enter
- jump to a line: `:42` + Enter, or send `42G`
- save: `:w` + Enter
- quit: `:q` + Enter
- search: `/pattern` + Enter
- go to next/previous error: `:cnext` / `:cprev`
- jump to definition: `gd`

## Notes

- The tmux prefix is Ctrl-b; from tmux send-keys use `C-b`. To send a literal
  Ctrl-b to nvim, the config binds `prefix C-b`.
- Escape takes you from insert to normal mode — send `Escape` before command
  sequences if unsure of the current mode.
- For large edits, write the file directly on disk instead of typing into nvim,
  then send `:e!` to reload the buffer.
