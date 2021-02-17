#!/usr/bin/env bash

clear

pid=0
name=""
rows=5
params=""

digits='^[0-9]+$'

function help() {
  echo "Parser of netstat"
  echo
  echo "Usage: $SCRIPT options"
  echo "-p , pid of process"
  echo "-n , name of process"
  echo "-r , num of result rows"
  echo
}

function selector() {
  echo "Please, select operation:"
  echo "1) Set up PID or name of process"
  echo "2) Set up name of process"
  echo "3) Set up max result rows"
  echo "4) Wanna see another connection states? (not available now)"
  echo "0) Run"
  echo -n "Operation: "

  read -r operation

  case $operation in
  "1" | "1)")
    echo -n "Enter PID of process: "
    read -r pid
    if ! [[ "$pid" =~ $digits ]]; then
      echo "Oh no! Incorrect port number!"
    else
      params="$params | grep \":$pid \""
    fi

    selector
    ;;
  "2" | "2)")
    echo -n "Enter name of process: "
    read -r name
    if [ -z "$name" ]; then
      params="$params | awk '/firefox/ {print \$5}'"
    else
      params="$params | awk '/$name/ {print \$5}'"
    fi
    selector
    ;;
  "3" | "3)")
    echo -n "Enter max result rows: "
    read -r rows
    if ! [[ "$rows" =~ $digits ]]; then
      echo "It is not integer value of rows!"
      rows=5
    fi
    selector
    ;;
  "0" | "0)")
    run="sudo netstat -tunapl $params | cut -d: -f1 | sort | uniq -c | sort | tail -n$rows | grep -oP '(\d+\.){3}\d+' | while read IP ; do whois \$IP | awk -F':' '/^Organization/ {print \$2}' ; done"
    eval $run
    ;;
  esac

}

if [ $# = 0 ]; then
  selector
fi
