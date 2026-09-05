#!/usr/bin/env python3
"""Run authoritative verification and emit truthful agent-QA evidence."""
from __future__ import annotations

import argparse
import hashlib
import json
import locale
import os
import re
import shutil
import struct
import subprocess
import time
from pathlib import Path
from typing import Any


RESULT_STATUSES = {"PASS", "FAIL", "BLOCKED_ENVIRONMENT", "TIMEOUT_PARTIAL", "INVALID_EVIDENCE"}


def load_scenario(root: Path, scenario_arg: str | None) -> tuple[dict[str, object], dict[str, Any] | None, str | None]:
    if not scenario_arg:
        return {"status": "NOT_CONFIGURED"}, None, None
    path = Path(scenario_arg)
    if not path.is_absolute():
        path = root / path
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001 - malformed agent input is evidence
        return {"status": "INVALID_MANIFEST", "path": str(path), "error": str(exc)}, None, None
    required = {
        "schema_version", "game", "scenario_id", "status", "seed", "expected_states",
        "semantic_commands", "checkpoints", "screenshot_states", "time_budget_ms",
    }
    missing = sorted(required - set(data))
    if missing:
        return {"status": "INVALID_MANIFEST", "path": str(path), "missing": missing}, None, None
    for key in ("expected_states", "semantic_commands"):
        if not isinstance(data[key], list) or not data[key]:
            return {"status": "INVALID_MANIFEST", "path": str(path), "error": f"{key} must be a non-empty list"}, None, None
    status = str(data.get("status", "")).upper()
    if status == "IMPLEMENTED":
        adapter = data.get("adapter")
        if not isinstance(adapter, dict):
            return {"status": "INVALID_MANIFEST", "path": str(path), "error": "implemented scenario requires adapter"}, None, None
        bindings = adapter.get("command_bindings", {})
        if set(bindings) != set(data["semantic_commands"]):
            return {"status": "INVALID_MANIFEST", "path": str(path), "error": "adapter command_bindings must cover every semantic command exactly"}, None, None
    summary = {
        "status": status,
        "path": str(path),
        "scenario_id": data["scenario_id"],
        "declared_game": data["game"],
        "expected_state_count": len(data["expected_states"]),
        "semantic_command_count": len(data["semantic_commands"]),
        "checkpoint_count": len(data["checkpoints"]),
        "screenshot_state_count": len(data["screenshot_states"]),
        "time_budget_ms": data["time_budget_ms"],
    }
    return summary, data, json.dumps(data, indent=2) + "\n"


def project_setting(root: Path, key: str, fallback: str) -> str:
    text = (root / "project.godot").read_text(encoding="utf-8")
    match = re.search(rf"^{re.escape(key)}=\"([^\"]+)\"$", text, re.MULTILINE)
    return match.group(1) if match else fallback


def command_output(command: list[str], root: Path, fallback: str) -> str:
    try:
        return subprocess.run(command, cwd=root, text=True, capture_output=True, timeout=10, check=False).stdout.strip() or fallback
    except (OSError, subprocess.TimeoutExpired):
        return fallback


def resolve_godot(requested: str) -> str | None:
    path = Path(requested).expanduser()
    if path.is_file() and os.access(path, os.X_OK):
        return str(path.resolve())
    return shutil.which(requested)


def run_logged(command: list[str], root: Path, env: dict[str, str], timeout: int, stdout_path: Path, stderr_path: Path) -> dict[str, object]:
    started = time.time()
    try:
        completed = subprocess.run(command, cwd=root, env=env, text=True, capture_output=True, timeout=timeout, check=False)
        stdout_path.write_text(completed.stdout, encoding="utf-8")
        stderr_path.write_text(completed.stderr, encoding="utf-8")
        return {"exit_code": completed.returncode, "duration_ms": round((time.time() - started) * 1000, 2), "timed_out": False}
    except subprocess.TimeoutExpired as exc:
        stdout = exc.stdout.decode("utf-8", errors="replace") if isinstance(exc.stdout, bytes) else (exc.stdout or "")
        stderr = exc.stderr.decode("utf-8", errors="replace") if isinstance(exc.stderr, bytes) else (exc.stderr or "")
        stdout_path.write_text(stdout, encoding="utf-8")
        stderr_path.write_text(stderr, encoding="utf-8")
        return {"exit_code": 124, "duration_ms": round((time.time() - started) * 1000, 2), "timed_out": True}


