---
name: pane-layout
version: 0.1.0
description: canonical tmux pane layout per project so commands go to the right pane
metadata:
  opencode/slash: "true"
---

# Session & pane layout

## Task

Route commands to the correct pane by using pane names.

## Naming panes

Rename a pane from inside tmux with `prefix T` (prompt) — this sets
`@name`. Pane titles render in the top border as `[#P: name]`.

List all panes with their names:

```
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_id} #{@name}'
```

## Canonical layout (suggestion, adjust to taste)

- `nvim`: the editor pane (left, main pane, 80 cols)
- `dev`: dev container shell (started with `./dev.sh ...`)
- `test`: test runner / watch pane
- `logs`: tail of application or container logs

## Splitting

- `prefix v`: vertical split (stacked)
- `prefix t`: horizontal split (side by side)
- `prefix A` / `prefix Ctrl-a`: main-vertical layouts (the latter sized for
  two 80-col columns)

## Selecting / resizing

- `prefix h/j/k/l` or `Alt-h/j/k/l`: select pane
- `prefix H/J/K/L`: resize by 10; `prefix Ctrl-h/j/k/l`: resize by 1

## Notes

- When creating a new pane for a container, name it immediately with
  `tmux set-option -p -t %<id> @name '<name>'`.
- If a pane has no `@name`, infer its role from the current command:
  `tmux list-panes -a -F '#{pane_id} #{pane_current_command} #{@name}'`
