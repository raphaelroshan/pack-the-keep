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
        validator.validate_enemy(Path("sapper.json"), enemy, {"gate"}, {"pike_squad"}, {"gate_assault"}, set(), {}, set(), errors)
        joined = "\n".join(errors)
        for expected in ("health", "unknown target room", "doctrine", "unknown piece", "at least three"):
            self.assertIn(expected, joined)

    def test_armored_enemy_requires_valid_armor_and_counter_tag(self) -> None:
        enemy = copy.deepcopy(load("data/enemies/shield_guard.json"))
        enemy["armor"] = -1
        errors: list[str] = []
        validator.validate_enemy(Path("shield_guard.json"), enemy, {"gate", "barracks", "inner_yard"}, {"crossbow_patrol"}, {"shielded_advance"}, set(), {}, set(), errors)
        self.assertIn("armor must be a non-negative integer", "\n".join(errors))

        enemy["armor"] = 2
        enemy["armor_counter_tag"] = ""
        errors = []
        validator.validate_enemy(Path("shield_guard.json"), enemy, {"gate", "barracks", "inner_yard"}, {"crossbow_patrol"}, {"shielded_advance"}, set(), {}, set(), errors)
        self.assertIn("armor_counter_tag", "\n".join(errors))

    def test_signal_disruption_profile_requires_bounded_complete_fields(self) -> None:
        enemy = copy.deepcopy(load("data/enemies/ash_slinger.json"))
        enemy["disruption_profile"]["arrival_step_delta"] = -4
        enemy["disruption_profile"]["relay_modifier"] = ""
        errors: list[str] = []
        validator.validate_enemy(Path("ash_slinger.json"), enemy, {"gate", "barracks", "north_tower"}, {"bellkeepers"}, {"smoke_and_signal"}, {"signal_redundancy", "warden_signal_coverage"}, {}, set(), errors)
        joined = "\n".join(errors)
        self.assertIn("arrival_step_delta", joined)
        self.assertIn("relay_modifier", joined)

    def test_protection_fields_and_breaker_profile_are_typed(self) -> None:
        piece = copy.deepcopy(load("data/pieces/emergency_shutters.json"))
        piece["support_profile"]["room_damage_reduction"] = -1
        errors: list[str] = []
        validator.validate_piece(Path("emergency_shutters.json"), piece, {"gate"}, {"shieldbreaker"}, {"shieldwall"}, {}, {}, set(), errors)
        self.assertIn("room_damage_reduction", "\n".join(errors))

        enemy = copy.deepcopy(load("data/enemies/shieldbreaker.json"))
        enemy["target_piece_categories"] = []
        enemy["target_piece_preference"] = "random"
        enemy["ignores_protection"] = "yes"
        errors = []
        validator.validate_enemy(Path("shieldbreaker.json"), enemy, {"gate", "barracks", "inner_yard"}, {"shield_wardens"}, {"break_the_line"}, set(), {}, set(), errors)
        joined = "\n".join(errors)
        for expected in ("target_piece_categories", "target_piece_preference", "ignores_protection"):
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
        validator.validate_event(Path("wrong_filename.json"), event, {"relief_road"}, {"roadside_intelligence"}, set(), errors)
        joined = "\n".join(errors)
        for expected in ("does not match filename", "unsupported trigger phase", "trigger wave", "unsupported effect", "duplicate choice", "follow itself"):
            self.assertIn(expected, joined)

    def test_modifier_rejects_unknown_unlock_effect_and_cost(self) -> None:
        modifier = copy.deepcopy(load("data/modifiers/roadside_intelligence.json"))
        modifier["unlock_event"] = "missing_event"
        modifier["effect"] = "raw_power"
        modifier["starting_morale_cost"] = -1
        errors: list[str] = []
        validator.validate_modifier(Path("wrong_filename.json"), modifier, {"relief_road_report"}, set(), errors)
        joined = "\n".join(errors)
        for expected in ("does not match filename", "unknown unlock_event", "unsupported modifier effect", "starting_morale_cost"):
            self.assertIn(expected, joined)

    def test_health_modifier_requires_a_bounded_matching_bonus(self) -> None:
        modifier = copy.deepcopy(load("data/modifiers/hardened_vanguard.json"))
        modifier["enemy_health_bonus"] = 9
        errors: list[str] = []
        validator.validate_modifier(Path("hardened_vanguard.json"), modifier, {"relief_road_report"}, set(), errors)
        self.assertIn("enemy_health_bonus", "\n".join(errors))

        intelligence = copy.deepcopy(load("data/modifiers/roadside_intelligence.json"))
        intelligence["enemy_health_bonus"] = 2
        errors = []
        validator.validate_modifier(Path("roadside_intelligence.json"), intelligence, {"relief_road_report"}, set(), errors)
        self.assertIn("only valid", "\n".join(errors))


if __name__ == "__main__":
    unittest.main()
