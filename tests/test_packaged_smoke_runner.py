from __future__ import annotations

import importlib.util
from contextlib import redirect_stdout
from io import StringIO
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("run_packaged_smoke", ROOT / "tools" / "run_packaged_smoke.py")
assert SPEC and SPEC.loader
runner = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(runner)


def complete_report(profile_dir: Path, version: str, phase: str, executable: Path) -> dict[str, object]:
    report: dict[str, object] = {
        "schema_version": 2, "phase": phase, "ok": True, "errors": [],
        "build_version": version, "editor_feature": False,
        "offline_proxy_guard": True, "smoke_guard": True, "main_scene_freed": True,
        "battle_step": 1, "save_schema_version": 4, "settings_schema_version": 5,
        "controller_navigation_ready": True, "controller_defaults_ready": True,
        "settings_state_unchanged": True,
        "content_status": {"ok": True, "keep_count": 3, "region_count": 1, "commander_count": 3, "piece_count": 21, "pack_count": 11, "enemy_count": 10, "doctrine_count": 12, "scenario_count": 15, "event_count": 9, "modifier_count": 2},
        "user_data_dir": str(profile_dir), "save_path": str(profile_dir / "packaged_smoke_run.save"),
        "settings_path": str(profile_dir / "packaged_smoke_settings.json"),
        "executable_path": str(executable),
    }
    if phase == "clean_install":
        report.update({
            "controller_remap_ready": True, "ui_scale_ready": True,
            "settings_scale_ready": True, "settings_remap_ready": True,
            "initial_realtime_ready": True, "paused_state_frozen": True,
            "remapped_pause_ready": True, "manual_step_ready": True,
            "profile_files_present": False, "profile_files_complete": False,
        })
    elif phase == "reinstall":
        report.update({
            "profile_files_present": True, "profile_files_complete": True,
            "restored_run_ready": True, "restored_scale_ready": True,
            "restored_remap_ready": True,
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


class PackagedSmokeReportTests(unittest.TestCase):
    def test_timeout_preserves_child_output(self) -> None:
        command = [sys.executable, "-c", "import time; print('ready', flush=True); time.sleep(5)"]
        with self.assertRaisesRegex(RuntimeError, "timed out.*ready"):
            runner.run_process(command, os.environ.copy(), 0.1)

    def test_process_runs_from_requested_install_directory(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            install_dir = Path(directory).resolve()
            result = runner.run_process(
                [sys.executable, "-c", "import os; print(os.getcwd())"],
                os.environ.copy(),
                5,
                install_dir,
            )
            self.assertEqual(result.returncode, 0)
            self.assertEqual(Path(result.stdout.strip()).resolve(), install_dir)

    def test_main_runs_complete_lifecycle_matrix(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            executable = root / "build" / "pack-the-keep.exe"
            executable.parent.mkdir()
            executable.write_bytes(b"embedded executable fixture")
            manifest = root / "manifest.json"
            manifest.write_text(json.dumps({"build_version": "v"}), encoding="utf-8")
            profile_root = (root / "profile").resolve()
            report_copy = root / "artifact.json"
            working_directories: list[tuple[str, Path]] = []

            def fake_run(command: list[str], environment: dict[str, str], _timeout: int, cwd: Path | None = None):
                assert cwd is not None
                phase = environment["PACK_THE_KEEP_SMOKE_PHASE"]
                working_directories.append((phase if "--packaged-smoke" in command else "main_launch", Path(cwd).resolve()))
                if "--packaged-smoke" in command:
                    active_profile = Path(environment["APPDATA"])
                    report_dir = active_profile / "Godot" / "app_userdata" / "Pack the Keep"
                    report_dir.mkdir(parents=True, exist_ok=True)
                    report = complete_report(report_dir, "v", phase, Path(command[0]).resolve())
                    (report_dir / runner.REPORT_FILENAME).write_text(json.dumps(report), encoding="utf-8")
                    if phase == "clean_install":
                        (report_dir / runner.SAVE_FILENAME).write_text(json.dumps({"schema_version": 4, "seed": 3307, "battle_step": 1, "unlocked_modifier_ids": [], "equipped_modifier_id": ""}), encoding="utf-8")
                        (report_dir / runner.SETTINGS_FILENAME).write_text(json.dumps({"schema_version": 5, "ui_scale_index": 2, "input_bindings": {}, "event_feed_retention_index": 0, "auto_pause_on_threat": False, "tutorial_completed": False, "tutorial_dismissed": False}), encoding="utf-8")
                return runner.subprocess.CompletedProcess(command, 0, "", "")

            arguments = [
                "run_packaged_smoke.py", "--executable", str(executable),
                "--profile-root", str(profile_root), "--report-copy", str(report_copy),
                "--manifest", str(manifest),
            ]
            def fake_forced_close(executable_path: Path, active_profile: Path, _timeout: int):
                working_directories.append(("forced_close_prepare", executable_path.parent.resolve()))
                return {"ready": True, "terminated": True, "exit_code": -9, "stdout_tail": "", "stderr_tail": ""}

            with patch.object(runner, "run_process", side_effect=fake_run), patch.object(runner, "run_forced_close_prepare", side_effect=fake_forced_close), patch.object(sys, "argv", arguments), redirect_stdout(StringIO()):
                self.assertEqual(runner.main(), 0)

            combined = json.loads(report_copy.read_text(encoding="utf-8"))
            self.assertEqual(combined["schema_version"], 3)
            self.assertEqual(set(combined) - {"schema_version", "forced_close"}, runner.SUPPORTED_PHASES)
            self.assertTrue(combined["forced_close"]["terminated"])
            smoke_phases = [phase for phase, _cwd in working_directories if phase in runner.SUPPORTED_PHASES]
            self.assertEqual(smoke_phases, ["clean_install", "reinstall", "stale_backup", "missing_profile", "upgrade", "forced_close_recovery"])
            phase_directories = {phase: cwd for phase, cwd in working_directories if phase in runner.SUPPORTED_PHASES}
            self.assertNotEqual(phase_directories["clean_install"], phase_directories["reinstall"])
            self.assertEqual(phase_directories["reinstall"], phase_directories["stale_backup"])
            self.assertEqual(phase_directories["reinstall"], phase_directories["missing_profile"])
            self.assertEqual(phase_directories["reinstall"], phase_directories["forced_close_recovery"])
            self.assertNotIn(phase_directories["upgrade"], {phase_directories["clean_install"], phase_directories["reinstall"]})

    def test_forced_close_prepare_terminates_after_readiness(self) -> None:
        class FakeProcess:
            def __init__(self, ready_path: Path) -> None:
                self.returncode: int | None = None
                self.ready_path = ready_path

            def poll(self):
                if self.returncode is None and not self.ready_path.exists():
                    self.ready_path.write_text("ready", encoding="utf-8")
                return self.returncode

            def kill(self) -> None:
                self.returncode = -9

            def communicate(self, timeout=None):
                return ("ready", "")

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            executable = root / "pack-the-keep.exe"
            executable.write_bytes(b"fixture")
            ready_dir = root / "Godot" / "app_userdata" / "Pack the Keep"
            ready_dir.mkdir(parents=True)
            ready_path = ready_dir / runner.FORCED_CLOSE_READY_FILENAME
            ready_path.write_text("stale", encoding="utf-8")
            with patch.object(runner.subprocess, "Popen", return_value=FakeProcess(ready_path)):
                evidence = runner.run_forced_close_prepare(executable, root, 1)
            self.assertTrue(evidence["ready"])
            self.assertTrue(evidence["terminated"])
            self.assertEqual(evidence["exit_code"], -9)
            self.assertFalse(ready_path.exists())

    def test_accepts_complete_report_inside_profile(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            report_path = root / "Godot" / "app_userdata" / "Pack the Keep" / "packaged_smoke_report.json"
            report_path.parent.mkdir(parents=True)
            report_path.write_text(json.dumps(complete_report(report_path.parent, "v", "clean_install", root / "pack-the-keep.exe")), encoding="utf-8")
            self.assertEqual(runner.validate_report(report_path, root, "v", "clean_install"), [])

    def test_accepts_reinstalled_report_with_restored_profile(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            report_path = root / "Godot" / "app_userdata" / "Pack the Keep" / "packaged_smoke_report.json"
            report_path.parent.mkdir(parents=True)
            report_path.write_text(json.dumps(complete_report(report_path.parent, "v", "reinstall", root / "pack-the-keep.exe")), encoding="utf-8")
            self.assertEqual(runner.validate_report(report_path, root, "v", "reinstall"), [])

    def test_accepts_missing_profile_stale_backup_upgrade_and_forced_close_reports(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            executable = root / "pack-the-keep.exe"
            for phase in ("missing_profile", "stale_backup", "upgrade", "forced_close_recovery"):
                report_path = root / f"{phase}.json"
                report_path.write_text(json.dumps(complete_report(root, "v", phase, executable)), encoding="utf-8")
                self.assertEqual(runner.validate_report(report_path, root, "v", phase), [])

    def test_rejects_failed_lifecycle_specific_assertions(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            executable = root / "pack-the-keep.exe"
            cases = (
                ("stale_backup", "primary_preferred_ready", "prefer valid primary"),
                ("missing_profile", "missing_profile_state_unchanged", "missing-profile assertion"),
                ("upgrade", "upgraded_files_current", "upgrade assertion"),
                ("forced_close_recovery", "forced_close_run_recovered", "forced-close assertion"),
            )
            for phase, field, expected in cases:
                with self.subTest(phase=phase, field=field):
                    report_path = root / f"{phase}.json"
                    report = complete_report(root, "v", phase, executable)
                    report[field] = False
                    report_path.write_text(json.dumps(report), encoding="utf-8")
                    self.assertIn(expected, "\n".join(runner.validate_report(report_path, root, "v", phase)))

    def test_profile_fixture_adapters_create_stale_and_legacy_cases(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source_root = root / "source"
            user_data = source_root / "Godot" / "app_userdata" / "Pack the Keep"
            user_data.mkdir(parents=True)
            save_path = user_data / runner.SAVE_FILENAME
            settings_path = user_data / runner.SETTINGS_FILENAME
            save_path.write_text(json.dumps({"schema_version": 4, "seed": 3307, "battle_step": 1, "unlocked_modifier_ids": ["x"], "equipped_modifier_id": "x"}), encoding="utf-8")
            settings_path.write_text(json.dumps({"schema_version": 5, "ui_scale_index": 2, "input_bindings": {"battle_pause": []}, "event_feed_retention_index": 3, "auto_pause_on_threat": True, "tutorial_completed": False, "tutorial_dismissed": False}), encoding="utf-8")
            report = {"user_data_dir": str(user_data), "save_path": str(save_path), "settings_path": str(settings_path)}

            runner.write_stale_backups(report)
            stale_save = json.loads(Path(f"{save_path}.bak").read_text(encoding="utf-8"))
            stale_settings = json.loads(Path(f"{settings_path}.bak").read_text(encoding="utf-8"))
            self.assertEqual(stale_save["seed"], 9901)
            self.assertEqual(stale_settings["ui_scale_index"], 0)

            upgrade_root = root / "upgrade"
            runner.write_legacy_profile(report, source_root, upgrade_root)
            legacy_dir = upgrade_root / "Godot" / "app_userdata" / "Pack the Keep"
            legacy_save = json.loads((legacy_dir / runner.SAVE_FILENAME).read_text(encoding="utf-8"))
            legacy_settings = json.loads((legacy_dir / runner.SETTINGS_FILENAME).read_text(encoding="utf-8"))
            self.assertEqual(legacy_save["schema_version"], 3)
            self.assertNotIn("unlocked_modifier_ids", legacy_save)
            self.assertEqual(legacy_settings["schema_version"], 3)
            self.assertNotIn("auto_pause_on_threat", legacy_settings)

    def test_rejects_editor_or_escaped_user_data(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            report_path = root / "packaged_smoke_report.json"
            report_path.write_text(json.dumps({
                "schema_version": 2,
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
                "initial_realtime_ready": False,
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
            errors = "\n".join(runner.validate_report(report_path, root, "0.12.0-alpha-packaged-smoke", "clean_install"))
            for expected in ("phase", "runtime errors", "build version", "release template", "offline proxy", "environment guard", "did not free", "battle step", "schemas", "input/scaling", "pause assertion", "clean", "catalog", "escaped"):
                self.assertIn(expected, errors)


if __name__ == "__main__":
    unittest.main()
