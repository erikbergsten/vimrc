---
name: volumes-search
version: 0.1.0
description: find code, configs and logs across projects and dev-volumes directories
metadata:
  opencode/slash: "true"
---

# Searching across projects and volumes

## Task

Locate code or configuration across the working directories and the
[dev-volumes](https://github.com/erikbergsten/dev-volumes) repo.

## Where things live

- Project checkouts: current working directories; inside containers mounted at
  `/work`.
- Container definitions: `dev-volumes/dev/Containerfile`, `entrypoint.sh`,
  `.bashrc`.
- Feature tooling images: `ghcr.io/erikbergsten/dev-volumes/<feature>`
  (node, docker, opencode, kubectl, python) — mounted read-only at
  `/opt/<feature>`.

## Search recipes

Ripgrep for content (respects .gitignore):

```
rg -n 'pattern' .
```

Find by name:

```
fd -H 'name' .
```

Find files under /opt in a container:

```
find /opt -maxdepth 3 -name '*name*'
```

## Watch pattern

The tmux config binds `prefix w` to re-run `watch` in the active pane —
use it to keep a grep or log tail refreshing:

```
watch 'rg -c TODO .'
```
