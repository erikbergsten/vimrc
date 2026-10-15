---
name: tmux-panel-logs
version: 1.0.0
description: Get the logs from tmux panel in the users workspace
license: MIT
metadata:
    opencode/slash: "true"
---

# Skill Instructions

## Task

Use the following command to list panel names and IDs

```
tmux list-panes -a -F "#D: #T"
```

And then get the logs for that panel using the ID

```
tmux capture-pane -p -t %1
```
