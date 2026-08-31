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


def packaged_report(phase: str, profile: str, executable: str) -> dict[str, object]:
    report: dict[str, object] = {
        "schema_version": 2, "phase": phase, "ok": True, "build_version": "v", "editor_feature": False, "errors": [],
        "smoke_guard": True, "offline_proxy_guard": True, "main_scene_freed": True,
        "battle_step": 1, "save_schema_version": 4, "settings_schema_version": 5,
        "controller_navigation_ready": True, "controller_defaults_ready": True,
        "settings_state_unchanged": True,
        "content_status": {
            "ok": True, "commander_count": 3, "piece_count": 19, "pack_count": 10,
            "keep_count": 3, "region_count": 1, "enemy_count": 9, "doctrine_count": 10, "scenario_count": 13,
            "event_count": 9, "modifier_count": 2,
        },
        "user_data_dir": profile, "save_path": f"{profile}\\run.save",
        "settings_path": f"{profile}\\settings.json", "executable_path": executable,
    }
    if phase == "clean_install":
        report.update({
            "profile_files_present": False, "profile_files_complete": False,
            "controller_remap_ready": True, "ui_scale_ready": True,
            "settings_scale_ready": True, "settings_remap_ready": True,
            "initial_realtime_ready": True, "paused_state_frozen": True,
            "remapped_pause_ready": True, "manual_step_ready": True,
        })
    elif phase == "reinstall":
        report.update({
            "profile_files_present": True, "profile_files_complete": True,
            "restored_run_ready": True, "restored_scale_ready": True, "restored_remap_ready": True,
        })
    elif phase == "stale_backup":
        report.update({
            "profile_files_present": True, "profile_files_complete": True,
            "profile_backups_complete": True, "primary_preferred_ready": True,
        })
    elif phase == "missing_profile":
        report.update({
            "battle_step": 0, "save_schema_version": 0, "settings_schema_version": 0,
            "profile_files_present": False, "profile_files_complete": False,
            "missing_profile_defaults_ready": True, "missing_profile_state_unchanged": True,
        })
    elif phase == "upgrade":
        report.update({
            "profile_files_present": True, "profile_files_complete": True,
            "legacy_profile_detected": True, "upgrade_run_migrated": True,
            "upgrade_settings_ready": True, "upgraded_files_current": True,
        })
    elif phase == "forced_close_recovery":
        report.update({
            "profile_files_present": True, "profile_files_complete": True,
            "profile_backups_complete": True,
            "forced_close_detected": True, "forced_close_run_recovered": True,
            "forced_close_settings_recovered": True, "forced_close_files_current": True,
        })
    return report


class P12AlphaValidatorTests(unittest.TestCase):
    def test_evidence_paths_must_stay_repository_relative(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            evidence = root / "evidence.md"
            evidence.write_text("proof", encoding="utf-8")
            self.assertTrue(validator.evidence_file_exists(root, "evidence.md"))
            self.assertFalse(validator.evidence_file_exists(root, str(evidence)))
            self.assertFalse(validator.evidence_file_exists(root, "../evidence.md"))

    def test_requires_human_release_boundary(self) -> None:
        errors: list[str] = []
        build_version = validator.validate_ci_manifest({"build_version": "v", "release_ready": True}, errors)
        self.assertEqual(build_version, "v")
        self.assertIn("release_ready must remain false", "\n".join(errors))

    def test_accepts_complete_packaged_lifecycle_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "report.json"
            reports = {
                "clean_install": packaged_report("clean_install", r"C:\profile", r"C:\build\pack-the-keep.exe"),
                "reinstall": packaged_report("reinstall", r"C:\profile", r"C:\reinstalled-app\pack-the-keep.exe"),
                "stale_backup": packaged_report("stale_backup", r"C:\profile", r"C:\reinstalled-app\pack-the-keep.exe"),
                "missing_profile": packaged_report("missing_profile", r"C:\missing-profile", r"C:\reinstalled-app\pack-the-keep.exe"),
                "upgrade": packaged_report("upgrade", r"C:\upgrade-profile", r"C:\upgraded-app\pack-the-keep.exe"),
                "forced_close_recovery": packaged_report("forced_close_recovery", r"C:\profile", r"C:\reinstalled-app\pack-the-keep.exe"),
            }
            path.write_text(json.dumps({"schema_version": 3, "forced_close": {"ready": True, "terminated": True, "exit_code": -9}, **reports}), encoding="utf-8")
            errors: list[str] = []
            validator.validate_report(path, "v", errors)
            self.assertEqual(errors, [])

    def test_rejects_incomplete_packaged_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "report.json"
            reports = {
                "clean_install": packaged_report("clean_install", r"C:\first", r"C:\same\pack-the-keep.exe"),
                "reinstall": packaged_report("reinstall", r"C:\second", r"C:\same\pack-the-keep.exe"),
                "stale_backup": packaged_report("stale_backup", r"C:\second", r"C:\same\pack-the-keep.exe"),
                "missing_profile": packaged_report("missing_profile", r"C:\first", r"C:\same\pack-the-keep.exe"),
                "upgrade": packaged_report("upgrade", r"C:\first", r"C:\same\pack-the-keep.exe"),
                "forced_close_recovery": packaged_report("forced_close_recovery", r"C:\second", r"C:\same\pack-the-keep.exe"),
            }
            reports["clean_install"]["main_scene_freed"] = False
            reports["clean_install"]["errors"] = ["failure"]
            reports["clean_install"]["profile_files_present"] = True
            reports["clean_install"]["save_path"] = r"C:\escaped\run.save"
            reports["reinstall"]["profile_files_complete"] = False
            reports["reinstall"]["restored_run_ready"] = False
            reports["forced_close_recovery"]["forced_close_run_recovered"] = False
            path.write_text(json.dumps({"schema_version": 3, "forced_close": {"ready": True, "terminated": True, "exit_code": -9}, **reports}), encoding="utf-8")
            errors: list[str] = []
            validator.validate_report(path, "v", errors)
            joined = "\n".join(errors)
            self.assertIn("close cleanly", joined)
            self.assertIn("restored_run_ready", joined)
            self.assertIn("clean profile", joined)
            self.assertIn("relocate the executable", joined)
            self.assertIn("changed user_data_dir", joined)
            self.assertIn("runtime errors", joined)
            self.assertIn("outside user data", joined)
            self.assertIn("reused the clean-install profile", joined)
            self.assertIn("forced-close packaged evidence failed", joined)


if __name__ == "__main__":
    unittest.main()
