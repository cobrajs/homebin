#!/bin/bash

FILES="bashrc vimperatorrc vimrc Xdefaults Xmodmap"

echo "This will backup some of your dotfiles to ~/bin/dotfiles/originals, and replace them with symbolic links to their ~/bin/dotfiles counterparts"
echo "The following files will be moved: "
echo $FILES
echo "Type yes to continue"

read -p "> " ANSWER

if [ $ANSWER = "yes" ]; then
  if [ ! -e ~/bin/dotfiles/originals ]; then
    mkdir ~/bin/dotfiles/originals
  fi
  for file in $FILES; do
    echo "Moving: $file"
    mv ~/.$file ~/bin/dotfiles/originals/$file
    ln -s $HOME/bin/dotfiles/$file $HOME/.$file
  done
fi


