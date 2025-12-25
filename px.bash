#!/usr/bin/env bash
##
##  px - Python Environment Execution Utility
##  Copyright (c) 2025 Dr. Ralf S. Engelschall <rse@engelschall.com>
##  Licensed under MIT <https://spdx.org/licenses/MIT>
##

#   use sane environment
#set -o errexit -o pipefail

#   sanity check usage
if [[ $# -lt 2 ]]; then
    echo "px: ERROR: invalid arguments (environment and command expected)" 1>&2
    echo "px: USAGE: px <env> --create" 1>&2
    echo "px: USAGE: px <env> --destroy" 1>&2
    echo "px: USAGE: px <env> --list" 1>&2
    echo "px: USAGE: px <env> --update" 1>&2
    echo "px: USAGE: px <env> <cmd> [...]" 1>&2
    exit 1
fi

#   helper function for raising fatal error and terminate process
fatal () {
    echo "px: ERROR: $*" 1>&2
    exit 1
}

#   determine environment directory
env="$1"; shift
if [[ -z $env ]]; then
    fatal "invalid empty environment"
fi
if [[ ! $env =~ ^[a-zA-Z0-9_-]+$ ]]; then
    fatal "invalid environment name (use only alphanumeric, minus, and underscore)"
fi
envdir="$HOME/.px/$env"

#   helper function for setting up environment
setup_env_vars () {
    source "$envdir/bin/activate"
    local pyver=$(python --version 2>&1 | sed -e 's/Python //' -e 's/\.[0-9]*$//')
    export PYTHONPATH="$envdir/lib/python${pyver}/site-packages${PYTHONPATH+:}${PYTHONPATH}"
    export PIP_PREFIX="$envdir"
    export UV_TOOL_BIN_DIR="$envdir/bin"
    export UV_TOOL_DIR="$envdir/lib/uv"
}

#   dispatch according to command arguments
case "$1" in
    --create )
        #   create environment
        if [[ -d $envdir ]]; then
            fatal "environment \"$env\" already exists"
        fi
        echo "++ creating \"$envdir\""
        mkdir -p "$envdir/bin" "$envdir/lib" || \
            fatal "failed to create environment directory"
        python=`which python 2>/dev/null`
        if [ ".$python" = . ]; then
            echo "ERROR: Python not in PATH" 1>&2
            exit 1
        fi
        python -m venv "$envdir"
        setup_env_vars
        pip install -U pipx
        pip install -U uv
        ;;

    --destroy )
        #   destroy environment
        if [[ ! -d $envdir ]]; then
            fatal "environment \"$env\" does not exist"
        fi
        if [[ ! $envdir =~ /.px/ ]]; then
            fatal "refusing to destroy directory outside .px namespace"
        fi
        echo "++ destroying \"$envdir\""
        rm -rf "$envdir" || \
            fatal "failed to destroy environment directory"
        ;;

    --list )
        #   list PIP/UV packages
        if [[ ! -d $envdir ]]; then
            fatal "environment \"$env\" does not exist"
        fi
        setup_env_vars
        pip list --format=freeze 2>/dev/null | while IFS="==" read -r pkg version; do
            version=$(echo "$version" | sed  -e "s/^=//")
            echo "px: INFO: PIP package $pkg $version"
        done
        pipx list --short 2>/dev/null | while read -r line; do
            pkg=$(echo "$line" | awk '{ print $1 }')
            version=$(echo "$line" | awk '{ print $2 }')
            if [[ -n $pkg && -n $version ]]; then
                echo "px: INFO: PIPX tool $pkg $version"
            fi
        done
        uv tool list --color=never --no-progress 2>/dev/null | grep -v -E "^-" | while read -r line; do
            pkg=$(echo "$line" | awk '{ print $1 }')
            version=$(echo "$line" | awk '{ print $2 }' | sed -e "s/^v//")
            if [[ -n $pkg && -n $version ]]; then
                echo "px: INFO: UV tool $pkg $version"
            fi
        done
        ;;

    --update )
        #   update PIP/UV packages
        if [[ ! -d $envdir ]]; then
            fatal "environment \"$env\" does not exist"
        fi
        setup_env_vars
        pip list --outdated --format=columns | tail -n +3 | while read -r pkg version_old version_new _; do
            echo "px: INFO: package $pkg $version_old -- updating to $version_new"
            pip install --quiet "$pkg==$version_new" || \
                fatal "failed to update PIP package: $pkg==$version_new"
        done
        pipx upgrade-all || \
            fatal "failed to update PIPX tools"
        uv tool upgrade --all || \
            fatal "failed to update UV tools"
        ;;

    * )
        setup_env_vars
        "$@"
        ;;
esac

