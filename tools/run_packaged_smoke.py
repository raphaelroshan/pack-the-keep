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


def validate_report(report_path: Path, profile_root: Path, expected_version: str, expected_phase: str = "initial") -> list[str]:
    errors: list[str] = []
    try:
        report = json.loads(report_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"cannot read packaged smoke report: {exc}"]
    if report.get("schema_version") != 1:
        errors.append("smoke report schema_version must be 1")
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
    if report.get("battle_step") != 1:
        errors.append("packaged gameplay did not save deterministic battle step one")
    if report.get("save_schema_version") != 4 or report.get("settings_schema_version") != 4:
        errors.append("packaged persistence schemas do not match the current runtime")
    for field in ("controller_navigation_ready", "controller_defaults_ready"):
        if report.get(field) is not True:
            errors.append(f"packaged input/scaling assertion failed: {field}")
    if expected_phase == "initial":
        if report.get("profile_files_present") is not False or report.get("profile_files_complete") is not False:
            errors.append("initial packaged profile was not clean")
        for field in ("controller_remap_ready", "ui_scale_ready", "settings_scale_ready", "settings_remap_ready"):
            if report.get(field) is not True:
                errors.append(f"packaged input/scaling assertion failed: {field}")
        for field in ("initial_pause_ready", "paused_state_frozen", "remapped_pause_ready", "manual_step_ready"):
            if report.get(field) is not True:
                errors.append(f"packaged pause assertion failed: {field}")
    elif expected_phase == "reinstall":
        if report.get("profile_files_present") is not True or report.get("profile_files_complete") is not True:
            errors.append("reinstalled build did not observe both existing profile files")
        for field in ("restored_run_ready", "restored_scale_ready", "restored_remap_ready"):
            if report.get(field) is not True:
                errors.append(f"packaged reinstall assertion failed: {field}")
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
            "scenario_count": 8,
            "event_count": 7,
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
    environment = os.environ.copy()
    environment.update({
        "APPDATA": str(profile_root),
        "XDG_DATA_HOME": str(profile_root),
        "HTTP_PROXY": "http://127.0.0.1:9",
        "HTTPS_PROXY": "http://127.0.0.1:9",
        "ALL_PROXY": "http://127.0.0.1:9",
        "NO_PROXY": "",
        "PACK_THE_KEEP_PACKAGED_SMOKE": "1",
        "PACK_THE_KEEP_SMOKE_PHASE": "initial",
    })
    common = [str(executable), "--headless", "--audio-driver", "Dummy"]
    try:
        launch = run_process(common + ["--quit-after", "2"], environment, args.timeout, executable.parent)
        require_success("packaged main-scene launch", launch)
        smoke = run_process(common + ["--", "--packaged-smoke"], environment, args.timeout, executable.parent)
        require_success("packaged gameplay smoke", smoke)
    except RuntimeError as exc:
        print(f"ERROR: {exc}")
        return 1
    reports = list(profile_root.rglob("packaged_smoke_report.json"))
    if len(reports) != 1:
        print(f"ERROR: expected one packaged smoke report below {profile_root}, found {len(reports)}")
        return 1
    initial_report_path = reports[0]
    errors = validate_report(initial_report_path, profile_root, expected_version, "initial")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    initial_report = json.loads(initial_report_path.read_text(encoding="utf-8"))
    if not isinstance(initial_report.get("executable_path"), str) or not paths_equal(initial_report["executable_path"], executable):
        print(f"ERROR: initial smoke ran from unexpected executable: {initial_report.get('executable_path')!r}")
        return 1
    reinstall_dir = Path(tempfile.mkdtemp(prefix=f"{profile_root.name}-reinstalled-app-", dir=profile_root.parent))
    reinstalled_executable = reinstall_dir / executable.name
    shutil.copy2(executable, reinstalled_executable)
    environment["PACK_THE_KEEP_SMOKE_PHASE"] = "reinstall"
    try:
        reinstall = run_process([str(reinstalled_executable), "--headless", "--audio-driver", "Dummy", "--", "--packaged-smoke"], environment, args.timeout, reinstall_dir)
        require_success("reinstalled packaged gameplay smoke", reinstall)
    except RuntimeError as exc:
        print(f"ERROR: {exc}")
        return 1
    errors = validate_report(initial_report_path, profile_root, expected_version, "reinstall")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    reinstall_report = json.loads(initial_report_path.read_text(encoding="utf-8"))
    if not isinstance(reinstall_report.get("executable_path"), str) or not paths_equal(reinstall_report["executable_path"], reinstalled_executable):
        print(f"ERROR: reinstall smoke ran from unexpected executable: {reinstall_report.get('executable_path')!r}")
        return 1
    if args.report_copy is not None:
        args.report_copy.parent.mkdir(parents=True, exist_ok=True)
        args.report_copy.write_text(json.dumps({"schema_version": 1, "initial": initial_report, "reinstall": reinstall_report}, indent=2), encoding="utf-8")
    print(f"packaged smoke: PASS ({initial_report_path}; relocated to {reinstalled_executable})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
