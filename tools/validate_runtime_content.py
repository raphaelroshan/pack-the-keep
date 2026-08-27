#!/usr/bin/env python3
"""Validate externalized runtime content before Godot loads it."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


PACK_FIELDS = {
    "id", "content_version", "status", "name", "short_role", "question", "family",
    "contents", "doctrine", "cost", "strength", "weakness", "choice",
    "commander_affinity", "spatial_demand",
}
COMMANDER_FIELDS = {
    "id", "content_version", "status", "name", "short_role", "question", "passive",
    "ability", "ability_name", "ability_text", "limitation", "starting_materials",
    "starting_morale", "preferred_pattern", "favored_pack_families",
}
COMMANDER_TEXT_FIELDS = {
    "name", "short_role", "question", "passive", "ability", "ability_name",
    "ability_text", "limitation", "preferred_pattern",
}
SUPPORTED_FLOORS = {"ground", "upper"}
SUPPORTED_ZONES = {"wall", "courtyard", "keep"}
SNAKE_CASE = re.compile(r"^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")


def load_json(path: Path, errors: list[str]) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{path}: cannot read JSON: {exc}")
        return None


def json_files(directory: Path, content_type: str, errors: list[str]) -> list[Path]:
    paths = sorted(directory.glob("*.json")) if directory.is_dir() else []
    if not paths:
        errors.append(f"{directory}: no {content_type} JSON files found")
    return paths


def is_integer(value: Any) -> bool:
    return isinstance(value, int) and not isinstance(value, bool)


def validate_pack(
    path: Path,
    pack: dict[str, Any],
    piece_ids: set[str],
    commander_ids: set[str],
    manifest_packs: dict[str, dict[str, Any]],
    seen: set[str],
    errors: list[str],
) -> tuple[str | None, str | None]:
    for field in sorted(PACK_FIELDS - pack.keys()):
        errors.append(f"{path}: missing required field: {field}")
    pack_id = pack.get("id")
    if not isinstance(pack_id, str) or not SNAKE_CASE.fullmatch(pack_id):
        errors.append(f"{path}: id must be non-empty snake_case")
        return None, None
    if pack_id != path.stem:
        errors.append(f"{path}: id {pack_id} does not match filename")
    if pack_id in seen:
        errors.append(f"duplicate runtime pack id: {pack_id}")
    seen.add(pack_id)
    if pack.get("status") != "active":
        errors.append(f"{path}: runtime pack status must be active")
    if not is_integer(pack.get("content_version")) or pack["content_version"] < 1:
        errors.append(f"{path}: content_version must be a positive integer")
    if not is_integer(pack.get("cost")) or pack["cost"] < 0:
        errors.append(f"{path}: cost must be a non-negative integer")
    contents = pack.get("contents")
    if not isinstance(contents, list) or not 2 <= len(contents) <= 3:
        errors.append(f"{path}: contents must contain two or three piece IDs")
    else:
        for piece_id in contents:
            if not isinstance(piece_id, str) or piece_id not in piece_ids:
                errors.append(f"{path}: unknown piece reference: {piece_id}")
    affinities = pack.get("commander_affinity")
    if not isinstance(affinities, list):
        errors.append(f"{path}: commander_affinity must be an array")
    else:
        for commander_id in affinities:
            if not isinstance(commander_id, str) or commander_id not in commander_ids:
                errors.append(f"{path}: unknown commander affinity: {commander_id}")
    spatial = pack.get("spatial_demand")
    if not isinstance(spatial, dict):
        errors.append(f"{path}: spatial_demand must be an object")
    else:
        floors = spatial.get("preferred_floors")
        zones = spatial.get("preferred_zones")
        if not isinstance(floors, list) or not floors or any(not isinstance(value, str) or value not in SUPPORTED_FLOORS for value in floors):
            errors.append(f"{path}: preferred_floors contains an unsupported floor")
        if not isinstance(zones, list) or not zones or any(not isinstance(value, str) or value not in SUPPORTED_ZONES for value in zones):
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
    family = pack.get("family")
    if not isinstance(family, str) or not SNAKE_CASE.fullmatch(family):
        errors.append(f"{path}: family must be non-empty snake_case")
        family = None
    return pack_id, family


def validate_commander(
    path: Path,
    commander: dict[str, Any],
    pack_families: set[str],
    manifest_commanders: dict[str, dict[str, Any]],
    runtime_pack_families: dict[str, str],
    seen: set[str],
    errors: list[str],
) -> str | None:
    for field in sorted(COMMANDER_FIELDS - commander.keys()):
        errors.append(f"{path}: missing required field: {field}")
    commander_id = commander.get("id")
    if not isinstance(commander_id, str) or not SNAKE_CASE.fullmatch(commander_id):
        errors.append(f"{path}: id must be non-empty snake_case")
        return None
    if commander_id != path.stem:
        errors.append(f"{path}: id {commander_id} does not match filename")
    if commander_id in seen:
        errors.append(f"duplicate runtime commander id: {commander_id}")
    seen.add(commander_id)
    if commander.get("status") != "active":
        errors.append(f"{path}: runtime commander status must be active")
    if not is_integer(commander.get("content_version")) or commander["content_version"] < 1:
        errors.append(f"{path}: content_version must be a positive integer")
    if not is_integer(commander.get("starting_materials")) or commander["starting_materials"] < 0:
        errors.append(f"{path}: starting_materials must be a non-negative integer")
    morale = commander.get("starting_morale")
    if not is_integer(morale) or not 0 <= morale <= 10:
        errors.append(f"{path}: starting_morale must be an integer from 0 to 10")
    for field in sorted(COMMANDER_TEXT_FIELDS):
        value = commander.get(field)
        if not isinstance(value, str) or not value.strip():
            errors.append(f"{path}: {field} must be non-empty text")
    families = commander.get("favored_pack_families")
    if not isinstance(families, list) or not families:
        errors.append(f"{path}: favored_pack_families must be a non-empty array")
        families = []
    elif any(not isinstance(family, str) for family in families):
        errors.append(f"{path}: favored_pack_families must contain only strings")
        families = [family for family in families if isinstance(family, str)]
    elif len(families) != len(set(families)):
        errors.append(f"{path}: favored_pack_families contains duplicates")
    for family in families:
        if family not in pack_families:
            errors.append(f"{path}: unknown favored pack family: {family}")
    manifest_commander = manifest_commanders.get(commander_id)
    if not isinstance(manifest_commander, dict):
        errors.append(f"{path}: commander is missing from content manifest")
    else:
        if commander.get("name") != manifest_commander.get("name"):
            errors.append(f"{path}: name differs from content manifest")
        if commander.get("ability") != manifest_commander.get("ability"):
            errors.append(f"{path}: ability differs from content manifest")
        favored_pack_ids = manifest_commander.get("favored_packs")
        if not isinstance(favored_pack_ids, list):
            errors.append(f"{path}: manifest favored_packs must be an array")
        else:
            expected_families = {
                runtime_pack_families[pack_id]
                for pack_id in favored_pack_ids
                if pack_id in runtime_pack_families
            }
            if len(expected_families) != len(favored_pack_ids):
                errors.append(f"{path}: manifest favored_packs references unavailable runtime packs")
            if set(families) != expected_families:
                errors.append(f"{path}: favored pack families differ from content manifest")
    return commander_id


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--packs", required=True)
    parser.add_argument("--commanders", required=True)
    parser.add_argument("--manifest", required=True)
    args = parser.parse_args()

    errors: list[str] = []
    manifest_path = Path(args.manifest)
    manifest = load_json(manifest_path, errors)
    if not isinstance(manifest, dict):
        errors.append(f"{manifest_path}: root must be an object")
        manifest = {}

    piece_ids = {
        item.get("id") for item in manifest.get("pieces", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }
    manifest_commanders = {
        item.get("id"): item for item in manifest.get("commanders", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }
    manifest_packs = {
        item.get("id"): item for item in manifest.get("packs", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }

    seen_packs: set[str] = set()
    runtime_pack_families: dict[str, str] = {}
    for path in json_files(Path(args.packs), "pack", errors):
        pack = load_json(path, errors)
        if not isinstance(pack, dict):
            errors.append(f"{path}: root must be an object")
            continue
        pack_id, family = validate_pack(
            path, pack, piece_ids, set(manifest_commanders), manifest_packs, seen_packs, errors
        )
        if pack_id is not None and family is not None:
            runtime_pack_families[pack_id] = family
    for pack_id in sorted(set(manifest_packs) - seen_packs):
        errors.append(f"runtime pack file missing for manifest pack: {pack_id}")

    seen_commanders: set[str] = set()
    for path in json_files(Path(args.commanders), "commander", errors):
        commander = load_json(path, errors)
        if not isinstance(commander, dict):
            errors.append(f"{path}: root must be an object")
            continue
        validate_commander(
            path,
            commander,
            set(runtime_pack_families.values()),
            manifest_commanders,
            runtime_pack_families,
            seen_commanders,
            errors,
        )
    for commander_id in sorted(set(manifest_commanders) - seen_commanders):
        errors.append(f"runtime commander file missing for manifest commander: {commander_id}")

    if errors:
        print(f"runtime content catalog: BLOCK ({len(errors)} errors)")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"runtime content catalog: PASS ({len(seen_packs)} packs, {len(seen_commanders)} commanders)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
