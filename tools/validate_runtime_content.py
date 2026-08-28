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
KEEP_FIELDS = {
    "id", "content_version", "status", "name", "short_role", "question", "grid_size",
    "rooms", "connections", "spatial_rule", "recovery_profile", "visual",
}
ROOM_FIELDS = {"name", "floor", "origin", "size", "critical", "role"}
REGION_FIELDS = {"id", "content_version", "status", "name", "need", "route", "consequences"}
REGION_CONSEQUENCE_FIELDS = {
    "id", "settlement_status", "route_status", "minimum_anchor_condition",
    "requires_non_collapse", "next_run_materials", "summary",
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
SCENARIO_FIELDS = {
    "id", "content_version", "status", "name", "short_role", "question", "objective",
    "lesson", "keep_id", "recommended_packs", "starting_doctrine", "doctrines", "wave_plans", "variations",
}
EVENT_FIELDS = {
    "id", "content_version", "status", "title", "short_role", "type", "scenario",
    "trigger", "selection", "setup", "choices", "follow_up",
}
EVENT_CHOICE_FIELDS = {"id", "label", "requirements", "effects", "visible_result"}
EVENT_SELECTION_FIELDS = {"stream", "repeat_policy", "cooldown_waves", "max_occurrences"}
MODIFIER_FIELDS = {
    "id", "content_version", "status", "name", "short_role", "question",
    "unlock_event", "effect", "starting_morale_cost", "limitation",
}
SUPPORTED_FLOORS = {"ground", "upper"}
SUPPORTED_ZONES = {"wall", "courtyard", "keep"}
SUPPORTED_ATTACK_STYLES = {"melee", "ranged", "support", "fortification"}
SUPPORTED_DOCTRINES = {"gate_assault", "distributed_sabotage", "feint_and_flank", "area_pressure", "rolling_breach", "shielded_advance", "smoke_and_signal", "break_the_line"}
SUPPORTED_NON_ENEMY_TARGETS = {"all"} | SUPPORTED_DOCTRINES
SUPPORTED_EVENT_TYPES = {"forecast", "recovery", "scenario_conclusion"}
SUPPORTED_EVENT_PHASES = {"preparation", "recovery", "results"}
SUPPORTED_EVENT_REQUIREMENTS = {"command_points", "recovery_actions", "morale", "materials", "piece_available"}
SUPPORTED_EVENT_REQUIREMENT_OPERATORS = {"gte", "lt"}
SUPPORTED_EVENT_EFFECTS = {
    "spend_command_points", "spend_recovery_action", "add_materials", "add_morale",
    "set_flag", "record_outcome", "unlock_modifier", "repair_room", "assign_piece",
}
EVENT_EFFECT_FIELDS = {
    "spend_command_points": {"amount"},
    "spend_recovery_action": {"amount"},
    "add_materials": {"amount"},
    "add_morale": {"amount"},
    "set_flag": {"flag", "value"},
    "record_outcome": {"tag"},
    "unlock_modifier": {"modifier"},
    "repair_room": {"room"},
    "assign_piece": {"piece", "room"},
}
SUPPORTED_EVENT_REPEAT_POLICIES = {"once_per_run", "repeat_after_cooldown"}
MAX_EVENT_COOLDOWN_WAVES = 3
MAX_EVENT_OCCURRENCES = 3
SUPPORTED_MODIFIER_EFFECTS = {"reveal_wave_composition", "enemy_health_bonus"}
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


def schema_string_set(path: Path, value: Any, field: str, errors: list[str]) -> set[str]:
    if not isinstance(value, list) or any(not isinstance(item, str) for item in value):
        errors.append(f"{path}: {field} must be an array of strings")
        return set()
    if len(value) != len(set(value)):
        errors.append(f"{path}: {field} contains duplicates")
    return set(value)


def validate_event_schema_contract(path: Path, schema: Any, errors: list[str]) -> None:
    if not isinstance(schema, dict):
        errors.append(f"{path}: root must be an object")
        return
    if schema.get("schema_version") != 1:
        errors.append(f"{path}: schema_version must be 1")
    comparisons = (
        ("required_event_fields", schema_string_set(path, schema.get("required_event_fields"), "required_event_fields", errors), EVENT_FIELDS),
        ("required_choice_fields", schema_string_set(path, schema.get("required_choice_fields"), "required_choice_fields", errors), EVENT_CHOICE_FIELDS),
    )
    for label, actual, expected in comparisons:
        if actual != expected:
            errors.append(f"{path}: {label} differ from validator contract")
    selection = schema.get("selection")
    if not isinstance(selection, dict):
        errors.append(f"{path}: selection contract must be an object")
    else:
        if schema_string_set(path, selection.get("required_fields"), "selection.required_fields", errors) != EVENT_SELECTION_FIELDS:
            errors.append(f"{path}: selection required_fields differ from validator contract")
        if schema_string_set(path, selection.get("repeat_policies"), "selection.repeat_policies", errors) != SUPPORTED_EVENT_REPEAT_POLICIES:
            errors.append(f"{path}: selection repeat_policies differ from validator contract")
        if selection.get("maximum_cooldown_waves") != MAX_EVENT_COOLDOWN_WAVES:
            errors.append(f"{path}: selection maximum_cooldown_waves differs from validator contract")
        if selection.get("maximum_occurrences") != MAX_EVENT_OCCURRENCES:
            errors.append(f"{path}: selection maximum_occurrences differs from validator contract")
    requirements = schema.get("requirements")
    if not isinstance(requirements, dict) or set(requirements) != SUPPORTED_EVENT_REQUIREMENTS:
        errors.append(f"{path}: requirement operations differ from validator contract")
    else:
        for requirement_id, operators in requirements.items():
            expected = {"piece_id"} if requirement_id == "piece_available" else SUPPORTED_EVENT_REQUIREMENT_OPERATORS
            if schema_string_set(path, operators, f"requirements.{requirement_id}", errors) != expected:
                errors.append(f"{path}: requirement {requirement_id} operators differ from validator contract")
    effects = schema.get("effects")
    if not isinstance(effects, dict) or set(effects) != SUPPORTED_EVENT_EFFECTS:
        errors.append(f"{path}: effect operations differ from validator contract")
    elif isinstance(effects, dict):
        for operation, expected_fields in EVENT_EFFECT_FIELDS.items():
            if schema_string_set(path, effects.get(operation), f"effects.{operation}", errors) != expected_fields:
                errors.append(f"{path}: effect {operation} fields differ from validator contract")


def validate_id_parity(kind: str, manifest_ids: set[str], runtime_ids: set[str], errors: list[str]) -> None:
    for content_id in sorted(manifest_ids - runtime_ids):
        errors.append(f"runtime {kind} file missing for manifest {kind}: {content_id}")
    for content_id in sorted(runtime_ids - manifest_ids):
        errors.append(f"runtime {kind} is missing from active-slice manifest: {content_id}")


def validate_event_graph(
    runtime_events: dict[str, tuple[str, str]],
    runtime_scenarios: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    for event_id, (event_scenario, follow_up) in runtime_events.items():
        if follow_up and follow_up not in runtime_events:
            errors.append(f"runtime event {event_id} references unknown follow_up: {follow_up}")
        elif follow_up and runtime_events[follow_up][0] != event_scenario:
            errors.append(f"runtime event {event_id} follow_up crosses scenarios: {follow_up}")
        chain = runtime_scenarios.get(event_scenario, {}).get("event_chain", [])
        if event_id not in chain:
            errors.append(f"runtime event {event_id} is missing from scenario {event_scenario} event_chain")

    visited: set[str] = set()
    active: set[str] = set()

    def visit(event_id: str) -> None:
        if event_id in active:
            errors.append(f"runtime event follow_up cycle includes: {event_id}")
            return
        if event_id in visited:
            return
        visited.add(event_id)
        active.add(event_id)
        follow_up = runtime_events.get(event_id, ("", ""))[1]
        if follow_up in runtime_events:
            visit(follow_up)
        active.remove(event_id)

    for event_id in sorted(runtime_events):
        visit(event_id)

    for scenario_id, scenario in runtime_scenarios.items():
        chain = scenario.get("event_chain", [])
        if not isinstance(chain, list):
            errors.append(f"runtime scenario {scenario_id} event_chain must be an array")
            continue
        if len(chain) != len(set(chain)):
            errors.append(f"runtime scenario {scenario_id} event_chain contains duplicates")
        for index, event_id in enumerate(chain):
            if event_id not in runtime_events:
                errors.append(f"runtime scenario {scenario_id} references unknown event: {event_id}")
            elif runtime_events[event_id][0] != scenario_id:
                errors.append(f"runtime scenario {scenario_id} references event for another scenario: {event_id}")
            else:
                expected_follow_up = chain[index + 1] if index + 1 < len(chain) else ""
                if runtime_events[event_id][1] != expected_follow_up:
                    errors.append(f"runtime scenario {scenario_id} event {event_id} follow_up does not match chain order")


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


def validate_keep(
    path: Path,
    keep: dict[str, Any],
    seen: set[str],
    errors: list[str],
) -> tuple[str | None, set[str]]:
    for field in sorted(KEEP_FIELDS - keep.keys()):
        errors.append(f"{path}: missing required field: {field}")
    keep_id = keep.get("id")
    if not isinstance(keep_id, str) or not SNAKE_CASE.fullmatch(keep_id):
        errors.append(f"{path}: id must be non-empty snake_case")
        return None, set()
    if keep_id != path.stem:
        errors.append(f"{path}: id {keep_id} does not match filename")
    if keep_id in seen:
        errors.append(f"duplicate runtime keep id: {keep_id}")
    seen.add(keep_id)
    if keep.get("status") != "active":
        errors.append(f"{path}: runtime keep status must be active")
    if not is_integer(keep.get("content_version")) or keep["content_version"] < 1:
        errors.append(f"{path}: content_version must be a positive integer")
    for field in ("name", "short_role", "question"):
        if not isinstance(keep.get(field), str) or not keep[field].strip():
            errors.append(f"{path}: {field} must be non-empty text")
    if keep.get("grid_size") != [12, 8]:
        errors.append(f"{path}: grid_size must be [12, 8] for the current board")
    rooms = keep.get("rooms")
    room_ids: set[str] = set()
    room_rects: dict[str, tuple[str, int, int, int, int]] = {}
    if not isinstance(rooms, dict) or not rooms:
        errors.append(f"{path}: rooms must be a non-empty object")
        rooms = {}
    for room_id, room in rooms.items():
        if not isinstance(room_id, str) or not SNAKE_CASE.fullmatch(room_id) or not isinstance(room, dict):
            errors.append(f"{path}: malformed room: {room_id}")
            continue
        room_ids.add(room_id)
        for field in sorted(ROOM_FIELDS - room.keys()):
            errors.append(f"{path}: room {room_id} missing required field: {field}")
        if room.get("floor") not in SUPPORTED_FLOORS:
            errors.append(f"{path}: room {room_id} floor is unsupported")
        if not isinstance(room.get("critical"), bool):
            errors.append(f"{path}: room {room_id} critical must be boolean")
        for field in ("name", "role"):
            if not isinstance(room.get(field), str) or not room[field].strip():
                errors.append(f"{path}: room {room_id} {field} must be non-empty text")
        origin = room.get("origin")
        size = room.get("size")
        valid_rect = (
            isinstance(origin, list) and len(origin) == 2 and all(is_integer(value) and value >= 0 for value in origin)
            and isinstance(size, list) and len(size) == 2 and all(is_integer(value) and value >= 1 for value in size)
            and origin[0] + size[0] <= 12 and origin[1] + size[1] <= 8
        )
        if not valid_rect:
            errors.append(f"{path}: room {room_id} must fit the 12x8 grid")
            continue
        rect = (str(room.get("floor")), origin[0], origin[1], size[0], size[1])
        for other_id, other in room_rects.items():
            same_floor = rect[0] == other[0]
            overlaps = rect[1] < other[1] + other[3] and other[1] < rect[1] + rect[3] and rect[2] < other[2] + other[4] and other[2] < rect[2] + rect[4]
            if same_floor and overlaps:
                errors.append(f"{path}: rooms {other_id} and {room_id} overlap")
        room_rects[room_id] = rect
    connections = keep.get("connections")
    seen_connections: set[tuple[str, str]] = set()
    if not isinstance(connections, list) or not connections:
        errors.append(f"{path}: connections must be a non-empty array")
    else:
        for connection in connections:
            if not isinstance(connection, list) or len(connection) != 2 or any(not isinstance(value, str) or value not in room_ids for value in connection) or connection[0] == connection[1]:
                errors.append(f"{path}: invalid room connection")
                continue
            key = tuple(sorted(connection))
            if key in seen_connections:
                errors.append(f"{path}: duplicate room connection: {'|'.join(key)}")
            seen_connections.add(key)
    spatial = keep.get("spatial_rule")
    if not isinstance(spatial, dict) or spatial.get("id") not in {"compact_adjacency", "clear_causeway"}:
        errors.append(f"{path}: invalid spatial_rule")
    else:
        lane_cells = spatial.get("lane_cells")
        reduction = spatial.get("room_damage_reduction")
        if not isinstance(spatial.get("label"), str) or not spatial["label"].strip():
            errors.append(f"{path}: spatial_rule label must be non-empty text")
        if not isinstance(lane_cells, list) or any(not isinstance(cell, list) or len(cell) != 2 or any(not is_integer(value) for value in cell) or not 0 <= cell[0] < 12 or not 0 <= cell[1] < 8 for cell in lane_cells):
            errors.append(f"{path}: spatial_rule lane_cells are invalid")
        if not is_integer(reduction) or not 0 <= reduction <= 3:
            errors.append(f"{path}: spatial_rule room_damage_reduction must be from 0 to 3")
        if spatial.get("id") == "clear_causeway" and (not lane_cells or not is_integer(reduction) or reduction < 1):
            errors.append(f"{path}: clear_causeway needs lane cells and positive room damage reduction")
    recovery = keep.get("recovery_profile")
    if not isinstance(recovery, dict):
        errors.append(f"{path}: recovery_profile must be an object")
    else:
        if not is_integer(recovery.get("room_repair_materials")) or recovery["room_repair_materials"] < 1:
            errors.append(f"{path}: room_repair_materials must be positive")
        if not is_integer(recovery.get("room_repair_condition")) or not 1 <= recovery["room_repair_condition"] <= 100:
            errors.append(f"{path}: room_repair_condition must be from 1 to 100")
        if not isinstance(recovery.get("question"), str) or not recovery["question"].strip():
            errors.append(f"{path}: recovery question must be non-empty text")
    visual = keep.get("visual")
    if not isinstance(visual, dict) or visual.get("terrain") not in {"fort", "river"}:
        errors.append(f"{path}: invalid visual profile")
    elif any(not isinstance(visual.get(field), str) or not visual[field].strip() for field in ("ground_label", "upper_label", "board_label")):
        errors.append(f"{path}: visual labels must be non-empty text")
    return keep_id, room_ids


def validate_region(
    path: Path,
    region: dict[str, Any],
    room_ids: set[str],
    seen: set[str],
    errors: list[str],
) -> str | None:
    for field in sorted(REGION_FIELDS - region.keys()):
        errors.append(f"{path}: missing required field: {field}")
    region_id = region.get("id")
    if not isinstance(region_id, str) or not SNAKE_CASE.fullmatch(region_id):
        errors.append(f"{path}: id must be non-empty snake_case")
        return None
    if region_id != path.stem:
        errors.append(f"{path}: id {region_id} does not match filename")
    if region_id in seen:
        errors.append(f"duplicate runtime region id: {region_id}")
    seen.add(region_id)
    if region.get("status") != "active":
        errors.append(f"{path}: runtime region status must be active")
    if not is_integer(region.get("content_version")) or region["content_version"] < 1:
        errors.append(f"{path}: content_version must be a positive integer")
    for field in ("name", "need"):
        if not isinstance(region.get(field), str) or not region[field].strip():
            errors.append(f"{path}: {field} must be non-empty text")
    route = region.get("route")
    if not isinstance(route, dict):
        errors.append(f"{path}: route must be an object")
    else:
        if not isinstance(route.get("id"), str) or not SNAKE_CASE.fullmatch(route["id"]):
            errors.append(f"{path}: route id must be snake_case")
        if not isinstance(route.get("name"), str) or not route["name"].strip():
            errors.append(f"{path}: route name must be non-empty text")
        anchors = route.get("anchor_rooms")
        if not isinstance(anchors, list) or len(anchors) != 2 or len(set(value for value in anchors if isinstance(value, str))) != 2 or any(not isinstance(value, str) or value not in room_ids for value in anchors):
            errors.append(f"{path}: route anchor_rooms must contain two distinct known rooms")
    consequences = region.get("consequences")
    if not isinstance(consequences, list) or not 1 <= len(consequences) <= 3:
        errors.append(f"{path}: consequences must contain one to three entries")
        consequences = []
    seen_consequences: set[str] = set()
    previous_threshold = 101
    for consequence in consequences:
        if not isinstance(consequence, dict):
            errors.append(f"{path}: consequence must be an object")
            continue
        for field in sorted(REGION_CONSEQUENCE_FIELDS - consequence.keys()):
            errors.append(f"{path}: consequence missing required field: {field}")
        consequence_id = consequence.get("id")
        if not isinstance(consequence_id, str) or not SNAKE_CASE.fullmatch(consequence_id) or consequence_id in seen_consequences:
            errors.append(f"{path}: consequence id must be unique snake_case")
        else:
            seen_consequences.add(consequence_id)
        for field in ("settlement_status", "route_status", "summary"):
            if not isinstance(consequence.get(field), str) or not consequence[field].strip():
                errors.append(f"{path}: consequence {field} must be non-empty text")
        threshold = consequence.get("minimum_anchor_condition")
        if not is_integer(threshold) or not 0 <= threshold <= 100:
            errors.append(f"{path}: consequence minimum_anchor_condition must be from 0 to 100")
        elif threshold >= previous_threshold:
            errors.append(f"{path}: consequences must use descending anchor thresholds")
        else:
            previous_threshold = threshold
        if not isinstance(consequence.get("requires_non_collapse"), bool):
            errors.append(f"{path}: consequence requires_non_collapse must be boolean")
        materials = consequence.get("next_run_materials")
        if not is_integer(materials) or not 0 <= materials <= 5:
            errors.append(f"{path}: consequence next_run_materials must be from 0 to 5")
    if consequences:
        fallback = consequences[-1]
        if isinstance(fallback, dict) and (fallback.get("minimum_anchor_condition") != 0 or fallback.get("requires_non_collapse") is not False):
            errors.append(f"{path}: final consequence must be an unconditional zero-threshold fallback")
    return region_id


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
        for field in ("room_damage_reduction", "piece_damage_reduction"):
            if field in support and (not is_integer(support.get(field)) or support[field] < 0):
                errors.append(f"{path}: support_profile {field} must be a non-negative integer")
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
    support_modifiers: set[str],
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
    if "armor" in enemy:
        armor = enemy.get("armor")
        if not is_integer(armor) or armor < 0:
            errors.append(f"{path}: armor must be a non-negative integer")
        elif armor > 0 and (not isinstance(enemy.get("armor_counter_tag"), str) or not enemy["armor_counter_tag"].strip()):
            errors.append(f"{path}: armored enemies must name a non-empty armor_counter_tag")
    if "disruption_profile" in enemy:
        disruption = enemy.get("disruption_profile")
        if not isinstance(disruption, dict):
            errors.append(f"{path}: disruption_profile must be an object")
        else:
            for field in ("kind", "counter_modifier", "relay_modifier", "forecast_target"):
                if not isinstance(disruption.get(field), str) or not disruption[field].strip():
                    errors.append(f"{path}: disruption_profile {field} must be non-empty text")
            arrival_delta = disruption.get("arrival_step_delta")
            if not is_integer(arrival_delta) or not -2 <= arrival_delta <= 0:
                errors.append(f"{path}: disruption_profile arrival_step_delta must be an integer from -2 to 0")
            if disruption.get("kind") != "signal_smoke":
                errors.append(f"{path}: disruption_profile kind is unsupported")
            for field in ("counter_modifier", "relay_modifier"):
                modifier = disruption.get(field)
                if isinstance(modifier, str) and modifier and modifier not in support_modifiers:
                    errors.append(f"{path}: disruption_profile references unknown support modifier: {modifier}")
    if "target_piece_categories" in enemy:
        validate_string_array(path, enemy.get("target_piece_categories"), "target_piece_categories", errors)
        if enemy.get("target_piece_preference") != "highest_max_health":
            errors.append(f"{path}: target_piece_preference must be highest_max_health")
    if "ignores_protection" in enemy and not isinstance(enemy.get("ignores_protection"), bool):
        errors.append(f"{path}: ignores_protection must be boolean")
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


def validate_scenario(
    path: Path,
    scenario: dict[str, Any],
    room_ids: set[str],
    enemy_ids: set[str],
    doctrine_ids: set[str],
    keep_ids: set[str],
    pack_ids: set[str],
    seen: set[str],
    errors: list[str],
) -> str | None:
    for field in sorted(SCENARIO_FIELDS - scenario.keys()):
        errors.append(f"{path}: missing required field: {field}")
    scenario_id = scenario.get("id")
    if not isinstance(scenario_id, str) or not SNAKE_CASE.fullmatch(scenario_id):
        errors.append(f"{path}: id must be non-empty snake_case")
        return None
    if scenario_id != path.stem:
        errors.append(f"{path}: id {scenario_id} does not match filename")
    if scenario_id in seen:
        errors.append(f"duplicate runtime scenario id: {scenario_id}")
    seen.add(scenario_id)
    if scenario.get("status") != "active":
        errors.append(f"{path}: runtime scenario status must be active")
    if not is_integer(scenario.get("content_version")) or scenario["content_version"] < 1:
        errors.append(f"{path}: content_version must be a positive integer")
    for field in ("name", "short_role", "question", "objective", "lesson", "starting_doctrine"):
        value = scenario.get(field)
        if not isinstance(value, str) or not value.strip():
            errors.append(f"{path}: {field} must be non-empty text")
    if scenario.get("keep_id") not in keep_ids:
        errors.append(f"{path}: keep_id references an unknown keep")
    recommended_packs = scenario.get("recommended_packs")
    if not isinstance(recommended_packs, list) or not 1 <= len(recommended_packs) <= 2:
        errors.append(f"{path}: recommended_packs must contain one or two pack IDs")
    elif len(recommended_packs) != len(set(recommended_packs)) or any(not isinstance(pack_id, str) or pack_id not in pack_ids for pack_id in recommended_packs):
        errors.append(f"{path}: recommended_packs contains duplicate or unknown pack IDs")
    doctrines = scenario.get("doctrines")
    wave_plans = scenario.get("wave_plans")
    if not isinstance(doctrines, list) or len(doctrines) != 3:
        errors.append(f"{path}: doctrines must contain exactly three entries")
        doctrines = []
    if not isinstance(wave_plans, list) or len(wave_plans) != 3:
        errors.append(f"{path}: wave_plans must contain exactly three waves")
        wave_plans = []
    for doctrine_id in doctrines:
        if not isinstance(doctrine_id, str) or doctrine_id not in doctrine_ids:
            errors.append(f"{path}: unknown doctrine reference: {doctrine_id}")
    if scenario.get("starting_doctrine") not in doctrine_ids:
        errors.append(f"{path}: starting_doctrine is unknown")
    for wave in wave_plans:
        if not isinstance(wave, list) or not wave:
            errors.append(f"{path}: each wave plan must contain enemies")
            continue
        for enemy_id in wave:
            if not isinstance(enemy_id, str) or enemy_id not in enemy_ids:
                errors.append(f"{path}: wave plan references unknown enemy: {enemy_id}")
    variations = scenario.get("variations")
    if not isinstance(variations, list) or not variations:
        errors.append(f"{path}: variations must be a non-empty array")
        variations = []
    variation_ids: set[str] = set()
    for variation in variations:
        if not isinstance(variation, dict):
            errors.append(f"{path}: variation must be an object")
            continue
        variation_id = variation.get("id")
        if not isinstance(variation_id, str) or not SNAKE_CASE.fullmatch(variation_id):
            errors.append(f"{path}: variation id must be snake_case")
        elif variation_id in variation_ids:
            errors.append(f"{path}: duplicate variation id: {variation_id}")
        else:
            variation_ids.add(variation_id)
        for field in ("materials", "morale"):
            if not is_integer(variation.get(field)):
                errors.append(f"{path}: variation {field} must be an integer")
        target_room = variation.get("target_room")
        if not isinstance(target_room, str) or (target_room and target_room not in room_ids):
            errors.append(f"{path}: variation target_room is unknown")
    if "standard_bell" not in variation_ids:
        errors.append(f"{path}: standard_bell variation is required")
    return scenario_id


def validate_event(
    path: Path,
    event: dict[str, Any],
    scenario_ids: set[str],
    modifier_ids: set[str],
    seen: set[str],
    errors: list[str],
    room_ids: set[str] | None = None,
    piece_ids: set[str] | None = None,
) -> tuple[str | None, str, str]:
    room_ids = room_ids or set()
    piece_ids = piece_ids or set()
    for field in sorted(EVENT_FIELDS - event.keys()):
        errors.append(f"{path}: missing required field: {field}")
    event_id = event.get("id")
    if not isinstance(event_id, str) or not SNAKE_CASE.fullmatch(event_id):
        errors.append(f"{path}: id must be non-empty snake_case")
        return None, "", ""
    if event_id != path.stem:
        errors.append(f"{path}: id {event_id} does not match filename")
    if event_id in seen:
        errors.append(f"duplicate runtime event id: {event_id}")
    seen.add(event_id)
    if event.get("status") != "active":
        errors.append(f"{path}: runtime event status must be active")
    if not is_integer(event.get("content_version")) or event["content_version"] < 1:
        errors.append(f"{path}: content_version must be a positive integer")
    for field in ("title", "short_role", "setup"):
        if not isinstance(event.get(field), str) or not event[field].strip():
            errors.append(f"{path}: {field} must be non-empty text")
    if event.get("type") not in SUPPORTED_EVENT_TYPES:
        errors.append(f"{path}: unsupported event type")
    scenario_id = event.get("scenario")
    if not isinstance(scenario_id, str) or scenario_id not in scenario_ids:
        errors.append(f"{path}: unknown scenario reference")
        scenario_id = ""
    trigger = event.get("trigger")
    if not isinstance(trigger, dict):
        errors.append(f"{path}: trigger must be an object")
    else:
        if trigger.get("phase") not in SUPPORTED_EVENT_PHASES:
            errors.append(f"{path}: unsupported trigger phase")
        wave = trigger.get("wave")
        if isinstance(wave, list):
            if not wave:
                errors.append(f"{path}: trigger wave array must not be empty")
            if any(not is_integer(value) or not 0 <= value <= 3 for value in wave):
                errors.append(f"{path}: trigger waves must be integers from 0 to 3")
            if len({value for value in wave if is_integer(value)}) != len(wave):
                errors.append(f"{path}: trigger wave array contains a duplicate")
        elif not is_integer(wave) or not 0 <= wave <= 3:
            errors.append(f"{path}: trigger wave must be an integer or array from 0 to 3")
    selection = event.get("selection")
    if not isinstance(selection, dict):
        errors.append(f"{path}: selection must be an object")
    else:
        for field in sorted(EVENT_SELECTION_FIELDS - selection.keys()):
            errors.append(f"{path}: selection is missing required field: {field}")
        for field in sorted(selection.keys() - EVENT_SELECTION_FIELDS):
            errors.append(f"{path}: selection has unsupported field: {field}")
        stream = selection.get("stream")
        if not isinstance(stream, str) or not SNAKE_CASE.fullmatch(stream):
            errors.append(f"{path}: selection stream must be snake_case")
        repeat_policy = selection.get("repeat_policy")
        if repeat_policy not in SUPPORTED_EVENT_REPEAT_POLICIES:
            errors.append(f"{path}: selection repeat_policy is unsupported")
        cooldown_waves = selection.get("cooldown_waves")
        if not is_integer(cooldown_waves) or not 0 <= cooldown_waves <= MAX_EVENT_COOLDOWN_WAVES:
            errors.append(f"{path}: selection cooldown_waves must be an integer from 0 to {MAX_EVENT_COOLDOWN_WAVES}")
        max_occurrences = selection.get("max_occurrences")
        if not is_integer(max_occurrences) or not 1 <= max_occurrences <= MAX_EVENT_OCCURRENCES:
            errors.append(f"{path}: selection max_occurrences must be an integer from 1 to {MAX_EVENT_OCCURRENCES}")
        if repeat_policy == "once_per_run" and (cooldown_waves != 0 or max_occurrences != 1):
            errors.append(f"{path}: selection once_per_run requires cooldown_waves 0 and max_occurrences 1")
        if repeat_policy == "repeat_after_cooldown" and (not is_integer(cooldown_waves) or cooldown_waves < 1):
            errors.append(f"{path}: selection repeat_after_cooldown requires at least one cooldown wave")
        if repeat_policy == "repeat_after_cooldown" and (not is_integer(max_occurrences) or max_occurrences < 2):
            errors.append(f"{path}: selection repeat_after_cooldown requires max_occurrences of at least 2")
    eligibility = event.get("eligibility", {})
    if not isinstance(eligibility, dict):
        errors.append(f"{path}: eligibility must be an object")
    else:
        for eligibility_id, constraint in eligibility.items():
            if eligibility_id == "room_condition":
                if (
                    not isinstance(constraint, dict)
                    or constraint.get("room") not in room_ids
                    or not is_integer(constraint.get("lte"))
                    or not 0 <= constraint["lte"] <= 100
                ):
                    errors.append(f"{path}: room_condition eligibility needs a known room and lte from 0 to 100")
            elif eligibility_id == "next_doctrine":
                if not isinstance(constraint, list) or not constraint:
                    errors.append(f"{path}: next_doctrine eligibility must be a non-empty array")
                elif any(not isinstance(value, str) or value not in SUPPORTED_DOCTRINES for value in constraint):
                    errors.append(f"{path}: next_doctrine eligibility references an unknown doctrine")
            elif eligibility_id == "any_flag":
                if not isinstance(constraint, list) or not constraint:
                    errors.append(f"{path}: any_flag eligibility must be a non-empty array")
                elif any(not isinstance(value, str) or not SNAKE_CASE.fullmatch(value) for value in constraint):
                    errors.append(f"{path}: any_flag eligibility contains an invalid flag")
            elif eligibility_id == "seed_slot":
                if (
                    not isinstance(constraint, dict)
                    or not is_integer(constraint.get("mod"))
                    or not 2 <= constraint["mod"] <= 32
                    or not isinstance(constraint.get("slots"), list)
                    or not constraint["slots"]
                ):
                    errors.append(f"{path}: seed_slot eligibility needs mod 2 to 32 and non-empty slots")
                elif any(not is_integer(value) or not 0 <= value < constraint["mod"] for value in constraint["slots"]):
                    errors.append(f"{path}: seed_slot eligibility contains an out-of-range slot")
            else:
                errors.append(f"{path}: unsupported eligibility: {eligibility_id}")
    choices = event.get("choices")
    choice_ids: set[str] = set()
    if not isinstance(choices, list) or not choices:
        errors.append(f"{path}: choices must be a non-empty array")
        choices = []
    for choice in choices:
        if not isinstance(choice, dict):
            errors.append(f"{path}: choice must be an object")
            continue
        choice_id = choice.get("id")
        if not isinstance(choice_id, str) or not SNAKE_CASE.fullmatch(choice_id):
            errors.append(f"{path}: choice id must be snake_case")
            choice_id = "invalid"
        elif choice_id in choice_ids:
            errors.append(f"{path}: duplicate choice id: {choice_id}")
        choice_ids.add(choice_id)
        for field in sorted(EVENT_CHOICE_FIELDS - choice.keys()):
            errors.append(f"{path}: choice {choice_id} is missing required field: {field}")
        for field in ("label", "visible_result"):
            if not isinstance(choice.get(field), str) or not choice[field].strip():
                errors.append(f"{path}: choice {choice_id} {field} must be non-empty text")
        requirements = choice.get("requirements")
        if not isinstance(requirements, dict):
            errors.append(f"{path}: choice {choice_id} requirements must be an object")
            requirements = {}
        for requirement_id, constraint in requirements.items():
            if requirement_id not in SUPPORTED_EVENT_REQUIREMENTS:
                errors.append(f"{path}: choice {choice_id} has unsupported requirement: {requirement_id}")
                continue
            if requirement_id == "piece_available":
                if not isinstance(constraint, str) or constraint not in piece_ids:
                    errors.append(f"{path}: choice {choice_id} piece_available must reference a known piece")
                continue
            if not isinstance(constraint, dict) or len(constraint) != 1:
                errors.append(f"{path}: choice {choice_id} requirement {requirement_id} must contain one constraint")
                continue
            operator, value = next(iter(constraint.items()))
            if operator not in SUPPORTED_EVENT_REQUIREMENT_OPERATORS or not is_integer(value):
                errors.append(f"{path}: choice {choice_id} requirement {requirement_id} has invalid constraint")
            elif value < 0:
                errors.append(f"{path}: choice {choice_id} requirement {requirement_id} must use a non-negative integer")
        effects = choice.get("effects")
        if not isinstance(effects, list) or not effects:
            errors.append(f"{path}: choice {choice_id} effects must be a non-empty array")
            effects = []
        for effect in effects:
            if not isinstance(effect, dict):
                errors.append(f"{path}: choice {choice_id} effect must be an object")
                continue
            operation = effect.get("op")
            if operation not in SUPPORTED_EVENT_EFFECTS:
                errors.append(f"{path}: choice {choice_id} has unsupported effect: {operation}")
                continue
            expected_fields = EVENT_EFFECT_FIELDS[operation]
            payload_fields = set(effect) - {"op"}
            for field in sorted(expected_fields - payload_fields):
                errors.append(f"{path}: choice {choice_id} effect {operation} is missing required field: {field}")
            for field in sorted(payload_fields - expected_fields):
                errors.append(f"{path}: choice {choice_id} effect {operation} has unsupported field: {field}")
            if operation in {"spend_command_points", "spend_recovery_action", "add_materials", "add_morale"}:
                if not is_integer(effect.get("amount")) or effect["amount"] <= 0:
                    errors.append(f"{path}: choice {choice_id} effect {operation} needs a positive integer amount")
            elif operation == "set_flag":
                if not isinstance(effect.get("flag"), str) or not SNAKE_CASE.fullmatch(effect["flag"]):
                    errors.append(f"{path}: choice {choice_id} set_flag needs a snake_case flag")
                if not isinstance(effect.get("value"), bool):
                    errors.append(f"{path}: choice {choice_id} set_flag needs a boolean value")
            elif operation == "record_outcome":
                if not isinstance(effect.get("tag"), str) or not SNAKE_CASE.fullmatch(effect["tag"]):
                    errors.append(f"{path}: choice {choice_id} record_outcome needs a snake_case tag")
            elif operation == "unlock_modifier":
                if not isinstance(effect.get("modifier"), str) or effect["modifier"] not in modifier_ids:
                    errors.append(f"{path}: choice {choice_id} references unknown modifier")
            elif operation == "repair_room":
                if not isinstance(effect.get("room"), str) or effect["room"] not in room_ids:
                    errors.append(f"{path}: choice {choice_id} repair_room references unknown room")
            elif operation == "assign_piece":
                if not isinstance(effect.get("piece"), str) or effect["piece"] not in piece_ids:
                    errors.append(f"{path}: choice {choice_id} assign_piece references unknown piece")
                if not isinstance(effect.get("room"), str) or effect["room"] not in room_ids:
                    errors.append(f"{path}: choice {choice_id} assign_piece references unknown room")
        if len(effects) > 1 and any(isinstance(effect, dict) and effect.get("op") in {"repair_room", "assign_piece"} for effect in effects):
            errors.append(f"{path}: choice {choice_id} authoritative recovery effects must be the only effect")
        flags = choice.get("flags", {})
        if not isinstance(flags, dict):
            errors.append(f"{path}: choice {choice_id} flags must be an object")
        else:
            for flag_id, value in flags.items():
                if not isinstance(flag_id, str) or not SNAKE_CASE.fullmatch(flag_id) or not isinstance(value, bool):
                    errors.append(f"{path}: choice {choice_id} flag {flag_id} must be a stable boolean")
    commander_variants = event.get("commander_variants", {})
    if not isinstance(commander_variants, dict):
        errors.append(f"{path}: commander_variants must be an object")
    else:
        for commander_id, variant in commander_variants.items():
            if (
                commander_id not in {"castellan", "warden"}
                or not isinstance(variant, dict)
                or not isinstance(variant.get("setup"), str)
                or not variant["setup"].strip()
                or not isinstance(variant.get("choice_labels", {}), dict)
            ):
                errors.append(f"{path}: commander variant {commander_id} is malformed")
                continue
            for variant_choice_id, label in variant.get("choice_labels", {}).items():
                if variant_choice_id not in choice_ids or not isinstance(label, str) or not label.strip():
                    errors.append(f"{path}: commander variant {commander_id} references an invalid choice label")
    follow_up = event.get("follow_up")
    if not isinstance(follow_up, str) or (follow_up and not SNAKE_CASE.fullmatch(follow_up)):
        errors.append(f"{path}: follow_up must be empty or snake_case")
        follow_up = ""
    if follow_up == event_id:
        errors.append(f"{path}: event cannot follow itself")
    return event_id, scenario_id, follow_up


def validate_modifier(
    path: Path,
    modifier: dict[str, Any],
    event_ids: set[str],
    seen: set[str],
    errors: list[str],
) -> str | None:
    for field in sorted(MODIFIER_FIELDS - modifier.keys()):
        errors.append(f"{path}: missing required field: {field}")
    modifier_id = modifier.get("id")
    if not isinstance(modifier_id, str) or not SNAKE_CASE.fullmatch(modifier_id):
        errors.append(f"{path}: id must be non-empty snake_case")
        return None
    if modifier_id != path.stem:
        errors.append(f"{path}: id {modifier_id} does not match filename")
    if modifier_id in seen:
        errors.append(f"duplicate runtime modifier id: {modifier_id}")
    seen.add(modifier_id)
    if modifier.get("status") != "active":
        errors.append(f"{path}: runtime modifier status must be active")
    if not is_integer(modifier.get("content_version")) or modifier["content_version"] < 1:
        errors.append(f"{path}: content_version must be a positive integer")
    cost = modifier.get("starting_morale_cost")
    if not is_integer(cost) or cost < 0:
        errors.append(f"{path}: starting_morale_cost must be a non-negative integer")
    for field in ("name", "short_role", "question", "unlock_event", "effect", "limitation"):
        if not isinstance(modifier.get(field), str) or not modifier[field].strip():
            errors.append(f"{path}: {field} must be non-empty text")
    if modifier.get("unlock_event") not in event_ids:
        errors.append(f"{path}: unknown unlock_event reference")
    if modifier.get("effect") not in SUPPORTED_MODIFIER_EFFECTS:
        errors.append(f"{path}: unsupported modifier effect")
    if modifier.get("effect") == "enemy_health_bonus":
        health_bonus = modifier.get("enemy_health_bonus")
        if not is_integer(health_bonus) or not 1 <= health_bonus <= 8:
            errors.append(f"{path}: enemy_health_bonus must be an integer from 1 to 8")
    elif "enemy_health_bonus" in modifier:
        errors.append(f"{path}: enemy_health_bonus is only valid for the enemy_health_bonus effect")
    return modifier_id


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
    parser.add_argument("--keeps", required=True)
    parser.add_argument("--regions", required=True)
    parser.add_argument("--packs", required=True)
    parser.add_argument("--commanders", required=True)
    parser.add_argument("--pieces", required=True)
    parser.add_argument("--enemies", required=True)
    parser.add_argument("--doctrines", required=True)
    parser.add_argument("--scenarios", required=True)
    parser.add_argument("--events", required=True)
    parser.add_argument("--modifiers", required=True)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--event-schema")
    args = parser.parse_args()

    errors: list[str] = []
    manifest_path = Path(args.manifest)
    manifest = load_json(manifest_path, errors)
    if not isinstance(manifest, dict):
        errors.append(f"{manifest_path}: root must be an object")
        manifest = {}
    event_schema_path = Path(args.event_schema) if args.event_schema else manifest_path.with_name("event_schema.json")
    event_schema = load_json(event_schema_path, errors)
    validate_event_schema_contract(event_schema_path, event_schema, errors)

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
    manifest_room_ids = {
        item.get("id") for item in manifest.get("rooms", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }
    enemy_ids = {
        item.get("id") for item in manifest.get("enemies", [])
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }

    manifest_keep_values = manifest.get("active_slice", {}).get("keep_ids")
    if not isinstance(manifest_keep_values, list) or any(not isinstance(value, str) for value in manifest_keep_values):
        errors.append(f"{manifest_path}: active_slice.keep_ids must be an array of keep IDs")
        manifest_keep_values = []
    manifest_keep_ids = set(manifest_keep_values)
    if len(manifest_keep_ids) != len(manifest_keep_values):
        errors.append(f"{manifest_path}: active_slice.keep_ids contains duplicates")
    seen_keeps: set[str] = set()
    runtime_keep_rooms: dict[str, set[str]] = {}
    room_ids: set[str] = set()
    for path in json_files(Path(args.keeps), "keep", errors):
        keep = load_json(path, errors)
        if not isinstance(keep, dict):
            errors.append(f"{path}: root must be an object")
            continue
        keep_id, keep_room_ids = validate_keep(path, keep, seen_keeps, errors)
        if keep_id is not None:
            runtime_keep_rooms[keep_id] = keep_room_ids
            room_ids.update(keep_room_ids)
    validate_id_parity("keep", manifest_keep_ids, seen_keeps, errors)
    if room_ids != manifest_room_ids:
        errors.append(f"{manifest_path}: room IDs differ from runtime keep room IDs")

    manifest_region_values = manifest.get("active_slice", {}).get("region_ids")
    if not isinstance(manifest_region_values, list) or any(not isinstance(value, str) for value in manifest_region_values):
        errors.append(f"{manifest_path}: active_slice.region_ids must be an array of region IDs")
        manifest_region_values = []
    manifest_region_ids = set(manifest_region_values)
    seen_regions: set[str] = set()
    for path in json_files(Path(args.regions), "region", errors):
        region = load_json(path, errors)
        if not isinstance(region, dict):
            errors.append(f"{path}: root must be an object")
            continue
        validate_region(path, region, room_ids, seen_regions, errors)
    validate_id_parity("region", manifest_region_ids, seen_regions, errors)

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
    support_modifiers: set[str] = set()
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
        support_profile = piece.get("support_profile")
        if isinstance(support_profile, dict) and isinstance(support_profile.get("response_modifier"), str):
            support_modifiers.add(support_profile["response_modifier"])
    for piece_id in sorted(set(manifest_pieces) - seen_pieces):
        errors.append(f"runtime piece file missing for manifest piece: {piece_id}")

    seen_enemies: set[str] = set()
    for path in json_files(Path(args.enemies), "enemy", errors):
        enemy = load_json(path, errors)
        if not isinstance(enemy, dict):
            errors.append(f"{path}: root must be an object")
            continue
        validate_enemy(path, enemy, room_ids, seen_pieces, seen_doctrines, support_modifiers, manifest_enemies, seen_enemies, errors)
    for enemy_id in sorted(set(manifest_enemies) - seen_enemies):
        errors.append(f"runtime enemy file missing for manifest enemy: {enemy_id}")

    manifest_scenario_ids = {
        value for value in manifest.get("active_slice", {}).get("scenario_ids", [])
        if isinstance(value, str)
    }
    seen_scenarios: set[str] = set()
    runtime_scenarios: dict[str, dict[str, Any]] = {}
    for path in json_files(Path(args.scenarios), "scenario", errors):
        scenario = load_json(path, errors)
        if not isinstance(scenario, dict):
            errors.append(f"{path}: root must be an object")
            continue
        scenario_keep_id = scenario.get("keep_id") if isinstance(scenario.get("keep_id"), str) else ""
        scenario_room_ids = runtime_keep_rooms.get(scenario_keep_id, room_ids)
        scenario_id = validate_scenario(path, scenario, scenario_room_ids, seen_enemies, seen_doctrines, seen_keeps, set(manifest_packs), seen_scenarios, errors)
        if scenario_id is not None:
            runtime_scenarios[scenario_id] = scenario
    for scenario_id in sorted(manifest_scenario_ids - seen_scenarios):
        errors.append(f"runtime scenario file missing for active scenario: {scenario_id}")
    for scenario_id in sorted(seen_scenarios - manifest_scenario_ids):
        errors.append(f"runtime scenario is missing from active-slice manifest: {scenario_id}")

    manifest_event_values = manifest.get("active_slice", {}).get("event_ids")
    if not isinstance(manifest_event_values, list) or any(not isinstance(value, str) for value in manifest_event_values):
        errors.append(f"{manifest_path}: active_slice.event_ids must be an array of event IDs")
        manifest_event_values = []
    manifest_event_ids = set(manifest_event_values)
    if len(manifest_event_ids) != len(manifest_event_values):
        errors.append(f"{manifest_path}: active_slice.event_ids contains duplicates")
    manifest_modifier_ids = {
        value for value in manifest.get("p9_run_progression", {}).get("modifiers", [])
        if isinstance(value, str)
    }
    seen_modifiers: set[str] = set()
    runtime_modifiers: dict[str, dict[str, Any]] = {}
    for path in json_files(Path(args.modifiers), "modifier", errors):
        modifier = load_json(path, errors)
        if not isinstance(modifier, dict):
            errors.append(f"{path}: root must be an object")
            continue
        modifier_id = validate_modifier(path, modifier, manifest_event_ids, seen_modifiers, errors)
        if modifier_id is not None:
            runtime_modifiers[modifier_id] = modifier
    for modifier_id in sorted(manifest_modifier_ids - seen_modifiers):
        errors.append(f"runtime modifier file missing for active modifier: {modifier_id}")
    for modifier_id in sorted(seen_modifiers - manifest_modifier_ids):
        errors.append(f"runtime modifier is missing from P9 manifest: {modifier_id}")

    seen_events: set[str] = set()
    runtime_events: dict[str, tuple[str, str]] = {}
    for path in json_files(Path(args.events), "event", errors):
        event = load_json(path, errors)
        if not isinstance(event, dict):
            errors.append(f"{path}: root must be an object")
            continue
        event_id, event_scenario, follow_up = validate_event(path, event, seen_scenarios, seen_modifiers, seen_events, errors, room_ids, seen_pieces)
        if event_id is not None:
            runtime_events[event_id] = (event_scenario, follow_up)
    validate_id_parity("event", manifest_event_ids, seen_events, errors)
    validate_event_graph(runtime_events, runtime_scenarios, errors)

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
        f"({len(seen_keeps)} keeps, {len(seen_regions)} regions, {len(seen_pieces)} pieces, {len(seen_packs)} packs, "
        f"{len(seen_commanders)} commanders, {len(seen_enemies)} enemies, "
        f"{len(seen_doctrines)} doctrines, {len(seen_scenarios)} scenarios, "
        f"{len(seen_events)} events, {len(seen_modifiers)} modifiers)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