def png_size(path: Path) -> tuple[int, int] | None:
    try:
        header = path.read_bytes()[:24]
    except OSError:
        return None
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    return struct.unpack(">II", header[16:24])


def collapsed_states(trace: list[dict[str, Any]]) -> list[str]:
    states: list[str] = []
    for row in trace:
        state = str(row.get("state_id", ""))
        if state and (not states or states[-1] != state):
            states.append(state)
    return states


def validate_capture(capture_dir: Path, scenario: dict[str, Any]) -> tuple[list[str], dict[str, str], list[dict[str, Any]]]:
    errors: list[str] = []
    adapter = scenario["adapter"]
    manifest_path = capture_dir / "capture-manifest.json"
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001 - malformed capture is invalid evidence
        return [f"capture manifest unavailable: {exc}"], {}, []
    viewport = adapter["viewport"]
    expected_size = (int(viewport["width"]), int(viewport["height"]))
    if manifest.get("resolution") != viewport:
        errors.append(f"capture resolution {manifest.get('resolution')} did not match {viewport}")
    if manifest.get("scenario") != adapter["capture_scenario"]:
        errors.append("capture scenario did not match adapter")
    trace = manifest.get("state_trace", [])
    if not isinstance(trace, list) or collapsed_states(trace) != scenario["expected_states"]:
        errors.append(f"state sequence {collapsed_states(trace) if isinstance(trace, list) else trace} did not match expected states")
    hashes: dict[str, str] = {}
    screenshots = adapter["state_screenshots"]
    if set(screenshots) != set(scenario["screenshot_states"]):
        errors.append("state_screenshots must cover every requested screenshot state exactly")
    for state, filename in screenshots.items():
        path = capture_dir / str(filename)
        if png_size(path) != expected_size:
            errors.append(f"{state} screenshot is missing, malformed, or wrong-size: {path}")
            continue
        hashes[state] = hashlib.sha256(path.read_bytes()).hexdigest()
    return errors, hashes, trace


