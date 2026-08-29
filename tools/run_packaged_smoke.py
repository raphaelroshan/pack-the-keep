#!/usr/bin/env python3
"""Launch and validate an exported Pack the Keep artifact in an isolated profile."""
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SAVE_FILENAME = "packaged_smoke_run.save"
SETTINGS_FILENAME = "packaged_smoke_settings.json"
REPORT_FILENAME = "packaged_smoke_report.json"
SUPPORTED_PHASES = {"clean_install", "reinstall", "stale_backup", "missing_profile", "upgrade"}


def run_process(command: list[str], environment: dict[str, str], timeout: float, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            command,
            env=environment,
            check=False,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=cwd,
        )
    except subprocess.TimeoutExpired as exc:
        output_parts: list[str] = []
        for part in (exc.stdout, exc.stderr):
            if isinstance(part, bytes):
                part = part.decode(errors="replace")
            if part:
                output_parts.append(part)
        output = "\n".join(output_parts)
        raise RuntimeError(f"timed out after {timeout}s: {' '.join(command)}\n{output}") from exc


def require_success(label: str, result: subprocess.CompletedProcess[str]) -> None:
    if result.returncode == 0:
        return
    output = "\n".join(part for part in (result.stdout, result.stderr) if part)
    raise RuntimeError(f"{label} exited {result.returncode}\n{output}")


def path_is_within(path: str, root: Path) -> bool:
    normalized_path = os.path.normcase(os.path.abspath(path))
    normalized_root = os.path.normcase(os.path.abspath(root))
    try:
        return os.path.commonpath([normalized_path, normalized_root]) == normalized_root
    except ValueError:
        return False


def paths_equal(first: str, second: Path) -> bool:
    return os.path.normcase(os.path.abspath(first)) == os.path.normcase(os.path.abspath(second))


def validate_report(report_path: Path, profile_root: Path, expected_version: str, expected_phase: str = "clean_install") -> list[str]:
    errors: list[str] = []
    try:
        report = json.loads(report_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"cannot read packaged smoke report: {exc}"]
    if report.get("schema_version") != 2:
        errors.append("smoke report schema_version must be 2")
    if expected_phase not in SUPPORTED_PHASES:
        errors.append(f"unsupported expected smoke phase: {expected_phase}")
    if report.get("phase") != expected_phase:
        errors.append(f"smoke report phase {report.get('phase')!r} does not match {expected_phase!r}")
    if report.get("build_version") != expected_version:
        errors.append(f"packaged build version {report.get('build_version')!r} does not match {expected_version!r}")
    if report.get("ok") is not True:
        errors.append(f"packaged smoke reported errors: {report.get('errors', [])}")
    if report.get("errors") != []:
        errors.append("packaged smoke report contains runtime errors")
    if report.get("editor_feature") is not False:
        errors.append("smoke script did not run from an exported release template")
    if report.get("offline_proxy_guard") is not True:
        errors.append("unreachable offline proxy guard was not visible to the packaged process")
    if report.get("smoke_guard") is not True:
        errors.append("packaged smoke environment guard was not visible to the packaged process")
    if report.get("main_scene_freed") is not True:
        errors.append("main scene did not free before packaged process shutdown")
    for field in ("controller_navigation_ready", "controller_defaults_ready"):
        if report.get(field) is not True:
            errors.append(f"packaged input/scaling assertion failed: {field}")
    if report.get("settings_state_unchanged") is not True:
        errors.append("packaged presentation settings changed authoritative state")
    if expected_phase != "missing_profile":
        if report.get("battle_step") != 1:
            errors.append("packaged gameplay did not preserve deterministic battle step one")
        if report.get("save_schema_version") != 4 or report.get("settings_schema_version") != 4:
            errors.append("packaged persistence schemas do not match the current runtime")
    if expected_phase == "clean_install":
        if report.get("profile_files_present") is not False or report.get("profile_files_complete") is not False:
            errors.append("clean-install packaged profile was not clean")
        for field in ("controller_remap_ready", "ui_scale_ready", "settings_scale_ready", "settings_remap_ready"):
            if report.get(field) is not True:
                errors.append(f"packaged input/scaling assertion failed: {field}")
        for field in ("initial_realtime_ready", "paused_state_frozen", "remapped_pause_ready", "manual_step_ready"):
            if report.get(field) is not True:
                errors.append(f"packaged pause assertion failed: {field}")
    elif expected_phase == "reinstall":
        if report.get("profile_files_present") is not True or report.get("profile_files_complete") is not True:
            errors.append("reinstalled build did not observe both existing profile files")
        for field in ("restored_run_ready", "restored_scale_ready", "restored_remap_ready"):
            if report.get(field) is not True:
                errors.append(f"packaged reinstall assertion failed: {field}")
    elif expected_phase == "stale_backup":
        if report.get("profile_files_complete") is not True or report.get("profile_backups_complete") is not True:
            errors.append("stale-backup phase did not observe complete primary and backup files")
        if report.get("primary_preferred_ready") is not True:
            errors.append("stale-backup phase did not prefer valid primary files")
    elif expected_phase == "missing_profile":
        if report.get("profile_files_present") is not False or report.get("profile_files_complete") is not False:
            errors.append("missing-profile phase unexpectedly found persistence files")
        for field in ("missing_profile_defaults_ready", "missing_profile_state_unchanged"):
            if report.get(field) is not True:
                errors.append(f"packaged missing-profile assertion failed: {field}")
    elif expected_phase == "upgrade":
        if report.get("legacy_profile_detected") is not True:
            errors.append("upgrade phase did not observe schema-3 profile files")
        for field in ("upgrade_run_migrated", "upgrade_settings_ready", "upgraded_files_current"):
            if report.get(field) is not True:
                errors.append(f"packaged upgrade assertion failed: {field}")
    content_status = report.get("content_status")
    if not isinstance(content_status, dict) or content_status.get("ok") is not True:
        errors.append("packaged runtime content catalog did not load")
    else:
        expected_counts = {
            "commander_count": 2,
            "piece_count": 17,
            "pack_count": 9,
            "enemy_count": 7,
            "doctrine_count": 8,
            "keep_count": 2,
            "region_count": 1,
            "scenario_count": 10,
            "event_count": 9,
            "modifier_count": 2,
        }
        for key, expected in expected_counts.items():
            if content_status.get(key) != expected:
                errors.append(f"packaged content {key} is {content_status.get(key)!r}, expected {expected}")
    for key in ("user_data_dir", "save_path", "settings_path"):
        value = report.get(key)
        if not isinstance(value, str) or not path_is_within(value, profile_root):
            errors.append(f"{key} escaped the isolated profile root: {value!r}")
    return errors


