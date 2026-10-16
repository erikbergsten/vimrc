---
name: tmux-session-interact
version: 1.0.0
description: interact with panels in the users tmux
metadata:
    opencode/slash: "true"
---

# Skill Instructions

## Task

Use the following command to list panel names and their names

```
tmux list-panes -a -F '#{pane_id} #{@name}'
```

And then get the logs for that panel using the ID instead of <id>

```
tmux capture-pane -p -t %<id>
```

Or execute a command in that pane

```
tmux send-keys -t %<id> "echo hello world" Enter
```
