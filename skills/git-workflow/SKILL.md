---
name: git-workflow
version: 0.1.0
description: preferred git conventions - branches, commits, PRs
metadata:
  opencode/slash: "true"
---

# Git workflow

## Task

Follow these conventions for branches, commits and pull requests.

## Branches

- kebab-case, short: `fix/tmux-reload`, `docs/readme-tmux`, `feat/<thing>`
- branch from `main`

## Commits

- conventional-commit style prefix: `docs:`, `fix:`, `feat:`, `refactor:`, `chore:`
- lowercase, imperative, concise subject; body only when needed

## Pull requests

- keep them small and focused
- link the issue being fixed in the description

## Notes

- These dotfile repos are personal; a quick push to `main` is fine for small
  changes, but use a branch + review for anything that documents behavior
  others might rely on.
