#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v godot >/dev/null 2>&1; then
  godot --headless --audio-driver Dummy --path . --editor --quit
  godot --headless --audio-driver Dummy --path . --script res://tests/test_keep_state.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p1_balance.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p2_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_p3_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_v082_ui.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_placement_boxes.gd
  godot --headless --audio-driver Dummy --path . --script res://tests/test_initial_combat.gd
elif command -v godot4 >/dev/null 2>&1; then
  godot4 --headless --audio-driver Dummy --path . --editor --quit
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_keep_state.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p1_balance.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p2_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_p3_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_v082_ui.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_placement_boxes.gd
  godot4 --headless --audio-driver Dummy --path . --script res://tests/test_initial_combat.gd
else
  echo "Godot 4.x is not installed or not on PATH."
  echo "Run: godot --headless --audio-driver Dummy --path . --script res://tests/test_keep_state.gd"
  exit 2
fi
