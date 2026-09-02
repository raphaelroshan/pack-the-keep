#!/usr/bin/env python3
"""Validate the K8 automated private-alpha gate without granting release approval."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


REQUIRED_AREAS = {
    "accessibility", "persistence", "controller_navigation", "audio_settings",
    "clean_install", "migration", "performance", "package_provenance",
    "failure_recovery", "known_limitations",
}
ALLOWED_STATUSES = {"automated", "packaged", "documented"}
REQUIRED_HUMAN_GATES = {
    "windows_gpu_presentation", "physical_controller_matrix", "authored_audio_mix_review",
    "forced_close_recovery", "signed_installer", "storefront_launch", "human_playtest",
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


def evidence_file_exists(root: Path, relative: str) -> bool:
    candidate = Path(relative)
    if candidate.is_absolute() or ".." in candidate.parts:
        return False
    try:
        resolved = (root / candidate).resolve()
        resolved.relative_to(root.resolve())
    except (OSError, ValueError):
        return False
    return resolved.is_file()


def validate_gate(gate: dict[str, Any], manifest: dict[str, Any], root: Path, errors: list[str]) -> None:
    if gate.get("schema_version") != 1:
        errors.append("K8 gate schema_version must be 1")
    if gate.get("build_version") != manifest.get("build_version"):
        errors.append("K8 gate build_version must match CI manifest")
    if gate.get("status") != "automated_candidate":
        errors.append("K8 gate status must remain automated_candidate")
    for field in ("release_ready", "public_alpha_ready", "storefront_ready"):
        if gate.get(field) is not False:
            errors.append(f"K8 gate {field} must remain false without owner and human approval")
    records = gate.get("required_areas")
    if not isinstance(records, list):
        errors.append("K8 required_areas must be an array")
        return
    seen: set[str] = set()
    for record in records:
        if not isinstance(record, dict):
            errors.append("K8 area entries must be objects")
            continue
        area_id = record.get("id")
        if not isinstance(area_id, str) or area_id not in REQUIRED_AREAS:
            errors.append(f"unknown K8 area: {area_id!r}")
            continue
        if area_id in seen:
            errors.append(f"duplicate K8 area: {area_id}")
        seen.add(area_id)
        if record.get("status") not in ALLOWED_STATUSES:
            errors.append(f"K8 area {area_id} has invalid status")
        evidence = record.get("evidence")
        if not isinstance(evidence, list) or not evidence:
            errors.append(f"K8 area {area_id} needs evidence paths")
            continue
        for relative in evidence:
            if not isinstance(relative, str) or not evidence_file_exists(root, relative):
                errors.append(f"K8 area {area_id} has missing evidence: {relative!r}")
    for missing in sorted(REQUIRED_AREAS - seen):
        errors.append(f"K8 gate is missing area: {missing}")
    performance = gate.get("performance_budget")
    if not isinstance(performance, dict):
        errors.append("K8 gate needs performance_budget")
    else:
        for field in ("simulation_runs", "simulation_budget_ms", "ui_refreshes", "ui_budget_ms"):
            if not isinstance(performance.get(field), int) or int(performance[field]) <= 0:
                errors.append(f"K8 performance budget needs a positive integer {field}")
        if not isinstance(performance.get("scope"), str) or not performance["scope"]:
            errors.append("K8 performance budget needs an honest scope")
    human_gates = gate.get("pending_human_gates")
    if not isinstance(human_gates, list) or any(not isinstance(value, str) for value in human_gates) or set(human_gates) != REQUIRED_HUMAN_GATES:
        errors.append("K8 pending_human_gates must exactly preserve the human approval boundary")
    limitations = gate.get("known_limitations")
    if not isinstance(limitations, str) or not evidence_file_exists(root, limitations):
        errors.append("K8 gate needs a repository-relative known limitations document")


def validate_packaged_report(report: dict[str, Any], build_version: str, errors: list[str]) -> None:
    if report.get("schema_version") != 3:
        errors.append("K8 packaged report schema_version must be 3")
    forced_close = report.get("forced_close")
    if not isinstance(forced_close, dict) or forced_close.get("ready") is not True or forced_close.get("terminated") is not True or forced_close.get("exit_code") in (None, 0):
        errors.append("K8 packaged report needs forced-termination evidence")
    for phase in PACKAGED_PHASES:
        row = report.get(phase)
        if not isinstance(row, dict):
            errors.append(f"K8 packaged report is missing {phase}")
            continue
        if row.get("phase") != phase or row.get("ok") is not True or row.get("errors") != []:
            errors.append(f"K8 packaged phase did not pass: {phase}")
        if row.get("build_version") != build_version:
            errors.append(f"K8 packaged phase has wrong build version: {phase}")
        if row.get("offline_proxy_guard") is not True or row.get("main_scene_freed") is not True:
            errors.append(f"K8 packaged phase lost offline/clean-close evidence: {phase}")
    clean_value = report.get("clean_install", {})
    clean = clean_value if isinstance(clean_value, dict) else {}
    for field in ("controller_navigation_ready", "controller_remap_ready", "ui_scale_ready", "initial_realtime_ready", "paused_state_frozen"):
        if clean.get(field) is not True:
            errors.append(f"K8 clean-install evidence failed: {field}")
    reinstall_value = report.get("reinstall", {})
    reinstall = reinstall_value if isinstance(reinstall_value, dict) else {}
    for field in ("restored_run_ready", "restored_scale_ready", "restored_remap_ready"):
        if reinstall.get(field) is not True:
            errors.append(f"K8 reinstall evidence failed: {field}")
    upgrade_value = report.get("upgrade", {})
    upgrade = upgrade_value if isinstance(upgrade_value, dict) else {}
    for field in ("legacy_profile_detected", "upgrade_run_migrated", "upgrade_settings_ready", "upgraded_files_current"):
        if upgrade.get(field) is not True:
            errors.append(f"K8 migration evidence failed: {field}")
    recovery_value = report.get("forced_close_recovery", {})
    recovery = recovery_value if isinstance(recovery_value, dict) else {}
    for field in ("forced_close_detected", "forced_close_run_recovered", "forced_close_settings_recovered", "forced_close_files_current"):
        if recovery.get(field) is not True:
            errors.append(f"K8 forced-close evidence failed: {field}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--gate", type=Path, default=Path("content/k8_private_alpha_gate.json"))
    parser.add_argument("--manifest", type=Path, default=Path("tools/ci_manifest.json"))
    parser.add_argument("--packaged-report", type=Path)
    args = parser.parse_args()
    root = Path.cwd()
    errors: list[str] = []
    gate = load_object(args.gate, errors)
    manifest = load_object(args.manifest, errors)
    validate_gate(gate, manifest, root, errors)
    if args.packaged_report is not None:
        report = load_object(args.packaged_report, errors)
        validate_packaged_report(report, str(manifest.get("build_version", "")), errors)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    suffix = " plus packaged lifecycle" if args.packaged_report is not None else ""
    print(f"K8 private-alpha gate: PASS ({len(REQUIRED_AREAS)} automated/documented areas, {len(REQUIRED_HUMAN_GATES)} pending human gates{suffix})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
