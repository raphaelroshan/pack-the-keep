#!/usr/bin/env python3
"""Regression coverage for the packaged P16 observer brief."""
from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import write_playtest_brief as brief_tool  # noqa: E402
import write_playtest_build_manifest as manifest_tool  # noqa: E402


class P16PlaytestBriefTests(unittest.TestCase):
    def setUp(self) -> None:
        self.protocol = json.loads((ROOT / "content/p16_playtest_protocol.json").read_text(encoding="utf-8"))
        self.ci_manifest = json.loads((ROOT / "tools/ci_manifest.json").read_text(encoding="utf-8"))

    def test_brief_identifies_build_and_keeps_human_boundary(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            artifact = Path(directory) / "pack-the-keep.exe"
            artifact.write_bytes(b"pack-the-keep-playtest")
            manifest = manifest_tool.build_manifest(artifact, self.ci_manifest, "a" * 40, 12345)
            rendered = brief_tool.render_brief(self.protocol, manifest)
            self.assertIn("**PRE-ALPHA:**", rendered)
            self.assertIn(self.protocol["build_version"], rendered)
            self.assertIn("`12345`", rendered)
            self.assertIn(manifest["artifact"]["sha256"], rendered)
            self.assertIn("human playtest gate remains pending", rendered.lower())
            self.assertNotIn('"completed": true', rendered.lower())
            self.assertNotIn('"status": "pass"', rendered.lower())
            for observation in self.protocol["required_observations"]:
                self.assertIn(f"`{observation['id']}`", rendered)
                self.assertIn(observation["prompt"], rendered)
                self.assertIn(observation["success_signal"], rendered)

    def test_cli_writes_the_validated_brief(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            artifact = root / "pack-the-keep.exe"
            artifact.write_bytes(b"packaged-candidate")
            manifest = manifest_tool.build_manifest(artifact, self.ci_manifest, "c" * 40, 24680)
            manifest_path = root / "playtest-build.json"
            output_path = root / "PLAYTEST_README.md"
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
            result = subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "tools/write_playtest_brief.py"),
                    "--protocol", str(ROOT / "content/p16_playtest_protocol.json"),
                    "--build-manifest", str(manifest_path),
                    "--artifact", str(artifact),
                    "--output", str(output_path),
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            self.assertIn("WROTE", result.stdout)
            rendered = output_path.read_text(encoding="utf-8")
            self.assertIn("`24680`", rendered)
            self.assertIn(manifest["artifact"]["sha256"], rendered)

    def test_cli_rejects_tampered_artifact(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            artifact = root / "pack-the-keep.exe"
            artifact.write_bytes(b"original")
            manifest = manifest_tool.build_manifest(artifact, self.ci_manifest, "b" * 40, 67890)
            manifest_path = root / "playtest-build.json"
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
            artifact.write_bytes(b"tampered")
            result = subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "tools/write_playtest_brief.py"),
                    "--protocol", str(ROOT / "content/p16_playtest_protocol.json"),
                    "--build-manifest", str(manifest_path),
                    "--artifact", str(artifact),
                    "--output", str(root / "PLAYTEST_README.md"),
                ],
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("does not match its build manifest", result.stdout)
            self.assertFalse((root / "PLAYTEST_README.md").exists())


if __name__ == "__main__":
    unittest.main()