def smoke_environment(profile_root: Path, phase: str) -> dict[str, str]:
    environment = os.environ.copy()
    environment.update({
        "APPDATA": str(profile_root),
        "XDG_DATA_HOME": str(profile_root),
        "HTTP_PROXY": "http://127.0.0.1:9",
        "HTTPS_PROXY": "http://127.0.0.1:9",
        "ALL_PROXY": "http://127.0.0.1:9",
        "NO_PROXY": "",
        "PACK_THE_KEEP_PACKAGED_SMOKE": "1",
        "PACK_THE_KEEP_SMOKE_PHASE": phase,
    })
    return environment


def run_smoke_phase(
    executable: Path,
    profile_root: Path,
    expected_version: str,
    phase: str,
    timeout: float,
) -> tuple[dict[str, object], Path]:
    for stale_report in profile_root.rglob(REPORT_FILENAME) if profile_root.exists() else []:
        stale_report.unlink()
    command = [str(executable), "--headless", "--audio-driver", "Dummy", "--", "--packaged-smoke"]
    result = run_process(command, smoke_environment(profile_root, phase), timeout, executable.parent)
    require_success(f"packaged {phase} smoke", result)
    reports = list(profile_root.rglob(REPORT_FILENAME))
    if len(reports) != 1:
        raise RuntimeError(f"expected one {phase} smoke report below {profile_root}, found {len(reports)}")
    report_path = reports[0]
    errors = validate_report(report_path, profile_root, expected_version, phase)
    if errors:
        raise RuntimeError("\n".join(errors))
    report = json.loads(report_path.read_text(encoding="utf-8"))
    if not isinstance(report.get("executable_path"), str) or not paths_equal(str(report["executable_path"]), executable):
        raise RuntimeError(f"{phase} smoke ran from unexpected executable: {report.get('executable_path')!r}")
    return report, report_path


def copy_executable(executable: Path, profile_root: Path, label: str) -> Path:
    install_dir = Path(tempfile.mkdtemp(prefix=f"{profile_root.name}-{label}-app-", dir=profile_root.parent))
    copied_executable = install_dir / executable.name
    shutil.copy2(executable, copied_executable)
    return copied_executable


