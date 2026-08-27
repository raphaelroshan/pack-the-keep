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


if __name__ == "__main__":
    unittest.main()
