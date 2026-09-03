#!/usr/bin/env python3
"""Validate the investment-evaluation vertical without claiming human approval."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


GATE_REQUIREMENTS = {
    "PTK-I1": {"normal_flow_capture", "deterministic_three_wave_run", "phase_save_resume", "accessible_input", "visible_first_plan"},
    "PTK-I2": {"second_keep_manifest", "two_viable_seeded_plans", "teaching_and_combination_scenarios", "distinct_opening_plan", "dual_resolution_evidence"},
    "PTK-I3": {"commander_breadth", "pack_breadth", "balance_matrix", "interaction_and_forecast", "replay_comparison"},
    "PTK-I4": {"enemy_question_breadth", "counter_matrix", "deterministic_fixtures", "battle_controls_and_accessibility", "battle_evidence"},
    "PTK-I5": {"multi_scenario_progression", "recovery_unlock_and_reserve", "consequence_and_new_keep", "migration_and_clean_reset", "failure_forward_result", "terminal_report"},
    "PTK-I6": {"full_verification", "seeded_balance", "package_launch_and_recovery", "input_and_scaling", "release_manifest", "distribution_boundary"},
}
GATE_IDS = [f"PTK-I{index}" for index in range(1, 7)]
BOARD_FIRST_CAPTURES = [
    ("docs/visual_evidence/v0.63.0-board-first-greywatch-1280x720/capture-manifest.json", "gatehouse_lock", {"width": 1280, "height": 720}, False),
    ("docs/visual_evidence/v0.63.0-board-first-ash-ford-1280x720/capture-manifest.json", "ash_ford_crossing", {"width": 1280, "height": 720}, False),
    ("docs/visual_evidence/v0.63.0-board-first-ash-ford-1600x900/capture-manifest.json", "ash_ford_crossing", {"width": 1600, "height": 900}, False),
]


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


def _evidence_exists(root: Path, relative: str) -> bool:
    candidate = Path(relative)
    if candidate.is_absolute() or ".." in candidate.parts:
        return False
    try:
        resolved = (root / candidate).resolve()
        resolved.relative_to(root.resolve())
    except (OSError, ValueError):
        return False
    return resolved.is_file()


def validate_preparation_capture(
    manifest: dict[str, Any], relative: str, build_version: str, scenario_id: str,
    resolution: dict[str, int], root: Path, errors: list[str], setup_only: bool,
) -> None:
    if manifest.get("build_version") != build_version or manifest.get("scenario") != scenario_id:
        errors.append(f"{relative}: board-first capture identity is stale")
    if manifest.get("resolution") != resolution:
        errors.append(f"{relative}: board-first capture resolution must be {resolution['width']}x{resolution['height']}")
    files = manifest.get("files")
    required = {"01_title.png", "02_war_council.png", "03_preparation.png"}
    if setup_only:
        if manifest.get("setup_only") is not True:
            errors.append(f"{relative}: board-first evidence must use the bounded setup-only capture")
        if not isinstance(files, list) or set(files) != required:
            errors.append(f"{relative}: board-first capture must contain exactly title, War Council, and Preparation")
            return
    elif not isinstance(files, list) or not required.union({"04_assault_phase_1.png", "05_recovery_phase_1.png", "06_assault_phase_2.png", "07_recovery_phase_2.png", "08_assault_phase_3.png", "09_terminal_results.png"}).issubset(set(files)):
        errors.append(f"{relative}: wide evidence must contain the complete three-wave flow")
        return
    if manifest.get("human_evidence") is not False or manifest.get("debug_ui") is not False:
        errors.append(f"{relative}: board-first capture must remain automated and debug-free")
    for filename in files:
        if not _evidence_exists(root, str(Path(relative).parent / filename)):
            errors.append(f"{relative}: missing captured image {filename}")


def validate_progress(progress: dict[str, Any], manifest: dict[str, Any], early_access: dict[str, Any], root: Path, errors: list[str]) -> None:
    if progress.get("schema_version") != 1:
        errors.append("investment progress schema_version must be 1")
    if progress.get("build_version") != manifest.get("build_version") or progress.get("build_version") != early_access.get("build_version"):
        errors.append("investment progress build_version must match CI and Early Access manifests")
    complete = progress.get("investment_vertical_complete") is True
    if progress.get("status") != ("implemented" if complete else "in_progress"):
        errors.append("investment progress status does not match completion")

    gates = progress.get("gates")
    if not isinstance(gates, list):
        errors.append("investment gates must be an array")
        return
    if [row.get("id") for row in gates if isinstance(row, dict)] != GATE_IDS:
        errors.append("investment gates must preserve ordered PTK-I1 through PTK-I6")
        return
    saw_planned = False
    for gate in gates:
        gate_id = str(gate.get("id", ""))
        status = gate.get("status")
        if status not in {"implemented", "planned"}:
            errors.append(f"{gate_id} has invalid status")
            continue
        if status == "planned":
            saw_planned = True
            continue
        if saw_planned:
            errors.append(f"{gate_id} cannot be implemented after a planned gate")
        requirements = gate.get("requirements")
        if not isinstance(requirements, list):
            errors.append(f"{gate_id} requirements must be an array")
            continue
        expected = GATE_REQUIREMENTS[gate_id]
        seen: set[str] = set()
        for row in requirements:
            if not isinstance(row, dict):
                errors.append(f"{gate_id} requirement entries must be objects")
                continue
            requirement_id = row.get("id")
            if requirement_id not in expected or requirement_id in seen:
                errors.append(f"invalid or duplicate {gate_id} requirement: {requirement_id!r}")
                continue
            seen.add(str(requirement_id))
            if row.get("status") not in {"automated", "documented"}:
                errors.append(f"{gate_id} requirement {requirement_id} has invalid status")
            evidence = row.get("evidence")
            if not isinstance(evidence, list) or not evidence:
                errors.append(f"{gate_id} requirement {requirement_id} needs evidence")
                continue
            for relative in evidence:
                if not isinstance(relative, str) or not _evidence_exists(root, relative):
                    errors.append(f"{gate_id} requirement {requirement_id} has missing evidence: {relative!r}")
        for missing in sorted(expected - seen):
            errors.append(f"{gate_id} is missing requirement: {missing}")

    first_planned = next((row.get("id") for row in gates if row.get("status") == "planned"), "")
    if progress.get("next_gate") != first_planned:
        errors.append(f"next_gate must be {first_planned!r}")
    if complete and first_planned:
        errors.append("investment vertical cannot be complete while gates remain planned")
    if complete and early_access.get("early_access_ready") is not True:
        errors.append("investment completion requires the Early Access breadth gate")
    if progress.get("human_evidence_required_for_implementation") is not False or progress.get("human_evidence_status") != "pending":
        errors.append("human evidence must remain honestly pending and non-blocking for implementation")
    if progress.get("owner_approval_required_for_distribution") is not True:
        errors.append("owner approval must remain required for distribution")

    plan_signatures: set[str] = set()
    for keep_path in sorted((root / "data" / "keeps").glob("*.json")):
        keep = _load(keep_path, errors)
        plan = keep.get("starter_plan")
        if not isinstance(plan, dict) or len(plan.get("placements", [])) < 2:
            errors.append(f"{keep_path.name} must expose a complete starter_plan")
            continue
        signature = json.dumps({"title": plan.get("title"), "pack_id": plan.get("pack_id"), "placements": plan.get("placements")}, sort_keys=True)
        if signature in plan_signatures:
            errors.append(f"{keep_path.name} duplicates another keep starter plan")
        plan_signatures.add(signature)

    for relative, scenario_id, resolution, setup_only in BOARD_FIRST_CAPTURES:
        capture = _load(root / relative, errors)
        validate_preparation_capture(capture, relative, str(progress.get("build_version", "")), scenario_id, resolution, root, errors, setup_only)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--progress", type=Path, default=Path("content/investment_progress.json"))
    parser.add_argument("--manifest", type=Path, default=Path("tools/ci_manifest.json"))
    parser.add_argument("--early-access", type=Path, default=Path("content/early_access_progress.json"))
    args = parser.parse_args()
    root = Path.cwd()
    errors: list[str] = []
    progress = _load(args.progress, errors)
    manifest = _load(args.manifest, errors)
    early_access = _load(args.early_access, errors)
    validate_progress(progress, manifest, early_access, root, errors)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("PTK investment vertical: PASS (PTK-I1 through PTK-I6 implemented; human evidence pending; owner distribution approval required)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
