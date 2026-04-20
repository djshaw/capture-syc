# capture-syc Copilot Instructions

Read `README.md` before working with this codebase.

Do not add information to this file that is already documented in `README.md`.

## Script Overview

### `run.sh`
The production entry point. Run inside the Docker container (or locally) on a schedule via cron. It:
1. Calls the open-meteo API to fetch today's sunrise/sunset times for Sarnia, ON.
2. Expands the window by one hour on each side.
3. Exits cleanly (exit 0) if the current time is outside that window.
4. Downloads a webcam snapshot from the Sarnia Yacht Club and saves it to `$OUTPUT/<YYYY-MM-DD-HH>.jpg`.

### `test-run.sh`
The unit-test harness for `run.sh`. It does **not** make real network calls or require Docker. It:
1. Stubs `curl` with a mock that returns a canned API response and creates empty `.jpg` files for image downloads.
2. Stubs `date +%s` with a mock that returns a controlled epoch value (`$MOCK_NOW_EPOCH`).
3. Runs a suite of tests covering: output directory creation, no-download before/after the daylight window, single-image download during the window, filename format, and API failure handling.
4. Reports pass/fail counts and exits non-zero if any test failed.

## Dockerfile Hygiene

When any file that is copied into the Docker image is added or modified (e.g. `run.sh`), check whether the `Dockerfile` apt package list needs updating:
- Can any packages be **removed** because they are no longer used?
- Do any **new packages** need to be added to support new dependencies?

The image requires both `ca-certificates` and `curl`; omitting `ca-certificates` causes `curl` to fail (exit 77) on all HTTPS requests.

## Git Hooks

The repo uses `.githooks/` for git hooks, configured via `git config core.hooksPath .githooks`. Running `docker-build.sh` installs this configuration automatically. The `pre-push` hook runs `test-run.sh` before every push and then delegates to the global `pre-push` hook (if one exists at the path returned by `git config --global core.hooksPath`).
