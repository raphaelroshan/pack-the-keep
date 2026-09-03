from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("validate_investment_progress", ROOT / "tools" / "validate_investment_progress.py")
assert SPEC and SPEC.loader
validator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validator)


class InvestmentProgressValidatorTests(unittest.TestCase):
    def _load(self) -> tuple[dict, dict, dict]:
        progress = json.loads((ROOT / "content" / "investment_progress.json").read_text(encoding="utf-8"))
        manifest = json.loads((ROOT / "tools" / "ci_manifest.json").read_text(encoding="utf-8"))
        early_access = json.loads((ROOT / "content" / "early_access_progress.json").read_text(encoding="utf-8"))
        return progress, manifest, early_access

    def test_repository_records_complete_investment_vertical(self) -> None:
        progress, manifest, early_access = self._load()
        errors: list[str] = []
        validator.validate_progress(progress, manifest, early_access, ROOT, errors)
        self.assertEqual(errors, [])
        self.assertTrue(progress["investment_vertical_complete"])
        self.assertEqual([gate["status"] for gate in progress["gates"]], ["implemented"] * 6)
        self.assertEqual(progress["human_evidence_status"], "pending")
        self.assertTrue(progress["owner_approval_required_for_distribution"])

    def test_rejects_false_completion_stale_version_and_missing_evidence(self) -> None:
        progress, manifest, early_access = self._load()
        progress["gates"][4]["status"] = "planned"
        progress["gates"][4].pop("requirements")
        progress["next_gate"] = "PTK-I5"
        progress["build_version"] = "stale"
        progress["gates"][0]["requirements"][0]["evidence"] = ["missing.png"]
        errors: list[str] = []
        validator.validate_progress(progress, manifest, early_access, ROOT, errors)
        joined = "\n".join(errors)
        self.assertIn("build_version", joined)
        self.assertIn("cannot be complete", joined)
        self.assertIn("missing evidence", joined)

    def test_rejects_escaped_evidence_and_distribution_claim(self) -> None:
        progress, manifest, early_access = self._load()
        progress["gates"][0]["requirements"][0]["evidence"] = ["../outside.md"]
        progress["owner_approval_required_for_distribution"] = False
        with tempfile.TemporaryDirectory() as directory:
            errors: list[str] = []
            validator.validate_progress(progress, manifest, early_access, Path(directory), errors)
        joined = "\n".join(errors)
        self.assertIn("missing evidence", joined)
        self.assertIn("owner approval", joined)

    def test_rejects_stale_or_non_setup_board_first_capture(self) -> None:
        progress, _manifest, _early_access = self._load()
        relative = "docs/visual_evidence/v0.60.0-board-first-greywatch-1280x720/capture-manifest.json"
        capture = json.loads((ROOT / relative).read_text(encoding="utf-8"))
        capture["resolution"] = {"width": 1024, "height": 768}
        capture["setup_only"] = False
        errors: list[str] = []
        validator.validate_preparation_capture(capture, relative, progress["build_version"], "gatehouse_lock", {"width": 1280, "height": 720}, ROOT, errors, True)
        joined = "\n".join(errors)
        self.assertIn("1280x720", joined)
        self.assertIn("setup-only", joined)


if __name__ == "__main__":
    unittest.main()
