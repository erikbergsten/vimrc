---
name: container-debugging
version: 0.1.0
description: debugging playbook for the dev containers - shells, logs, common failures
metadata:
  opencode/slash: "true"
---

# Container debugging playbook

## Task

Diagnose problems with the dev containers started via `dev.sh`.

## Get a shell in a running container

```
docker exec -it <container> bash
```

Find running containers: `docker ps`. Note that `dev.sh` runs with
`--rm` and no name, so identify by image `dev:latest`.

## Common failure modes

- **Missing feature**: `dev.sh` exits with `Unsupported feature` — supported
  features are node, docker, opencode, kubectl, python.
- **Docker socket permission**: the docker feature bind-mounts
  `/var/run/docker.sock` and adds the socket's group; if this fails check the
  socket exists and your user's docker group membership.
- **kubectl config**: requires `$KUBECONFIG` set on the host; it is mounted
  to `/opt/kubeconfig.yaml` inside.
- **tmux socket not shared**: without `--tmux` the container cannot see the
  host tmux server (`/tmp/tmux-1000` is not mounted).
- **Tool not on PATH**: features are image volumes mounted at `/opt/<feature>`;
  check `ls /opt/<feature>/bin` and the PATH wiring in `dev/.bashrc`.

## Logs

- Container stdout is visible in the tmux pane it was started in
  (`tmux capture-pane -p -t %<id>`).
- Docker daemon logs: `docker ps` for status; `docker logs <container>` for
  daemon-managed processes.

## Rebuild

The images build from the `dev-volumes` repo (`dev/Containerfile` and the
feature volumes). Re-tag `dev:latest` if the Containerfile changed.
