#!/bin/bash

function GIT_SCRIPTS_repository_dir() {
    echo "${REPO_DIRECTORY:-${HOME}/repos}"
}

function GIT_SCRIPTS_repo_completion() {
    RESPONSE_STRS="$(ls $(GIT_SCRIPTS_repository_dir))"
    if [[ ${#COMP_WORDS[@]} == "1" ]]; then
        RESPONSE_STRS=""
    fi
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "${RESPONSE_STRS}" -- ${cur}) )
}

function GIT_SCRIPTS_show_orgs() {
    local ORGS
    ORGS=$(gh org list | awk '{print $1}')
    if [[ -n ${OMIT_ORGS} ]]; then
        for ORG in $ORGS; do
            if ! [[ $OMIT_ORGS = *${ORG}* ]]; then
                echo "${ORG}"
            fi
        done
    else
        echo "${ORGS}"
    fi
}

function GIT_SCRIPTS_show_github_username() {
    gh api user -q ".login"
}

function GIT_SCRIPTS_repo_exists() {
    local ORG=$1
    local REPO=$2


    REPO_URL="git@github.com:${ORG}/${REPO}.git"

    if git ls-remote --exit-code --heads "$REPO_URL" >/dev/null 2>&1; then
        echo 1
    else
        echo 0
    fi
}

function GIT_SCRIPTS_clone_repo() {
    local REPO=$1
    local DESIRED_DIR=$2

    REPOSITORY_DIR=$(GIT_SCRIPTS_repository_dir)

    ORGS=$(GIT_SCRIPTS_show_orgs)

    local VALID_OPTIONS=()

    echo -n -e "${YELLOW_TEXT}> Searching Orgs "
    for ORG in $ORGS $(GIT_SCRIPTS_show_github_username); do
        local REPO_EXISTS
        if [[ $(GIT_SCRIPTS_repo_exists $ORG $REPO) -eq 1 ]]; then
            VALID_OPTIONS+=("${ORG}/${REPO}")
        fi
        echo -n "."
    done

    echo -e "${NO_COLOR_TEXT}"

    SELECTED_REPOSITORY=$(UTILS_SCRIPTS_select_from "${VALID_OPTIONS[@]}")

    local DESTINATION
    if [[ -z ${DESIRED_DIR} ]]; then
        DESTINATION="${REPOSITORY_DIR}/${REPO}"
    else
        DESTINATION="${REPOSITORY_DIR}/${DESIRED_DIR}"
    fi

    git clone "git@github.com:${SELECTED_REPOSITORY}.git" "${DESTINATION}"
    cd "${DESTINATION}"
}


function GIT_SCRIPTS_goto_root() {
    TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        return
    fi
    cd $TOPLEVEL
}

function GIT_SCRIPTS_goto_workflows() {
    TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        return
    fi
    WORKFLOW_DIR="${TOPLEVEL}/.github/workflows"
    if [[ -d $WORKFLOW_DIR ]]; then
        cd "${WORKFLOW_DIR}"
    fi
}

function GIT_SCRIPTS_goto_actions() {
    TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        return
    fi
    ACTIONS_DIR="${TOPLEVEL}/.github/actions"
    if [[ -d $ACTIONS_DIR ]]; then
        cd "${ACTIONS_DIR}"
    fi
}



# ---------------------------

function GIT_SCRIPTS_goto_repo() {
    FILTER=$1
    REPO_DIR="/home/$USER/repos/"
    RED='\033[1;31m'
    PURPLE='\033[0;35m'
    GREEN='\033[1;32m'
    NC='\033[0m'

    if [[ $FILTER == "" ]]; then
        echo -e "${RED}[ERROR]${NC} Must Provide Filter"
        return
    fi

    ITEMS=($(ls $REPO_DIR | grep $FILTER))
    if [[ "${#ITEMS[@]}" == 1 ]]; then
        cd "${REPO_DIR}${ITEMS[0]}"
        return
    fi

    INDEX=0
    echo -e "${GREEN}Select Number for repo${NC}"
    echo -e "${GREEN}----------------------${NC}"
    for ITEM in "${ITEMS[@]}"; do
        echo -e "${PURPLE}${INDEX}${NC}: $ITEM"
        INDEX=$((INDEX+1))
        if [[ $INDEX -gt 9 ]]; then
            break
        fi
    done

    read -n 1 -s INPUT
    ITEM=${ITEMS[$INPUT]}
    cd "${REPO_DIR}/${ITEM}"

}

