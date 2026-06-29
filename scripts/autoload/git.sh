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

    VALID_OPTIONS=($(gh api user/orgs --jq '.[].login' | xargs -P 4 -I {} gh repo list {} --limit 300 --json nameWithOwner --jq '.[].nameWithOwner' | grep "${REPO}"))

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


