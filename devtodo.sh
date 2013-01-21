#!/bin/bash

if [ ! $1 == "" ]; then
  DEVDIR="$1"
else
  DEVDIR="$HOME/dev"
fi

FILETYPES="hx c h cpp py lua pl sh rb js html css"
LEAVEOUTS=".git bin Export build DataTables* node_modules"

FILETYPEFIND=""
for FILETYPE in $FILETYPES; do
  FILETYPEFIND="$FILETYPEFIND -o -iname \"*.$FILETYPE\""
done

FILETYPEFIND=$(echo $FILETYPEFIND | cut -d' ' -f 2-)

LEAVEOUTFIND=""
for LEAVEOUT in $LEAVEOUTS; do
  LEAVEOUTFIND="$LEAVEOUTFIND ! -wholename \"*/$LEAVEOUT/*\""
done

FILES=$(eval find $DEVDIR $LEAVEOUTFIND \\\( $FILETYPEFIND \\\) )

LAST_FILE=''

grep -s "TODO:" $FILES |    \
  sed -e 's/\/\///'         \
      -e 's/--//'           \
      -e 's/#//'            \
      -e 's/<!--//'         \
      -e 's/-->//'          \
      -e 's/TODO://' |  \
      #-e 's/:\s*/\n\t/' |  \
  while read line; do
    CURRENT_FILE=$(echo $line | cut -d':' -f 1)
    REST=$(echo $line | cut -d':' -f 2-)
    if [ ! "$CURRENT_FILE" == "$LAST_FILE" ]; then
      echo -e "\e[1m$CURRENT_FILE\e[0m"
    fi
    echo -e "\t$REST"
    LAST_FILE=$CURRENT_FILE
  done

