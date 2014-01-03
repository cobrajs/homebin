#!/bin/bash

session_name=
session_pre=
if [[ "$1" ]]; then
  session_name="-t $1"
  session_pre="$1"
fi

session_path=$(tmux list-panes -t $session_pre:1 -F "#{pane_start_path}")

echo "project_name:" $(tmux display-message $session_name -p -F "#{session_name}")
echo "project_root: $session_path" 
echo "windows:"

function get_command() {
  processes=$(ps h -o cmd -s $1 | grep -v "\-bash" | head -n1)
  if [[ $(expr "$processes" : ".*$0") -gt 0 ]]; then
    echo -n ""
  else
    echo -n $processes
  fi
}

while read window; do
  window_id=$(echo $window | cut -d: -f1)
  window_name=$(echo $window | cut -d: -f2)
  window_panes=$(echo $window | cut -d: -f3)
  window_layout=$(echo $window | cut -d: -f4)
  
  if [[ $window_panes -gt 1 ]]; then
    echo "  - $window_name:"
    echo "      layout: $window_layout"
    echo "      panes: "
  else
    echo -n "  - $window_name: "
  fi

  while read pane; do
    pane_pid=$(echo $pane | cut -d: -f1)
    pane_current_path=$(echo $pane | cut -d: -f2)

    if [[ $window_panes -gt 1 ]]; then
      echo -n "        - "
    fi

    if [[ "$pane_current_path" != "$session_path" ]]; then
      echo -n "cd $pane_current_path "
    fi

    comm=$(get_command $pane_pid)

    if [[ "$comm" = "" ]]; then
      echo
    else
      if [[ "$pane_current_path" != "$session_path" ]]; then
        echo -n "&& "
      fi
      echo "$comm"
    fi

    #echo $pane
  done < <(tmux list-panes -t $session_pre:$window_id -F "#{pane_pid}:#{pane_current_path}")
done < <(tmux list-windows $session_name -F "#{window_id}:#{window_name}:#{window_panes}:#{window_layout}")

