---
name: dev-test-loop
version: 0.1.0
description: run tests in a dev container pane, capture failures and re-run until green
metadata:
  opencode/slash: "true"
---

# Test-driven loop

## Task

Iterate on code in nvim while running tests inside the dev container.

## Loop

1. Find the container/test pane:

   ```
   tmux list-panes -a -F '#{pane_id} #{@name}'
   ```

   (Panes are named with `prefix T` — see the pane-layout skill.)

2. Send the test command to the pane:

   ```
   tmux send-keys -t %<id> "<test command>" Enter
   ```

   Use the project's test command inside the container (the project is at
   `/work`).

3. Wait for the run to finish, then read the output:

   ```
   tmux capture-pane -p -t %<id> -S -200
   ```

4. Parse failures: pick the failing test name and file:line from the output.
   Framework patterns to look for:
   - pytest: `FAILED path/to/test.py::test_name`
   - go test: `--- FAIL: TestName` plus `file.go:12`
   - node/jest: `● Test name > case` plus `path:line:col`

5. Fix the code (edit in nvim via the tmux-nvim skill, or directly on disk).

6. Re-run only the failing tests when the framework supports it, then the
   full suite once green.

## Notes

- Never run long-running tests in the nvim pane; use the dedicated test pane.
- If the suite is running under a `watch`-style tool, the tmux config binds
  `prefix w` to re-trigger `watch` in the pane — from the shell use
  `tmux send-keys -t %<id> C-a watch Space Enter`.
