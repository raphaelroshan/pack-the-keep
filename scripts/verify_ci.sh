#!/usr/bin/env bash
set -uo pipefail

status=0
bash scripts/verify.sh || status=$?

if [[ "${RUNNER_OS:-}" == "Windows" && "$status" -eq 139 ]]; then
  echo "Godot exited 139 during Windows headless shutdown; retrying the deterministic suite once."
  exec bash scripts/verify.sh
fi

exit "$status"
