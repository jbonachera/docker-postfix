#!/bin/bash

pid_file="$1"
shift
cmd="$@"


echo "Running $cmd"
$cmd
status=$?
if [ "$status" -gt 0 ]; then
  echo "$cmd failed. Exiting"
  exit 1
fi

if [ !  -r $pid_file ]; then
  echo "$pid_file is not readable. Exiting."
  exit 1
fi

pid=$(cat $pid_file)
trap "{ kill $pid; exit 0; }" EXIT

kill -0 $pid
status=$?
while [ "$status" -eq 0 ]; do
  sleep 5
  kill -0 $pid
  status=$?
done
