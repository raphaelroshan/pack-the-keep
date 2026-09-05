from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("validate_gpt56_progress", ROOT / "tools" / "validate_gpt56_progress.py")
assert SPEC and SPEC.loader
validator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validator)


class GPT56ProgressValidatorTests(unittest.TestCase):
    def _load(self) -> tuple[dict, list[dict]]:
        progress = json.loads((ROOT / "content" / "gpt56_progress.json").read_text(encoding="utf-8"))
        manifests = [
            json.loads((ROOT / "tools" / "ci_manifest.json").read_text(encoding="utf-8")),
            json.loads((ROOT / "content" / "gameplay_framework.json").read_text(encoding="utf-8")),
            json.loads((ROOT / "content" / "investment_progress.json").read_text(encoding="utf-8")),
            json.loads((ROOT / "content" / "early_access_progress.json").read_text(encoding="utf-8")),
            json.loads((ROOT / "content" / "k8_private_alpha_gate.json").read_text(encoding="utf-8")),
        ]
        return progress, manifests

    def test_repository_records_complete_gpt56_sequence(self) -> None:
        progress, manifests = self._load()
        errors: list[str] = []
        validator.validate_progress(progress, manifests, ROOT, errors)
        self.assertEqual(errors, [])
        self.assertEqual([packet["id"] for packet in progress["packets"]], [f"PTK-GPT56-{index}" for index in range(1, 6)])
        self.assertEqual([packet["id"] for packet in progress["follow_up_packets"]], ["PTK-GPT56-1C"])
        self.assertEqual(progress["next_packet"], "PTK-P16")
        self.assertEqual(progress["human_evidence_status"], "pending")
        self.assertTrue(progress["owner_approval_required_for_distribution"])

    def test_rejects_stale_version_missing_evidence_and_false_boundary(self) -> None:
        progress, manifests = self._load()
        progress["build_version"] = "stale"
        progress["packets"][0]["requirements"][0]["evidence"] = ["missing.file"]
        progress["owner_approval_required_for_distribution"] = False
        errors: list[str] = []
        validator.validate_progress(progress, manifests, ROOT, errors)
        joined = "\n".join(errors)
        self.assertIn("build_version", joined)
        self.assertIn("missing evidence", joined)
        self.assertIn("owner approval", joined)

    def test_rejects_incomplete_matrix_and_weak_enemy_contract(self) -> None:
        progress, manifests = self._load()
        catalogs = {
            folder: validator._catalog(ROOT, folder, [])
            for folder in ("commanders", "keeps", "packs", "enemies", "scenarios", "events", "pieces")
        }
        catalogs = copy.deepcopy(catalogs)
        catalogs["keeps"]["greywatch_keep"]["doctrine_geometry"] = catalogs["keeps"]["greywatch_keep"]["doctrine_geometry"][:-1]
        catalogs["enemies"]["raider"]["counter_families"] = ["frontline"]
        errors: list[str] = []
        validator.validate_progress(copy.deepcopy(progress), manifests, ROOT, errors, catalogs=catalogs, validate_captures=False)
        joined = "\n".join(errors)
        self.assertIn("cover every active commander", joined)
        self.assertIn("at least two counters", joined)

    def test_rejects_incomplete_follow_up_packet(self) -> None:
        progress, manifests = self._load()
        progress["follow_up_packets"][0]["requirements"] = progress["follow_up_packets"][0]["requirements"][:-1]
        errors: list[str] = []
        validator.validate_progress(progress, manifests, ROOT, errors, validate_captures=False)
        self.assertIn("PTK-GPT56-1C is missing requirement: authoritative_state", "\n".join(errors))


if __name__ == "__main__":
    unittest.main()
