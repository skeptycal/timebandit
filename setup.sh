#!/usr/bin/env zsh
# -*- coding: utf-8 -*-
    # shellcheck shell=bash
    # shellcheck source=/dev/null
    # shellcheck disable=2178,2128,2206,2034

#* ###################### Setup

#? ####################### debug
    # SET_DEBUG: set to 1 for verbose testing;
    SET_DEBUG=1
#? ####################### initialization
	NO_BREW=0

    BASH_SOURCE="${0}"
    SCRIPT_NAME="${BASH_SOURCE##*/}"
    SCRIPT_PATH="${BASH_SOURCE%/*}"

    REPO_PATH="$PWD"
    REPO_NAME="${PWD##*/}"

#? ######################## configuration
	[[ ${SHELL##*/} == 'zsh' ]] && set -o shwordsplit
    export YEAR=$(date +%Y)
    t0=$(date +%s.%n)
    _set_basic_colors() {
        export MAIN=$(printf "%b" '\001\033[38;5;229m')
        export WARN=$(printf "%b" '\001\033[38;5;203m')
        export COOL=$(printf "%b" '\001\033[38;5;38m')
        export BLUE=$(printf "%b" '\001\033[38;5;38m')
        export GO=$(printf "%b" '\001\033[38;5;28m')
        export LIME=$(printf "%b" '\001\033[32;1m')
        export CHERRY=$(printf "%b" '\001\033[38;5;124m')
        export CANARY=$(printf "%b" '\001\033[38;5;226m')
        export ATTN=$(printf "%b" '\001\033[38;5;178m')
        export PURPLE=$(printf "%b" '\001\033[38;5;93m')
        export RAIN=$(printf "%b" '\001\033[38;5;93m')
        export WHITE=$(printf "%b" '\001\033[37m')
        export RESTORE=$(printf "%b" '\001\033[0m\002')
        export RESET=$(printf "%b" '\001\033[0m')
    	}
    # ssm - standard script modules or alternate
    . $(which ssm) || _set_basic_colors
    cleanup() {
        # cleanup and exit script
        unset echo

        # calculate and display script time
        t1=$(date +%s.%n)
        dt=$((t1-t0))
        dbecho '\n%bScript %s took %.3f seconds to load.\n\n' "${GO:-}" "$0" "$dt"
        unset t0 t1 dt
    	}
    trap cleanup EXIT
#? ######################## utilities
    echo () {
        if [ -n "$1" ]; then
            printf '%s' "$1"
            shift
        fi
        for arg in "$@"; do
            printf ' %s' "$arg"
        done
        printf '%s\n' ''
    	}
	dbecho() { (( SET_DEBUG==1 )) && echo "${ATTN:-}$@"; }
    _debug_show_paths() {
        tmp='BASH_SOURCE SCRIPT_NAME SCRIPT_PATH REPO_PATH REPO_NAME TEMPLATE_PATH'
        for i in $tmp; do
            echo -e "${MAIN:-}${(r:15:)i} ... ${CANARY:-}${(P)i}${RESET:-}"
        done;
    	}

	die() {
		echo "${ATTN:-}$@"
		exit 1
		}

	is_empty() {
		[ -z "$(ls -A $1)" ]
		}

    exists() { command -v $1 > /dev/null 2>&1 ; }
	version() { cat pyproject.toml | grep 'version = '; }

#? ######################## setup
    _setup_brew() {
		if (( $SET_DEBUG == 1 )); then
			dbecho 'Install brew if it is not installed...'
		else
        	exists brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

			brew cleanup
			brew doctor
			brew update

			brew install git hub python@3.8 poetry pre-commit
		fi

    } # > /dev/null 2>&1

	_setup_repo() {
        python3 -m venv .venv
		source ./.venv/bin/activate

		pip install -U pip

        REQS='loguru wheel'
        DEV_REQS='pip wheel setuptools pylint pytest tox coverage pytest-cov'
        DEV_OPTS='flake8 black tox-travis Sphinx sphinx-autobuild sphinx-rtd-theme'

		for i in $REQS; do poetry add $i; done;
		for i in $DEV_REQS; do poetry add -dev $i; done;
		for i in $DEV_OPTS; do poetry add -dev $i; done;

		poetry update
		poetry build
		poetry install

	}

    main() {

		TESTPATH=$(realpath $PWD)
		while [ -n $# ]; do
			case $1 in
				-h|--help)
					echo "Usage: $0 [-h|--help] [-v|--version] [--nobrew] [new/repo/path] "
					exit 0
					;;
				-v|--version)
					echo "$0 $(version)"
					exit 0
					;;
				--nobrew)
					NO_BREW=1
					;;
				*)
					echo ""
					;;
			esac
			shift
		done

		(( NO_BREW==1 )) && ( echo 'Skipping HomeBrew install ...'; ) || _setup_brew
        _setup_repo
        _end_timer
    }

main "$@"

# ------------------------ stuff ------------------------
#? ${PATH//:/\\n}    - replace all colons with newlines to display as a list
#? ${PATH// /}       - strip all spaces
#? ${VAR##*/}        - return only final element in path (program name)
#? ${VAR%/*}         - return only path elements in path (without program name)
