from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("validate_p12_alpha", ROOT / "tools" / "validate_p12_alpha.py")
assert SPEC and SPEC.loader
validator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validator)


class P12AlphaValidatorTests(unittest.TestCase):
    def test_accepts_complete_initial_and_reinstall_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "report.json"
            content_status = {
                "ok": True, "commander_count": 2, "piece_count": 17, "pack_count": 9,
                "enemy_count": 7, "doctrine_count": 8, "scenario_count": 8,
                "event_count": 3, "modifier_count": 2,
            }
            shared = {
                "ok": True, "build_version": "v", "editor_feature": False,
                "errors": [],
                "smoke_guard": True, "offline_proxy_guard": True, "main_scene_freed": True,
                "battle_step": 1, "save_schema_version": 4, "settings_schema_version": 4,
                "controller_navigation_ready": True, "controller_defaults_ready": True,
                "content_status": content_status, "user_data_dir": r"C:\\profile",
                "save_path": r"C:\\profile\\run.save", "settings_path": r"C:\\profile\\settings.json",
            }
            initial = {
                **shared, "phase": "initial", "executable_path": r"C:\\build\\pack-the-keep.exe",
                "profile_files_present": False, "controller_remap_ready": True,
                "ui_scale_ready": True, "settings_scale_ready": True, "settings_remap_ready": True,
                "initial_pause_ready": True, "paused_state_frozen": True,
                "remapped_pause_ready": True, "manual_step_ready": True,
            }
            reinstall = {
                **shared, "phase": "reinstall", "executable_path": r"C:\\reinstalled-app\\pack-the-keep.exe",
                "profile_files_present": True, "profile_files_complete": True, "restored_run_ready": True,
                "restored_scale_ready": True, "restored_remap_ready": True,
            }
            path.write_text(json.dumps({"schema_version": 1, "initial": initial, "reinstall": reinstall}), encoding="utf-8")
            errors: list[str] = []
            validator.validate_report(path, "v", errors)
            self.assertEqual(errors, [])

    def test_rejects_incomplete_packaged_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "report.json"
            path.write_text(json.dumps({
                "schema_version": 1,
                "initial": {
                    "phase": "initial", "ok": True, "build_version": "v", "main_scene_freed": False,
                    "errors": ["failure"],
                    "profile_files_present": True, "executable_path": r"C:\\same\\pack-the-keep.exe",
                    "user_data_dir": r"C:\\first", "save_path": r"C:\\escaped\\run.save",
                    "settings_path": r"C:\\first\\settings.json",
                },
                "reinstall": {
                    "phase": "reinstall", "ok": True, "build_version": "v", "main_scene_freed": True,
                    "profile_files_present": True, "profile_files_complete": False,
                    "executable_path": r"C:\\same\\pack-the-keep.exe", "user_data_dir": r"C:\\second",
                    "save_path": r"C:\\second\\run.save", "settings_path": r"C:\\second\\settings.json",
                },
            }), encoding="utf-8")
            errors: list[str] = []
            validator.validate_report(path, "v", errors)
            joined = "\n".join(errors)
            self.assertIn("close cleanly", joined)
            self.assertIn("controller_navigation_ready", joined)
            self.assertIn("restored_run_ready", joined)
            self.assertIn("clean profile", joined)
            self.assertIn("relocate the executable", joined)
            self.assertIn("changed user_data_dir", joined)
            self.assertIn("runtime errors", joined)
            self.assertIn("outside user data", joined)


if __name__ == "__main__":
    unittest.main()
