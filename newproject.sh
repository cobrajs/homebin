#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
  echo "Usage: $0 PROJECTTYPE PROJECTNAME"
  echo "PROJECTTYPE should be of: openfl love processing"
  echo "PROJECTNAME should be a name with no spaces"
  exit 1
fi

if [ "$1" != "openfl" ] && [ "$1" != "love" ] && [ "$1" != "processing" ]; then
  echo "Invalid PROJECTTYPE"
  echo "PROJECTTYPE should be one of: openfl love processing"
  exit 1
fi

BOILERDIR="$HOME/dev/boilerplate"
EDITFILE="$2"

cp -rv "$BOILERDIR/$1" $2

case "$1" in
  love)
    EDITFILE="main.lua"
    cd $2
  ;;
  openfl)
    sed -i "s/Default/$2/" $2/project.xml
    #mv $2/default.nmml $2/${2}.nmml
    EDITFILE="src/"
    cd $2
  ;;
  processing)
    EDITFILE="$2/${2}.pde"
    mv "$2/Default.pde" "$EDITFILE"
  ;;
esac

if [ "$3" == "-e" ]; then
  vim $EDITFILE
fi
