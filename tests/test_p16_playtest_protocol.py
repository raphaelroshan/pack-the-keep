#!/usr/bin/env python3
"""Regression coverage for P16 playtest evidence tooling."""
from __future__ import annotations

import copy
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import validate_p16_playtests as validator  # noqa: E402


def load(relative_path: str) -> dict:
    return json.loads((ROOT / relative_path).read_text(encoding="utf-8"))


class P16PlaytestProtocolTests(unittest.TestCase):
    def test_protocol_matches_build_and_keeps_human_gate_pending(self) -> None:
        errors: list[str] = []
        validator.validate_protocol(
            load("content/p16_playtest_protocol.json"),
            load("tools/ci_manifest.json"),
            load("content/p12_alpha_checklist.json"),
            errors,
        )
        self.assertFalse(errors)

    def test_protocol_rejects_missing_observation_and_release_claim(self) -> None:
        protocol = copy.deepcopy(load("content/p16_playtest_protocol.json"))
        protocol["required_observations"].pop()
        protocol["release_ready"] = True
        errors: list[str] = []
        validator.validate_protocol(protocol, load("tools/ci_manifest.json"), load("content/p12_alpha_checklist.json"), errors)
        joined = "\n".join(errors)
        self.assertIn("required_observations differ", joined)
        self.assertIn("release_ready must remain false", joined)

    def test_generator_creates_unfilled_privacy_light_record(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "session_001.json"
            subprocess.run(
                [
                    sys.executable, str(ROOT / "tools/new_playtest_session.py"),
                    "--protocol", str(ROOT / "content/p16_playtest_protocol.json"),
                    "--session-id", "session_001", "--tester-alias", "tester_a",
                    "--commander", "castellan", "--run-type", "baseline",
                    "--scenario", "gatehouse_lock", "--output", str(output),
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            record = json.loads(output.read_text(encoding="utf-8"))
            self.assertFalse(record["completed"])
            self.assertEqual({item["id"] for item in record["observations"]}, validator.REQUIRED_OBSERVATIONS)
            self.assertEqual({item["status"] for item in record["observations"]}, {"not_tested"})
            errors: list[str] = []
            completed, matrix_entry = validator.validate_session(output, record, record["build_version"], errors)
            self.assertFalse(completed)
            self.assertIsNone(matrix_entry)
            self.assertFalse(errors)

    def test_generator_rejects_identifying_or_malformed_aliases(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                [
                    sys.executable, str(ROOT / "tools/new_playtest_session.py"),
                    "--protocol", str(ROOT / "content/p16_playtest_protocol.json"),
                    "--session-id", "session_004", "--tester-alias", "name@example.com",
                    "--commander", "castellan", "--run-type", "baseline",
                    "--scenario", "gatehouse_lock", "--output", str(Path(directory) / "session.json"),
                ],
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("snake_case", result.stderr)

    def test_completed_session_requires_every_observation(self) -> None:
        protocol = load("content/p16_playtest_protocol.json")
        record = {
            "schema_version": 1,
            "build_version": protocol["build_version"],
            "session_id": "session_002",
            "tester_alias": "tester_b",
            "recorded_at": "2026-08-28T06:00:00Z",
            "platform": "windows_packaged",
            "input_method": "xbox_controller",
            "display": "1920x1080_fullscreen",
            "commander": "warden",
            "run_type": "hardened_vanguard",
            "scenario": "ash_ford_crossing",
            "completed": True,
            "observations": [
                {"id": item["id"], "status": "pass", "notes": "Observed directly."}
                for item in protocol["required_observations"]
            ],
            "findings": [],
            "observer_summary": "Completed the required path.",
        }
        errors: list[str] = []
        completed, matrix_entry = validator.validate_session(Path("session_002.json"), record, protocol["build_version"], errors)
        self.assertTrue(completed)
        self.assertEqual(matrix_entry, ("warden", "hardened_vanguard"))
        self.assertFalse(errors)
        record["observations"][0]["status"] = "not_tested"
        errors = []
        validator.validate_session(Path("session_002.json"), record, protocol["build_version"], errors)
        self.assertIn("completed session cannot contain not_tested", "\n".join(errors))

    def test_friction_and_findings_require_actionable_text(self) -> None:
        protocol = load("content/p16_playtest_protocol.json")
        record = {
            "schema_version": 1,
            "build_version": protocol["build_version"],
            "session_id": "session_003",
            "tester_alias": "tester_c",
            "recorded_at": "2026-08-28T06:00:00Z",
            "platform": "windows_packaged",
            "input_method": "keyboard_mouse",
            "display": "1280x720_windowed",
            "commander": "castellan",
            "run_type": "baseline",
            "scenario": "gatehouse_lock",
            "completed": False,
            "observations": [
                {"id": item["id"], "status": "friction" if index == 0 else "not_tested", "notes": ""}
                for index, item in enumerate(protocol["required_observations"])
            ],
            "findings": [{"id": "unclear_start", "severity": "urgent", "summary": "", "reproduction": ""}],
            "observer_summary": "",
        }
        errors: list[str] = []
        validator.validate_session(Path("session_003.json"), record, protocol["build_version"], errors)
        joined = "\n".join(errors)
        self.assertIn("needs notes for friction", joined)
        self.assertIn("finding severity is unsupported", joined)
        self.assertIn("finding must reference a required observation_id", joined)
        self.assertIn("finding summary must be non-empty", joined)
        self.assertIn("finding reproduction must be non-empty", joined)
        self.assertIn("finding suggested_action must be non-empty", joined)

    def test_complete_matrix_still_reports_human_gate_pending(self) -> None:
        protocol = load("content/p16_playtest_protocol.json")
        with tempfile.TemporaryDirectory() as directory:
            sessions = Path(directory)
            index = 0
            for commander in ("castellan", "warden"):
                for run_type in ("baseline", "hardened_vanguard"):
                    index += 1
                    record = {
                        "schema_version": 1,
                        "build_version": protocol["build_version"],
                        "session_id": f"matrix_{index}",
                        "tester_alias": f"tester_{index}",
                        "recorded_at": f"2026-08-28T06:00:0{index}Z",
                        "platform": "windows_packaged",
                        "input_method": "keyboard_mouse",
                        "display": "1280x720_windowed",
                        "commander": commander,
                        "run_type": run_type,
                        "scenario": "gatehouse_lock",
                        "completed": True,
                        "observations": [
                            {"id": item["id"], "status": "pass", "notes": "Observed directly."}
                            for item in protocol["required_observations"]
                        ],
                        "findings": [],
                        "observer_summary": "Completed the required observed flow.",
                    }
                    (sessions / f"matrix_{index}.json").write_text(json.dumps(record), encoding="utf-8")
            result = subprocess.run(
                [
                    sys.executable, str(ROOT / "tools/validate_p16_playtests.py"),
                    "--protocol", str(ROOT / "content/p16_playtest_protocol.json"),
                    "--sessions", str(sessions),
                    "--ci-manifest", str(ROOT / "tools/ci_manifest.json"),
                    "--alpha-checklist", str(ROOT / "content/p12_alpha_checklist.json"),
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            self.assertIn("matrix complete", result.stdout)
            self.assertIn("human gate remains pending", result.stdout)


if __name__ == "__main__":
    unittest.main()
