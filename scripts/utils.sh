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

