#!/usr/bin/env python3
"""Create an unfilled P16 human-playtest session record."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path


ID_PATTERN = re.compile(r"^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
REVISION_PATTERN = re.compile(r"^[0-9a-f]{40}$")


def snake_case(value: str) -> str:
    if not ID_PATTERN.fullmatch(value):
        raise argparse.ArgumentTypeError("must be a lowercase snake_case identifier")
    return value


def non_empty(value: str) -> str:
    if not value.strip():
        raise argparse.ArgumentTypeError("must be non-empty text")
    return value


def source_revision(value: str) -> str:
    if not REVISION_PATTERN.fullmatch(value):
        raise argparse.ArgumentTypeError("must be a lowercase 40-character commit SHA")
    return value


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--protocol", default="content/p16_playtest_protocol.json")
    parser.add_argument("--source-revision", type=source_revision, required=True)
    parser.add_argument("--artifact", type=Path, required=True)
    parser.add_argument("--session-id", type=snake_case, required=True)
    parser.add_argument("--tester-alias", type=snake_case, required=True)
    parser.add_argument("--commander", choices=("castellan", "warden"), required=True)
    parser.add_argument("--run-type", choices=("baseline", "hardened_vanguard"), required=True)
    parser.add_argument("--scenario", type=snake_case, required=True)
    parser.add_argument("--platform", type=non_empty, default="windows_packaged")
    parser.add_argument("--input-method", type=non_empty, default="keyboard_mouse")
    parser.add_argument("--display", type=non_empty, default="1280x720_windowed")
    parser.add_argument("--output", required=True)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    protocol_path = Path(args.protocol)
    try:
        protocol = json.loads(protocol_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"cannot read playtest protocol: {exc}") from exc
    observations = protocol.get("required_observations") if isinstance(protocol, dict) else None
    if not isinstance(protocol.get("build_version"), str) or not isinstance(observations, list):
        raise SystemExit("playtest protocol is missing build_version or required_observations")
    if any(not isinstance(observation, dict) or not isinstance(observation.get("id"), str) for observation in observations):
        raise SystemExit("playtest protocol contains an invalid observation definition")
    artifact_path = args.artifact
    if not artifact_path.is_file():
        raise SystemExit(f"playtest artifact does not exist: {artifact_path}")
    if artifact_path.stat().st_size <= 0:
        raise SystemExit(f"playtest artifact is empty: {artifact_path}")
    output_path = Path(args.output)
    if output_path.exists() and not args.force:
        raise SystemExit(f"refusing to overwrite existing session: {output_path}")
    record = {
        "schema_version": 1,
        "build_version": protocol["build_version"],
        "source_revision": args.source_revision,
        "artifact": {
            "name": artifact_path.name,
            "sha256": sha256_file(artifact_path),
            "size_bytes": artifact_path.stat().st_size,
        },
        "session_id": args.session_id,
        "tester_alias": args.tester_alias,
        "recorded_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "platform": args.platform,
        "input_method": args.input_method,
        "display": args.display,
        "commander": args.commander,
        "run_type": args.run_type,
        "scenario": args.scenario,
        "completed": False,
        "observations": [
            {"id": observation["id"], "status": "not_tested", "notes": ""}
            for observation in observations
        ],
        "findings": [],
        "observer_summary": ""
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    print(f"Created unfilled playtest session: {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
