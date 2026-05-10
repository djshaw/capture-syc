#!/bin/bash

set -e
set -o pipefail
set -u

IMAGE_DIR="${1:-/home/cerf/djshaw.ca/diving/SYC}"
RETAIN_DAYS="${2:-7}"

if [[ ! -d "$IMAGE_DIR" ]]; then
    exit 0
fi

if ! [[ "$RETAIN_DAYS" =~ ^[0-9]+$ ]] || [[ "$RETAIN_DAYS" -lt 1 ]]; then
    echo "RETAIN_DAYS must be a positive integer" >&2
    exit 2
fi

mapfile -t IMAGE_DAYS < <(
    find "$IMAGE_DIR" -type f -iname "*.jpg" -printf '%TY-%Tm-%Td\n' \
    | sort --reverse --unique
)

if [[ ${#IMAGE_DAYS[@]} -le "$RETAIN_DAYS" ]]; then
    exit 0
fi

for day in "${IMAGE_DAYS[@]:$RETAIN_DAYS}"; do
    prev_second=$(date --date="$day - 1 second" "+%Y-%m-%d %H:%M:%S")
    next_day=$(date --date="$day + 1 day" +%Y-%m-%d)
    find "$IMAGE_DIR" -type f -iname "*.jpg" \
        -newermt "$prev_second" ! -newermt "$next_day" \
        -execdir rm -- '{}' \;
done
