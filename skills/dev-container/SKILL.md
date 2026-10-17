---
name: dev-container
version: 0.1.0
description: start, enter and stop the dev containers for a project using dev.sh from the dev-volumes repo
metadata:
  opencode/slash: "true"
---

# Dev container lifecycle

## Task

Run project work inside the dev containers defined in the
[dev-volumes](https://github.com/erikbergsten/dev-volumes) repo (`dev.sh`).

## Starting a container

From the project directory (the project is bind-mounted at `/work`):

```
./dev.sh --feature <feature> [--feature <feature> ...] [--tmux] [passthrough docker args]
```

Supported features: `node`, `docker`, `opencode`, `kubectl`, `python`.

- `docker` bind-mounts the host docker socket into the container.
- `kubectl` bind-mounts `$KUBECONFIG` to `/opt/kubeconfig.yaml` and sets `KUBECONFIG`.
- `--tmux` bind-mounts the host tmux socket (`/tmp/tmux-1000`) so a tmux session
  started inside the container is visible from the host tmux server.
- All remaining arguments are passed through to `docker run`.

Feature tooling is provided as image volumes mounted at `/opt/<feature>`
(from `ghcr.io/erikbergsten/dev-volumes/<feature>:latest`).

## Notes

- The container runs interactively (`-it --rm`), so it should be started in a
  dedicated tmux pane, not in the nvim pane.
- Prefer running the container in a named pane (see pane-layout skill) so its
  output can be inspected with `tmux capture-pane`.
- To just get a shell: no passthrough args are needed, the default entrypoint
  gives a shell in `/work`.
