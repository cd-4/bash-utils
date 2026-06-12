#!/bin/bash

RED_TEXT='\033[1;32m'
PURPLE_TEXT='\033[1;35m'
GREEN_TEXT='\033[1;32m'
YELLOW_TEXT='\033[0;33m'
NO_COLOR_TEXT='\033[0m'

function UTILS_SCRIPTS_select_from() {
    local ITEMS=($@)

    if [[ "${#ITEMS[@]}" == 1 ]]; then
        echo "${ITEMS[0]}"
        return
    fi

    echo -e "${GREEN_TEXT}Select:${NO_COLOR_TEXT}" >&2
    echo -e "${GREEN_TEXT}-----------------------${NO_COLOR_TEXT}" >&2
    local INDEX=0
    for ITEM in "${ITEMS[@]}"; do
        echo -e "${PURPLE_TEXT}${INDEX}${NO_COLOR_TEXT}: ${ITEM}" >&2
        INDEX=$((INDEX + 1))
        if [[ $INDEX -gt 9 ]]; then
            break
        fi
    done
    read -r -n 1 -s INPUT

    if [[ -z "${INPUT}" ]]; then
        return
    fi

    echo "${ITEMS[$INPUT]}"

}

