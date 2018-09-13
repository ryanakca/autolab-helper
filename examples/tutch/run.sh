#!/bin/sh

abort () {
    if [ "x$1" != "x" ]; then
	echo "$1"
    fi
    printf "\n\n{\"scores\": {}}"
    exit 0
}

tar -mxf autograde.tar || \
    abort "Failed to extract autograder."

[ -d handin ] || mkdir handin

[ -f handin.tar ] || \
    abort "Submission is expected to be at handin.tar. This file does not exist!"

tar -xf handin.tar -C handin || \
    abort "Failed to extract submission."

ml-build sources.cm Main.main grader || \
    abort "Failed to compile autograder. Please contact course staff."

sml @SMLload grader.* || \
    abort "SML autograder exited with error. Please contact course staff."
