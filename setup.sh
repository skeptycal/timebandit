#!/usr/bin/env zsh
# -*- coding: utf-8 -*-
    # shellcheck shell=bash
    # shellcheck source=/dev/null
    # shellcheck disable=2178,2128,2206,2034

#* ###################### Setup

#? ####################### debug
    # SET_DEBUG: set to 1 for verbose testing;
    SET_DEBUG=1

#? ######################## configuration
	[[ ${SHELL##*/} == 'zsh' ]] && set -o shwordsplit
    export YEAR=$(date +%Y)
    t0=$(date +%s.%n)
    _set_basic_colors() {
        export MAIN='\001\033[38;5;229m'
        export WARN='\001\033[38;5;203m'
        export COOL='\001\033[38;5;38m'
        export BLUE='\001\033[38;5;38m'
        export GO='\001\033[38;5;28m'
        export LIME='\001\033[32;1m'
        export CHERRY='\001\033[38;5;124m'
        export CANARY='\001\033[38;5;226m'
        export ATTN='\001\033[38;5;178m'
        export PURPLE='\001\033[38;5;93m'
        export RAIN='\001\033[38;5;93m'
        export WHITE='\001\033[37m'
        export RESTORE='\001\033[0m\002'
        export RESET='\001\033[0m'
    	}
    # ssm - standard script modules or alternate
    . $(which ssm) || _set_basic_colors
    cleanup() {
        # cleanup and exit script
        unset echo

        # calculate and display script time
        t1=$(date +%s.%n)
        dt=$((t1-t0))
        printf '\n%bScript %s took %.3f seconds to load.\n\n' "${GO:-}" "$SCRIPT_NAME" "$dt"
        unset t0 t1 dt
    	}
    trap cleanup EXIT

	NO_BREW=0

    BASH_SOURCE="${0}"
    SCRIPT_NAME="${BASH_SOURCE##*/}"
    SCRIPT_PATH="${BASH_SOURCE%/*}"

    REPO_PATH="$PWD"
    REPO_NAME="${PWD##*/}"
#? ######################## utilities
    # echo () {
    #     if [ -n "$1" ]; then
    #         printf '%s' "$1"
    #         shift
    #     fi
    #     for arg in "$@"; do
    #         printf ' %s' "$arg"
    #     done
    #     printf '%s\n' ''
    # 	}
	dbecho() { (( SET_DEBUG==1 )) && echo "${ATTN:-}$@"; }
    _debug_show_paths() {
        tmp='BASH_SOURCE SCRIPT_NAME SCRIPT_PATH REPO_PATH REPO_NAME TEMPLATE_PATH'
        for i in $tmp; do
            echo "${MAIN:-}${(r:15:)i} ... ${CANARY:-}${(P)i}${RESET:-}"
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
			echo "${ATTN:-}Install brew if it is not installed..."
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
        DEV_OPTS='flake8 tox-travis Sphinx sphinx-autobuild sphinx-rtd-theme'

		poetry add $REQS
		poetry add --dev $DEV_REQS
		poetry add --dev --optional $DEV_OPTS

		poetry update
		poetry build
		poetry install

	}

    main() {
		(( SET_DEBUG==1 )) && _debug_show_paths
		TESTPATH=$(realpath $PWD)
		while (( $# > 0 )); do
			case $1 in
				-h|--help)
					echo "Usage: $0 [-h|--help] [-v|--version] [--nobrew] "
					exit 0
					;;
				-v|--version)
					echo "$SCRIPT_NAME $(version)"
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
    }

main "$@"

# ------------------------ stuff ------------------------
#? ${PATH//:/\\n}    - replace all colons with newlines to display as a list
#? ${PATH// /}       - strip all spaces
#? ${VAR##*/}        - return only final element in path (program name)
#? ${VAR%/*}         - return only path elements in path (without program name)
