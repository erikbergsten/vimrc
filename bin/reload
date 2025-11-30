#!/bin/bash
pattern=^.*$1$
program=$2
echo "> program: $program"
echo "> matching: $pattern"
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

start() {
  echo "> $program"
  $program &
  program_id=$!
}

restart() {
  echo "> restarting"
  kill $program_id
  sleep 0.1
  start
}

start

inotifywait -m -r -q -e CLOSE_WRITE . | \
while read dir evt file; do
  fullpath="$dir$file"
  if [[ $fullpath =~ $pattern ]]; then
    restart
  fi
done
