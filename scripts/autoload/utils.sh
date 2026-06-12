#!/bin/bash

RED_TEXT='\033[1;32m'
PURPLE_TEXT='\033[1;35m'
GREEN_TEXT='\033[1;32m'
YELLOW_TEXT='\033[0;33m'
NO_COLOR_TEXT='\033[0m'


function UTILS_SCRIPTS_select_from() {
    local ITEMS=("$@")          # Better quoting
    local MAX_ITEMS=36

    # Single item case
    if [[ "${#ITEMS[@]}" -eq 1 ]]; then
        echo "${ITEMS[0]}"
        return 0
    fi

    # Show menu to stderr so it appears even when captured
    echo -e "${GREEN_TEXT}Select:${NO_COLOR_TEXT}" >&2
    echo -e "${GREEN_TEXT}-----------------------${NO_COLOR_TEXT}" >&2

    local INDEX=0
    local KEY
    local KEYS="0123456789abcdefghijklmnopqrstuvwxyz"

    for ITEM in "${ITEMS[@]}"; do
        if [[ $INDEX -ge $MAX_ITEMS ]]; then
            echo -e "${RED_TEXT}... (showing only first 36 items)${NO_COLOR_TEXT}" >&2
            break
        fi

        KEY="${KEYS:$INDEX:1}"
        echo -e "${PURPLE_TEXT}${KEY}${NO_COLOR_TEXT}: ${ITEM}" >&2
        INDEX=$((INDEX + 1))
    done

    # Read user input
    local INPUT
    read -r -n 1 -s INPUT
    echo >&2   # newline for cleanliness

    if [[ -z "${INPUT}" ]]; then
        return 1
    fi

    # Convert input to lowercase (support both A-Z and a-z)
    INPUT="${INPUT,,}"

    # Find the index of the pressed key
    local POS
    POS="${KEYS%%${INPUT}*}"   # everything before the matching char

    if [[ "${#POS}" -eq "${#KEYS}" ]]; then
        # Character not found in our key list
        echo -e "${RED_TEXT}Invalid selection${NO_COLOR_TEXT}" >&2
        return 1
    fi

    local SELECTED_INDEX="${#POS}"

    if [[ $SELECTED_INDEX -lt "${#ITEMS[@]}" ]]; then
        echo "${ITEMS[$SELECTED_INDEX]}"
        return 0
    else
        echo -e "${RED_TEXT}Invalid selection${NO_COLOR_TEXT}" >&2
        return 1
    fi
}

function UTILS_SCRIPTS_goto_dir() {
    local ROOT_DIR=$1
    local FILTER=$2

    local OPTIONS
    OPTIONS=$(find "${ROOT_DIR}" -maxdepth 1 -type d -name "*${FILTER}*" -exec basename {} \;)

    if [[ "${#OPTIONS[@]}" == 0 ]]; then
        echo "No Directories Found"
    fi

    if [[ "${#OPTIONS[@]}" == 1 ]]; then
        cd "${ROOT_DIR}/${OPTIONS[0]}" || return
        return
    fi

    local CHOICE
    CHOICE=$(UTILS_SCRIPTS_select_from "${OPTIONS[@]}")
    cd "${ROOT_DIR}/${CHOICE}" || return
}

