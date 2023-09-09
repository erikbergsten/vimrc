#!/bin/bash

rm ~/.vimrc
ln -sf $PWD/.vimrc ~/.vimrc
rm ~/.vim
ln -sf $PWD/.vim ~/.vim

rm ~/.tmux.conf
ln -sf $PWD/.tmux.conf ~/.tmux.conf

mkdir -p ~/.config/nvim
ln -sf  ~/.vimrc ~/.config/nvim/init.vim

echo "source $PWD/cool.rc" >> ~/.bashrc
echo "export PATH=\$PATH:$PWD/bin" >> ~/.bashrc

chmod +x bin/kubedev.sh
chmod +x bin/remote_sync.sh
