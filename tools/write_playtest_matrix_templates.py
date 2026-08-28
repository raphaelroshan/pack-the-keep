#!/usr/bin/env python3
"""Write provenance-bound, intentionally unfilled P16 matrix session templates."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from new_playtest_session import ID_PATTERN, build_unfilled_record
from write_playtest_build_manifest import validate_build_manifest


def matrix_values(protocol: dict[str, Any], key: str) -> list[str]:
    matrix = protocol.get("required_matrix")
    values = matrix.get(key) if isinstance(matrix, dict) else None
    if (
        not isinstance(values, list)
        or not values
        or any(not isinstance(value, str) or not ID_PATTERN.fullmatch(value) for value in values)
        or len(values) != len(set(values))
    ):
        raise ValueError(f"playtest protocol required_matrix needs unique {key}")
    return sorted(values)


def build_templates(protocol: dict[str, Any], manifest: dict[str, Any]) -> dict[str, dict[str, Any]]:
    commanders = matrix_values(protocol, "commanders")
    run_types = matrix_values(protocol, "run_types")
    observations = protocol.get("required_observations")
    if not isinstance(observations, list) or not observations:
        raise ValueError("playtest protocol needs required_observations")
    templates: dict[str, dict[str, Any]] = {}
    for commander in commanders:
        for run_type in run_types:
            filename = f"session-{commander}-{run_type}.template.json"
            templates[filename] = build_unfilled_record(
                protocol,
                manifest,
                session_id="",
                tester_alias="",
                recorded_at="",
                platform="windows_packaged",
                input_method="",
                display="",
                commander=commander,
                run_type=run_type,
                scenario="",
            )
    return templates


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--protocol", default="content/p16_playtest_protocol.json", type=Path)
    parser.add_argument("--build-manifest", required=True, type=Path)
    parser.add_argument("--artifact", required=True, type=Path)
    parser.add_argument("--output-directory", required=True, type=Path)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    try:
        protocol = json.loads(args.protocol.read_text(encoding="utf-8"))
        manifest = json.loads(args.build_manifest.read_text(encoding="utf-8"))
        if not isinstance(protocol, dict) or not isinstance(manifest, dict):
            raise ValueError("protocol and build manifest roots must be objects")
        build_version = protocol.get("build_version")
        if not isinstance(build_version, str) or not build_version:
            raise ValueError("playtest protocol needs a build_version")
        errors = validate_build_manifest(manifest, args.artifact, build_version)
        if errors:
            raise ValueError("invalid playtest build:\n" + "\n".join(errors))
        templates = build_templates(protocol, manifest)
        existing = [args.output_directory / filename for filename in templates if (args.output_directory / filename).exists()]
        if existing and not args.force:
            raise ValueError(f"refusing to overwrite existing template: {existing[0]}")
    except (OSError, json.JSONDecodeError, KeyError, ValueError) as exc:
        print(f"ERROR: {exc}")
        return 1

    args.output_directory.mkdir(parents=True, exist_ok=True)
    for filename, record in templates.items():
        output_path = args.output_directory / filename
        with output_path.open("w", encoding="utf-8", newline="\n") as stream:
            stream.write(json.dumps(record, indent=2) + "\n")
    print(f"Playtest matrix templates: WROTE {len(templates)} files to {args.output_directory}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
