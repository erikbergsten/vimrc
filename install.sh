#!/bin/bash

rm ~/.vimrc
ln -sf $PWD/.vimrc ~/.vimrc
rm ~/.vim
ln -sf $PWD/.vim ~/.vim

rm ~/.tmux.conf
ln -sf $PWD/.tmux.conf ~/.tmux.conf
