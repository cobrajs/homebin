#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: $0 <nametest> <command>"
  exit 1
fi

TEST="nor"
if [ $# -eq 3 ]; then
  if [ "$1" == "-r" ]; then
    TEST="reg"
  fi
  COMMAND=$3
else
  COMMAND="$2"
fi

while true; do
  change=$(inotifywait -q -r -e close_write,moved_to,create .)
  change=${change#./ * }
  if ( [[ $TEST == "nor" ]] && [[ "$change" == $1 ]] ) || ( [[ $TEST == "reg" ]] && [[ "$change" =~ $2 ]] ); then
    eval "$COMMAND"
    sleep 2s
  fi
done
