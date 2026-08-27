#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v godot >/dev/null 2>&1; then
  godot --headless --path . --script res://tests/test_keep_state.gd
  godot --headless --path . --script res://tests/test_p1_balance.gd
elif command -v godot4 >/dev/null 2>&1; then
  godot4 --headless --path . --script res://tests/test_keep_state.gd
  godot4 --headless --path . --script res://tests/test_p1_balance.gd
else
  echo "Godot 4.x is not installed or not on PATH."
  echo "Run: godot --headless --path . --script res://tests/test_keep_state.gd"
  exit 2
fi
