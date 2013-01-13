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

grep -s "TODO:" $FILES | sed -e 's/\/\///' -e 's/--//' -e 's/#//' -e 's/<!--//' -e 's/-->//' -e 's/:\s*/\n\t/'
