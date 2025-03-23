#!/bin/bash

set -e
set -o pipefail
set -u
set -x



# TODO: find a more canonical way to determine if we're in a dev container
JAR=sunrisesunsetlib.jar
if [[ -d /home/vscode ]] ; then
    # TODO: use $SCRIPT_DIR
    ROOT=/workspaces/capture-syc
else
    ROOT=/app
    OUTPUT=/output
fi

if [[ -z ${OUTPUT:-} ]] ; then
    OUTPUT=$ROOT/output
fi
mkdir --parents $OUTPUT

LIB=$ROOT/$JAR

# TODO: use SCRIPT_DIR
java -cp $LIB:. Main || exit 0
pushd $OUTPUT
    python3 $ROOT/syc.py
popd
