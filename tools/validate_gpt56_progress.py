#!/usr/bin/env python3
"""Validate GPT56 packet completion without converting automation into human evidence."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


PACKET_REQUIREMENTS = {
    "PTK-GPT56-1": {"greywatch_normal_flow", "two_seeded_openings", "visible_plan_rationale", "preparation_first_viewport", "deterministic_three_wave_replay", "all_phase_save_resume", "accessible_input_motion", "greywatch_1600_capture", "authoritative_state"},
    "PTK-GPT56-2": {"distinct_keep_geometry", "teaching_and_combined_scenarios", "recovery_rule_and_signature_pack", "two_seeded_openings", "keep_comparison_and_geometry_matrix", "placement_counter_and_failure_forward", "migration_controller_scaling", "second_keep_screenshots"},
    "PTK-GPT56-3": {"commander_lens", "four_high_signal_packs", "two_enemy_families", "commander_keep_matrix", "pack_interactions_and_teaching", "deterministic_balance_no_dominance", "doctrine_pressure_replay_report"},
    "PTK-GPT56-4": {"campaign_content_floor", "progression_and_recovery", "reserve_open_decisions", "bounded_variation", "failure_forward_consequences", "terminal_campaign_memory"},
    "PTK-GPT56-5": {"clean_install_and_migration", "backup_recovery_and_rollback", "controller_and_scaling", "audio_and_reduced_motion", "offline_operation", "package_provenance", "known_limitations"},
}
PACKET_IDS = list(PACKET_REQUIREMENTS)


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
    return resolved.is_file() or resolved.is_dir()


def _catalog(root: Path, folder: str, errors: list[str]) -> dict[str, dict[str, Any]]:
    values: dict[str, dict[str, Any]] = {}
    for path in sorted((root / "data" / folder).glob("*.json")):
        value = _load(path, errors)
        item_id = value.get("id")
        if isinstance(item_id, str):
            values[item_id] = value
    return values


def _validate_capture(root: Path, relative: str, scenario: str, build_version: str, errors: list[str], intervention: bool = False) -> None:
    manifest = _load(root / relative, errors)
    if manifest.get("build_version") != build_version or manifest.get("scenario") != scenario:
        errors.append(f"{relative}: capture identity must match {build_version}/{scenario}")
    if manifest.get("resolution") != {"width": 1600, "height": 900}:
        errors.append(f"{relative}: capture must be 1600x900")
    files = manifest.get("files")
    required = {"01_title.png", "02_war_council.png", "03_preparation.png", "04_assault_phase_1.png", "05_recovery_phase_1.png", "06_assault_phase_2.png", "07_recovery_phase_2.png", "08_assault_phase_3.png", "09_terminal_results.png"}
    if not isinstance(files, list) or not required.issubset(set(files)):
        errors.append(f"{relative}: capture is missing a complete three-wave sequence")
    if intervention and (manifest.get("intervention_captured") is not True or "04b_emergency_intervention.png" not in set(files or [])):
        errors.append(f"{relative}: Greywatch capture must include the emergency intervention")
    for filename in files if isinstance(files, list) else []:
        if not _evidence_exists(root, str(Path(relative).parent / filename)):
            errors.append(f"{relative}: missing captured image {filename}")
    if manifest.get("human_evidence") is not False or manifest.get("debug_ui") is not False:
        errors.append(f"{relative}: automated evidence must remain non-human and debug-free")


def validate_progress(
    progress: dict[str, Any],
    manifests: list[dict[str, Any]],
    root: Path,
    errors: list[str],
    catalogs: dict[str, dict[str, dict[str, Any]]] | None = None,
    validate_captures: bool = True,
) -> None:
    if progress.get("schema_version") != 1:
        errors.append("GPT56 progress schema_version must be 1")
    build_versions = {str(value.get("build_version", value.get("framework_version", ""))) for value in manifests}
    if build_versions != {progress.get("build_version")}:
        errors.append("GPT56 build_version must match CI, framework, investment, Early Access, and K8 manifests")
    if progress.get("status") != "implemented" or progress.get("all_packets_complete") is not True:
        errors.append("GPT56 packets must be explicitly implemented and complete")
    packets = progress.get("packets")
    if not isinstance(packets, list) or [row.get("id") for row in packets if isinstance(row, dict)] != PACKET_IDS:
        errors.append("GPT56 packets must preserve ordered PTK-GPT56-1 through PTK-GPT56-5")
    else:
        for packet in packets:
            packet_id = str(packet.get("id", ""))
            if packet.get("status") != "implemented":
                errors.append(f"{packet_id} must be implemented")
            requirements = packet.get("requirements")
            if not isinstance(requirements, list):
                errors.append(f"{packet_id} requirements must be an array")
                continue
            seen: set[str] = set()
            for requirement in requirements:
                requirement_id = requirement.get("id") if isinstance(requirement, dict) else None
                if requirement_id not in PACKET_REQUIREMENTS[packet_id] or requirement_id in seen:
                    errors.append(f"{packet_id} has invalid or duplicate requirement: {requirement_id!r}")
                    continue
                seen.add(str(requirement_id))
                if requirement.get("status") not in {"automated", "documented", "packaged"}:
                    errors.append(f"{packet_id}/{requirement_id} has invalid status")
                evidence = requirement.get("evidence")
                if not isinstance(evidence, list) or not evidence:
                    errors.append(f"{packet_id}/{requirement_id} needs evidence")
                    continue
                for relative in evidence:
                    if not isinstance(relative, str) or not _evidence_exists(root, relative):
                        errors.append(f"{packet_id}/{requirement_id} has missing evidence: {relative!r}")
            for missing in sorted(PACKET_REQUIREMENTS[packet_id] - seen):
                errors.append(f"{packet_id} is missing requirement: {missing}")

    source_catalogs = catalogs or {folder: _catalog(root, folder, errors) for folder in ("commanders", "keeps", "packs", "enemies", "scenarios", "events", "pieces")}
    commanders = source_catalogs["commanders"]
    keeps = source_catalogs["keeps"]
    packs = source_catalogs["packs"]
    enemies = source_catalogs["enemies"]
    scenarios = source_catalogs["scenarios"]
    events = source_catalogs["events"]
    pieces = source_catalogs["pieces"]
    bounds = {"keeps": (len(keeps), 3, 3), "commanders": (len(commanders), 4, 4), "packs": (len(packs), 15, 18), "pieces": (len(pieces), 24, 30), "enemies": (len(enemies), 12, 14), "scenarios": (len(scenarios), 20, 24), "events": (len(events), 14, 18)}
    for label, (actual, minimum, maximum) in bounds.items():
        if not minimum <= actual <= maximum:
            errors.append(f"GPT56 {label} inventory {actual} must be within {minimum}..{maximum}")

    commander_ids = set(commanders)
    pack_ids = set(packs)
    matrix_pairs: set[tuple[str, str]] = set()
    spatial_rules: set[str] = set()
    recovery_profiles: set[tuple[int, int]] = set()
    for keep_id, keep in keeps.items():
        spatial = keep.get("spatial_rule", {})
        spatial_rules.add(str(spatial.get("id", "")))
        recovery = keep.get("recovery_profile", {})
        recovery_profiles.add((int(recovery.get("room_repair_materials", 0)), int(recovery.get("room_repair_condition", 0))))
        rows = keep.get("doctrine_geometry")
        if not isinstance(rows, list):
            errors.append(f"{keep_id} must define doctrine_geometry")
            continue
        row_commanders: set[str] = set()
        for row in rows:
            commander_id = str(row.get("commander_id", ""))
            pack_id = str(row.get("recommended_pack_id", ""))
            row_commanders.add(commander_id)
            matrix_pairs.add((commander_id, keep_id))
            if pack_id not in pack_ids:
                errors.append(f"{keep_id}/{commander_id} references unknown pack {pack_id}")
            for field in ("opening", "fit", "risk"):
                if not isinstance(row.get(field), str) or not row[field].strip():
                    errors.append(f"{keep_id}/{commander_id} has empty {field}")
        if row_commanders != commander_ids:
            errors.append(f"{keep_id} doctrine_geometry must cover every active commander exactly once")
    if len(matrix_pairs) != len(keeps) * len(commanders):
        errors.append("commander/keep doctrine matrix must contain all 12 pairings")
    if len(spatial_rules) != len(keeps) or len(recovery_profiles) != len(keeps):
        errors.append("each keep must have a distinct spatial rule and recovery profile")

    for pack_id, pack in packs.items():
        for field in ("short_role", "question", "strength", "weakness", "choice"):
            if not isinstance(pack.get(field), str) or not pack[field].strip():
                errors.append(f"pack {pack_id} must state {field}")
        if not isinstance(pack.get("cost"), int) or pack["cost"] < 1 or len(pack.get("contents", [])) < 2 or not isinstance(pack.get("spatial_demand"), dict):
            errors.append(f"pack {pack_id} must expose cost, contents, and spatial demand")
    for enemy_id, enemy in enemies.items():
        for field in ("telegraph", "target_mode", "failure_mode", "report_phrase"):
            if not isinstance(enemy.get(field), str) or not enemy[field].strip():
                errors.append(f"enemy {enemy_id} must state {field}")
        if enemy.get("target_mode") not in {"unit_hunter", "room_destroyer"} or len(enemy.get("counter_families", [])) < 2:
            errors.append(f"enemy {enemy_id} must expose a distinct target preference and at least two counters")

    scenario_ids = progress.get("scenario_ids")
    if not isinstance(scenario_ids, dict):
        errors.append("GPT56 report must list scenario IDs")
    else:
        listed = {str(value) for values in scenario_ids.values() if isinstance(values, list) for value in values}
        if not listed.issubset(set(scenarios)) or not {"gatehouse_lock", "ash_ford_crossing", "last_stand"}.issubset(listed):
            errors.append("GPT56 scenario report contains missing or incomplete scenario IDs")
    seeded_results = progress.get("seeded_results")
    if not isinstance(seeded_results, list) or len(seeded_results) < 2 or any(not _evidence_exists(root, str(row.get("evidence", ""))) for row in seeded_results if isinstance(row, dict)):
        errors.append("GPT56 report must contain reproducible seeded results")
    failed_plans = progress.get("failed_plans_discovered")
    if not isinstance(failed_plans, list) or len(failed_plans) < 3 or any(not _evidence_exists(root, str(row.get("evidence", ""))) for row in failed_plans if isinstance(row, dict)):
        errors.append("GPT56 report must record at least three evidenced failed plans")
    owners = progress.get("state_owners")
    if not isinstance(owners, dict) or set(owners) != {"simulation", "content", "presentation", "persistence", "packaging"}:
        errors.append("GPT56 report must name all state owners")
    assets = progress.get("assets", {})
    if assets.get("active_temporary") != [] or not _evidence_exists(root, str(assets.get("archived_temporary_manifest", ""))):
        errors.append("GPT56 asset report must distinguish no active temporary assets from the archive")

    if validate_captures:
        _validate_capture(root, "docs/visual_evidence/v0.65.0-preparation-first-viewport-greywatch-1600x900/capture-manifest.json", "gatehouse_lock", str(progress.get("build_version", "")), errors, True)
        _validate_capture(root, "docs/visual_evidence/v0.65.0-preparation-first-viewport-ash-ford-1600x900/capture-manifest.json", "ash_ford_crossing", str(progress.get("build_version", "")), errors)
    if progress.get("human_evidence_required_for_implementation") is not False or progress.get("human_evidence_status") != "pending":
        errors.append("human evidence must remain pending and non-blocking")
    if progress.get("owner_approval_required_for_distribution") is not True:
        errors.append("owner approval must remain required for distribution")
    if progress.get("next_packet") != "PTK-P16":
        errors.append("GPT56 completion must name exactly one bounded next packet: PTK-P16")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--progress", type=Path, default=Path("content/gpt56_progress.json"))
    args = parser.parse_args()
    root = Path.cwd()
    errors: list[str] = []
    progress = _load(args.progress, errors)
    manifests = [
        _load(root / "tools/ci_manifest.json", errors),
        _load(root / "content/gameplay_framework.json", errors),
        _load(root / "content/investment_progress.json", errors),
        _load(root / "content/early_access_progress.json", errors),
        _load(root / "content/k8_private_alpha_gate.json", errors),
    ]
    validate_progress(progress, manifests, root, errors)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("GPT56 investment packets: PASS (PTK-GPT56-1 through PTK-GPT56-5 plus PTK-GPT56-1B implemented; PTK-P16 remains human-owned)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
