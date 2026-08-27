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
PIECE_FIELDS = {
    "id", "content_version", "status", "name", "short_role", "role", "question", "kind",
    "category", "footprint", "allowed_floors", "allowed_zones", "cost", "max_health",
    "placement_question", "skill", "strength_tags", "weakness_tags", "attack_profile",
    "support_profile", "assignment_rule", "availability", "presentation",
}
PIECE_TEXT_FIELDS = {
    "name", "short_role", "role", "question", "category", "placement_question", "skill", "availability",
}
ENEMY_FIELDS = {
    "id", "content_version", "status", "name", "short_role", "question", "health",
    "damage", "arrival_step", "route", "target_rooms", "doctrine", "counter", "telegraph",
    "counter_families", "failure_mode", "report_phrase", "presentation",
}
ENEMY_TEXT_FIELDS = {
    "name", "short_role", "question", "route", "doctrine", "counter", "telegraph",
    "failure_mode", "report_phrase",
}
DOCTRINE_FIELDS = {
    "id", "content_version", "status", "name", "short_role", "question", "composition",
    "route_pattern", "target_priority", "principal_pressure", "likely_target", "uncertainty",
    "counter_families",
}
DOCTRINE_TEXT_FIELDS = {
    "name", "short_role", "question", "route_pattern", "target_priority",
    "principal_pressure", "likely_target", "uncertainty",
}
SUPPORTED_FLOORS = {"ground", "upper"}
SUPPORTED_ZONES = {"wall", "courtyard", "keep"}
SUPPORTED_ATTACK_STYLES = {"melee", "ranged", "support", "fortification"}
SUPPORTED_DOCTRINES = {"gate_assault", "distributed_sabotage", "feint_and_flank", "area_pressure"}
SUPPORTED_NON_ENEMY_TARGETS = {"all"} | SUPPORTED_DOCTRINES
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


def validate_string_array(
    path: Path,
    value: Any,
    field: str,
    errors: list[str],
    supported: set[str] | None = None,
    allow_duplicates: bool = False,
) -> list[str]:
    if not isinstance(value, list) or not value:
        errors.append(f"{path}: {field} must be a non-empty array")
        return []
    strings = [item for item in value if isinstance(item, str) and item]
    if len(strings) != len(value):
        errors.append(f"{path}: {field} must contain only non-empty strings")
    if not allow_duplicates and len(strings) != len(set(strings)):
        errors.append(f"{path}: {field} contains duplicates")
    if supported is not None:
        for item in strings:
            if item not in supported:
                errors.append(f"{path}: {field} contains unsupported value: {item}")
    return strings


