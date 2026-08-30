from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("validate_k8_private_alpha", ROOT / "tools" / "validate_k8_private_alpha.py")
assert SPEC and SPEC.loader
validator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validator)


class K8PrivateAlphaValidatorTests(unittest.TestCase):
    def test_repository_gate_is_complete_and_non_releasing(self) -> None:
        errors: list[str] = []
        gate = json.loads((ROOT / "content" / "k8_private_alpha_gate.json").read_text(encoding="utf-8"))
        manifest = json.loads((ROOT / "tools" / "ci_manifest.json").read_text(encoding="utf-8"))
        validator.validate_gate(gate, manifest, ROOT, errors)
        self.assertEqual(errors, [])
        self.assertFalse(gate["release_ready"])
        self.assertFalse(gate["public_alpha_ready"])
        self.assertFalse(gate["storefront_ready"])

    def test_rejects_release_claims_missing_evidence_and_human_boundary_changes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            gate = {
                "schema_version": 1,
                "build_version": "wrong",
                "status": "complete",
                "release_ready": True,
                "public_alpha_ready": True,
                "storefront_ready": True,
                "required_areas": [{"id": "accessibility", "status": "done", "evidence": ["missing"]}],
                "performance_budget": {"simulation_runs": 0},
                "pending_human_gates": [],
                "known_limitations": "../escaped.md",
            }
            errors: list[str] = []
            validator.validate_gate(gate, {"build_version": "v"}, root, errors)
            joined = "\n".join(errors)
            self.assertIn("release_ready must remain false", joined)
            self.assertIn("missing evidence", joined)
            self.assertIn("human approval boundary", joined)
            self.assertIn("known limitations", joined)

    def test_packaged_lifecycle_requires_clean_install_reinstall_and_migration_evidence(self) -> None:
        report = {"schema_version": 3, "forced_close": {"ready": True, "terminated": True, "exit_code": -9}}
        for phase in validator.PACKAGED_PHASES:
            report[phase] = {
                "phase": phase,
                "ok": True,
                "errors": [],
                "build_version": "v",
                "offline_proxy_guard": True,
                "main_scene_freed": True,
            }
        report["clean_install"].update({
            "controller_navigation_ready": True,
            "controller_remap_ready": True,
            "ui_scale_ready": True,
            "initial_realtime_ready": True,
            "paused_state_frozen": True,
        })
        report["reinstall"].update({"restored_run_ready": True, "restored_scale_ready": True, "restored_remap_ready": True})
        report["upgrade"].update({
            "legacy_profile_detected": True,
            "upgrade_run_migrated": True,
            "upgrade_settings_ready": True,
            "upgraded_files_current": True,
        })
        report["forced_close_recovery"].update({
            "forced_close_detected": True,
            "forced_close_run_recovered": True,
            "forced_close_settings_recovered": True,
            "forced_close_files_current": True,
        })
        errors: list[str] = []
        validator.validate_packaged_report(report, "v", errors)
        self.assertEqual(errors, [])
        report["upgrade"]["upgraded_files_current"] = False
        validator.validate_packaged_report(report, "v", errors)
        self.assertIn("migration evidence failed", "\n".join(errors))


if __name__ == "__main__":
    unittest.main()
