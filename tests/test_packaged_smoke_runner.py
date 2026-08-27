from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("run_packaged_smoke", ROOT / "tools" / "run_packaged_smoke.py")
assert SPEC and SPEC.loader
runner = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(runner)


class PackagedSmokeReportTests(unittest.TestCase):
    def test_accepts_complete_report_inside_profile(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            report_path = root / "Godot" / "app_userdata" / "Pack the Keep" / "packaged_smoke_report.json"
            report_path.parent.mkdir(parents=True)
            report_path.write_text(json.dumps({
                "schema_version": 1,
                "phase": "initial",
                "ok": True,
                "errors": [],
                "build_version": "0.12.0-alpha-packaged-smoke",
                "editor_feature": False,
                "offline_proxy_guard": True,
                "smoke_guard": True,
                "main_scene_freed": True,
                "battle_step": 1,
                "save_schema_version": 4,
                "settings_schema_version": 4,
                "controller_navigation_ready": True,
                "controller_defaults_ready": True,
                "controller_remap_ready": True,
                "ui_scale_ready": True,
                "settings_scale_ready": True,
                "settings_remap_ready": True,
                "initial_pause_ready": True,
                "paused_state_frozen": True,
                "remapped_pause_ready": True,
                "manual_step_ready": True,
                "profile_files_present": False,
                "profile_files_complete": False,
                "content_status": {"ok": True, "commander_count": 2, "piece_count": 17, "pack_count": 9, "enemy_count": 7, "doctrine_count": 8, "scenario_count": 8, "event_count": 3, "modifier_count": 2},
                "user_data_dir": str(report_path.parent),
                "save_path": str(report_path.parent / "pack_the_keep_prototype.save"),
                "settings_path": str(report_path.parent / "pack_the_keep_settings.json"),
            }), encoding="utf-8")
            self.assertEqual(runner.validate_report(report_path, root, "0.12.0-alpha-packaged-smoke", "initial"), [])

    def test_accepts_reinstalled_report_with_restored_profile(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            report_path = root / "Godot" / "app_userdata" / "Pack the Keep" / "packaged_smoke_report.json"
            report_path.parent.mkdir(parents=True)
            report_path.write_text(json.dumps({
                "schema_version": 1, "phase": "reinstall", "ok": True, "errors": [],
                "build_version": "0.12.0-alpha-packaged-smoke", "editor_feature": False,
                "offline_proxy_guard": True, "smoke_guard": True, "main_scene_freed": True,
                "battle_step": 1, "save_schema_version": 4, "settings_schema_version": 4,
                "controller_navigation_ready": True, "controller_defaults_ready": True,
                "profile_files_present": True, "profile_files_complete": True, "restored_run_ready": True,
                "restored_scale_ready": True, "restored_remap_ready": True,
                "content_status": {"ok": True, "commander_count": 2, "piece_count": 17, "pack_count": 9, "enemy_count": 7, "doctrine_count": 8, "scenario_count": 8, "event_count": 3, "modifier_count": 2},
                "user_data_dir": str(report_path.parent),
                "save_path": str(report_path.parent / "packaged_smoke_run.save"),
                "settings_path": str(report_path.parent / "packaged_smoke_settings.json"),
            }), encoding="utf-8")
            self.assertEqual(runner.validate_report(report_path, root, "0.12.0-alpha-packaged-smoke", "reinstall"), [])

    def test_rejects_editor_or_escaped_user_data(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            report_path = root / "packaged_smoke_report.json"
            report_path.write_text(json.dumps({
                "schema_version": 1,
                "phase": "wrong",
                "ok": True,
                "errors": ["runtime failure"],
                "build_version": "wrong",
                "editor_feature": True,
                "offline_proxy_guard": False,
                "smoke_guard": False,
                "main_scene_freed": False,
                "battle_step": 0,
                "save_schema_version": 3,
                "settings_schema_version": 3,
                "controller_navigation_ready": False,
                "controller_defaults_ready": False,
                "controller_remap_ready": False,
                "ui_scale_ready": False,
                "settings_scale_ready": False,
                "settings_remap_ready": False,
                "initial_pause_ready": False,
                "paused_state_frozen": False,
                "remapped_pause_ready": False,
                "manual_step_ready": False,
                "profile_files_present": True,
                "profile_files_complete": True,
                "content_status": {"ok": False},
                "user_data_dir": str(root.parent),
                "save_path": str(root.parent / "save"),
                "settings_path": str(root.parent / "settings"),
            }), encoding="utf-8")
            errors = "\n".join(runner.validate_report(report_path, root, "0.12.0-alpha-packaged-smoke", "initial"))
            for expected in ("phase", "runtime errors", "build version", "release template", "offline proxy", "environment guard", "did not free", "battle step", "schemas", "input/scaling", "pause assertion", "clean", "catalog", "escaped"):
                self.assertIn(expected, errors)


if __name__ == "__main__":
    unittest.main()