def validate_piece(
    path: Path,
    piece: dict[str, Any],
    room_ids: set[str],
    enemy_ids: set[str],
    pack_ids: set[str],
    manifest_pieces: dict[str, dict[str, Any]],
    manifest_assignments: dict[str, dict[str, Any]],
    seen: set[str],
    errors: list[str],
) -> str | None:
    for field in sorted(PIECE_FIELDS - piece.keys()):
        errors.append(f"{path}: missing required field: {field}")
    piece_id = piece.get("id")
    if not isinstance(piece_id, str) or not SNAKE_CASE.fullmatch(piece_id):
        errors.append(f"{path}: id must be non-empty snake_case")
        return None
    if piece_id != path.stem:
        errors.append(f"{path}: id {piece_id} does not match filename")
    if piece_id in seen:
        errors.append(f"duplicate runtime piece id: {piece_id}")
    seen.add(piece_id)
    if piece.get("status") != "active":
        errors.append(f"{path}: runtime piece status must be active")
    if not is_integer(piece.get("content_version")) or piece["content_version"] < 1:
        errors.append(f"{path}: content_version must be a positive integer")
    if piece.get("kind") not in {"unit", "equipment"}:
        errors.append(f"{path}: kind must be unit or equipment")
    for field in sorted(PIECE_TEXT_FIELDS):
        value = piece.get(field)
        if not isinstance(value, str) or not value.strip():
            errors.append(f"{path}: {field} must be non-empty text")
    footprint = piece.get("footprint")
    if (
        not isinstance(footprint, list)
        or len(footprint) != 2
        or any(not is_integer(value) or value < 1 for value in footprint)
        or (isinstance(footprint, list) and len(footprint) == 2 and (footprint[0] > 12 or footprint[1] > 8))
    ):
        errors.append(f"{path}: footprint must be two positive integers within the 12x8 grid")
    validate_string_array(path, piece.get("allowed_floors"), "allowed_floors", errors, SUPPORTED_FLOORS)
    validate_string_array(path, piece.get("allowed_zones"), "allowed_zones", errors, SUPPORTED_ZONES)
    validate_string_array(path, piece.get("strength_tags"), "strength_tags", errors)
    validate_string_array(path, piece.get("weakness_tags"), "weakness_tags", errors)
    if not is_integer(piece.get("cost")) or piece["cost"] < 0:
        errors.append(f"{path}: cost must be a non-negative integer")
    if not is_integer(piece.get("max_health")) or piece["max_health"] < 1:
        errors.append(f"{path}: max_health must be a positive integer")
    attack = piece.get("attack_profile")
    if not isinstance(attack, dict):
        errors.append(f"{path}: attack_profile must be an object")
    else:
        if attack.get("style") not in SUPPORTED_ATTACK_STYLES:
            errors.append(f"{path}: attack_profile style is unsupported")
        for field in ("range", "cooldown_steps", "damage", "defense", "ammo_capacity"):
            if not is_integer(attack.get(field)) or attack[field] < 0:
                errors.append(f"{path}: attack_profile {field} must be a non-negative integer")
        targets = validate_string_array(path, attack.get("targets"), "attack_profile.targets", errors)
        for target in targets:
            if target not in SUPPORTED_NON_ENEMY_TARGETS and target not in enemy_ids:
                errors.append(f"{path}: attack_profile references unknown enemy: {target}")
    support = piece.get("support_profile")
    if support is not None and not isinstance(support, dict):
        errors.append(f"{path}: support_profile must be null or an object")
    elif isinstance(support, dict):
        target_rooms = support.get("target_rooms")
        if not isinstance(target_rooms, list) or any(not isinstance(room, str) or room not in room_ids for room in target_rooms):
            errors.append(f"{path}: support_profile target_rooms contains an unknown room")
        if not is_integer(support.get("condition_restore")) or support["condition_restore"] < 0:
            errors.append(f"{path}: support_profile condition_restore must be a non-negative integer")
        if not isinstance(support.get("kind"), str) or not support["kind"]:
            errors.append(f"{path}: support_profile kind must be non-empty text")
        if not isinstance(support.get("response_modifier"), str) or not support["response_modifier"]:
            errors.append(f"{path}: support_profile response_modifier must be non-empty text")
    assignment = piece.get("assignment_rule")
    if assignment is not None and not isinstance(assignment, dict):
        errors.append(f"{path}: assignment_rule must be null or an object")
    elif isinstance(assignment, dict):
        if assignment.get("room") not in room_ids:
            errors.append(f"{path}: assignment_rule references an unknown room")
        if not isinstance(assignment.get("effect"), str) or not assignment["effect"].strip():
            errors.append(f"{path}: assignment_rule effect must be non-empty text")
        manifest_assignment = manifest_assignments.get(piece_id)
        if assignment != manifest_assignment:
            errors.append(f"{path}: assignment_rule differs from content manifest")
    elif piece_id in manifest_assignments:
        errors.append(f"{path}: assignment_rule is missing for manifest assignment")
    availability = piece.get("availability")
    if availability != "starter" and availability not in pack_ids:
        errors.append(f"{path}: availability references an unknown pack")
    presentation = piece.get("presentation")
    if not isinstance(presentation, dict):
        errors.append(f"{path}: presentation must be an object")
    else:
        if not isinstance(presentation.get("icon"), str):
            errors.append(f"{path}: presentation icon must be text")
        if not isinstance(presentation.get("marker_color_role"), str) or not presentation["marker_color_role"]:
            errors.append(f"{path}: presentation marker_color_role must be non-empty text")
    manifest_piece = manifest_pieces.get(piece_id)
    if not isinstance(manifest_piece, dict):
        errors.append(f"{path}: piece is missing from content manifest")
    else:
        if piece.get("name") != manifest_piece.get("name"):
            errors.append(f"{path}: name differs from content manifest")
        if footprint != manifest_piece.get("size"):
            errors.append(f"{path}: footprint differs from content manifest")
    return piece_id


