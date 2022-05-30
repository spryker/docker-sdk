#!/bin/sh

if [ -z "$1" ]
  then
    echo "${RED}No argument supplied, please use 'pre-deploy' or 'post-deploy'"
    exit
fi

keys=$(echo "${SPRYKER_FEATURES}" | jq 'keys')
echo ${keys} | jq -c '.[]' | while read key; do
    command=$(echo "$key" | tr '[:upper:]' '[:lower:]' | tr '"' ' ' | xargs)
    if [ ! -f ${command}/$1.py ]
    then
        echo "'${command}/$1.py' does not exist. Please check the list of enabled features.${NC}"
        exit
    fi
    python3 ${command}/$1.py
done
