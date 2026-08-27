#!/usr/bin/env python3
"""Validate P12 alpha checklist evidence and optional packaged smoke results."""
from __future__ import annotations

import argparse
import json
import ntpath
from pathlib import Path
from typing import Any


REQUIRED_CHECKS = {
    "windows_launch", "offline_play", "save_location", "malformed_save", "save_migration",
    "controller", "scaling", "input_remapping", "pause", "crash_safe_close", "clean_reinstall",
}
REQUIRED_HUMAN_GATES = {
    "windows_gpu_presentation", "physical_controller_matrix", "procedural_audio_review",
    "forced_close_recovery", "signed_installer", "storefront_launch", "human_playtest",
}
EXPECTED_CONTENT_COUNTS = {
    "commander_count": 2,
    "piece_count": 17,
    "pack_count": 9,
    "enemy_count": 7,
    "doctrine_count": 8,
    "scenario_count": 8,
    "event_count": 3,
    "modifier_count": 2,
}


def load_object(path: Path, errors: list[str]) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{path}: cannot read JSON: {exc}")
        return {}
    if not isinstance(value, dict):
        errors.append(f"{path}: root must be an object")
        return {}
    return value


def windows_path_is_within(path: str, root: str) -> bool:
    try:
        normalized_path = ntpath.normcase(ntpath.abspath(path))
        normalized_root = ntpath.normcase(ntpath.abspath(root))
        return ntpath.commonpath((normalized_path, normalized_root)) == normalized_root
    except ValueError:
        return False


def validate_checklist(path: Path, root: Path, build_version: str, errors: list[str]) -> None:
    checklist = load_object(path, errors)
    if checklist.get("schema_version") != 1:
        errors.append("P12 checklist schema_version must be 1")
    if checklist.get("build_version") != build_version:
        errors.append("P12 checklist build_version must match CI manifest")
    if checklist.get("status") != "candidate":
        errors.append("P12 checklist status must be candidate before human alpha approval")
    records = checklist.get("checks")
    if not isinstance(records, list):
        errors.append("P12 checklist checks must be an array")
        return
    seen: set[str] = set()
    for record in records:
        if not isinstance(record, dict):
            errors.append("P12 checklist entries must be objects")
            continue
        check_id = record.get("id")
        if not isinstance(check_id, str) or check_id not in REQUIRED_CHECKS:
            errors.append(f"unknown P12 checklist ID: {check_id!r}")
            continue
        if check_id in seen:
            errors.append(f"duplicate P12 checklist ID: {check_id}")
        seen.add(check_id)
        if record.get("status") != "implemented":
            errors.append(f"P12 check {check_id} is not implemented")
        evidence = record.get("evidence")
        if not isinstance(evidence, list) or not evidence:
            errors.append(f"P12 check {check_id} needs evidence paths")
            continue
        for relative in evidence:
            if not isinstance(relative, str) or not (root / relative).is_file():
                errors.append(f"P12 check {check_id} has missing evidence: {relative!r}")
    for missing in sorted(REQUIRED_CHECKS - seen):
        errors.append(f"P12 checklist is missing: {missing}")
    human_records = checklist.get("human_gates")
    if not isinstance(human_records, list):
        errors.append("P12 checklist human_gates must be an array")
        return
    human_seen: set[str] = set()
    for record in human_records:
        if not isinstance(record, dict) or record.get("id") not in REQUIRED_HUMAN_GATES:
            errors.append(f"unknown P12 human gate: {record!r}")
            continue
        gate_id = str(record["id"])
        if gate_id in human_seen:
            errors.append(f"duplicate P12 human gate: {gate_id}")
        human_seen.add(gate_id)
        if record.get("status") != "pending":
            errors.append(f"P12 human gate {gate_id} must remain pending until human approval")
        evidence = record.get("evidence")
        if not isinstance(evidence, str) or not (root / evidence).is_file():
            errors.append(f"P12 human gate {gate_id} has missing evidence guidance")
    for missing in sorted(REQUIRED_HUMAN_GATES - human_seen):
        errors.append(f"P12 checklist is missing human gate: {missing}")


