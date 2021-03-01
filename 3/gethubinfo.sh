#!/usr/bin/env bash

clear

function get_open_pr_info() {
  PAGE=1
  OPEN_PR_NUM=0
  OPEN_PR_NUM_PAGE=1
  PR_REQUESTS=()
  while [[ $OPEN_PR_NUM_PAGE -gt 0 ]]; do
    PR_REQUESTS_PAGE=$(curl -sb -H "Accept: application/json" "$1/pulls?page=$PAGE")
    OPEN_PR_NUM_PAGE=$(echo "$PR_REQUESTS_PAGE" | jq '. | length')
    PR_REQUESTS+=$PR_REQUESTS_PAGE
    ((PAGE++))
    ((OPEN_PR_NUM+=$OPEN_PR_NUM_PAGE))
  done
  if [ "$OPEN_PR_NUM" -eq "0" ]; then
    echo "There is no open pull requests"
  else
    if [ "$OPEN_PR_NUM" -eq "1" ]; then
      echo "There is 1 open pull request"
    else
      echo "There are $OPEN_PR_NUM open pull requests"
    fi
  fi
  echo "Is anybody productive contributors here?"
  echo "$PR_REQUESTS" | jq -r '.[].user.login' | uniq -c | sort -r | awk '$1 > 1 {print $2" has "$1" open PR"}'

  echo "Author and name of PRs"
  echo "$PR_REQUESTS" | jq -r '.[] | { "user":  .user.login , "label": .title, "number": .number}'
}

BASE_API_URL=$(echo $1 | awk -F/ '{api_url="https://api.github.com/repos/"$4"/"$5; print api_url}')

get_open_pr_info $BASE_API_URL
