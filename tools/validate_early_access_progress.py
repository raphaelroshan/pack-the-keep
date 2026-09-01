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
EA1_REQUIREMENTS = {
    "distinct_room_graph",
    "two_approach_patterns",
    "recovery_rule",
    "two_viable_seeded_plans",
    "contextual_briefing",
    "complete_multi_wave_journey",
    "responsive_input_accessibility",
    "save_and_replay",
    "presentation_evidence",
    "asset_provenance",
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
    if progress.get("status") != "in_progress" or progress.get("early_access_ready") is not False:
        errors.append("Early Access must remain in_progress and not ready until every breadth floor and milestone passes")
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
    ea1 = milestones[0]
    if ea1.get("status") != "implemented" or ea1.get("keep_id") != "greywatch_keep":
        errors.append("PTK-EA-1 must identify the implemented Greywatch anchor")
    requirements = ea1.get("requirements")
    if not isinstance(requirements, list):
        errors.append("PTK-EA-1 requirements must be an array")
    else:
        seen: set[str] = set()
        for row in requirements:
            if not isinstance(row, dict):
                errors.append("PTK-EA-1 requirement entries must be objects")
                continue
            requirement_id = row.get("id")
            if requirement_id not in EA1_REQUIREMENTS or requirement_id in seen:
                errors.append(f"invalid or duplicate PTK-EA-1 requirement: {requirement_id!r}")
                continue
            seen.add(str(requirement_id))
            if row.get("status") not in {"automated", "documented"}:
                errors.append(f"PTK-EA-1 requirement {requirement_id} has invalid status")
            evidence = row.get("evidence")
            if not isinstance(evidence, list) or not evidence:
                errors.append(f"PTK-EA-1 requirement {requirement_id} needs evidence")
                continue
            for relative in evidence:
                if not isinstance(relative, str) or not _exists(root, relative):
                    errors.append(f"PTK-EA-1 requirement {requirement_id} has missing evidence: {relative!r}")
        for missing in sorted(EA1_REQUIREMENTS - seen):
            errors.append(f"PTK-EA-1 is missing requirement: {missing}")
    for milestone in milestones[1:]:
        if milestone.get("status") != "planned":
            errors.append(f"{milestone.get('id')} must remain planned until its own acceptance gate lands")
    if progress.get("next_milestone") != "PTK-EA-2":
        errors.append("PTK-EA-2 must be the next milestone after the Greywatch anchor")
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
        "PTK-EA-1 Greywatch anchor: PASS "
        f"({inventory['keeps']} keeps, {inventory['commanders']} commanders, "
        f"{inventory['packs']} packs, {inventory['pieces']} pieces, "
        f"{inventory['enemies']} enemies, {inventory['scenarios']} scenarios, "
        f"{inventory['events']} events; PTK-EA-2 next)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
