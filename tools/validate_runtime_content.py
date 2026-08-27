#!/usr/bin/env python3
"""Validate externalized runtime content before Godot loads it."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


PACK_FIELDS = {
    "id",
    "content_version",
    "status",
    "name",
    "short_role",
    "question",
    "family",
    "contents",
    "doctrine",
    "cost",
    "strength",
    "weakness",
    "choice",
    "commander_affinity",
    "spatial_demand",
}
SNAKE_CASE = re.compile(r"^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")


def load_json(path: Path, errors: list[str]) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{path}: cannot read JSON: {exc}")
        return None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--packs", required=True)
    parser.add_argument("--manifest", required=True)
    args = parser.parse_args()

    errors: list[str] = []
    manifest_path = Path(args.manifest)
    manifest = load_json(manifest_path, errors)
    if not isinstance(manifest, dict):
        errors.append(f"{manifest_path}: root must be an object")
        manifest = {}

    piece_ids = {
        item.get("id")
        for item in manifest.get("pieces", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }
    commander_ids = {
        item.get("id")
        for item in manifest.get("commanders", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }
    manifest_packs = {
        item.get("id"): item
        for item in manifest.get("packs", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }

    pack_dir = Path(args.packs)
    paths = sorted(pack_dir.glob("*.json")) if pack_dir.is_dir() else []
    if not paths:
        errors.append(f"{pack_dir}: no pack JSON files found")

    seen: set[str] = set()
    for path in paths:
        pack = load_json(path, errors)
        if not isinstance(pack, dict):
            errors.append(f"{path}: root must be an object")
            continue
        missing = sorted(PACK_FIELDS - pack.keys())
        for field in missing:
            errors.append(f"{path}: missing required field: {field}")
        pack_id = pack.get("id")
        if not isinstance(pack_id, str) or not SNAKE_CASE.fullmatch(pack_id):
            errors.append(f"{path}: id must be non-empty snake_case")
            continue
        if pack_id != path.stem:
            errors.append(f"{path}: id {pack_id} does not match filename")
        if pack_id in seen:
            errors.append(f"duplicate runtime pack id: {pack_id}")
        seen.add(pack_id)
        if pack.get("status") != "active":
            errors.append(f"{path}: runtime pack status must be active")
        if not isinstance(pack.get("content_version"), int) or pack["content_version"] < 1:
            errors.append(f"{path}: content_version must be a positive integer")
        if not isinstance(pack.get("cost"), int) or pack["cost"] < 0:
            errors.append(f"{path}: cost must be a non-negative integer")
        contents = pack.get("contents")
        if not isinstance(contents, list) or not 2 <= len(contents) <= 3:
            errors.append(f"{path}: contents must contain two or three piece IDs")
        else:
            for piece_id in contents:
                if piece_id not in piece_ids:
                    errors.append(f"{path}: unknown piece reference: {piece_id}")
        affinities = pack.get("commander_affinity")
        if not isinstance(affinities, list):
            errors.append(f"{path}: commander_affinity must be an array")
        else:
            for commander_id in affinities:
                if commander_id not in commander_ids:
                    errors.append(f"{path}: unknown commander affinity: {commander_id}")
        spatial = pack.get("spatial_demand")
        if not isinstance(spatial, dict):
            errors.append(f"{path}: spatial_demand must be an object")
        else:
            floors = spatial.get("preferred_floors")
            zones = spatial.get("preferred_zones")
            if not isinstance(floors, list) or not floors or any(value not in {"ground", "upper"} for value in floors):
                errors.append(f"{path}: preferred_floors contains an unsupported floor")
            if not isinstance(zones, list) or not zones or any(value not in {"wall", "courtyard", "keep"} for value in zones):
                errors.append(f"{path}: preferred_zones contains an unsupported zone")
        manifest_pack = manifest_packs.get(pack_id)
        if not isinstance(manifest_pack, dict):
            errors.append(f"{path}: pack is missing from content manifest")
        else:
            if pack.get("name") != manifest_pack.get("name"):
                errors.append(f"{path}: name differs from content manifest")
            if pack.get("contents") != manifest_pack.get("pieces"):
                errors.append(f"{path}: contents differ from content manifest")
            if pack.get("doctrine") != manifest_pack.get("doctrine"):
                errors.append(f"{path}: doctrine differs from content manifest")

    for pack_id in sorted(set(manifest_packs) - seen):
        errors.append(f"runtime pack file missing for manifest pack: {pack_id}")

    if errors:
        print(f"runtime content catalog: BLOCK ({len(errors)} errors)")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"runtime content catalog: PASS ({len(seen)} packs)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
