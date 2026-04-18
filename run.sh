#!/bin/bash

set -e
set -o pipefail
set -u
set -x

# TODO: find a more canonical way to determine if we're in a dev container
if [[ -d /home/vscode ]]; then
    ROOT=/workspaces/capture-syc
else
    ROOT=/app
    OUTPUT=${OUTPUT:-/output}
fi

if [[ -z ${OUTPUT:-} ]]; then
    OUTPUT=$ROOT/output
fi
mkdir --parents "$OUTPUT"

# Get today's sunrise and sunset for Sarnia, ON
RESPONSE=$(curl --silent --fail "https://api.open-meteo.com/v1/forecast?latitude=42.9745&longitude=-82.4066&daily=sunrise,sunset&timezone=auto")
SUNRISE=$(echo "$RESPONSE" | jq --raw-output '.daily.sunrise[0]')
SUNSET=$(echo  "$RESPONSE" | jq --raw-output '.daily.sunset[0]')

# Expand window by 1 hour on each side (matching original behaviour)
SUNRISE_EPOCH=$(date -d "$SUNRISE - 1 hour" +%s)
SUNSET_EPOCH=$(date  -d "$SUNSET + 1 hour"  +%s)
NOW_EPOCH=$(date +%s)

# Outside daylight window — exit cleanly without capturing
if [[ $NOW_EPOCH -lt $SUNRISE_EPOCH ]] || [[ $NOW_EPOCH -gt $SUNSET_EPOCH ]]; then
    exit 0
fi

# Download webcam snapshot named by current hour
FILENAME="$OUTPUT/$(date +"%Y-%m-%d-%H").jpg"
curl --silent \
     --fail \
     --output "$FILENAME" \
     "http://sarniayachtclub.ca/webcam/FI9900P_C4D6554097B7/snap/webcam_1.jpg" \
