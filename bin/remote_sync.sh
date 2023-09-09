#!/bin/bash

COPY=$1
DEST=$2

is_ignored() {
  git check-ignore --non-matching --verbose $1 > /dev/null
}

is_git() {
  echo $1 | grep -Eq \.git.*
}

is_kubedev() {
  echo $1 | grep -Eq \.kubedev.*
}

# INITAL SYNC
find . -not -path '*/.*' |
while read line;
do
  while read line;
  do
    if ! is_ignored $line &&
       ! is_git $line
    then
      echo "moving file: $line"
      $COPY $line $DEST/$line
    fi
  done
done


# KEEP SYNC GOING
inotifywait -rmq . --format "%w%f" --event CLOSE_WRITE |
while read line;
do
  if ! is_ignored $line &&
     ! is_git $line &&
     ! is_kubedev $line
  then
    echo "moving file: $line"
    $COPY $line $DEST/$line
  fi
done

