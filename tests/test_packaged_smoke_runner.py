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
        "schema_version": 1, "phase": phase, "ok": True, "errors": [],
        "build_version": version, "editor_feature": False,
        "offline_proxy_guard": True, "smoke_guard": True, "main_scene_freed": True,
        "battle_step": 1, "save_schema_version": 4, "settings_schema_version": 4,
        "controller_navigation_ready": True, "controller_defaults_ready": True,
        "content_status": {"ok": True, "commander_count": 2, "piece_count": 17, "pack_count": 9, "enemy_count": 7, "doctrine_count": 8, "scenario_count": 8, "event_count": 7, "modifier_count": 2},
        "user_data_dir": str(profile_dir), "save_path": str(profile_dir / "packaged_smoke_run.save"),
        "settings_path": str(profile_dir / "packaged_smoke_settings.json"),
        "executable_path": str(executable),
    }
    if phase == "initial":
        report.update({
            "controller_remap_ready": True, "ui_scale_ready": True,
            "settings_scale_ready": True, "settings_remap_ready": True,
            "initial_pause_ready": True, "paused_state_frozen": True,
            "remapped_pause_ready": True, "manual_step_ready": True,
            "profile_files_present": False, "profile_files_complete": False,
        })
    else:
        report.update({
            "profile_files_present": True, "profile_files_complete": True,
            "restored_run_ready": True, "restored_scale_ready": True,
            "restored_remap_ready": True,
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

    def test_main_runs_two_phases_from_separate_install_directories(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            executable = root / "build" / "pack-the-keep.exe"
            executable.parent.mkdir()
            executable.write_bytes(b"embedded executable fixture")
            manifest = root / "manifest.json"
            manifest.write_text(json.dumps({"build_version": "v"}), encoding="utf-8")
            profile_root = (root / "profile").resolve()
            report_copy = root / "artifact.json"
            working_directories: list[Path] = []

            def fake_run(command: list[str], environment: dict[str, str], _timeout: int, cwd: Path | None = None):
                assert cwd is not None
                working_directories.append(Path(cwd).resolve())
                if "--packaged-smoke" in command:
                    report_dir = profile_root / "Godot" / "app_userdata" / "Pack the Keep"
                    report_dir.mkdir(parents=True, exist_ok=True)
                    phase = environment["PACK_THE_KEEP_SMOKE_PHASE"]
                    report = complete_report(report_dir, "v", phase, Path(command[0]).resolve())
                    (report_dir / "packaged_smoke_report.json").write_text(json.dumps(report), encoding="utf-8")
                    if phase == "reinstall":
                        self.assertEqual(Path(cwd).resolve(), Path(command[0]).resolve().parent)
                        self.assertEqual([entry.name for entry in Path(cwd).iterdir()], [executable.name])
                return runner.subprocess.CompletedProcess(command, 0, "", "")

            arguments = [
                "run_packaged_smoke.py", "--executable", str(executable),
                "--profile-root", str(profile_root), "--report-copy", str(report_copy),
                "--manifest", str(manifest),
            ]
            with patch.object(runner, "run_process", side_effect=fake_run), patch.object(sys, "argv", arguments), redirect_stdout(StringIO()):
                self.assertEqual(runner.main(), 0)

            combined = json.loads(report_copy.read_text(encoding="utf-8"))
            self.assertEqual(combined["initial"]["phase"], "initial")
            self.assertEqual(combined["reinstall"]["phase"], "reinstall")
            self.assertEqual(working_directories[:2], [executable.parent.resolve(), executable.parent.resolve()])
            self.assertNotEqual(working_directories[1], working_directories[2])

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
                "content_status": {"ok": True, "commander_count": 2, "piece_count": 17, "pack_count": 9, "enemy_count": 7, "doctrine_count": 8, "scenario_count": 8, "event_count": 7, "modifier_count": 2},
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
                "content_status": {"ok": True, "commander_count": 2, "piece_count": 17, "pack_count": 9, "enemy_count": 7, "doctrine_count": 8, "scenario_count": 8, "event_count": 7, "modifier_count": 2},
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
