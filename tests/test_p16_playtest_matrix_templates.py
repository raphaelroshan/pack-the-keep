#!/usr/bin/env python3
"""Regression coverage for provenance-bound P16 matrix templates."""
from __future__ import annotations

import copy
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import validate_p16_playtests as validator  # noqa: E402
import write_playtest_build_manifest as manifest_tool  # noqa: E402
import write_playtest_matrix_templates as template_tool  # noqa: E402


class P16PlaytestMatrixTemplateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.protocol = json.loads((ROOT / "content/p16_playtest_protocol.json").read_text(encoding="utf-8"))
        self.ci_manifest = json.loads((ROOT / "tools/ci_manifest.json").read_text(encoding="utf-8"))

    def test_templates_cover_matrix_without_inventing_human_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            artifact = Path(directory) / "pack-the-keep.exe"
            artifact.write_bytes(b"matrix-candidate")
            manifest = manifest_tool.build_manifest(artifact, self.ci_manifest, "d" * 40, 13579)
            templates = template_tool.build_templates(self.protocol, manifest)
            expected_matrix = {
                (commander, run_type)
                for commander in validator.COMMANDERS
                for run_type in validator.RUN_TYPES
            }
            self.assertEqual(len(templates), 4)
            self.assertEqual(
                {(record["commander"], record["run_type"]) for record in templates.values()},
                expected_matrix,
            )
            for record in templates.values():
                self.assertEqual(record["source_revision"], "d" * 40)
                self.assertEqual(record["ci_run_id"], 13579)
                self.assertEqual(record["artifact"], manifest["artifact"])
                self.assertEqual(record["session_id"], "")
                self.assertEqual(record["tester_alias"], "")
                self.assertEqual(record["recorded_at"], "")
                self.assertFalse(record["completed"])
                self.assertEqual({item["status"] for item in record["observations"]}, {"not_tested"})
                self.assertEqual(record["findings"], [])
                self.assertEqual(record["observer_summary"], "")

    def test_cli_writes_lf_normalized_templates(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            artifact = root / "pack-the-keep.exe"
            artifact.write_bytes(b"matrix-candidate")
            manifest = manifest_tool.build_manifest(artifact, self.ci_manifest, "e" * 40, 97531)
            manifest_path = root / "playtest-build.json"
            output_directory = root / "templates"
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
            result = subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "tools/write_playtest_matrix_templates.py"),
                    "--protocol", str(ROOT / "content/p16_playtest_protocol.json"),
                    "--build-manifest", str(manifest_path),
                    "--artifact", str(artifact),
                    "--output-directory", str(output_directory),
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            self.assertIn("WROTE 4 files", result.stdout)
            paths = sorted(output_directory.glob("*.template.json"))
            self.assertEqual(len(paths), 4)
            self.assertTrue(all(b"\r\n" not in path.read_bytes() for path in paths))

    def test_template_names_reject_unsafe_matrix_values(self) -> None:
        protocol = copy.deepcopy(self.protocol)
        protocol["required_matrix"]["commanders"][0] = "../outside"
        with self.assertRaisesRegex(ValueError, "unique commanders"):
            template_tool.build_templates(protocol, {
                "source_revision": "a" * 40,
                "ci_run_id": 1,
                "artifact": {"name": "pack-the-keep.exe", "sha256": "b" * 64, "size_bytes": 1},
            })

    def test_cli_rejects_tampered_artifact(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            artifact = root / "pack-the-keep.exe"
            artifact.write_bytes(b"original")
            manifest = manifest_tool.build_manifest(artifact, self.ci_manifest, "f" * 40, 86420)
            manifest_path = root / "playtest-build.json"
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
            artifact.write_bytes(b"tampered")
            result = subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "tools/write_playtest_matrix_templates.py"),
                    "--protocol", str(ROOT / "content/p16_playtest_protocol.json"),
                    "--build-manifest", str(manifest_path),
                    "--artifact", str(artifact),
                    "--output-directory", str(root / "templates"),
                ],
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("does not match its build manifest", result.stdout)
            self.assertFalse((root / "templates").exists())


if __name__ == "__main__":
    unittest.main()
