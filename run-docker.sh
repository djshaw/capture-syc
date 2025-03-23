#!/bin/bash

set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [[ -z ${OUTPUT:-} ]] ; then
    OUTPUT=$SCRIPT_DIR/output
fi

mkdir --parent $OUTPUT

docker run --volume $SCRIPT_DIR/output:/output:rw \
           capture-syc
