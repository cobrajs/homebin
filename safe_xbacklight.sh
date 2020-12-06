#!/bin/bash

function get_level {
  printf "%.0f" $(xbacklight)
}

ADJUST=10
LOWEST=1

if [ "$1" == "up" ]; then
  xbacklight -inc $ADJUST
else
  if [ "$( get_level )" -gt "$ADJUST" ]; then
    xbacklight -dec $ADJUST
  else
    xbacklight -set $LOWEST
  fi
fi


#if [ "$2" == "notify" ]; then
#  notify-send -t 500 "Backlight $( get_level )"
#fi