def validate_report(path: Path, build_version: str, errors: list[str]) -> None:
    combined = load_object(path, errors)
    if combined.get("schema_version") != 1:
        errors.append("combined packaged smoke schema_version must be 1")
    initial = combined.get("initial")
    reinstall = combined.get("reinstall")
    if not isinstance(initial, dict) or not isinstance(reinstall, dict):
        errors.append("combined packaged smoke needs initial and reinstall reports")
        return
    for phase, report in (("initial", initial), ("reinstall", reinstall)):
        if report.get("phase") != phase or report.get("ok") is not True:
            errors.append(f"packaged {phase} phase did not pass")
        if report.get("errors") != []:
            errors.append(f"packaged {phase} phase reported runtime errors")
        if report.get("build_version") != build_version:
            errors.append(f"packaged {phase} build version does not match")
        if report.get("editor_feature") is not False:
            errors.append(f"packaged {phase} phase did not use a release template")
        if report.get("smoke_guard") is not True or report.get("offline_proxy_guard") is not True:
            errors.append(f"packaged {phase} phase lost its guarded offline launch")
        if report.get("main_scene_freed") is not True:
            errors.append(f"packaged {phase} main scene did not close cleanly")
        if report.get("battle_step") != 1:
            errors.append(f"packaged {phase} phase did not preserve battle step one")
        if report.get("save_schema_version") != 4 or report.get("settings_schema_version") != 4:
            errors.append(f"packaged {phase} persistence schemas do not match")
        content_status = report.get("content_status")
        if not isinstance(content_status, dict) or content_status.get("ok") is not True:
            errors.append(f"packaged {phase} runtime content catalog did not load")
        else:
            for field, expected in EXPECTED_CONTENT_COUNTS.items():
                if content_status.get(field) != expected:
                    errors.append(f"packaged {phase} content count does not match: {field}")
        for field in ("controller_navigation_ready", "controller_defaults_ready"):
            if report.get(field) is not True:
                errors.append(f"packaged {phase} controller evidence failed: {field}")
    initial_fields = (
        "offline_proxy_guard", "controller_navigation_ready", "controller_defaults_ready",
        "controller_remap_ready", "ui_scale_ready", "settings_scale_ready", "settings_remap_ready",
        "initial_pause_ready", "paused_state_frozen", "remapped_pause_ready", "manual_step_ready",
    )
    for field in initial_fields:
        if initial.get(field) is not True:
            errors.append(f"initial packaged evidence failed: {field}")
    if initial.get("profile_files_present") is not False:
        errors.append("initial packaged evidence did not start from a clean profile")
    for field in ("profile_files_present", "profile_files_complete", "restored_run_ready", "restored_scale_ready", "restored_remap_ready"):
        if reinstall.get(field) is not True:
            errors.append(f"reinstall packaged evidence failed: {field}")
    initial_executable = initial.get("executable_path")
    reinstall_executable = reinstall.get("executable_path")
    if not isinstance(initial_executable, str) or not isinstance(reinstall_executable, str):
        errors.append("packaged evidence needs both executable paths")
    elif ntpath.normcase(ntpath.abspath(initial_executable)) == ntpath.normcase(ntpath.abspath(reinstall_executable)):
        errors.append("reinstall packaged evidence did not relocate the executable")
    elif ntpath.basename(initial_executable).casefold() != ntpath.basename(reinstall_executable).casefold():
        errors.append("reinstall packaged executable name changed unexpectedly")
    for field in ("user_data_dir", "save_path", "settings_path"):
        initial_path = initial.get(field)
        reinstall_path = reinstall.get(field)
        if not isinstance(initial_path, str) or not isinstance(reinstall_path, str):
            errors.append(f"packaged evidence needs both {field} values")
        elif ntpath.normcase(ntpath.abspath(initial_path)) != ntpath.normcase(ntpath.abspath(reinstall_path)):
            errors.append(f"reinstall packaged evidence changed {field}")
    user_data_dir = initial.get("user_data_dir")
    if isinstance(user_data_dir, str):
        for field in ("save_path", "settings_path"):
            value = initial.get(field)
            if isinstance(value, str) and not windows_path_is_within(value, user_data_dir):
                errors.append(f"initial packaged evidence placed {field} outside user data")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--checklist", type=Path, default=Path("content/p12_alpha_checklist.json"))
    parser.add_argument("--manifest", type=Path, default=Path("tools/ci_manifest.json"))
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    root = Path.cwd()
    errors: list[str] = []
    manifest = load_object(args.manifest, errors)
    build_version = str(manifest.get("build_version", ""))
    if not build_version:
        errors.append("CI manifest needs build_version")
    validate_checklist(args.checklist, root, build_version, errors)
    if args.report is not None:
        validate_report(args.report, build_version, errors)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    suffix = " plus packaged report" if args.report is not None else ""
    print(f"P12 alpha checklist: PASS ({len(REQUIRED_CHECKS)} automated checks, {len(REQUIRED_HUMAN_GATES)} pending human gates{suffix})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
