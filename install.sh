#!/bin/bash

rm ~/.vimrc
ln -sf $PWD/.vimrc ~/.vimrc
rm ~/.vim
ln -sf $PWD/.vim ~/.vim
