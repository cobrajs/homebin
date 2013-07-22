#!/bin/bash

# Set arg to var so it can be overridden
ARG1="$1"

# Constants
FNT="-*-profont-*-*-*-*-22-*-*-*-*-*-*-*"
HEIGHT=100
OFFSET=10
TEXT_WIDTH=11

# Check to see if Mplayer is running
ACTIVE_WINDOW_ID=$(xprop -root _NET_ACTIVE_WINDOW | cut -d' ' -f5)
ACTIVE_WINDOW_CLASS=$(xprop -id $ACTIVE_WINDOW_ID WM_CLASS)

if (( $(echo $ACTIVE_WINDOW_CLASS | grep "mplayer" -i -c) > 0 )); then
  ARG1="mplayer"
fi

case "$ARG1" in
  cmus)
    CONFIG="PREV:cmus-remote -r\nPAUSE:cmus-remote -u\nNEXT:cmus-remote -n\n"
    ;;
  mplayer)
    CONFIG="PAUSE:xdotool key --window $ACTIVE_WINDOW_ID 'space'\nKeyboard:^exit 27\n"
    ;;
  awesomectrl)
    CONFIG="LEFT:xdotool key 'alt+Left'\nRIGHT:xdotool key 'alt+Right'\nUP:xdotool key 'alt+k'\nDOWN:xdotool key 'alt+j'\n"
    ;;
  *)
    CONFIG="CMUS:^exit 28\nWMCTRL:^exit 29\nXournal:^exit 30\nKeyboard:^exit 27\n"
    ;;
esac 

CONFIG="${CONFIG}Exit:^exit 2"

BUTTON_COUNT=$(echo -e $CONFIG | wc -l)

# Calculations
SCREEN_SIZE=$(xprop -root _NET_DESKTOP_GEOMETRY | cut -d'=' -f2)
SCREEN_WIDTH=$(echo $SCREEN_SIZE | cut -d',' -f1)
SCREEN_HEIGHT=$(echo $SCREEN_SIZE | cut -d',' -f2)
BUTTON_HEIGHT=$(( $HEIGHT - $OFFSET * 2 ))
BUTTON_WIDTH=$(( $SCREEN_WIDTH / $BUTTON_COUNT - $OFFSET ))
HALF_WIDTH=$(( $BUTTON_WIDTH / 2 ))

FINAL=""

I=0

while read BUTTON_LINE; do
#for (( i=0; i<$BUTTON_COUNT; i++));  do
  if (( $I != 0 )); then 
    FINAL="$FINAL^p($OFFSET)"
  fi

  TEXT=$(echo $BUTTON_LINE | cut -d':' -f1)
  ACTION=$(echo $BUTTON_LINE | cut -d':' -f2)

  LEN=$(echo $TEXT | wc -c)
  HALF_TEXT_WIDTH=$(( ( $LEN * $TEXT_WIDTH ) / 2 ))
  TEXT_OFFSET=$(( $HALF_WIDTH + $HALF_TEXT_WIDTH ))
  RESET=$(( $HALF_WIDTH - $HALF_TEXT_WIDTH ))
  FINAL="$FINAL^ca(1,$ACTION)^ro(${BUTTON_WIDTH}x${BUTTON_HEIGHT})^ib(1)^p(-$TEXT_OFFSET)$TEXT^p($RESET)^ca()"
  I=$(( $I + 1 ))
done < <(echo -e $CONFIG)

echo $FINAL |
/home/cobra/dev/git/forked/dzen/dzen2 -fn $FNT -h $HEIGHT -y $(( $SCREEN_HEIGHT - $HEIGHT)) -p 0 -e "button3=exit:2"

case $? in
  27)
    onboard &
    ;;
  28)
    $0 cmus &
    ;;
  29)
    $0 awesomectrl &
    ;;
  30)
    xournal ~/home.xoj &
    ;;
esac

