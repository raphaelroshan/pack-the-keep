#!/usr/bin/env python3
"""Validate Pack the Keep's two-floor vertical-layer design data."""
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


def refs(values: Any, known: set[str], label: str, errors: list[str]) -> None:
    if not isinstance(values, list):
        errors.append(f"{label} must be an array")
        return
    for value in values:
        if value not in known:
            errors.append(f"{label} references unknown id: {value}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--layers", required=True)
    args = parser.parse_args()
    path = Path(args.layers)
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"ERROR: cannot read vertical-layer JSON: {exc}")
        return 1
    errors: list[str] = []
    if not isinstance(data, dict):
        print("ERROR: vertical-layer root must be an object")
        return 1
    if data.get("game_id") != "pack-the-keep":
        errors.append("game_id must be pack-the-keep")
    layout = data.get("layout", {})
    if layout.get("layers") != ["upper", "ground"]:
        errors.append("layout.layers must be exactly ['upper', 'ground']")
    if layout.get("shared_footprint") is not True or layout.get("shared_room_graph") is not True:
        errors.append("the two layers must share one footprint and room graph")

    floor_ids = collect_ids(data.get("floor_roles", []), "floor_roles", errors)
    upper_ids = collect_ids(data.get("upper_units", []), "upper_units", errors)
    ground_ids = collect_ids(data.get("ground_units", []), "ground_units", errors)
    connection_ids = collect_ids(layout.get("vertical_connections", []), "vertical_connections", errors)
    enemy_ids = {item.get("enemy") for item in data.get("enemy_floor_tests", []) if isinstance(item, dict)}
    pack_entries = data.get("pack_layer_identity", [])
    pack_ids = {item.get("pack") for item in pack_entries if isinstance(item, dict)}

    if floor_ids != {"upper", "ground"}:
        errors.append("floor_roles must define upper and ground")
    if len(upper_ids) < 3:
        errors.append("at least three upper-layer units are required")
    if len(ground_ids) < 3:
        errors.append("at least three ground-layer units are required")
    if len(connection_ids) < 3:
        errors.append("at least three vertical connections are required")
    if len(enemy_ids) < 4:
        errors.append("at least four enemy floor tests are required")
    if len(pack_ids) < 4:
        errors.append("at least four pack-layer identity entries are required")

    all_units = upper_ids | ground_ids
    for index, connection in enumerate(layout.get("vertical_connections", [])):
        if not isinstance(connection, dict):
            continue
        for key in ("type", "connects", "purpose", "failure_effect"):
            if not connection.get(key):
                errors.append(f"vertical_connections[{index}] missing {key}")
        endpoint_count = len(connection.get("connects", []))
        if connection.get("type") == "signal":
            if endpoint_count < 2:
                errors.append(f"signal connection {connection.get('id')} must connect at least two endpoints")
        elif endpoint_count != 2:
            errors.append(f"vertical connection {connection.get('id')} must connect exactly two endpoints")

    for label, entries in (("upper_units", data.get("upper_units", [])), ("ground_units", data.get("ground_units", []))):
        for index, unit in enumerate(entries if isinstance(entries, list) else []):
            if not isinstance(unit, dict):
                continue
            if unit.get("floor") not in {"upper", "ground"}:
                errors.append(f"{label}[{index}] has invalid floor: {unit.get('floor')}")
            for key in ("role", "purpose", "needs", "supports", "fails_when"):
                if not unit.get(key):
                    errors.append(f"{label}[{index}] missing {key}")

    for index, pack in enumerate(pack_entries if isinstance(pack_entries, list) else []):
        if not isinstance(pack, dict):
            continue
        for key in ("pack", "upper_pieces", "ground_pieces", "cross_floor_benefit", "cross_floor_risk"):
            if not pack.get(key):
                errors.append(f"pack_layer_identity[{index}] missing {key}")
        refs(pack.get("upper_pieces", []), all_units | {"narrow_gate", "brace", "fire_brazier", "signal_beacon", "emergency_shutters", "supply_cache"}, f"pack_layer_identity[{index}].upper_pieces", errors)
        refs(pack.get("ground_pieces", []), all_units | {"supply_cache"}, f"pack_layer_identity[{index}].ground_pieces", errors)

    scope = data.get("vertical_slice_scope", {})
    for key in ("upper", "ground", "connections", "enemies", "excluded_until_after_slice"):
        if key not in scope:
            errors.append(f"vertical_slice_scope missing {key}")
    refs(scope.get("upper", []), upper_ids | ground_ids, "vertical_slice_scope.upper", errors)
    refs(scope.get("ground", []), upper_ids | ground_ids, "vertical_slice_scope.ground", errors)
    refs(scope.get("connections", []), connection_ids, "vertical_slice_scope.connections", errors)

    progression = data.get("progression", {})
    track_ids = collect_ids(progression.get("new_tracks", []), "progression.new_tracks", errors) if isinstance(progression, dict) else set()
    if len(track_ids) < 2:
        errors.append("at least two vertical progression tracks are required")
    for index, track in enumerate(progression.get("new_tracks", []) if isinstance(progression, dict) else []):
        if not isinstance(track, dict) or len(track.get("nodes", [])) < 3:
            errors.append(f"progression.new_tracks[{index}] needs at least three nodes")

    if errors:
        print(f"Pack the Keep vertical layers: BLOCK ({len(errors)} errors)")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"Pack the Keep vertical layers: PASS ({len(upper_ids)} upper units, {len(ground_ids)} ground units, {len(connection_ids)} connections, {len(pack_ids)} pack relationships)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
