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
    "keep_count": 3,
    "region_count": 1,
    "commander_count": 3,
    "piece_count": 19,
    "pack_count": 10,
    "enemy_count": 9,
    "doctrine_count": 10,
    "scenario_count": 13,
    "event_count": 9,
    "modifier_count": 2,
}
PACKAGED_PHASES = ("clean_install", "reinstall", "stale_backup", "missing_profile", "upgrade", "forced_close_recovery")


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


def validate_ci_manifest(manifest: dict[str, Any], errors: list[str]) -> str:
    build_version = manifest.get("build_version")
    if not isinstance(build_version, str) or not build_version:
        errors.append("CI manifest needs build_version")
        build_version = ""
    if manifest.get("release_ready") is not False:
        errors.append("CI manifest release_ready must remain false before human alpha approval")
    return build_version


def evidence_file_exists(root: Path, relative: str) -> bool:
    candidate = Path(relative)
    if candidate.is_absolute() or ".." in candidate.parts:
        return False
    try:
        candidate_path = (root / candidate).resolve()
        candidate_path.relative_to(root.resolve())
    except (OSError, ValueError):
        return False
    return candidate_path.is_file()


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
            if not isinstance(relative, str) or not evidence_file_exists(root, relative):
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
        if not isinstance(evidence, str) or not evidence_file_exists(root, evidence):
            errors.append(f"P12 human gate {gate_id} has missing evidence guidance")
    for missing in sorted(REQUIRED_HUMAN_GATES - human_seen):
        errors.append(f"P12 checklist is missing human gate: {missing}")


