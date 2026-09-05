#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${AGENT_QA_OUTPUT_DIR:-$ROOT/artifacts/agent-qa}"
TIMEOUT_SECONDS="${AGENT_QA_TIMEOUT_SECONDS:-900}"
GAME="${AGENT_QA_GAME:-$(basename "$ROOT")}"
SCENARIO="${AGENT_QA_SCENARIO:-}"
if [[ -z "$SCENARIO" ]]; then
  case "$GAME" in
    market|market-of-ash) SCENARIO="qa/scenarios/market_ordinary_trade_round_trip.json" ;;
    pack|pack-the-keep) SCENARIO="qa/scenarios/pack_greywatch_three_wave.json" ;;
    long|the-long-march) SCENARIO="qa/scenarios/long_march_complete_journey.json" ;;
  esac
fi
GODOT_BIN="${GODOT_BIN:-godot}"
mkdir -p "$OUTPUT_DIR"

if [[ ! -f "$ROOT/scripts/verify.sh" ]]; then
  echo "AGENT_QA_CONFIG_ERROR: scripts/verify.sh is missing" >&2
  exit 2
fi

set +e
python3 "$ROOT/tools/agent_qa_runner.py" \
  --game "$GAME" \
  --output "$OUTPUT_DIR" \
  --timeout "$TIMEOUT_SECONDS" \
  --godot "$GODOT_BIN" \
  --capture "${AGENT_QA_CAPTURE:-1}" \
  ${SCENARIO:+--scenario "$SCENARIO"} \
  --verify bash scripts/verify.sh
STATUS=$?
set -e

exit "$STATUS"
