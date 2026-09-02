from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("validate_early_access_progress", ROOT / "tools" / "validate_early_access_progress.py")
assert SPEC and SPEC.loader
validator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validator)


class EarlyAccessProgressValidatorTests(unittest.TestCase):
    def test_repository_records_complete_automated_candidate(self) -> None:
        errors: list[str] = []
        progress = json.loads((ROOT / "content" / "early_access_progress.json").read_text(encoding="utf-8"))
        manifest = json.loads((ROOT / "tools" / "ci_manifest.json").read_text(encoding="utf-8"))
        validator.validate_progress(progress, manifest, ROOT, errors)
        self.assertEqual(errors, [])
        self.assertTrue(progress["early_access_ready"])
        self.assertEqual(progress["status"], "candidate")
        self.assertEqual([row["status"] for row in progress["milestones"]], ["implemented"] * 6)
        self.assertEqual(progress["active_temporary_asset_families"], [])
        self.assertTrue(progress["owner_approval_required_for_distribution"])

    def test_rejects_stale_inventory_incomplete_readiness_and_missing_evidence(self) -> None:
        progress = json.loads((ROOT / "content" / "early_access_progress.json").read_text(encoding="utf-8"))
        progress["milestones"][4]["status"] = "planned"
        progress["milestones"][4].pop("requirements")
        progress["next_milestone"] = "PTK-EA-5"
        progress["current_inventory"]["packs"] = 99
        progress["milestones"][0]["requirements"][0]["evidence"] = ["missing.md"]
        errors: list[str] = []
        validator.validate_progress(progress, {"build_version": progress["build_version"]}, ROOT, errors)
        joined = "\n".join(errors)
        self.assertIn("cannot be ready", joined)
        self.assertIn("inventory is stale", joined)
        self.assertIn("missing evidence", joined)

    def test_rejects_escaped_evidence_path(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            progress = json.loads((ROOT / "content" / "early_access_progress.json").read_text(encoding="utf-8"))
            progress["milestones"][0]["requirements"][0]["evidence"] = ["../outside.md"]
            errors: list[str] = []
            validator.validate_progress(progress, {"build_version": progress["build_version"]}, root, errors)
            self.assertIn("missing evidence", "\n".join(errors))


if __name__ == "__main__":
    unittest.main()
