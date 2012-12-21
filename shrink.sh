#!/bin/bash

TPWD=$(pwd | sed 's#'${HOME}'#~#')

SHRINK=$(echo $TPWD | sed 's#\(\w\)\w*/#\1/#g')

echo $SHRINK
