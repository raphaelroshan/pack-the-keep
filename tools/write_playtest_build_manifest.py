#!/usr/bin/env python3
"""Write a deterministic provenance manifest for a packaged playtest build."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any


REVISION_PATTERN = re.compile(r"^[0-9a-f]{40}$")
SHA256_PATTERN = re.compile(r"^[0-9a-f]{64}$")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_manifest(executable: Path, ci_manifest: dict[str, Any], source_revision: str, run_id: int) -> dict[str, Any]:
    if not REVISION_PATTERN.fullmatch(source_revision):
        raise ValueError("source_revision must be a lowercase 40-character commit SHA")
    if type(run_id) is not int or run_id <= 0:
        raise ValueError("ci_run_id must be a positive integer")
    if not executable.is_file() or executable.stat().st_size <= 0:
        raise ValueError(f"packaged executable must be a non-empty file: {executable}")
    build_version = ci_manifest.get("build_version")
    if not isinstance(build_version, str) or not build_version:
        raise ValueError("CI manifest needs a non-empty build_version")
    if ci_manifest.get("release_ready") is not False:
        raise ValueError("CI manifest release_ready must remain false")
    return {
        "schema_version": 1,
        "build_version": build_version,
        "source_revision": source_revision,
        "ci_run_id": run_id,
        "release_ready": False,
        "artifact": {
            "name": executable.name,
            "sha256": sha256_file(executable),
            "size_bytes": executable.stat().st_size,
        },
    }


def validate_build_manifest(manifest: dict[str, Any], executable: Path, expected_version: str) -> list[str]:
    errors: list[str] = []
    if manifest.get("schema_version") != 1:
        errors.append("playtest build manifest schema_version must be 1")
    if manifest.get("build_version") != expected_version:
        errors.append("playtest build manifest version does not match the protocol")
    if manifest.get("release_ready") is not False:
        errors.append("playtest build manifest release_ready must remain false")
    revision = manifest.get("source_revision")
    if not isinstance(revision, str) or not REVISION_PATTERN.fullmatch(revision):
        errors.append("playtest build manifest source_revision is invalid")
    run_id = manifest.get("ci_run_id")
    if type(run_id) is not int or run_id <= 0:
        errors.append("playtest build manifest ci_run_id must be a positive integer")
    artifact = manifest.get("artifact")
    if not isinstance(artifact, dict):
        errors.append("playtest build manifest artifact must be an object")
        return errors
    if not executable.is_file() or executable.stat().st_size <= 0:
        errors.append(f"playtest artifact must be a non-empty file: {executable}")
        return errors
    if artifact.get("name") != executable.name:
        errors.append("playtest artifact filename does not match its build manifest")
    expected_sha = artifact.get("sha256")
    if not isinstance(expected_sha, str) or not SHA256_PATTERN.fullmatch(expected_sha):
        errors.append("playtest build manifest artifact sha256 is invalid")
    elif sha256_file(executable) != expected_sha:
        errors.append("playtest artifact sha256 does not match its build manifest")
    if artifact.get("size_bytes") != executable.stat().st_size:
        errors.append("playtest artifact size does not match its build manifest")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--executable", required=True, type=Path)
    parser.add_argument("--ci-manifest", default="tools/ci_manifest.json", type=Path)
    parser.add_argument("--source-revision", required=True)
    parser.add_argument("--run-id", required=True, type=int)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    try:
        ci_manifest = json.loads(args.ci_manifest.read_text(encoding="utf-8"))
        if not isinstance(ci_manifest, dict):
            raise ValueError("CI manifest root must be an object")
        manifest = build_manifest(args.executable, ci_manifest, args.source_revision, args.run_id)
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        print(f"ERROR: {exc}")
        return 1
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8", newline="\n") as stream:
        stream.write(json.dumps(manifest, indent=2) + "\n")
    print(f"Playtest build manifest: WROTE {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
