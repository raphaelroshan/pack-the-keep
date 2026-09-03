from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("validate_player_facing_copy", ROOT / "tools" / "validate_player_facing_copy.py")
assert SPEC and SPEC.loader
validator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validator)


class PlayerFacingCopyValidatorTests(unittest.TestCase):
    def test_repository_copy_passes(self) -> None:
        errors: list[str] = []
        validator.validate_repository(ROOT, errors)
        self.assertEqual(errors, [])

    def test_rejects_meta_copy_duplicate_titles_and_long_event_setup(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for folder in ("data/scenarios", "data/events", "src/ui"):
                (root / folder).mkdir(parents=True, exist_ok=True)
            (root / "data/scenarios/meta.json").write_text(json.dumps({"short_role": "Teach P11 through authored pressure."}), encoding="utf-8")
            long_setup = "A" * 181
            for name in ("one", "two"):
                (root / f"data/events/{name}.json").write_text(json.dumps({"title": "Repeated Bell", "setup": long_setup}), encoding="utf-8")
            for relative in validator.UI_SOURCES:
                path = root / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('label.text = "automated baseline verified"\n', encoding="utf-8")

            errors: list[str] = []
            validator.validate_repository(root, errors)
            joined = "\n".join(errors)
            self.assertIn("development term 'authored'", joined)
            self.assertIn("development term 'milestone'", joined)
            self.assertIn("describe the threat", joined)
            self.assertIn("duplicated", joined)
            self.assertIn("exceeds the compact event-copy budget", joined)
            self.assertIn("automated baseline", joined)


if __name__ == "__main__":
    unittest.main()
