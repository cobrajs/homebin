#!/bin/bash

FILES="bashrc vimperatorrc vimrc Xdefaults Xmodmap"

echo "This will move some of your dotfiles to ~/bin/dotfiles, and replace them with symbolic links to their ~/bin/dotfiles counterparts"
echo "The following files will be moved: "
echo $FILES
echo "Type yes to continue"

read -p "> " ANSWER

if [ $ANSWER = "yes" ]; then
  for butt in $FILES; do
    echo "Moving: $butt"
    mv ~/.$butt ~/bin/dotfiles/$butt
    ln -s $HOME/bin/dotfiles/$butt $HOME/.$butt
  done
fi

