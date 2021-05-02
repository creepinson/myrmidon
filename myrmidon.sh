#!/bin/bash
cwd=$(echo $(dirname $0))

# Use ~/.myrmidon-tasks.json as default, otherwise use incoming path
config_file="${1:-"$HOME/.myrmidon-tasks.json"}"
tasks=$(cat $config_file)

# Pass tasks to rofi, and get the output as the selected option
selected=$(echo $tasks | boop -s '.map(i => i.name).join("\n")' | rofi -dmenu -matching fuzzy -i -p "Search tasks")
task=$(echo $tasks | boop -s ".filter(i => i.name == '$selected')")

# Exit if no task was found
if [[ $task == "" ]]; then
  echo "No task defined as '$selected' within config file."
  exit 1
fi

task_command=$(echo $task | boop -s "[0].command")
confirm=$(echo $task | boop -s "[0].confirm")

# Check whether we need confirmation to run this task
if [[ $confirm == "true" ]]; then
  # Chain the confirm command before executing the selected command
  confirm_script="$cwd/confirm.sh 'Confirm $selected?'"
  eval "$confirm_script && eval \"$task_command\" > /dev/null &"
else
  eval "\"$task_command\" > /dev/null &"
fi
