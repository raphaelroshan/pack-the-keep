from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class ReleaseIdentityTests(unittest.TestCase):
    def test_project_manifest_and_framework_versions_match(self) -> None:
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        match = re.search(r'^config/version="([^"]+)"$', project, re.MULTILINE)
        self.assertIsNotNone(match, "project.godot must declare application/config/version")
        project_version = match.group(1)
        ci_manifest = json.loads((ROOT / "tools" / "ci_manifest.json").read_text(encoding="utf-8"))
        framework = json.loads((ROOT / "content" / "gameplay_framework.json").read_text(encoding="utf-8"))
        content = json.loads((ROOT / "content" / "content_manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(ci_manifest.get("build_version"), project_version)
        self.assertEqual(framework.get("framework_version"), project_version)
        self.assertTrue(project_version.startswith(f"{content.get('content_version')}-"))

    def test_windows_release_preset_supports_single_file_relocation(self) -> None:
        presets = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
        self.assertIn('name="Windows Desktop"', presets)
        self.assertIn('platform="Windows Desktop"', presets)
        self.assertIn('export_filter="all_resources"', presets)
        self.assertIn('binary_format/embed_pck=true', presets)
        self.assertIn('binary_format/architecture="x86_64"', presets)

    def test_tagged_release_publishes_the_complete_playtest_kit(self) -> None:
        workflow = (ROOT / ".github" / "workflows" / "release.yml").read_text(encoding="utf-8")
        required_steps = [
            "tools/write_playtest_build_manifest.py",
            "tools/write_playtest_brief.py",
            "tools/write_playtest_matrix_templates.py",
        ]
        for step in required_steps:
            self.assertIn(step, workflow)
        required_assets = [
            '"artifacts/packaged-smoke.json"',
            '"artifacts/playtest-build.json"',
            '"artifacts/PLAYTEST_README.md"',
            '"artifacts/PRIVATE_ALPHA_LIMITATIONS.md"',
            "artifacts/playtest-templates/*.json",
            '"artifacts/release_manifest.json"',
        ]
        publish_start = workflow.index('gh release create "$GITHUB_REF_NAME"')
        publish_block = workflow[publish_start:]
        for asset in required_assets:
            self.assertIn(asset, publish_block)
        self.assertLess(
            workflow.index("tools/write_playtest_build_manifest.py"),
            workflow.index("tools/write_playtest_brief.py"),
        )
        self.assertLess(
            workflow.index("tools/write_playtest_brief.py"),
            workflow.index("tools/write_playtest_matrix_templates.py"),
        )


if __name__ == "__main__":
    unittest.main()
