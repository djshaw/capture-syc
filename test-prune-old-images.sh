#!/bin/bash

set -o pipefail
set -u

SCRIPT="$(dirname "$(realpath "$0")")/prune-old-images.sh"

PASS=0
FAIL=0

pass() { echo "PASS: $1"; (( PASS++ )) || true; }
fail() { echo "FAIL: $1"; (( FAIL++ )) || true; }

setup() {
    IMAGE_DIR="$(mktemp --directory)"
}

teardown() {
    rm --recursive --force "$IMAGE_DIR"
}

run_test() {
    local name="$1"
    setup
    "$2"
    local result=$?
    teardown
    if [[ $result -eq 0 ]]; then
        pass "$name"
    else
        fail "$name"
    fi
}

touch_image() {
    local image="$1"
    local date="${2:-now}"
    touch --date="$date" "$IMAGE_DIR/$image"
}

count_images() {
    find "$IMAGE_DIR" -type f -iname '*.jpg' | wc --lines
}

test_keeps_everything_when_7_or_fewer_days_exist() {
    touch_image "img-01.jpg" "2026-01-01"
    touch_image "img-02.jpg" "2026-01-02"
    touch_image "img-03.jpg" "2026-01-03"
    touch_image "img-04.jpg" "2026-01-04"
    touch_image "img-05.jpg" "2026-01-05"
    touch_image "img-06.jpg" "2026-01-06"
    touch_image "img-07.jpg" "2026-01-07"

    bash "$SCRIPT" "$IMAGE_DIR" 7

    [[ "$(count_images)" -eq 7 ]]
}

test_keeps_newest_7_days_even_when_gaps_exist() {
    touch_image "img-01.jpg" "2026-01-01"
    touch_image "img-03.jpg" "2026-01-03"
    touch_image "img-05.jpg" "2026-01-05"
    touch_image "img-06.jpg" "2026-01-06"
    touch_image "img-10.jpg" "2026-01-10"
    touch_image "img-11.jpg" "2026-01-11"
    touch_image "img-15.jpg" "2026-01-15"
    touch_image "img-20.jpg" "2026-01-20"
    touch_image "img-21.jpg" "2026-01-21"

    bash "$SCRIPT" "$IMAGE_DIR" 7

    [[ ! -e "$IMAGE_DIR/img-01.jpg" ]]
    [[ ! -e "$IMAGE_DIR/img-03.jpg" ]]
    [[ -e "$IMAGE_DIR/img-05.jpg" ]]
    [[ -e "$IMAGE_DIR/img-21.jpg" ]]
}

test_retains_images_regardless_of_file_name() {
    touch_image "img-01.jpg" "2026-01-01"
    touch_image "not-a-timestamp.jpg" "2026-01-07"
    touch_image "arbitrary_name.jpg" "2026-01-08"

    bash "$SCRIPT" "$IMAGE_DIR" 2

    [[ ! -e "$IMAGE_DIR/img-01.jpg" ]]
    [[ -e "$IMAGE_DIR/not-a-timestamp.jpg" ]]
    [[ -e "$IMAGE_DIR/arbitrary_name.jpg" ]]
}

test_fails_for_non_numeric_retention() {
    local status=0

    touch_image "img-01.jpg" "2026-01-01"
    bash "$SCRIPT" "$IMAGE_DIR" seven >/dev/null 2>&1 || status=$?

    [[ $status -eq 2 ]]
}

run_test "keeps all images when 7 or fewer distinct days exist" test_keeps_everything_when_7_or_fewer_days_exist
run_test "keeps newest 7 distinct day-groups when days are non-contiguous" test_keeps_newest_7_days_even_when_gaps_exist
run_test "retains images regardless of file name" test_retains_images_regardless_of_file_name
run_test "fails for non numeric retention argument" test_fails_for_non_numeric_retention

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
