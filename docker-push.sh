#!/bin/bash

# TODO: autoincrement the pushed image version
docker image tag capture-syc nas:5000/capture-syc
docker push nas:5000/capture-syc

