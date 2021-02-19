#!/usr/bin/env bash

clear

pid=0
name=""
rows=5
params=""

digits='^[0-9]+$'

function get_info() {
  netstat -tunapl "${params}" | cut -d: -f1 | sort | uniq -c | sort | tail -n"${rows}" |
    grep -oP '(\d+\.){3}\d+' | while read IP; do
      whois $IP | awk -F':' '/^Organization/ {print $2}'
    done
}

function help() {
  echo "Parser of connections"
  echo
  echo "Usage: $SCRIPT options"
  echo "-p , PID of process"
  echo "-n , name of process"
  echo "-r , num of result rows"
  echo
}

function selector() {
  echo "Please, select operation:"
  echo "1) Set up PID of process"
  echo "2) Set up name of process"
  echo "3) Set up max result rows"
  #  echo "4) Wanna see another connection states? (not available now)"
  echo "0) Run"

  read -p "Operation: " operation
  case $operation in
  "1" | "1)")
    read -rp "Enter PID of process: " pid
    set_pid "$pid"
    selector
    ;;
  "2" | "2)")
    read -rp "Enter name of process: " name
    set_process_name "$name"

    selector
    ;;
  "3" | "3)")
    read -rp "Enter max result rows: " rows_num
    set_result_rows "$rows_num"
    selector
    ;;
  "4" | "4)")
    echo "Coming soon..."
    selector
    ;;
  "0" | "0)")
    get_info
    ;;
  esac

}

function set_pid() {
  if ! [[ "$1" =~ $digits ]]; then
    echo "Oh no! Incorrect PID!"
  else
    params="$params | grep \" $1\/\""
  fi
}

function set_process_name() {
  if [ -z "$1" ]; then
    params="$params | awk '/firefox/ {print \$5}'"
  else
    params="$params | awk '/$1/ {print \$5}'"
  fi
}

function set_result_rows() {
  rows="$1"
}

if [ $# = 0 ]; then
  selector
else
  while [ -n "$1" ]; do
    case "$1" in
    -p)
      set_pid $2
      shift
      ;;
    -n)
      set_process_name $2
      shift
      ;;
    -r)
      set_result_rows $2
      shift
      ;;
    *) echo "$1 is not an option" ;;
    esac
    shift
  done
  get_info
fi