def validate_enemy(
    path: Path,
    enemy: dict[str, Any],
    room_ids: set[str],
    piece_ids: set[str],
    doctrine_ids: set[str],
    manifest_enemies: dict[str, dict[str, Any]],
    seen: set[str],
    errors: list[str],
) -> str | None:
    for field in sorted(ENEMY_FIELDS - enemy.keys()):
        errors.append(f"{path}: missing required field: {field}")
    enemy_id = enemy.get("id")
    if not isinstance(enemy_id, str) or not SNAKE_CASE.fullmatch(enemy_id):
        errors.append(f"{path}: id must be non-empty snake_case")
        return None
    if enemy_id != path.stem:
        errors.append(f"{path}: id {enemy_id} does not match filename")
    if enemy_id in seen:
        errors.append(f"duplicate runtime enemy id: {enemy_id}")
    seen.add(enemy_id)
    if enemy.get("status") != "active":
        errors.append(f"{path}: runtime enemy status must be active")
    if not is_integer(enemy.get("content_version")) or enemy["content_version"] < 1:
        errors.append(f"{path}: content_version must be a positive integer")
    if not is_integer(enemy.get("health")) or enemy["health"] < 1:
        errors.append(f"{path}: health must be a positive integer")
    if not is_integer(enemy.get("damage")) or enemy["damage"] < 0:
        errors.append(f"{path}: damage must be a non-negative integer")
    if not is_integer(enemy.get("arrival_step")) or enemy["arrival_step"] < 1:
        errors.append(f"{path}: arrival_step must be a positive integer")
    for field in sorted(ENEMY_TEXT_FIELDS):
        value = enemy.get(field)
        if not isinstance(value, str) or not value.strip():
            errors.append(f"{path}: {field} must be non-empty text")
    target_rooms = validate_string_array(path, enemy.get("target_rooms"), "target_rooms", errors)
    for room_id in target_rooms:
        if room_id not in room_ids:
            errors.append(f"{path}: unknown target room: {room_id}")
    if enemy.get("doctrine") not in doctrine_ids:
        errors.append(f"{path}: doctrine is unsupported")
    if enemy.get("counter") not in piece_ids:
        errors.append(f"{path}: counter references an unknown piece")
    counter_families = validate_string_array(path, enemy.get("counter_families"), "counter_families", errors)
    if len(counter_families) < 3:
        errors.append(f"{path}: counter_families must contain at least three options")
    presentation = enemy.get("presentation")
    if not isinstance(presentation, dict):
        errors.append(f"{path}: presentation must be an object")
    else:
        if not isinstance(presentation.get("icon"), str):
            errors.append(f"{path}: presentation icon must be text")
        if not isinstance(presentation.get("marker_color_role"), str) or not presentation["marker_color_role"]:
            errors.append(f"{path}: presentation marker_color_role must be non-empty text")
        radius_scale = presentation.get("radius_scale")
        if not isinstance(radius_scale, (int, float)) or isinstance(radius_scale, bool) or radius_scale <= 0:
            errors.append(f"{path}: presentation radius_scale must be positive")
    manifest_enemy = manifest_enemies.get(enemy_id)
    if not isinstance(manifest_enemy, dict):
        errors.append(f"{path}: enemy is missing from content manifest")
    elif enemy.get("name") != manifest_enemy.get("name"):
        errors.append(f"{path}: name differs from content manifest")
    return enemy_id