def write_result(output: Path, result: dict[str, object]) -> int:
    assert result["status"] in RESULT_STATUSES
    (output / "qa-result.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
    return 0 if result["status"] == "PASS" else 1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--verify", nargs="+", required=True, help="Verifier command")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--timeout", type=int, default=900)
    parser.add_argument("--game", required=True)
    parser.add_argument("--scenario", help="Scenario manifest path relative to the repository root")
    parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "godot"))
    parser.add_argument("--capture", choices=("0", "1"), default="1")
    args = parser.parse_args()

    root = Path.cwd()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    scenario_summary, scenario, scenario_text = load_scenario(root, args.scenario)
    if scenario_text is not None:
        (output / "scenario-manifest.json").write_text(scenario_text, encoding="utf-8")
    started = time.time()
    godot = resolve_godot(args.godot)
    version = project_setting(root, "config/version", "unknown")
    renderer = project_setting(root, "renderer/rendering_method", "unknown")
    result: dict[str, object] = {
        "schema_version": 3,
        "game": args.game,
        "commit": command_output(["git", "rev-parse", "HEAD"], root, "unknown"),
        "version": version,
        "engine": command_output([godot, "--version"], root, "unavailable") if godot else "unavailable",
        "viewport": scenario.get("adapter", {}).get("viewport", {"width": 1280, "height": 720}) if scenario else {"width": 1280, "height": 720},
        "renderer": renderer,
        "locale": locale.getlocale()[0] or os.environ.get("LANG", "unknown"),
        "seed": scenario.get("seed") if scenario else None,
        "command": list(args.verify),
        "cwd": str(root),
        "timeout_seconds": args.timeout,
        "started_unix": started,
        "status": "UNKNOWN",
        "scenario": scenario_summary,
        "known_limitations": [],
    }
    if scenario_summary.get("status") == "INVALID_MANIFEST":
        result.update({"status": "INVALID_EVIDENCE", "exit_code": 2, "duration_ms": 0.0, "note": "Scenario manifest is invalid; no verifier was run."})
        return write_result(output, result)
    if godot is None:
        result.update({"status": "BLOCKED_ENVIRONMENT", "exit_code": 127, "duration_ms": 0.0, "note": f"Godot executable unavailable: {args.godot}"})
        return write_result(output, result)

    env = os.environ.copy()
    env.setdefault("GODOT_SILENCE_ROOT_WARNING", "1")
    env["GODOT_BIN"] = godot
    verify = run_logged(list(args.verify), root, env, args.timeout, output / "verify.stdout.log", output / "verify.stderr.log")
    result["verification"] = {**verify, "stdout_log": "verify.stdout.log", "stderr_log": "verify.stderr.log"}
    if verify["timed_out"]:
        result.update({"status": "TIMEOUT_PARTIAL", "exit_code": 124, "note": "Verifier exceeded its time budget; partial logs are preserved."})
        result["duration_ms"] = round((time.time() - started) * 1000, 2)
        return write_result(output, result)
    if verify["exit_code"] != 0:
        result.update({"status": "FAIL", "exit_code": verify["exit_code"], "note": "Authoritative verifier failed; inspect its logs."})
        result["duration_ms"] = round((time.time() - started) * 1000, 2)
        return write_result(output, result)

    if scenario and scenario_summary["status"] == "IMPLEMENTED":
        adapter = scenario["adapter"]
        logic_command = [godot, "--headless", "--audio-driver", "Dummy", "--path", str(root), "--script", str(adapter["logic_script"])]
        logic = run_logged(logic_command, root, env, max(1, int(scenario["time_budget_ms"]) // 1000), output / "journey.stdout.log", output / "journey.stderr.log")
        journey: dict[str, object] = {**logic, "stdout_log": "journey.stdout.log", "stderr_log": "journey.stderr.log"}
        result["journey"] = journey
        if logic["timed_out"]:
            result.update({"status": "TIMEOUT_PARTIAL", "exit_code": 124, "note": "Semantic Greywatch journey exceeded its time budget."})
            result["duration_ms"] = round((time.time() - started) * 1000, 2)
            return write_result(output, result)
        if logic["exit_code"] != 0:
            result.update({"status": "FAIL", "exit_code": logic["exit_code"], "note": "Semantic Greywatch journey failed."})
            result["duration_ms"] = round((time.time() - started) * 1000, 2)
            return write_result(output, result)

        bindings = adapter["command_bindings"]
        result["input_trace"] = [{"command": command, "binding": bindings[command]} for command in scenario["semantic_commands"]]
        result["known_limitations"].extend(adapter.get("known_limitations", []))
        if args.capture == "1":
            capture_dir = output / "scenario-capture"
            capture_dir.mkdir(parents=True, exist_ok=True)
            viewport = adapter["viewport"]
            capture_command = [
                godot, "--path", str(root), "--script", str(adapter["capture_script"]), "--",
                f"--output-dir={capture_dir}", f"--width={viewport['width']}", f"--height={viewport['height']}",
                f"--ui-scale-index={adapter['ui_scale_index']}", f"--commander={adapter['capture_commander']}",
                f"--scenario={adapter['capture_scenario']}", *[str(value) for value in adapter["capture_arguments"]],
            ]
            if shutil.which("xvfb-run"):
                capture_command = ["xvfb-run", "-a", "--server-args=-screen 0 1280x720x24", *capture_command]
            capture = run_logged(capture_command, root, env, max(1, int(scenario["time_budget_ms"]) // 1000), output / "capture.stdout.log", output / "capture.stderr.log")
            journey["capture"] = {**capture, "stdout_log": "capture.stdout.log", "stderr_log": "capture.stderr.log"}
            if capture["timed_out"]:
                result.update({"status": "TIMEOUT_PARTIAL", "exit_code": 124, "note": "Scenario capture exceeded its time budget."})
                result["duration_ms"] = round((time.time() - started) * 1000, 2)
                return write_result(output, result)
            errors, hashes, trace = validate_capture(capture_dir, scenario)
            if capture["exit_code"] != 0:
                errors.insert(0, f"capture command exited {capture['exit_code']}")
            journey["state_sequence"] = collapsed_states(trace)
            journey["state_trace"] = trace
            journey["screenshot_paths"] = {state: f"scenario-capture/{name}" for state, name in adapter["state_screenshots"].items()}
            journey["deterministic_hashes"] = hashes
            if errors:
                journey["evidence_errors"] = errors
                result.update({"status": "INVALID_EVIDENCE", "exit_code": 2, "note": "Scenario screenshots or readiness trace were invalid."})
                result["duration_ms"] = round((time.time() - started) * 1000, 2)
                return write_result(output, result)
        else:
            result["known_limitations"].append("Visual capture disabled by AGENT_QA_CAPTURE=0.")
    elif scenario:
        result["known_limitations"].append("Scenario manifest is planned and was not executed.")

    result.update({"status": "PASS", "exit_code": 0, "duration_ms": round((time.time() - started) * 1000, 2)})
    return write_result(output, result)


if __name__ == "__main__":
    raise SystemExit(main())
