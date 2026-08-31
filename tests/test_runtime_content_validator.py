#!/usr/bin/env python3
"""Negative-path regression tests for the runtime content validator."""
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
    def test_quartermaster_profiles_require_bounded_matching_values(self) -> None:
        commander = copy.deepcopy(load("data/commanders/quartermaster.json"))
        commander["passive_profile"]["first_pack_discount"] = -1
        commander["ability_profile"]["kind"] = "lockdown"
        errors: list[str] = []
        validator.validate_commander(
            Path("quartermaster.json"), commander, {"support", "mobile_response"},
            {"quartermaster": {"name": "The Quartermaster", "ability": "resupply", "favored_packs": ["field_engineers", "fallback_convoy"]}},
            {"field_engineers": "support", "fallback_convoy": "mobile_response"}, set(), errors,
        )
        joined = "\n".join(errors)
        self.assertIn("first_pack_discount", joined)
        self.assertIn("ability_profile kind", joined)

    def test_keep_rejects_overlaps_and_unbounded_profiles(self) -> None:
        keep = copy.deepcopy(load("data/keeps/ash_ford_redoubt.json"))
        keep["rooms"]["gate"]["origin"] = [3, 3]
        keep["spatial_rule"]["room_damage_reduction"] = 9
        keep["recovery_profile"]["room_repair_condition"] = 0
        errors: list[str] = []
        validator.validate_keep(Path("ash_ford_redoubt.json"), keep, set(), errors)
        joined = "\n".join(errors)
        self.assertIn("overlap", joined)
        self.assertIn("room_damage_reduction", joined)
        self.assertIn("room_repair_condition", joined)

    def test_paired_bastions_require_two_known_distinct_anchors(self) -> None:
        keep = copy.deepcopy(load("data/keeps/twinwatch_bastion.json"))
        keep["spatial_rule"]["anchor_rooms"] = ["gate", "missing_room"]
        errors: list[str] = []
        validator.validate_keep(Path("twinwatch_bastion.json"), keep, set(), errors)
        self.assertIn("paired_bastions", "\n".join(errors))

    def test_region_rejects_unknown_route_anchors_and_unbounded_support(self) -> None:
        region = copy.deepcopy(load("data/regions/low_mill.json"))
        region["route"]["anchor_rooms"] = ["gate", "missing_room"]
        region["consequences"][0]["next_run_materials"] = 99
        region["consequences"][1]["minimum_anchor_condition"] = 80
        errors: list[str] = []
        validator.validate_region(Path("low_mill.json"), region, {"gate", "supply_room"}, set(), errors)
        joined = "\n".join(errors)
        self.assertIn("anchor_rooms", joined)
        self.assertIn("next_run_materials", joined)
        self.assertIn("descending anchor thresholds", joined)

    def test_event_schema_contract_rejects_validator_drift(self) -> None:
        schema = load("content/event_schema.json")
        schema["selection"]["repeat_policies"].append("forever")
        schema["effects"]["set_flag"] = ["prose"]
        errors: list[str] = []
        validator.validate_event_schema_contract(Path("event_schema.json"), schema, errors)
        joined = "\n".join(errors)
        self.assertIn("repeat_policies differ", joined)
        self.assertIn("set_flag fields differ", joined)

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
        enemy["target_mode"] = "anything"
        enemy["attack_interval"] = 0
        enemy["attack_style"] = "magic"
        enemy["ignores_protection"] = "yes"
        errors = []
        validator.validate_enemy(Path("shieldbreaker.json"), enemy, {"gate", "barracks", "inner_yard"}, {"shield_wardens"}, {"break_the_line"}, set(), {}, set(), errors)
        joined = "\n".join(errors)
        for expected in ("target_piece_categories", "target_piece_preference", "target_mode", "attack_interval", "attack_style", "ignores_protection"):
            self.assertIn(expected, joined)

    def test_assigned_first_targeting_requires_boolean(self) -> None:
        enemy = copy.deepcopy(load("data/enemies/standard_cutter.json"))
        enemy["targets_assigned_first"] = "yes"
        errors: list[str] = []
        validator.validate_enemy(
            Path("standard_cutter.json"), enemy,
            {"barracks", "workshop", "inner_yard", "north_tower"},
            {"crossbow_patrol"}, {"cut_the_chain"}, set(), {}, set(), errors,
        )
        self.assertIn("targets_assigned_first must be boolean", "\n".join(errors))

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
            Path("gatehouse_lock.json"), scenario, {"gate"}, {"raider"}, {"gate_assault"}, {"greywatch_keep"}, {"pike_line", "field_engineers"}, set(), errors
        )
        joined = "\n".join(errors)
        for expected in ("exactly three", "variation id", "materials", "target_room", "standard_bell"):
            self.assertIn(expected, joined)

    def test_scenario_rejects_invalid_difficulty_and_terminal_rule(self) -> None:
        scenario = copy.deepcopy(load("data/scenarios/last_stand.json"))
        scenario["difficulty"] = "impossible"
        scenario["collapse_on_defender_wipe"] = "yes"
        errors: list[str] = []
        validator.validate_scenario(
            Path("last_stand.json"), scenario, {"gate"},
            {"raider", "shieldbreaker", "shield_guard", "ash_slinger", "sapper", "climber", "siege_beast"},
            {"break_the_line", "smoke_and_signal", "area_pressure"}, {"greywatch_keep"},
            {"shieldwall", "crossbow_watch"}, set(), errors,
        )
        joined = "\n".join(errors)
        self.assertIn("difficulty", joined)
        self.assertIn("collapse_on_defender_wipe", joined)

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

    def test_event_requires_explicit_bounded_selection_policy(self) -> None:
        event = copy.deepcopy(load("data/events/relief_road_warning.json"))
        event.pop("selection", None)
        errors: list[str] = []
        validator.validate_event(Path("relief_road_warning.json"), event, {"relief_road"}, set(), set(), errors)
        self.assertIn("missing required field: selection", "\n".join(errors))

        event["selection"] = {
            "stream": "Not Stable",
            "repeat_policy": "repeat_after_cooldown",
            "cooldown_waves": 0,
            "max_occurrences": 4,
            "surprise": True,
        }
        errors = []
        validator.validate_event(Path("relief_road_warning.json"), event, {"relief_road"}, set(), set(), errors)
        joined = "\n".join(errors)
        for expected in ("stream must be snake_case", "repeat_after_cooldown", "max_occurrences", "unsupported field: surprise"):
            self.assertIn(expected, joined)

        malformed_cases = (
            (None, "selection must be an object"),
            ({"stream": "valid_stream"}, "selection is missing required field: repeat_policy"),
            ({"stream": "valid_stream", "repeat_policy": "forever", "cooldown_waves": 0, "max_occurrences": 1}, "repeat_policy is unsupported"),
            ({"stream": "valid_stream", "repeat_policy": "once_per_run", "cooldown_waves": 4, "max_occurrences": 1}, "cooldown_waves must be an integer from 0 to 3"),
            ({"stream": "valid_stream", "repeat_policy": "repeat_after_cooldown", "cooldown_waves": 1, "max_occurrences": 1}, "requires max_occurrences of at least 2"),
        )
        for selection, expected in malformed_cases:
            with self.subTest(expected=expected):
                candidate = copy.deepcopy(load("data/events/relief_road_warning.json"))
                candidate["selection"] = selection
                errors = []
                validator.validate_event(Path("relief_road_warning.json"), candidate, {"relief_road"}, set(), set(), errors)
                self.assertIn(expected, "\n".join(errors))

    def test_once_per_run_selection_rejects_cooldown_or_multiple_occurrences(self) -> None:
        event = copy.deepcopy(load("data/events/relief_road_warning.json"))
        event["selection"] = {
            "stream": "relief_road_warning",
            "repeat_policy": "once_per_run",
            "cooldown_waves": 1,
            "max_occurrences": 2,
        }
        errors: list[str] = []
        validator.validate_event(Path("relief_road_warning.json"), event, {"relief_road"}, set(), set(), errors)
        self.assertIn("once_per_run requires cooldown_waves 0 and max_occurrences 1", "\n".join(errors))

    def test_event_choice_requires_complete_fields_and_bounded_requirement(self) -> None:
        event = copy.deepcopy(load("data/events/relief_road_warning.json"))
        event["choices"][0].pop("visible_result")
        event["choices"][0]["requirements"] = {"materials": {"gte": -1}}
        errors: list[str] = []
        validator.validate_event(Path("relief_road_warning.json"), event, {"relief_road"}, set(), set(), errors)
        joined = "\n".join(errors)
        self.assertIn("missing required field: visible_result", joined)
        self.assertIn("must use a non-negative integer", joined)

        event = copy.deepcopy(load("data/events/relief_road_warning.json"))
        event["choices"][0]["requirements"] = {"materials": {"equals": 8}, "luck": {"gte": 1}}
        errors = []
        validator.validate_event(Path("relief_road_warning.json"), event, {"relief_road"}, set(), set(), errors)
        joined = "\n".join(errors)
        self.assertIn("requirement materials has invalid constraint", joined)
        self.assertIn("unsupported requirement: luck", joined)

    def test_event_effect_rejects_missing_and_extra_payload_fields(self) -> None:
        event = copy.deepcopy(load("data/events/relief_road_warning.json"))
        event["choices"][0]["effects"] = [
            {"op": "set_flag", "flag": "safe_flag", "prose": "true"},
            {"op": "add_materials"},
        ]
        errors: list[str] = []
        validator.validate_event(Path("relief_road_warning.json"), event, {"relief_road"}, set(), set(), errors)
        joined = "\n".join(errors)
        self.assertIn("set_flag is missing required field: value", joined)
        self.assertIn("set_flag has unsupported field: prose", joined)
        self.assertIn("add_materials is missing required field: amount", joined)

        for operation, required_fields in validator.EVENT_EFFECT_FIELDS.items():
            with self.subTest(operation=operation):
                candidate = copy.deepcopy(load("data/events/relief_road_warning.json"))
                candidate["choices"][0]["effects"] = [{"op": operation}]
                errors = []
                validator.validate_event(Path("relief_road_warning.json"), candidate, {"relief_road"}, set(), set(), errors)
                for field in required_fields:
                    self.assertIn(f"effect {operation} is missing required field: {field}", "\n".join(errors))

    def test_event_graph_rejects_unknown_cross_scenario_and_cyclic_links(self) -> None:
        runtime_events = {
            "first": ("one", "second"),
            "second": ("two", "first"),
            "orphan": ("one", "missing"),
        }
        runtime_scenarios = {
            "one": {"event_chain": ["first", "orphan"]},
            "two": {"event_chain": ["second"]},
        }
        errors: list[str] = []
        validator.validate_event_graph(runtime_events, runtime_scenarios, errors)
        joined = "\n".join(errors)
        self.assertIn("references unknown follow_up: missing", joined)
        self.assertIn("follow_up crosses scenarios", joined)
        self.assertIn("follow_up cycle", joined)

    def test_manifest_parity_reports_missing_and_unlisted_runtime_events(self) -> None:
        errors: list[str] = []
        validator.validate_id_parity("event", {"manifest_only"}, {"runtime_only"}, errors)
        joined = "\n".join(errors)
        self.assertIn("runtime event file missing for manifest event: manifest_only", joined)
        self.assertIn("runtime event is missing from active-slice manifest: runtime_only", joined)

    def test_recovery_event_rejects_unknown_spatial_references(self) -> None:
        event = copy.deepcopy(load("data/events/workshop_can_wait.json"))
        event["eligibility"]["room_condition"]["room"] = "missing_room"
        event["choices"][0]["effects"] = [{"op": "repair_room", "room": "missing_room"}]
        event["choices"][1]["requirements"]["piece_available"] = "missing_piece"
        errors: list[str] = []
        validator.validate_event(
            Path("workshop_can_wait.json"),
            event,
            {"gatehouse_lock"},
            set(),
            set(),
            errors,
            {"workshop"},
            {"repair_station"},
        )
        joined = "\n".join(errors)
        self.assertIn("room_condition eligibility", joined)
        self.assertIn("repair_room references unknown room", joined)
        self.assertIn("piece_available must reference a known piece", joined)

    def test_event_trigger_wave_array_rejects_duplicates_and_range(self) -> None:
        event = copy.deepcopy(load("data/events/wrong_wall_report.json"))
        event["trigger"]["wave"] = [1, 1, 4]
        errors: list[str] = []
        validator.validate_event(
            Path("wrong_wall_report.json"),
            event,
            {"wrong_wall"},
            set(),
            set(),
            errors,
            {"workshop"},
            {"repair_station"},
        )
        joined = "\n".join(errors)
        self.assertIn("trigger waves must be integers from 0 to 3", joined)
        self.assertIn("trigger wave array contains a duplicate", joined)

    def test_event_rejects_invalid_choice_flags_and_commander_variants(self) -> None:
        event = copy.deepcopy(load("data/events/mara_second_door.json"))
        event["eligibility"]["any_flag"] = ["Not Stable"]
        event["choices"][0]["flags"] = {"bad.flag": "yes"}
        event["commander_variants"]["missing_commander"] = event["commander_variants"].pop("castellan")
        errors: list[str] = []
        validator.validate_event(
            Path("mara_second_door.json"), event, {"gatehouse_lock"}, set(), set(), errors,
            {"workshop"}, {"repair_station"}, {"castellan", "warden", "quartermaster"},
        )
        joined = "\n".join(errors)
        self.assertIn("any_flag eligibility contains an invalid flag", joined)
        self.assertIn("must be a stable boolean", joined)
        self.assertIn("commander variant missing_commander is malformed", joined)

    def test_rare_event_rejects_invalid_seed_slot(self) -> None:
        event = copy.deepcopy(load("data/events/old_drain_opens.json"))
        event["eligibility"]["seed_slot"] = {"mod": 3, "slots": [3]}
        errors: list[str] = []
        validator.validate_event(
            Path("old_drain_opens.json"), event, {"open_yard_net"}, set(), set(), errors,
            {"outer_wall"}, set(),
        )
        self.assertIn("seed_slot eligibility contains an out-of-range slot", "\n".join(errors))

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