def validate_report(path: Path, build_version: str, errors: list[str]) -> None:
    combined = load_object(path, errors)
    if combined.get("schema_version") != 3:
        errors.append("combined packaged smoke schema_version must be 3")
    forced_close = combined.get("forced_close")
    if not isinstance(forced_close, dict) or forced_close.get("ready") is not True or forced_close.get("terminated") is not True or forced_close.get("exit_code") in (None, 0):
        errors.append("combined packaged smoke needs forced-termination evidence")
    reports = {phase: combined.get(phase) for phase in PACKAGED_PHASES}
    if any(not isinstance(report, dict) for report in reports.values()):
        errors.append("combined packaged smoke needs clean-install, reinstall, stale-backup, missing-profile, upgrade, and forced-close-recovery reports")
        return
    for phase, report in reports.items():
        assert isinstance(report, dict)
        if report.get("schema_version") != 2:
            errors.append(f"packaged {phase} report schema_version must be 2")
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
        if phase != "missing_profile":
            if report.get("battle_step") != 1:
                errors.append(f"packaged {phase} phase did not preserve battle step one")
            if report.get("save_schema_version") != 4 or report.get("settings_schema_version") != 5:
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
        if report.get("settings_state_unchanged") is not True:
            errors.append(f"packaged {phase} settings changed authoritative state")
        user_data_dir = report.get("user_data_dir")
        if not isinstance(user_data_dir, str):
            errors.append(f"packaged {phase} phase needs user_data_dir")
        else:
            for field in ("save_path", "settings_path"):
                value = report.get(field)
                if not isinstance(value, str) or not windows_path_is_within(value, user_data_dir):
                    errors.append(f"packaged {phase} evidence placed {field} outside user data")
    clean_install = reports["clean_install"]
    reinstall = reports["reinstall"]
    stale_backup = reports["stale_backup"]
    missing_profile = reports["missing_profile"]
    upgrade = reports["upgrade"]
    forced_close_recovery = reports["forced_close_recovery"]
    assert all(isinstance(report, dict) for report in reports.values())
    clean_install_fields = (
        "offline_proxy_guard", "controller_navigation_ready", "controller_defaults_ready",
        "controller_remap_ready", "ui_scale_ready", "settings_scale_ready", "settings_remap_ready",
        "initial_realtime_ready", "paused_state_frozen", "remapped_pause_ready", "manual_step_ready",
    )
    for field in clean_install_fields:
        if clean_install.get(field) is not True:
            errors.append(f"clean-install packaged evidence failed: {field}")
    if clean_install.get("profile_files_present") is not False or clean_install.get("profile_files_complete") is not False:
        errors.append("clean-install packaged evidence did not start from a clean profile")
    for field in ("profile_files_present", "profile_files_complete", "restored_run_ready", "restored_scale_ready", "restored_remap_ready"):
        if reinstall.get(field) is not True:
            errors.append(f"reinstall packaged evidence failed: {field}")
    for field in ("profile_files_present", "profile_files_complete", "profile_backups_complete", "primary_preferred_ready"):
        if stale_backup.get(field) is not True:
            errors.append(f"stale-backup packaged evidence failed: {field}")
    if missing_profile.get("profile_files_present") is not False or missing_profile.get("profile_files_complete") is not False:
        errors.append("missing-profile packaged evidence unexpectedly found persistence files")
    for field in ("missing_profile_defaults_ready", "missing_profile_state_unchanged"):
        if missing_profile.get(field) is not True:
            errors.append(f"missing-profile packaged evidence failed: {field}")
    for field in ("legacy_profile_detected", "upgrade_run_migrated", "upgrade_settings_ready", "upgraded_files_current"):
        if upgrade.get(field) is not True:
            errors.append(f"upgrade packaged evidence failed: {field}")
    for field in ("forced_close_detected", "forced_close_run_recovered", "forced_close_settings_recovered", "forced_close_files_current"):
        if forced_close_recovery.get(field) is not True:
            errors.append(f"forced-close packaged evidence failed: {field}")
    initial_executable = clean_install.get("executable_path")
    reinstall_executable = reinstall.get("executable_path")
    if not isinstance(initial_executable, str) or not isinstance(reinstall_executable, str):
        errors.append("packaged evidence needs both executable paths")
    elif ntpath.normcase(ntpath.abspath(initial_executable)) == ntpath.normcase(ntpath.abspath(reinstall_executable)):
        errors.append("reinstall packaged evidence did not relocate the executable")
    elif ntpath.basename(initial_executable).casefold() != ntpath.basename(reinstall_executable).casefold():
        errors.append("reinstall packaged executable name changed unexpectedly")
    upgrade_executable = upgrade.get("executable_path")
    if not isinstance(initial_executable, str) or not isinstance(upgrade_executable, str):
        errors.append("upgrade packaged evidence needs both executable paths")
    elif ntpath.normcase(ntpath.abspath(initial_executable)) == ntpath.normcase(ntpath.abspath(upgrade_executable)):
        errors.append("upgrade packaged evidence did not use a fresh install directory")
    elif ntpath.basename(initial_executable).casefold() != ntpath.basename(upgrade_executable).casefold():
        errors.append("upgrade packaged executable name changed unexpectedly")
    for field in ("user_data_dir", "save_path", "settings_path"):
        initial_path = clean_install.get(field)
        reinstall_path = reinstall.get(field)
        if not isinstance(initial_path, str) or not isinstance(reinstall_path, str):
            errors.append(f"packaged evidence needs both {field} values")
        elif ntpath.normcase(ntpath.abspath(initial_path)) != ntpath.normcase(ntpath.abspath(reinstall_path)):
            errors.append(f"reinstall packaged evidence changed {field}")
    for field in ("user_data_dir", "save_path", "settings_path"):
        if stale_backup.get(field) != clean_install.get(field):
            errors.append(f"stale-backup packaged evidence changed {field}")
    if missing_profile.get("user_data_dir") == clean_install.get("user_data_dir"):
        errors.append("missing-profile packaged evidence reused the clean-install profile")
    if upgrade.get("user_data_dir") == clean_install.get("user_data_dir"):
        errors.append("upgrade packaged evidence reused the clean-install profile")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--checklist", type=Path, default=Path("content/p12_alpha_checklist.json"))
    parser.add_argument("--manifest", type=Path, default=Path("tools/ci_manifest.json"))
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    root = Path.cwd()
    errors: list[str] = []
    manifest = load_object(args.manifest, errors)
    build_version = validate_ci_manifest(manifest, errors)
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
