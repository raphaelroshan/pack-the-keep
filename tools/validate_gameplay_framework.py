#!/usr/bin/env python3
"""Validate Pack the Keep's machine-readable gameplay framework."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def collect_ids(items: Any, label: str, errors: list[str]) -> set[str]:
    if not isinstance(items, list):
        errors.append(f"{label} must be an array")
        return set()
    result: set[str] = set()
    for index, item in enumerate(items):
        if not isinstance(item, dict) or not isinstance(item.get("id"), str) or not item["id"]:
            errors.append(f"{label}[{index}] requires a non-empty id")
            continue
        item_id = item["id"]
        if item_id in result:
            errors.append(f"duplicate id in {label}: {item_id}")
        result.add(item_id)
    return result


def references(values: Any, known: set[str], label: str, errors: list[str]) -> None:
    if not isinstance(values, list):
        errors.append(f"{label} must be an array")
        return
    for value in values:
        if value not in known:
            errors.append(f"{label} references unknown id: {value}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--framework", required=True)
    args = parser.parse_args()
    path = Path(args.framework)
    errors: list[str] = []
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"ERROR: cannot read framework JSON: {exc}")
        return 1
    if not isinstance(data, dict):
        print("ERROR: framework root must be an object")
        return 1

    for key in ("schema_version", "game_id", "framework_version", "vertical_slice", "units", "pack_families", "enemy_doctrines", "enemies", "resources", "progression", "spatial_rules", "solo_balance"):
        if key not in data:
            errors.append(f"missing top-level key: {key}")
    if data.get("game_id") != "pack-the-keep":
        errors.append("game_id must be pack-the-keep")

    unit_ids = collect_ids(data.get("units", []), "units", errors)
    equipment_ids = collect_ids(data.get("equipment", []), "equipment", errors)
    pack_ids = collect_ids(data.get("pack_families", []), "pack_families", errors)
    doctrine_ids = collect_ids(data.get("enemy_doctrines", []), "enemy_doctrines", errors)
    enemy_ids = collect_ids(data.get("enemies", []), "enemies", errors)
    resource_ids = collect_ids(data.get("resources", []), "resources", errors)
    spatial_ids = collect_ids(data.get("spatial_rules", []), "spatial_rules", errors)

    vertical = data.get("vertical_slice", {})
    if not isinstance(vertical, dict):
        errors.append("vertical_slice must be an object")
        vertical = {}
    references(vertical.get("units", []), unit_ids, "vertical_slice.units", errors)
    references(vertical.get("packs", []), pack_ids, "vertical_slice.packs", errors)
    references(vertical.get("enemies", []), enemy_ids, "vertical_slice.enemies", errors)

    for index, pack in enumerate(data.get("pack_families", [])):
        if not isinstance(pack, dict):
            continue
        references(pack.get("contents", []), unit_ids | equipment_ids, f"pack_families[{index}].contents", errors)
        references(pack.get("commander_affinity", []), {"castellan", "warden", "quartermaster", "beacon_keeper", "artificer", "refuge_keeper"}, f"pack_families[{index}].commander_affinity", errors)
        for key in ("purpose", "doctrine", "player_question", "strength", "weakness", "does_not_guarantee"):
            if not pack.get(key):
                errors.append(f"pack {pack.get('id')} missing {key}")

    for index, enemy in enumerate(data.get("enemies", [])):
        if not isinstance(enemy, dict):
            continue
        doctrine = enemy.get("doctrine")
        if doctrine and doctrine not in doctrine_ids:
            errors.append(f"enemies[{index}] references unknown doctrine: {doctrine}")
        if not enemy.get("role") or not enemy.get("readable_behavior"):
            errors.append(f"enemy {enemy.get('id')} needs role and readable_behavior")
        if len(enemy.get("counterplay", [])) < 3:
            errors.append(f"enemy {enemy.get('id')} needs at least three counterplay options")

    for index, doctrine in enumerate(data.get("enemy_doctrines", [])):
        if not isinstance(doctrine, dict):
            continue
        references(doctrine.get("response_families", []), {"frontline", "support", "control", "recon", "mobile_response", "morale", "specialist", "precision", "direct_damage", "controlled_sacrifice", "open_space", "commander_ability", "refuge_plan", "pause", "alternate_lanes", "reserve"}, f"enemy_doctrines[{index}].response_families", errors)
        for key in ("question", "telegraph", "pressure_pattern"):
            if not doctrine.get(key):
                errors.append(f"doctrine {doctrine.get('id')} missing {key}")

    progression = data.get("progression", {})
    if not isinstance(progression, dict):
        errors.append("progression must be an object")
    else:
        for key in ("run_structure", "within_run_tracks", "campaign_progression"):
            if key not in progression:
                errors.append(f"progression missing {key}")
        track_ids = collect_ids(progression.get("within_run_tracks", []), "progression.within_run_tracks", errors)
        if not track_ids:
            errors.append("at least one within-run progression track is required")

    if len(data.get("solo_balance", {}).get("principles", [])) < 4:
        errors.append("solo_balance requires at least four principles")
    if len(data.get("sample_builds", [])) < 2:
        errors.append("at least two sample builds are required")

    if errors:
        print(f"Pack the Keep gameplay framework: BLOCK ({len(errors)} errors)")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"Pack the Keep gameplay framework: PASS ({len(unit_ids)} units, {len(pack_ids)} packs, {len(enemy_ids)} enemies, {len(doctrine_ids)} doctrines)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