def validate_doctrine(
    path: Path,
    doctrine: dict[str, Any],
    enemy_ids: set[str],
    seen: set[str],
    errors: list[str],
) -> str | None:
    for field in sorted(DOCTRINE_FIELDS - doctrine.keys()):
        errors.append(f"{path}: missing required field: {field}")
    doctrine_id = doctrine.get("id")
    if not isinstance(doctrine_id, str) or not SNAKE_CASE.fullmatch(doctrine_id):
        errors.append(f"{path}: id must be non-empty snake_case")
        return None
    if doctrine_id != path.stem:
        errors.append(f"{path}: id {doctrine_id} does not match filename")
    if doctrine_id in seen:
        errors.append(f"duplicate runtime doctrine id: {doctrine_id}")
    seen.add(doctrine_id)
    if doctrine_id not in SUPPORTED_DOCTRINES:
        errors.append(f"{path}: doctrine is not registered for the active slice")
    if doctrine.get("status") != "active":
        errors.append(f"{path}: runtime doctrine status must be active")
    if not is_integer(doctrine.get("content_version")) or doctrine["content_version"] < 1:
        errors.append(f"{path}: content_version must be a positive integer")
    for field in sorted(DOCTRINE_TEXT_FIELDS):
        value = doctrine.get(field)
        if not isinstance(value, str) or not value.strip():
            errors.append(f"{path}: {field} must be non-empty text")
    composition = validate_string_array(path, doctrine.get("composition"), "composition", errors, allow_duplicates=True)
    for enemy_id in composition:
        if enemy_id not in enemy_ids:
            errors.append(f"{path}: composition references unknown enemy: {enemy_id}")
    counter_families = validate_string_array(path, doctrine.get("counter_families"), "counter_families", errors)
    if len(counter_families) < 3:
        errors.append(f"{path}: counter_families must contain at least three options")
    return doctrine_id


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
    parser.add_argument("--pieces", required=True)
    parser.add_argument("--enemies", required=True)
    parser.add_argument("--doctrines", required=True)
    parser.add_argument("--manifest", required=True)
    args = parser.parse_args()

    errors: list[str] = []
    manifest_path = Path(args.manifest)
    manifest = load_json(manifest_path, errors)
    if not isinstance(manifest, dict):
        errors.append(f"{manifest_path}: root must be an object")
        manifest = {}

    manifest_pieces = {
        item.get("id"): item for item in manifest.get("pieces", [])
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
    manifest_enemies = {
        item.get("id"): item for item in manifest.get("enemies", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }
    room_ids = {
        item.get("id") for item in manifest.get("rooms", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }
    enemy_ids = {
        item.get("id") for item in manifest.get("enemies", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }

    seen_doctrines: set[str] = set()
    for path in json_files(Path(args.doctrines), "doctrine", errors):
        doctrine = load_json(path, errors)
        if not isinstance(doctrine, dict):
            errors.append(f"{path}: root must be an object")
            continue
        validate_doctrine(path, doctrine, set(manifest_enemies), seen_doctrines, errors)
    for doctrine_id in sorted(SUPPORTED_DOCTRINES - seen_doctrines):
        errors.append(f"runtime doctrine file missing for active doctrine: {doctrine_id}")
    manifest_assignments = {
        item.get("piece"): {"room": item.get("room"), "effect": item.get("effect")}
        for item in manifest.get("active_slice", {}).get("room_assignments", [])
        if isinstance(item, dict) and isinstance(item.get("piece"), str)
    }

    seen_pieces: set[str] = set()
    runtime_piece_availability: dict[str, str] = {}
    for path in json_files(Path(args.pieces), "piece", errors):
        piece = load_json(path, errors)
        if not isinstance(piece, dict):
            errors.append(f"{path}: root must be an object")
            continue
        piece_id = validate_piece(
            path,
            piece,
            room_ids,
            enemy_ids,
            set(manifest_packs),
            manifest_pieces,
            manifest_assignments,
            seen_pieces,
            errors,
        )
        if piece_id is not None and isinstance(piece.get("availability"), str):
            runtime_piece_availability[piece_id] = piece["availability"]
    for piece_id in sorted(set(manifest_pieces) - seen_pieces):
        errors.append(f"runtime piece file missing for manifest piece: {piece_id}")

    seen_enemies: set[str] = set()
    for path in json_files(Path(args.enemies), "enemy", errors):
        enemy = load_json(path, errors)
        if not isinstance(enemy, dict):
            errors.append(f"{path}: root must be an object")
            continue
        validate_enemy(path, enemy, room_ids, seen_pieces, seen_doctrines, manifest_enemies, seen_enemies, errors)
    for enemy_id in sorted(set(manifest_enemies) - seen_enemies):
        errors.append(f"runtime enemy file missing for manifest enemy: {enemy_id}")

    seen_packs: set[str] = set()
    runtime_pack_families: dict[str, str] = {}
    runtime_packs: dict[str, dict[str, Any]] = {}
    for path in json_files(Path(args.packs), "pack", errors):
        pack = load_json(path, errors)
        if not isinstance(pack, dict):
            errors.append(f"{path}: root must be an object")
            continue
        pack_id, family = validate_pack(
            path, pack, seen_pieces, set(manifest_commanders), manifest_packs, seen_packs, errors
        )
        if pack_id is not None and family is not None:
            runtime_pack_families[pack_id] = family
            runtime_packs[pack_id] = pack
    for pack_id in sorted(set(manifest_packs) - seen_packs):
        errors.append(f"runtime pack file missing for manifest pack: {pack_id}")
    for piece_id, availability in sorted(runtime_piece_availability.items()):
        if availability == "starter":
            continue
        pack = runtime_packs.get(availability)
        if not isinstance(pack, dict) or piece_id not in pack.get("contents", []):
            errors.append(f"runtime piece {piece_id} is not contained by availability pack {availability}")

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
    print(
        "runtime content catalog: PASS "
        f"({len(seen_pieces)} pieces, {len(seen_packs)} packs, "
        f"{len(seen_commanders)} commanders, {len(seen_enemies)} enemies, "
        f"{len(seen_doctrines)} doctrines)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
