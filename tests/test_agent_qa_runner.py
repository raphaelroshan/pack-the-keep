#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
import struct
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("agent_qa_runner", ROOT / "tools" / "agent_qa_runner.py")
assert SPEC and SPEC.loader
RUNNER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(RUNNER)


class AgentQaRunnerTest(unittest.TestCase):
    def test_repository_scenario_is_executable_and_fully_bound(self) -> None:
        summary, scenario, _ = RUNNER.load_scenario(ROOT, "qa/scenarios/pack_greywatch_three_wave.json")
        self.assertEqual(summary["status"], "IMPLEMENTED")
        self.assertIsNotNone(scenario)
        self.assertEqual(set(scenario["semantic_commands"]), set(scenario["adapter"]["command_bindings"]))

    def test_implemented_scenario_rejects_missing_command_binding(self) -> None:
        source = json.loads((ROOT / "qa/scenarios/pack_greywatch_three_wave.json").read_text(encoding="utf-8"))
        source["adapter"]["command_bindings"].pop("open_results")
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "scenario.json"
            path.write_text(json.dumps(source), encoding="utf-8")
            summary, scenario, _ = RUNNER.load_scenario(ROOT, str(path))
        self.assertEqual(summary["status"], "INVALID_MANIFEST")
        self.assertIsNone(scenario)

    def test_capture_requires_exact_state_trace_and_named_screenshots(self) -> None:
        _, scenario, _ = RUNNER.load_scenario(ROOT, "qa/scenarios/pack_greywatch_three_wave.json")
        assert scenario is not None
        with tempfile.TemporaryDirectory() as temporary:
            capture_dir = Path(temporary)
            trace = [{"state_id": state} for state in scenario["expected_states"]]
            manifest = {
                "resolution": scenario["adapter"]["viewport"],
                "scenario": scenario["adapter"]["capture_scenario"],
                "state_trace": trace,
            }
            (capture_dir / "capture-manifest.json").write_text(json.dumps(manifest), encoding="utf-8")
            width = scenario["adapter"]["viewport"]["width"]
            height = scenario["adapter"]["viewport"]["height"]
            png_header = b"\x89PNG\r\n\x1a\n" + b"\0" * 8 + struct.pack(">II", width, height)
            for filename in scenario["adapter"]["state_screenshots"].values():
                (capture_dir / filename).write_bytes(png_header)
            errors, hashes, observed = RUNNER.validate_capture(capture_dir, scenario)
            self.assertEqual(errors, [])
            self.assertEqual(len(hashes), len(scenario["screenshot_states"]))
            self.assertEqual(RUNNER.collapsed_states(observed), scenario["expected_states"])


if __name__ == "__main__":
    unittest.main()