def write_stale_backups(report: dict[str, object]) -> None:
    save_path = Path(str(report["save_path"]))
    settings_path = Path(str(report["settings_path"]))
    stale_save = json.loads(save_path.read_text(encoding="utf-8"))
    stale_save["seed"] = 9901
    stale_save["battle_step"] = 0
    Path(f"{save_path}.bak").write_text(json.dumps(stale_save), encoding="utf-8")
    stale_settings = json.loads(settings_path.read_text(encoding="utf-8"))
    stale_settings["ui_scale_index"] = 0
    stale_settings["input_bindings"] = {}
    Path(f"{settings_path}.bak").write_text(json.dumps(stale_settings), encoding="utf-8")


def write_legacy_profile(source_report: dict[str, object], source_root: Path, destination_root: Path) -> None:
    source_user_data = Path(str(source_report["user_data_dir"]))
    relative_user_data = source_user_data.resolve().relative_to(source_root.resolve())
    destination_user_data = destination_root / relative_user_data
    destination_user_data.mkdir(parents=True, exist_ok=True)
    save_payload = json.loads(Path(str(source_report["save_path"])).read_text(encoding="utf-8"))
    save_payload["schema_version"] = 3
    save_payload.pop("unlocked_modifier_ids", None)
    save_payload.pop("equipped_modifier_id", None)
    (destination_user_data / SAVE_FILENAME).write_text(json.dumps(save_payload), encoding="utf-8")
    settings_payload = json.loads(Path(str(source_report["settings_path"])).read_text(encoding="utf-8"))
    settings_payload["schema_version"] = 3
    settings_payload.pop("event_feed_retention_index", None)
    settings_payload.pop("auto_pause_on_threat", None)
    (destination_user_data / SETTINGS_FILENAME).write_text(json.dumps(settings_payload), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--executable", required=True, type=Path)
    parser.add_argument("--profile-root", required=True, type=Path)
    parser.add_argument("--report-copy", type=Path)
    parser.add_argument("--manifest", type=Path, default=Path("tools/ci_manifest.json"))
    parser.add_argument("--timeout", type=int, default=30)
    args = parser.parse_args()
    executable = args.executable.resolve()
    profile_root = args.profile_root.resolve()
    if not executable.is_file():
        print(f"ERROR: packaged executable is missing: {executable}")
        return 1
    try:
        manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
        expected_version = str(manifest["build_version"])
    except (OSError, json.JSONDecodeError, KeyError) as exc:
        print(f"ERROR: cannot read build_version from {args.manifest}: {exc}")
        return 1
    profile_root.mkdir(parents=True, exist_ok=True)
    environment = smoke_environment(profile_root, "clean_install")
    common = [str(executable), "--headless", "--audio-driver", "Dummy"]
    try:
        launch = run_process(common + ["--quit-after", "2"], environment, args.timeout, executable.parent)
        require_success("packaged main-scene launch", launch)
        clean_install_report, _ = run_smoke_phase(executable, profile_root, expected_version, "clean_install", args.timeout)

        reinstalled_executable = copy_executable(executable, profile_root, "reinstalled")
        reinstall_report, _ = run_smoke_phase(reinstalled_executable, profile_root, expected_version, "reinstall", args.timeout)

        write_stale_backups(clean_install_report)
        stale_backup_report, _ = run_smoke_phase(reinstalled_executable, profile_root, expected_version, "stale_backup", args.timeout)

        missing_profile_root = Path(tempfile.mkdtemp(prefix=f"{profile_root.name}-missing-profile-", dir=profile_root.parent))
        missing_profile_root.rmdir()
        missing_profile_report, _ = run_smoke_phase(reinstalled_executable, missing_profile_root, expected_version, "missing_profile", args.timeout)

        upgrade_profile_root = Path(tempfile.mkdtemp(prefix=f"{profile_root.name}-upgrade-profile-", dir=profile_root.parent))
        write_legacy_profile(clean_install_report, profile_root, upgrade_profile_root)
        upgraded_executable = copy_executable(executable, profile_root, "upgraded")
        upgrade_report, _ = run_smoke_phase(upgraded_executable, upgrade_profile_root, expected_version, "upgrade", args.timeout)
    except (RuntimeError, OSError, json.JSONDecodeError, ValueError) as exc:
        print(f"ERROR: {exc}")
        return 1
    if args.report_copy is not None:
        args.report_copy.parent.mkdir(parents=True, exist_ok=True)
        combined = {
            "schema_version": 2,
            "clean_install": clean_install_report,
            "reinstall": reinstall_report,
            "stale_backup": stale_backup_report,
            "missing_profile": missing_profile_report,
            "upgrade": upgrade_report,
        }
        args.report_copy.write_text(json.dumps(combined, indent=2), encoding="utf-8")
    print(f"packaged smoke: PASS (five lifecycle phases; relocated to {reinstalled_executable})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
