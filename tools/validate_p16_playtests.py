#!/usr/bin/env python3
"""Validate the P16 human-playtest protocol and any recorded sessions."""
from __future__ import annotations

import argparse
import json
import re
from datetime import datetime
from pathlib import Path
from typing import Any


REQUIRED_OBSERVATIONS = {
    "onboarding", "first_successful_hold", "partial_breach_recovery",
    "event_comprehension", "replay_motivation", "controller_scaling",
    "pause_trust", "save_recovery", "packaged_close",
}
ALLOWED_STATUSES = {"pass", "friction", "blocked", "not_tested"}
ALLOWED_SEVERITIES = {"critical", "high", "medium", "low"}
COMMANDERS = {"castellan", "warden"}
RUN_TYPES = {"baseline", "hardened_vanguard"}
ID_PATTERN = re.compile(r"^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
TIMESTAMP_PATTERN = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
REVISION_PATTERN = re.compile(r"^[0-9a-f]{40}$")
SHA256_PATTERN = re.compile(r"^[0-9a-f]{64}$")
PLAYTEST_GUIDE = "docs/p16_human_playtest_protocol.md"
REQUIRED_FINDING_FIELDS = {
    "id", "issue_key", "observation_id", "severity", "summary", "reproduction", "suggested_action",
}


def is_exact_unique_list(value: Any, expected: set[str]) -> bool:
    return (
        isinstance(value, list)
        and all(isinstance(item, str) for item in value)
        and len(value) == len(expected)
        and len(value) == len(set(value))
        and set(value) == expected
    )


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


def validate_protocol(
    protocol: dict[str, Any],
    ci_manifest: dict[str, Any],
    alpha_checklist: dict[str, Any],
    errors: list[str],
) -> None:
    if protocol.get("schema_version") != 1:
        errors.append("P16 protocol schema_version must be 1")
    if protocol.get("build_version") != ci_manifest.get("build_version"):
        errors.append("P16 protocol build_version must match CI manifest")
    if protocol.get("build_version") != alpha_checklist.get("build_version"):
        errors.append("P16 protocol build_version must match alpha checklist")
    if protocol.get("status") != "ready_for_human_sessions":
        errors.append("P16 protocol status must remain ready_for_human_sessions")
    if protocol.get("release_ready") is not False or ci_manifest.get("release_ready") is not False:
        errors.append("P16 protocol and CI manifest release_ready must remain false")
    if protocol.get("minimum_completed_sessions") != len(COMMANDERS) * len(RUN_TYPES):
        errors.append("P16 protocol requires exactly four minimum matrix sessions")
    matrix = protocol.get("required_matrix")
    if (
        not isinstance(matrix, dict)
        or not is_exact_unique_list(matrix.get("commanders"), COMMANDERS)
        or not is_exact_unique_list(matrix.get("run_types"), RUN_TYPES)
    ):
        errors.append("P16 protocol required_matrix must cover both commanders and run types")
    observations = protocol.get("required_observations")
    if not isinstance(observations, list):
        errors.append("P16 protocol required_observations must be an array")
    else:
        ids = [item.get("id") for item in observations if isinstance(item, dict)]
        if len(ids) != len(observations) or set(ids) != REQUIRED_OBSERVATIONS or len(ids) != len(set(ids)):
            errors.append("P16 protocol required_observations differ from the roadmap contract")
        for item in observations:
            if not isinstance(item, dict):
                continue
            for field in ("prompt", "success_signal"):
                if not isinstance(item.get(field), str) or not item[field].strip():
                    errors.append(f"P16 observation {item.get('id')} needs non-empty {field}")
    if not is_exact_unique_list(protocol.get("allowed_observation_statuses"), ALLOWED_STATUSES):
        errors.append("P16 protocol observation statuses differ from validator contract")
    if not is_exact_unique_list(protocol.get("allowed_finding_severities"), ALLOWED_SEVERITIES):
        errors.append("P16 protocol finding severities differ from validator contract")
    if not is_exact_unique_list(protocol.get("required_finding_fields"), REQUIRED_FINDING_FIELDS):
        errors.append("P16 protocol finding fields differ from validator contract")
    if protocol.get("repeat_threshold") != 2:
        errors.append("P16 protocol repeat_threshold must be 2")
    if not is_exact_unique_list(
        protocol.get("required_provenance_fields"),
        {"source_revision", "ci_run_id", "artifact.name", "artifact.sha256", "artifact.size_bytes"},
    ):
        errors.append("P16 protocol provenance fields differ from validator contract")
    for field in ("privacy_rule", "completion_rule", "finding_rule", "approval_rule"):
        if not isinstance(protocol.get(field), str) or not protocol[field].strip():
            errors.append(f"P16 protocol needs a non-empty {field}")
    gates = alpha_checklist.get("human_gates")
    playtest_gate = next((gate for gate in gates if isinstance(gate, dict) and gate.get("id") == "human_playtest"), None) if isinstance(gates, list) else None
    if not isinstance(playtest_gate, dict) or playtest_gate.get("status") != "pending":
        errors.append("human_playtest gate must remain explicitly pending before owner approval")
    elif playtest_gate.get("evidence") != PLAYTEST_GUIDE:
        errors.append("human_playtest gate must point to the P16 human playtest protocol")


def validate_session(path: Path, session: dict[str, Any], build_version: str, errors: list[str]) -> tuple[bool, tuple[str, str] | None]:
    if session.get("schema_version") != 1:
        errors.append(f"{path}: schema_version must be 1")
    if session.get("build_version") != build_version:
        errors.append(f"{path}: build_version must match the active playtest build")
    source_revision = session.get("source_revision")
    if not isinstance(source_revision, str) or not REVISION_PATTERN.fullmatch(source_revision):
        errors.append(f"{path}: source_revision must be a lowercase 40-character commit SHA")
    ci_run_id = session.get("ci_run_id")
    if type(ci_run_id) is not int or ci_run_id <= 0:
        errors.append(f"{path}: ci_run_id must be a positive integer")
    artifact = session.get("artifact")
    if not isinstance(artifact, dict):
        errors.append(f"{path}: artifact must be an object")
    else:
        artifact_name = artifact.get("name")
        if (
            not isinstance(artifact_name, str)
            or not artifact_name.strip()
            or Path(artifact_name).name != artifact_name
        ):
            errors.append(f"{path}: artifact name must be a plain filename")
        artifact_sha256 = artifact.get("sha256")
        if not isinstance(artifact_sha256, str) or not SHA256_PATTERN.fullmatch(artifact_sha256):
            errors.append(f"{path}: artifact sha256 must be 64 lowercase hexadecimal characters")
        artifact_size = artifact.get("size_bytes")
        if type(artifact_size) is not int or artifact_size <= 0:
            errors.append(f"{path}: artifact size_bytes must be a positive integer")
    session_id = session.get("session_id")
    if not isinstance(session_id, str) or not ID_PATTERN.fullmatch(session_id):
        errors.append(f"{path}: session_id must be snake_case")
    tester_alias = session.get("tester_alias")
    if not isinstance(tester_alias, str) or not ID_PATTERN.fullmatch(tester_alias):
        errors.append(f"{path}: tester_alias must be a non-identifying snake_case alias")
    recorded_at = session.get("recorded_at")
    if not isinstance(recorded_at, str) or not TIMESTAMP_PATTERN.fullmatch(recorded_at):
        errors.append(f"{path}: recorded_at must use UTC YYYY-MM-DDTHH:MM:SSZ")
    else:
        try:
            datetime.strptime(recorded_at, "%Y-%m-%dT%H:%M:%SZ")
        except ValueError:
            errors.append(f"{path}: recorded_at must be a real UTC date and time")
    for field in ("platform", "input_method", "display", "scenario"):
        if not isinstance(session.get(field), str) or not session[field].strip():
            errors.append(f"{path}: {field} must be non-empty text")
    commander = session.get("commander")
    run_type = session.get("run_type")
    if commander not in COMMANDERS:
        errors.append(f"{path}: commander is unsupported")
    if run_type not in RUN_TYPES:
        errors.append(f"{path}: run_type is unsupported")
    completed = session.get("completed")
    if not isinstance(completed, bool):
        errors.append(f"{path}: completed must be boolean")
        completed = False
    observations = session.get("observations")
    observed_ids: list[str] = []
    statuses: list[str] = []
    status_by_observation: dict[str, str] = {}
    if not isinstance(observations, list):
        errors.append(f"{path}: observations must be an array")
    else:
        for observation in observations:
            if not isinstance(observation, dict):
                errors.append(f"{path}: observation must be an object")
                continue
            observation_id = observation.get("id")
            status = observation.get("status")
            notes = observation.get("notes")
            observed_ids.append(observation_id if isinstance(observation_id, str) else "")
            statuses.append(status if isinstance(status, str) else "")
            if isinstance(observation_id, str) and isinstance(status, str):
                status_by_observation[observation_id] = status
            if observation_id not in REQUIRED_OBSERVATIONS:
                errors.append(f"{path}: unknown observation id: {observation_id}")
            if status not in ALLOWED_STATUSES:
                errors.append(f"{path}: observation {observation_id} has unsupported status")
            if not isinstance(notes, str):
                errors.append(f"{path}: observation {observation_id} notes must be text")
            if status in {"friction", "blocked"} and (not isinstance(notes, str) or not notes.strip()):
                errors.append(f"{path}: observation {observation_id} needs notes for {status}")
        if set(observed_ids) != REQUIRED_OBSERVATIONS or len(observed_ids) != len(set(observed_ids)):
            errors.append(f"{path}: observations must contain every required ID exactly once")
    if completed and "not_tested" in statuses:
        errors.append(f"{path}: completed session cannot contain not_tested observations")
    findings = session.get("findings")
    if not isinstance(findings, list):
        errors.append(f"{path}: findings must be an array")
    else:
        finding_ids: set[str] = set()
        finding_issue_keys: set[str] = set()
        finding_observation_ids: set[str] = set()
        for finding in findings:
            if not isinstance(finding, dict):
                errors.append(f"{path}: finding must be an object")
                continue
            finding_id = finding.get("id")
            if not isinstance(finding_id, str) or not ID_PATTERN.fullmatch(finding_id) or finding_id in finding_ids:
                errors.append(f"{path}: finding id must be unique snake_case")
            else:
                finding_ids.add(finding_id)
            issue_key = finding.get("issue_key")
            if not isinstance(issue_key, str) or not ID_PATTERN.fullmatch(issue_key) or issue_key in finding_issue_keys:
                errors.append(f"{path}: finding issue_key must be unique snake_case within a session")
            else:
                finding_issue_keys.add(issue_key)
            if finding.get("severity") not in ALLOWED_SEVERITIES:
                errors.append(f"{path}: finding severity is unsupported")
            observation_id = finding.get("observation_id")
            if observation_id not in REQUIRED_OBSERVATIONS:
                errors.append(f"{path}: finding must reference a required observation_id")
            else:
                finding_observation_ids.add(str(observation_id))
                if status_by_observation.get(str(observation_id)) not in {"friction", "blocked"}:
                    errors.append(f"{path}: finding observation_id must reference friction or blocked status")
            for field in ("summary", "reproduction", "suggested_action"):
                if not isinstance(finding.get(field), str) or not finding[field].strip():
                    errors.append(f"{path}: finding {field} must be non-empty text")
        for observation_id, status in status_by_observation.items():
            if status in {"friction", "blocked"} and observation_id not in finding_observation_ids:
                errors.append(f"{path}: observation {observation_id} needs a linked finding")
    observer_summary = session.get("observer_summary")
    if not isinstance(observer_summary, str):
        errors.append(f"{path}: observer_summary must be text")
    elif completed and not observer_summary.strip():
        errors.append(f"{path}: completed session needs an observer_summary")
    return bool(completed), (str(commander), str(run_type)) if completed and commander in COMMANDERS and run_type in RUN_TYPES else None


def load_and_validate_evidence(
    protocol_path: Path,
    sessions_directory: Path,
    ci_manifest_path: Path,
    alpha_checklist_path: Path,
) -> dict[str, Any]:
    errors: list[str] = []
    protocol = load_object(protocol_path, errors)
    ci_manifest = load_object(ci_manifest_path, errors)
    alpha_checklist = load_object(alpha_checklist_path, errors)
    validate_protocol(protocol, ci_manifest, alpha_checklist, errors)
    if not sessions_directory.is_dir():
        errors.append(f"{sessions_directory}: sessions directory does not exist")
    session_paths = sorted(sessions_directory.glob("*.json")) if sessions_directory.is_dir() else []
    session_ids: set[str] = set()
    completed_count = 0
    completed_matrix: set[tuple[str, str]] = set()
    completed_cohorts: dict[tuple[str, str], set[tuple[str, str]]] = {}
    sessions: list[dict[str, Any]] = []
    for path in session_paths:
        session = load_object(path, errors)
        session_id = session.get("session_id")
        if isinstance(session_id, str):
            if session_id in session_ids:
                errors.append(f"duplicate playtest session id: {session_id}")
            session_ids.add(session_id)
        completed, matrix_entry = validate_session(path, session, str(protocol.get("build_version", "")), errors)
        if completed:
            completed_count += 1
        if matrix_entry is not None:
            completed_matrix.add(matrix_entry)
            artifact = session.get("artifact")
            if isinstance(session.get("source_revision"), str) and isinstance(artifact, dict) and isinstance(artifact.get("sha256"), str):
                cohort = (str(session["source_revision"]), str(artifact["sha256"]))
                completed_cohorts.setdefault(cohort, set()).add(matrix_entry)
        sessions.append({"path": path, "session": session, "completed": completed, "matrix_entry": matrix_entry})
    return {
        "protocol": protocol,
        "sessions": sessions,
        "completed_count": completed_count,
        "completed_matrix": completed_matrix,
        "completed_cohorts": completed_cohorts,
        "errors": errors,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--protocol", required=True)
    parser.add_argument("--sessions", required=True)
    parser.add_argument("--ci-manifest", required=True)
    parser.add_argument("--alpha-checklist", required=True)
    args = parser.parse_args()
    evidence = load_and_validate_evidence(
        Path(args.protocol), Path(args.sessions), Path(args.ci_manifest), Path(args.alpha_checklist)
    )
    errors = evidence["errors"]
    protocol = evidence["protocol"]
    if errors:
        print(f"P16 playtest protocol: BLOCK ({len(errors)} errors)")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    completed_count = int(evidence["completed_count"])
    required_matrix = {(commander, run_type) for commander in COMMANDERS for run_type in RUN_TYPES}
    matrix_status = "complete" if any(required_matrix <= matrix for matrix in evidence["completed_cohorts"].values()) else "pending"
    print(f"P16 playtest protocol: READY ({len(evidence['sessions'])} records, {completed_count} completed, matrix {matrix_status}; human gate remains pending)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
