#!/usr/bin/env python3
"""Write a self-contained observer brief for a packaged P16 playtest build."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from write_playtest_build_manifest import validate_build_manifest


def render_brief(protocol: dict[str, Any], manifest: dict[str, Any]) -> str:
    observations = protocol.get("required_observations")
    if not isinstance(observations, list) or not observations:
        raise ValueError("playtest protocol needs required_observations")
    artifact = manifest.get("artifact")
    if not isinstance(artifact, dict):
        raise ValueError("playtest build manifest needs artifact metadata")

    lines = [
        "# Pack the Keep — Controlled P16 Playtest",
        "",
        "> **PRE-ALPHA:** this candidate is not release-approved. Owner review remains required.",
        "",
        "## Exact build identity",
        "",
        "| Field | Value |",
        "| --- | --- |",
        f"| Build | `{manifest['build_version']}` |",
        f"| Source revision | `{manifest['source_revision']}` |",
        f"| CI run | `{manifest['ci_run_id']}` |",
        f"| Executable | `{artifact['name']}` |",
        f"| SHA-256 | `{artifact['sha256']}` |",
        f"| Size | `{artifact['size_bytes']}` bytes |",
        "",
        "## Before play",
        "",
        "- Launch the executable listed above from this artifact without replacing or renaming it.",
        "- Use a non-identifying tester alias. Do not record names, email addresses, voice, video, or unrelated device identifiers.",
        "- Create the JSON record with `tools/new_playtest_session.py`; it verifies this manifest against the executable and starts every observation as `not_tested`.",
        "- An observer must record what the tester actually did. Automated checks are not human evidence.",
        "",
        "## Observation prompts",
        "",
    ]
    for observation in observations:
        if not isinstance(observation, dict):
            raise ValueError("playtest protocol observation must be an object")
        observation_id = observation.get("id")
        prompt = observation.get("prompt")
        success_signal = observation.get("success_signal")
        if not all(isinstance(value, str) and value.strip() for value in (observation_id, prompt, success_signal)):
            raise ValueError("playtest protocol observation needs id, prompt, and success_signal")
        lines.extend([
            f"### `{observation_id}`",
            "",
            f"Prompt: {prompt}",
            "",
            f"Success signal: {success_signal}",
            "",
        ])
    lines.extend([
        "## Close-out boundary",
        "",
        "Record friction or blocked observations with concrete notes and one linked finding. Only the human observer may mark a session complete after all required observations were exercised and an observer summary was written.",
        "",
        "A complete four-case matrix is evidence, not release approval. The human playtest gate remains pending until the owner explicitly approves it.",
        "",
    ])
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--protocol", default="content/p16_playtest_protocol.json", type=Path)
    parser.add_argument("--build-manifest", required=True, type=Path)
    parser.add_argument("--artifact", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
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
        rendered = render_brief(protocol, manifest)
    except (OSError, json.JSONDecodeError, KeyError, ValueError) as exc:
        print(f"ERROR: {exc}")
        return 1
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(rendered, encoding="utf-8")
    print(f"Playtest observer brief: WROTE {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
