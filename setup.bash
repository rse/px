#!/usr/bin/env bash
##
##  px - Python Environment Execution Utility
##  Copyright (c) 2025 Dr. Ralf S. Engelschall <rse@engelschall.com>
##  Licensed under MIT <https://spdx.org/licenses/MIT>
##

#   sanity check usage
if [[ $1 != "install" && $1 != "uninstall" ]]; then
    echo "USAGE: setup install|uninstall [<prefix>]" 1>&2
    exit 1
fi

#   determine installation prefix
prefix="${2-$HOME}"

#   determine base directory
basedir=""
case "$0" in
    /* )
        #   absolute path
        basedir=$(dirname "$0")
        ;;
    */* )
        #   relative path
        basedir=$(dirname "$0")
        basedir=$(cd "$basedir" && pwd)
        ;;
    * )
        if [[ -f "./$0" ]]; then
            #   special case of local usage
            basedir=$(pwd)
        else
            #   no path
            OIFS="$IFS"; IFS=":"
            for p in $PATH; do
                IFS="$OIFS"
                if [[ -f "$p/$0" ]]; then
                    basedir="$p"
                    break
                fi
            done
            IFS="$OIFS"
        fi
        ;;
esac

#   helper function for running a shell command
run () {
    echo "\$ $@"
    eval "$@"
}

#   dispatch according to command
case $1 in
    #   install all files (production)
    install )
        run "mkdir -p $prefix/bin"
        run "cp $basedir/px.bash $prefix/bin/px"
        run "chmod 755 $prefix/bin/px"
        ;;

    #   uninstall all files (production)
    uninstall )
        run "rm -f $prefix/bin/px"
        ;;
esac

