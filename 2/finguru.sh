#!/usr/bin/env bash

clear
curl -s https://yandex.ru/news/quotes/graph_2000.json > ./quotes.json
DEFAULT_LAST_DAY_COUNT=30

function get_prices_for_last_days() {
  jq -r ".prices[][]" quotes.json | awk "NR % 2 == 0" | tail -n"$1"
}

function get_prices_for_period() {
  START_ROW=$(($1 * 2 + 1))
  # NR % 2' | awk '{ print last,$0; last=$0 }'
  NEEDED_ROWS=$(jq -r ".prices[][]" quotes.json | awk -v start_row=$START_ROW 'NR>=start_row' |
  awk 'NR % 2 {print substr($1, 1, length($1)-3)}' |
  awk '{("date +%m:%Y -d @"$1)|getline $1}1' | awk -F: -v current="02" '$1 == current {print $2 "," NR}')
}

function get_mean_price_for_last_days() {
  if [ -z "$1" ]; then
    LAST_DAY_COUNT=$DEFAULT_LAST_DAY_COUNT
  else
    LAST_DAY_COUNT=$1
  fi
  echo "Return mean price for last $LAST_DAY_COUNT business days"
  get_prices_for_last_days "$LAST_DAY_COUNT" | awk -v mean=0 "{mean+=\$1} END {print mean/$LAST_DAY_COUNT}"
}

function get_least_volatile() {
  ANALYZE_MONTH="01"
  select year in 2014 2015 2016 2017 2018 2019 2020 2021; do
    select month in "January" "February" "March" "April" "May" "June" "July" \
      "August" "September" "October" "November" "December"; do
      case $month in
      "January") ANALYZE_MONTH="01" ;;
      "February") ANALYZE_MONTH="02" ;;
      "March") ANALYZE_MONTH="03" ;;
      "April") ANALYZE_MONTH="04" ;;
      "May") ANALYZE_MONTH="05" ;;
      "June") ANALYZE_MONTH="06" ;;
      "July") ANALYZE_MONTH="07" ;;
      "August") ANALYZE_MONTH="08" ;;
      "September") ANALYZE_MONTH="09" ;;
      "October") ANALYZE_MONTH="10" ;;
      "November") ANALYZE_MONTH="11" ;;
      "December") ANALYZE_MONTH="12" ;;
      esac
      break
    done
    break
  done
  echo "Analyze since $year, for $month"
  SINCE_DATE=$(date -d "$year-01-01" +"%s")
  jq -r ".prices[][]" quotes.json | awk '{ print last,$0; last=substr($1, 1, length($1)-3) }' | awk 'NR % 2 == 0'
  LAST_DAYS=$(jq -r ".prices[][]" quotes.json | awk 'NR % 2 {print substr($1, 1, length($1)-3)}' | awk -v since_date="$SINCE_DATE" '$1 > since_date' | wc -l)
  START_ROW_NUM=$((ALL_DAYS_COUNT - LAST_DAYS))
  get_prices_for_period "$START_ROW_NUM" "$ANALYZE_MONTH" "$year"
}

function selector() {
  echo "Please, select operation:"
  echo "1) Return mean price for last X business days"
  echo "2) Return least volatile since some year for current name of month (will available soon)"
  read -rp "Operation: " operation

  case $operation in
  "1" | "1)")
    read -rp "Return mean price for last days (default: $DEFAULT_LAST_DAY_COUNT): " last_days
    get_mean_price_for_last_days "${last_days}"
    ;;
  "2" | "2)")
    get_least_volatile
    ;;
  esac
}

selector