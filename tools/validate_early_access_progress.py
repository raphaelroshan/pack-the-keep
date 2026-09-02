#!/usr/bin/env python3
"""Validate Early Access roadmap progress without granting distribution approval."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


FLOOR = {
    "keeps": 3,
    "commanders": 4,
    "packs_min": 15,
    "packs_max": 18,
    "pieces_min": 24,
    "pieces_max": 30,
    "enemies_min": 12,
    "enemies_max": 14,
    "scenarios_min": 20,
    "scenarios_max": 24,
    "events_min": 14,
    "events_max": 18,
    "viable_commander_keep_starts": 12,
}
MILESTONE_REQUIREMENTS = {
    "PTK-EA-1": {
        "distinct_room_graph", "two_approach_patterns", "recovery_rule",
        "two_viable_seeded_plans", "contextual_briefing", "complete_multi_wave_journey",
        "responsive_input_accessibility", "save_and_replay", "presentation_evidence", "asset_provenance",
    },
    "PTK-EA-2": {
        "ash_ford_scenario_set", "distinct_geometry", "two_approach_patterns",
        "recovery_rule", "two_viable_seeded_plans", "complete_flow", "presentation_evidence",
    },
    "PTK-EA-3": {
        "twinwatch_scenario_set", "fourth_commander", "distinct_geometry",
        "two_viable_seeded_plans", "complete_flow", "save_and_replay", "presentation_evidence",
    },
    "PTK-EA-4": {
        "two_enemy_families", "explicit_counters", "telegraphs", "recovery_consequences",
        "save_and_replay", "visual_identity",
    },
    "PTK-EA-5": {
        "event_floor", "scenario_floor", "bounded_variation", "mastery_comparison", "event_persistence",
    },
    "PTK-EA-6": {
        "breadth_floor", "accessibility", "controller", "performance", "persistence",
        "packaging", "known_limitations", "distribution_boundary",
    },
}
MILESTONE_IDS = [f"PTK-EA-{index}" for index in range(1, 7)]


def _load(path: Path, errors: list[str]) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{path}: cannot read JSON: {exc}")
        return {}
    if not isinstance(value, dict):
        errors.append(f"{path}: root must be an object")
        return {}
    return value


def _exists(root: Path, relative: str) -> bool:
    candidate = Path(relative)
    if candidate.is_absolute() or ".." in candidate.parts:
        return False
    try:
        resolved = (root / candidate).resolve()
        resolved.relative_to(root.resolve())
    except (OSError, ValueError):
        return False
    return resolved.is_file()


def _catalog_count(root: Path, directory: str) -> int:
    return len(list((root / "data" / directory).glob("*.json")))


def validate_progress(progress: dict[str, Any], manifest: dict[str, Any], root: Path, errors: list[str]) -> None:
    if progress.get("schema_version") != 1:
        errors.append("Early Access progress schema_version must be 1")
    if progress.get("build_version") != manifest.get("build_version"):
        errors.append("Early Access progress build_version must match CI manifest")
    ready = progress.get("early_access_ready") is True
    expected_status = "candidate" if ready else "in_progress"
    if progress.get("status") != expected_status:
        errors.append(f"Early Access status must be {expected_status} for its readiness state")
    if progress.get("breadth_floor") != FLOOR:
        errors.append("Early Access breadth floor must match the approved product contract")

    expected_inventory = {
        "keeps": _catalog_count(root, "keeps"),
        "commanders": _catalog_count(root, "commanders"),
        "packs": _catalog_count(root, "packs"),
        "pieces": _catalog_count(root, "pieces"),
        "enemies": _catalog_count(root, "enemies"),
        "doctrines": _catalog_count(root, "doctrines"),
        "scenarios": _catalog_count(root, "scenarios"),
        "events": _catalog_count(root, "events"),
    }
    expected_inventory["commander_keep_starts"] = expected_inventory["keeps"] * expected_inventory["commanders"]
    if progress.get("current_inventory") != expected_inventory:
        errors.append(f"Early Access inventory is stale: expected {expected_inventory}")

    milestones = progress.get("milestones")
    if not isinstance(milestones, list):
        errors.append("Early Access milestones must be an array")
        return
    milestone_ids = [row.get("id") for row in milestones if isinstance(row, dict)]
    if milestone_ids != MILESTONE_IDS:
        errors.append("Early Access milestones must preserve ordered PTK-EA-1 through PTK-EA-6")
        return
    saw_planned = False
    for milestone in milestones:
        milestone_id = milestone.get("id")
        milestone_status = milestone.get("status")
        if milestone_status not in {"implemented", "planned"}:
            errors.append(f"{milestone_id} has invalid status")
            continue
        if milestone_status == "planned":
            saw_planned = True
            continue
        if saw_planned:
            errors.append(f"{milestone_id} cannot be implemented after a planned milestone")
        requirements = milestone.get("requirements")
        if not isinstance(requirements, list):
            errors.append(f"{milestone_id} requirements must be an array")
            continue
        seen: set[str] = set()
        expected_requirements = MILESTONE_REQUIREMENTS.get(str(milestone_id), set())
        for row in requirements:
            if not isinstance(row, dict):
                errors.append(f"{milestone_id} requirement entries must be objects")
                continue
            requirement_id = row.get("id")
            if requirement_id not in expected_requirements or requirement_id in seen:
                errors.append(f"invalid or duplicate {milestone_id} requirement: {requirement_id!r}")
                continue
            seen.add(str(requirement_id))
            if row.get("status") not in {"automated", "documented"}:
                errors.append(f"{milestone_id} requirement {requirement_id} has invalid status")
            evidence = row.get("evidence")
            if not isinstance(evidence, list) or not evidence:
                errors.append(f"{milestone_id} requirement {requirement_id} needs evidence")
                continue
            for relative in evidence:
                if not isinstance(relative, str) or not _exists(root, relative):
                    errors.append(f"{milestone_id} requirement {requirement_id} has missing evidence: {relative!r}")
        for missing in sorted(expected_requirements - seen):
            errors.append(f"{milestone_id} is missing requirement: {missing}")
    first_planned = next((row.get("id") for row in milestones if row.get("status") == "planned"), "")
    if progress.get("next_milestone") != first_planned:
        errors.append(f"next_milestone must be {first_planned!r}")
    if ready and first_planned:
        errors.append("Early Access cannot be ready while milestones remain planned")
    if not ready and not first_planned:
        errors.append("Early Access must be ready when every milestone is implemented")
    if ready:
        inventory = progress.get("current_inventory", {})
        for field in ["keeps", "commanders"]:
            if int(inventory.get(field, 0)) < FLOOR[field]:
                errors.append(f"Early Access inventory is below the {field} floor")
        if int(inventory.get("commander_keep_starts", 0)) < FLOOR["viable_commander_keep_starts"]:
            errors.append("Early Access inventory is below the viable commander/keep start floor")
        for field in ["packs", "pieces", "enemies", "scenarios", "events"]:
            if not FLOOR[f"{field}_min"] <= int(inventory.get(field, 0)) <= FLOOR[f"{field}_max"]:
                errors.append(f"Early Access inventory {field} is outside its approved range")
        scenarios_per_keep: dict[str, int] = {}
        for path in (root / "data" / "scenarios").glob("*.json"):
            scenario = _load(path, errors)
            keep_id = scenario.get("keep_id")
            if isinstance(keep_id, str):
                scenarios_per_keep[keep_id] = scenarios_per_keep.get(keep_id, 0) + 1
        for keep_id in ["greywatch_keep", "ash_ford_redoubt", "twinwatch_bastion"]:
            if scenarios_per_keep.get(keep_id, 0) < 6:
                errors.append(f"{keep_id} must have at least six scenarios")
    if progress.get("human_evidence_required_for_implementation") is not False:
        errors.append("human evidence must not block implementation")
    if progress.get("owner_approval_required_for_distribution") is not True:
        errors.append("owner approval must remain required for distribution")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--progress", type=Path, default=Path("content/early_access_progress.json"))
    parser.add_argument("--manifest", type=Path, default=Path("tools/ci_manifest.json"))
    args = parser.parse_args()
    root = Path.cwd()
    errors: list[str] = []
    progress = _load(args.progress, errors)
    manifest = _load(args.manifest, errors)
    validate_progress(progress, manifest, root, errors)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    inventory = progress["current_inventory"]
    print(
        "PTK Early Access roadmap: PASS "
        f"({inventory['keeps']} keeps, {inventory['commanders']} commanders, "
        f"{inventory['packs']} packs, {inventory['pieces']} pieces, "
        f"{inventory['enemies']} enemies, {inventory['scenarios']} scenarios, "
        f"{inventory['events']} events; readiness={progress['early_access_ready']})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
