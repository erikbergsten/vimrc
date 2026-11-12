export PS1="[\[\033[0;32m\]\$(date +%H:%M:%S)\[\033[0m\]] \[\033[0;34m\]\u@\h\[\033[0m\] \w\n$ "
export PROMPT_COMMAND="export PROMPT_COMMAND=echo"

alias r='source ~/.bashrc'

# keep a stable agent socket path so persistent tmux sessions keep working
# after the original SSH session (and its agent socket) is gone
# skip if SSH_AUTH_SOCK is already the stable path (e.g. inside tmux),
# otherwise ln would recreate the symlink pointing to itself
if [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent_sock" ]; then
  mkdir -p ~/.ssh
  ln -sfn "$SSH_AUTH_SOCK" "$HOME/.ssh/agent_sock"
  export SSH_AUTH_SOCK="$HOME/.ssh/agent_sock"
fi
