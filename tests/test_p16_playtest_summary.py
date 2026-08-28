#!/usr/bin/env python3
"""Regression coverage for deterministic P16 playtest triage summaries."""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import summarize_p16_playtests as summary  # noqa: E402
import validate_p16_playtests as validator  # noqa: E402


def base_record(protocol: dict, session_id: str) -> dict:
    return {
        "schema_version": 1,
        "build_version": protocol["build_version"],
        "source_revision": "a" * 40,
        "artifact": {"name": "pack-the-keep.exe", "sha256": "b" * 64, "size_bytes": 1024},
        "session_id": session_id,
        "tester_alias": f"tester_{session_id}",
        "recorded_at": "2026-08-28T07:00:00Z",
        "platform": "windows_packaged",
        "input_method": "keyboard_mouse",
        "display": "1280x720_windowed",
        "commander": "castellan",
        "run_type": "baseline",
        "scenario": "gatehouse_lock",
        "completed": False,
        "observations": [
            {"id": observation_id, "status": "not_tested", "notes": ""}
            for observation_id in sorted(validator.REQUIRED_OBSERVATIONS)
        ],
        "findings": [],
        "observer_summary": "",
    }


class P16PlaytestSummaryTests(unittest.TestCase):
    def load_evidence(self, sessions: Path) -> dict:
        return validator.load_and_validate_evidence(
            ROOT / "content/p16_playtest_protocol.json",
            sessions,
            ROOT / "tools/ci_manifest.json",
            ROOT / "content/p12_alpha_checklist.json",
        )

    def test_empty_summary_reports_pending_without_inventing_findings(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            evidence = self.load_evidence(Path(directory))
            self.assertFalse(evidence["errors"])
            rendered = summary.render_summary(evidence)
            self.assertIn("Records: 0 total; 0 completed.", rendered)
            self.assertIn("Human playtest gate: **PENDING**", rendered)
            self.assertIn("No completed artifact cohort recorded.", rendered)
            self.assertIn("No human findings recorded.", rendered)

    def test_repeated_issue_keys_become_deterministic_task_candidates(self) -> None:
        protocol = json.loads((ROOT / "content/p16_playtest_protocol.json").read_text(encoding="utf-8"))
        with tempfile.TemporaryDirectory() as directory:
            sessions = Path(directory)
            for index, severity in enumerate(("medium", "high"), start=1):
                record = base_record(protocol, f"session_{index}")
                onboarding = next(item for item in record["observations"] if item["id"] == "onboarding")
                onboarding.update({"status": "friction", "notes": "Primary action was missed."})
                record["findings"] = [{
                    "id": f"primary_action_{index}",
                    "issue_key": "onboarding_primary_action",
                    "observation_id": "onboarding",
                    "severity": severity,
                    "summary": "The primary action did not read as the next step.",
                    "reproduction": "Open the title and enter Preparation at 1280x720.",
                    "suggested_action": "Increase hierarchy around the primary action without moving the fort.",
                }]
                (sessions / f"session_{index}.json").write_text(json.dumps(record), encoding="utf-8")
            evidence = self.load_evidence(sessions)
            self.assertFalse(evidence["errors"])
            rendered = summary.render_summary(evidence)
            self.assertIn("`onboarding_primary_action` — high — 2 sessions", rendered)
            self.assertIn("Sessions: session_1, session_2", rendered)
            self.assertIn("Suggested reversible actions", rendered)

    def test_invalid_issue_key_blocks_summary_input(self) -> None:
        protocol = json.loads((ROOT / "content/p16_playtest_protocol.json").read_text(encoding="utf-8"))
        with tempfile.TemporaryDirectory() as directory:
            sessions = Path(directory)
            record = base_record(protocol, "session_bad")
            record["findings"] = [{
                "id": "finding_one",
                "issue_key": "Not stable",
                "observation_id": "onboarding",
                "severity": "medium",
                "summary": "Summary",
                "reproduction": "Reproduction",
                "suggested_action": "Action",
            }]
            onboarding = next(item for item in record["observations"] if item["id"] == "onboarding")
            onboarding.update({"status": "friction", "notes": "Observed friction."})
            (sessions / "session_bad.json").write_text(json.dumps(record), encoding="utf-8")
            evidence = self.load_evidence(sessions)
            self.assertIn("finding issue_key must be unique snake_case", "\n".join(evidence["errors"]))

    def test_duplicate_issue_key_within_one_session_is_not_repetition(self) -> None:
        protocol = json.loads((ROOT / "content/p16_playtest_protocol.json").read_text(encoding="utf-8"))
        with tempfile.TemporaryDirectory() as directory:
            sessions = Path(directory)
            record = base_record(protocol, "session_duplicate")
            onboarding = next(item for item in record["observations"] if item["id"] == "onboarding")
            onboarding.update({"status": "friction", "notes": "Observed friction."})
            finding = {
                "issue_key": "onboarding_primary_action",
                "observation_id": "onboarding",
                "severity": "medium",
                "summary": "Summary",
                "reproduction": "Reproduction",
                "suggested_action": "Action",
            }
            record["findings"] = [dict(finding, id="finding_one"), dict(finding, id="finding_two")]
            (sessions / "session_duplicate.json").write_text(json.dumps(record), encoding="utf-8")
            evidence = self.load_evidence(sessions)
            self.assertIn("finding issue_key must be unique snake_case within a session", "\n".join(evidence["errors"]))


if __name__ == "__main__":
    unittest.main()
