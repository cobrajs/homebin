#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
  echo "Usage: $0 PROJECTTYPE PROJECTNAME"
  echo "PROJECTTYPE should be of: nme love"
  echo "PROJECTNAME should be a name with no spaces"
  exit 1
fi

if [ "$1" != "nme" ] && [ "$1" != "love" ]; then
  echo "Invalid PROJECTTYPE"
  echo "PROJECTTYPE should be one of: nme love"
  exit 1
fi

BOILERDIR="$HOME/dev/boilerplate"

cp -rv "$BOILERDIR/$1" $2

case "$1" in
  love)
  ;;
  nme)
    sed -i "s/Default/$2/" $2/default.nmml
    mv $2/default.nmml $2/${2}.nmml
  ;;
esac