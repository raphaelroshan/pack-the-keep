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
    def test_rejects_incomplete_packaged_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "report.json"
            path.write_text(json.dumps({
                "schema_version": 1,
                "initial": {"phase": "initial", "ok": True, "build_version": "v", "main_scene_freed": False},
                "reinstall": {"phase": "reinstall", "ok": True, "build_version": "v", "main_scene_freed": True},
            }), encoding="utf-8")
            errors: list[str] = []
            validator.validate_report(path, "v", errors)
            joined = "\n".join(errors)
            self.assertIn("close cleanly", joined)
            self.assertIn("controller_navigation_ready", joined)
            self.assertIn("restored_run_ready", joined)


if __name__ == "__main__":
    unittest.main()
