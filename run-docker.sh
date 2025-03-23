#!/bin/bash

set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [[ -z ${OUTPUT:-} ]] ; then
    OUTPUT=$SCRIPT_DIR/output
fi

function get_container_host_path() {
    for CONTAINER in $( docker ps -q ) ; do
        # TODO: test with other docker containers running...  I bet not all containers have .Mounts
        #       (i.e. non-running containers)
        HOST_PATH=$( docker inspect $CONTAINER | jq --raw-output ".[0].HostConfig.Mounts[] | select(.Target | contains(\"/workspaces/capture-syc\")) | .Source" )
        if [[ ! -z $HOST_PATH ]] ; then
            echo $HOST_PATH
        fi
    done
}
if [[ -d /home/vscode ]] ; then
    SCRIPT_DIR=$( get_container_host_path )
fi

mkdir --parent $OUTPUT

docker run --volume $SCRIPT_DIR/output:/output:rw \
           capture-syc
