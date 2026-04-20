#!/bin/bash

set -o pipefail
set -u

SCRIPT="$(dirname "$(realpath "$0")")/run.sh"

PASS=0
FAIL=0

pass() { echo "PASS: $1"; (( PASS++ )) || true; }
fail() { echo "FAIL: $1"; (( FAIL++ )) || true; }

setup() {
    MOCK_DIR="$(mktemp --directory)"
    OUTPUT_DIR="$(mktemp --directory)"
    export OUTPUT="$OUTPUT_DIR"

    local mock_sunrise="2026-04-18T06:30"
    local mock_sunset="2026-04-18T20:15"
    export MOCK_SUNRISE="$mock_sunrise"
    export MOCK_SUNSET="$mock_sunset"

    local sunrise_win_start
    local sunset_win_end
    sunrise_win_start=$(/bin/date --date="$mock_sunrise - 1 hour" +%s)
    sunset_win_end=$(/bin/date  --date="$mock_sunset  + 1 hour"  +%s)

    export DAYTIME_EPOCH=$(( (sunrise_win_start + sunset_win_end) / 2 ))
    export BEFORE_WIN_EPOCH=$(( sunrise_win_start - 3600 ))
    export AFTER_WIN_EPOCH=$(( sunset_win_end + 3600 ))

    local mock_response_file="$MOCK_DIR/api_response.json"
    cat >"$mock_response_file" <<EOF
{"daily":{"time":["2026-04-18"],"sunrise":["$mock_sunrise"],"sunset":["$mock_sunset"]}}
EOF
    export MOCK_RESPONSE_FILE="$mock_response_file"

    # Mock curl:
    #   - open-meteo requests → return canned API response
    #   - image download      → touch the --output file
    #   - exit code controlled by MOCK_CURL_EXIT_CODE (default 0)
    cat >"$MOCK_DIR/curl" <<'MOCK_EOF'
#!/bin/bash
if [[ "$*" == *"open-meteo"* ]]; then
    cat "$MOCK_RESPONSE_FILE"
elif [[ "$*" == *"--output"* ]]; then
    prev=""
    for arg in "$@"; do
        if [[ "$prev" == "--output" ]]; then
            touch "$arg"
            break
        fi
        prev="$arg"
    done
fi
exit "${MOCK_CURL_EXIT_CODE:-0}"
MOCK_EOF
    chmod +x "$MOCK_DIR/curl"

    # Mock date:
    #   - bare `date +%s` → return MOCK_NOW_EPOCH
    #   - everything else  → delegate to real date
    cat >"$MOCK_DIR/date" <<'MOCK_EOF'
#!/bin/bash
if [[ $# -eq 1 && "$1" == "+%s" ]]; then
    echo "$MOCK_NOW_EPOCH"
else
    exec /bin/date "$@"
fi
MOCK_EOF
    chmod +x "$MOCK_DIR/date"

    export MOCK_DIR
    export PATH="$MOCK_DIR:$PATH"
}

teardown() {
    rm --recursive --force "$MOCK_DIR" "$OUTPUT_DIR"
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

test_creates_output_directory() {
    local new_output="$OUTPUT_DIR/subdir/that/does/not/exist"
    export OUTPUT="$new_output"
    export MOCK_NOW_EPOCH="$DAYTIME_EPOCH"
    bash "$SCRIPT" >/dev/null 2>&1
    [[ -d "$new_output" ]]
}

test_no_download_before_window() {
    export MOCK_NOW_EPOCH="$BEFORE_WIN_EPOCH"
    bash "$SCRIPT" >/dev/null 2>&1
    local status=$?
    local count
    count=$(find "$OUTPUT_DIR" -name '*.jpg' | wc --lines)
    [[ $status -eq 0 ]] && [[ $count -eq 0 ]]
}

test_no_download_after_window() {
    export MOCK_NOW_EPOCH="$AFTER_WIN_EPOCH"
    bash "$SCRIPT" >/dev/null 2>&1
    local status=$?
    local count
    count=$(find "$OUTPUT_DIR" -name '*.jpg' | wc --lines)
    [[ $status -eq 0 ]] && [[ $count -eq 0 ]]
}

test_downloads_one_image_during_window() {
    export MOCK_NOW_EPOCH="$DAYTIME_EPOCH"
    bash "$SCRIPT" >/dev/null 2>&1
    local count
    count=$(find "$OUTPUT_DIR" -name '*.jpg' | wc --lines)
    [[ $count -eq 1 ]]
}

test_image_filename_format() {
    export MOCK_NOW_EPOCH="$DAYTIME_EPOCH"
    bash "$SCRIPT" >/dev/null 2>&1
    local file
    file=$(find "$OUTPUT_DIR" -name '*.jpg' | head --lines=1)
    [[ "$(basename "$file")" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}\.jpg$ ]]
}

test_fails_when_api_unavailable() {
    export MOCK_NOW_EPOCH="$DAYTIME_EPOCH"
    export MOCK_CURL_EXIT_CODE=1
    bash "$SCRIPT" >/dev/null 2>&1
    local status=$?
    [[ $status -ne 0 ]]
}

run_test "creates output directory when it does not exist" test_creates_output_directory
run_test "exits 0 and downloads no image before the daylight window"  test_no_download_before_window
run_test "exits 0 and downloads no image after the daylight window"   test_no_download_after_window
run_test "downloads exactly one image during the daylight window"      test_downloads_one_image_during_window
run_test "image filename matches YYYY-MM-DD-HH.jpg format"            test_image_filename_format
run_test "fails with non-zero exit when the API call fails"            test_fails_when_api_unavailable

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
