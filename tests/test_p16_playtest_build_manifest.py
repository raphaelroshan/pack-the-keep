#!/usr/bin/env python3
"""Regression coverage for packaged playtest build provenance."""
from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import write_playtest_build_manifest as build_tool  # noqa: E402


class P16PlaytestBuildManifestTests(unittest.TestCase):
    def test_build_manifest_records_exact_artifact(self) -> None:
        ci_manifest = json.loads((ROOT / "tools/ci_manifest.json").read_text(encoding="utf-8"))
        with tempfile.TemporaryDirectory() as directory:
            artifact = Path(directory) / "pack-the-keep.exe"
            artifact.write_bytes(b"packaged-build")
            manifest = build_tool.build_manifest(artifact, ci_manifest, "a" * 40, 12345)
            self.assertEqual(manifest["build_version"], ci_manifest["build_version"])
            self.assertEqual(manifest["source_revision"], "a" * 40)
            self.assertEqual(manifest["ci_run_id"], 12345)
            self.assertFalse(manifest["release_ready"])
            self.assertEqual(manifest["artifact"]["name"], artifact.name)
            self.assertEqual(manifest["artifact"]["sha256"], hashlib.sha256(artifact.read_bytes()).hexdigest())
            self.assertEqual(manifest["artifact"]["size_bytes"], artifact.stat().st_size)
            self.assertFalse(build_tool.validate_build_manifest(manifest, artifact, ci_manifest["build_version"]))

    def test_manifest_validation_rejects_tampered_artifact(self) -> None:
        ci_manifest = json.loads((ROOT / "tools/ci_manifest.json").read_text(encoding="utf-8"))
        with tempfile.TemporaryDirectory() as directory:
            artifact = Path(directory) / "pack-the-keep.exe"
            artifact.write_bytes(b"original")
            manifest = build_tool.build_manifest(artifact, ci_manifest, "b" * 40, 54321)
            artifact.write_bytes(b"tampered")
            errors = build_tool.validate_build_manifest(manifest, artifact, ci_manifest["build_version"])
            self.assertIn("playtest artifact sha256 does not match its build manifest", errors)

    def test_cli_writes_deterministic_manifest(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            artifact = Path(directory) / "pack-the-keep.exe"
            output = Path(directory) / "playtest-build.json"
            artifact.write_bytes(b"candidate")
            subprocess.run(
                [
                    sys.executable, str(ROOT / "tools/write_playtest_build_manifest.py"),
                    "--executable", str(artifact),
                    "--ci-manifest", str(ROOT / "tools/ci_manifest.json"),
                    "--source-revision", "c" * 40,
                    "--run-id", "999",
                    "--output", str(output),
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            manifest = json.loads(output.read_text(encoding="utf-8"))
            self.assertEqual(manifest["ci_run_id"], 999)
            self.assertEqual(manifest["source_revision"], "c" * 40)


if __name__ == "__main__":
    unittest.main()
