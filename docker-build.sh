#!/bin/bash

REPO_ROOT="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
git -C "$REPO_ROOT" config core.hooksPath .githooks

docker build . --tag capture-syc
