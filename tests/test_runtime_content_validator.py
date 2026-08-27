#!/usr/bin/env python3
"""Negative-path regression tests for the P6 runtime content validator."""
from __future__ import annotations

import copy
import json
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import validate_runtime_content as validator  # noqa: E402


def load(relative_path: str) -> dict:
    return json.loads((ROOT / relative_path).read_text(encoding="utf-8"))


class RuntimeContentValidatorTests(unittest.TestCase):
    def test_piece_reports_all_reference_and_shape_failures(self) -> None:
        piece = copy.deepcopy(load("data/pieces/fire_team.json"))
        piece["footprint"] = [0, 1]
        piece["allowed_floors"] = ["roof"]
        piece["allowed_zones"] = []
        piece["availability"] = "missing_pack"
        piece["attack_profile"]["targets"] = ["missing_enemy"]
        piece["assignment_rule"] = {"room": "missing_room", "effect": "invalid"}
        errors: list[str] = []
        validator.validate_piece(
            Path("fire_team.json"), piece, {"gate"}, {"raider"}, {"firekeepers"}, {}, {}, set(), errors
        )
        joined = "\n".join(errors)
        for expected in ("footprint", "allowed_floors", "allowed_zones", "unknown enemy", "unknown room", "unknown pack"):
            self.assertIn(expected, joined)

    def test_enemy_reports_bad_combat_and_cross_references(self) -> None:
        enemy = copy.deepcopy(load("data/enemies/sapper.json"))
        enemy["health"] = 0
        enemy["target_rooms"] = ["missing_room"]
        enemy["doctrine"] = "missing_doctrine"
        enemy["counter"] = "missing_piece"
        enemy["counter_families"] = ["support"]
        errors: list[str] = []
        validator.validate_enemy(Path("sapper.json"), enemy, {"gate"}, {"pike_squad"}, {"gate_assault"}, {}, set(), errors)
        joined = "\n".join(errors)
        for expected in ("health", "unknown target room", "doctrine", "unknown piece", "at least three"):
            self.assertIn(expected, joined)

    def test_doctrine_allows_repeated_actors_but_rejects_unknown_ones(self) -> None:
        doctrine = copy.deepcopy(load("data/doctrines/gate_assault.json"))
        errors: list[str] = []
        validator.validate_doctrine(Path("gate_assault.json"), doctrine, {"raider"}, set(), errors)
        self.assertFalse(errors)
        doctrine["composition"] = ["missing_enemy"]
        doctrine["counter_families"] = ["frontline"]
        errors = []
        validator.validate_doctrine(Path("gate_assault.json"), doctrine, {"raider"}, set(), errors)
        joined = "\n".join(errors)
        self.assertIn("unknown enemy", joined)
        self.assertIn("at least three", joined)

    def test_scenario_rejects_invalid_wave_and_variation_contracts(self) -> None:
        scenario = copy.deepcopy(load("data/scenarios/gatehouse_lock.json"))
        scenario["doctrines"] = ["gate_assault"]
        scenario["wave_plans"] = [["missing_enemy"]]
        scenario["variations"] = [{"id": "bad id", "materials": 0.5, "morale": 0, "target_room": "missing_room"}]
        errors: list[str] = []
        validator.validate_scenario(
            Path("gatehouse_lock.json"), scenario, {"gate"}, {"raider"}, {"gate_assault"}, set(), errors
        )
        joined = "\n".join(errors)
        for expected in ("exactly three", "variation id", "materials", "target_room", "standard_bell"):
            self.assertIn(expected, joined)

    def test_event_rejects_unknown_effect_trigger_and_duplicate_choice(self) -> None:
        event = copy.deepcopy(load("data/events/relief_road_warning.json"))
        event["trigger"] = {"phase": "missing", "wave": 7}
        event["choices"][0]["effects"] = [{"op": "run_script", "code": "unsafe"}]
        event["choices"].append(copy.deepcopy(event["choices"][0]))
        event["follow_up"] = "relief_road_warning"
        errors: list[str] = []
        validator.validate_event(Path("wrong_filename.json"), event, {"relief_road"}, set(), errors)
        joined = "\n".join(errors)
        for expected in ("does not match filename", "unsupported trigger phase", "trigger wave", "unsupported effect", "duplicate choice", "follow itself"):
            self.assertIn(expected, joined)


if __name__ == "__main__":
    unittest.main()
