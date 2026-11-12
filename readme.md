# all the configs

Personal configs: tmux, nvim, and bash. For a fresh machine, [cloud-init.yaml](cloud-init.yaml) automates the whole setup.

## installation

Clone this repo and install each config from it:

```sh
git clone https://github.com/erikbergsten/vimrc.git ~/vimrc
cd ~/vimrc

# tmux
mkdir -p ~/.config/tmux
ln -s $PWD/tmux.conf ~/.config/tmux/tmux.conf

# nvim
mkdir -p ~/.config/nvim
ln -s $PWD/init.vim ~/.config/nvim/init.vim

# bash: cat the bashrc into your existing ~/.bashrc (append mode)
cat $PWD/bashrc >> ~/.bashrc
```

The bashrc adds a two-line prompt with timestamp, a blank line between commands, and an `r` alias to reload `~/.bashrc`.

See [tmux.md](tmux.md) for the detailed tmux settings & bindings.

## init.vim

Important features:

- rendering whitespaces (tabs, trailing spaces and newlines)
- color columns
- many nice bindings
