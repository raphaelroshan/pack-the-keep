extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _resolve_wave(keep: PackKeepState) -> void:
	while keep.wave_active:
		keep.advance_wave(1.0)

func _start_relief(choice_id: String, with_layered_layout: bool = false) -> PackKeepState:
	var keep: PackKeepState = PackKeepState.new(3307)
	keep.select_scenario("relief_road")
	keep.choose_event_option(choice_id)
	keep.open_pack("runner_network")
	keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	keep.place_piece("supply_cache", Vector2i(6, 3), "ground")
	if with_layered_layout:
		keep.open_pack("fallback_convoy")
		keep.place_piece("runner_pair", Vector2i(4, 3), "ground")
		keep.place_piece("rear_guard", Vector2i(4, 4), "ground")
		keep.place_piece("breakaway_barricade", Vector2i(3, 3), "ground")
	keep.start_wave("feint_and_flank")
	return keep

func _complete_relief_run(first_choice: String, recovery_choice: String) -> PackKeepState:
	var keep: PackKeepState = _start_relief(first_choice, true)
	while keep.wave_active or keep.repair_interval_active:
		if keep.wave_active:
			_resolve_wave(keep)
		elif keep.repair_interval_active:
			if keep.active_event_id == "relief_road_recovery":
				keep.choose_event_option(recovery_choice)
			elif keep.active_event_id == "relief_road_report":
				keep.choose_event_option("record_the_cost")
			var continued: Dictionary = keep.finish_repair_interval()
			if not bool(continued.get("next_wave_started", false)):
				break
	return keep

func _initialize() -> void:
	_test_forecast_event_and_atomic_rejection()
	_test_marked_sapper_contact()
	_test_recovery_choices_and_migration()
	_test_conclusion_and_replay()
	if failures.is_empty():
		print("P8 authored events: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _test_forecast_event_and_atomic_rejection() -> void:
	var keep: PackKeepState = PackKeepState.new(3307)
	keep.select_scenario("relief_road")
	var active: Dictionary = keep.current_event()
	_check(bool(active.get("ok", false)) and String(active.get("id", "")) == "relief_road_warning", "Relief Road should activate its forecast event during Preparation")
	keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	var blocked_start: Dictionary = keep.start_wave("feint_and_flank")
	_check(String(blocked_start.get("reason", "")) == "active_event_unresolved", "an unresolved forecast event should block wave start")
	var before_invalid: String = JSON.stringify(keep.serialize())
	var invalid: Dictionary = keep.choose_event_option("missing_choice")
	_check(String(invalid.get("reason", "")) == "unknown_event_choice", "unknown event choices should be rejected with a stable reason")
	_check(JSON.stringify(keep.serialize()) == before_invalid, "a rejected event choice should not mutate authoritative state")
	keep.command_points = 0
	var before_unaffordable: String = JSON.stringify(keep.serialize())
	var unaffordable: Dictionary = keep.choose_event_option("mark_support_lane")
	_check(String(unaffordable.get("reason", "")) == "event_requirement_command_points", "forecast choice should reject insufficient command points")
	_check(JSON.stringify(keep.serialize()) == before_unaffordable, "an unaffordable event choice should remain atomic")
	keep.command_points = 3
	var marked: Dictionary = keep.choose_event_option("mark_support_lane")
	_check(bool(marked.get("ok", false)) and keep.command_points == 2, "marking the support lane should spend exactly one command point")
	_check(bool(keep.event_flags.get("support_lane_marked", false)) and keep.resolved_event_ids == ["relief_road_warning"], "forecast choice should persist its flag and resolved event ID")
	_check(not bool(keep.select_commander("warden").get("ok", false)), "commander changes should not reset a resolved event cost")
	var restored: PackKeepState = PackKeepState.new(0)
	_check(bool(restored.load_serialized(keep.serialize()).get("ok", false)), "active event state should serialize and load")
	_check(restored.event_flags == keep.event_flags and restored.event_history == keep.event_history, "loaded event flags and history should match the saved state")

func _test_marked_sapper_contact() -> void:
	var marked: PackKeepState = _start_relief("mark_support_lane")
	var unmarked: PackKeepState = _start_relief("keep_command_ready")
	for keep in [marked, unmarked]:
		_resolve_wave(keep)
		keep.choose_event_option("release_field_stores")
		keep.finish_repair_interval()
		keep.advance_wave(3.0)
	_check(int(unmarked.combat_metrics.get("piece_damage", 0)) - int(marked.combat_metrics.get("piece_damage", 0)) == 1, "marked support lane should reduce exactly one Sapper contact damage")
	_check(not bool(marked.event_flags.get("support_lane_marked", true)), "marked support lane should be consumed by the first Sapper contact")
	_check(marked.battle_report.has("The marked support lane reduced the first Sapper contact by 1 damage and is now spent."), "Sapper mitigation should be named in the causal battle report")

func _test_recovery_choices_and_migration() -> void:
	var stores: PackKeepState = _start_relief("keep_command_ready")
	_resolve_wave(stores)
	_check(stores.active_event_id == "relief_road_recovery", "wave one should activate the recovery event")
	var recovery_restored: PackKeepState = PackKeepState.new(0)
	_check(bool(recovery_restored.load_serialized(stores.serialize()).get("ok", false)) and recovery_restored.active_event_id == "relief_road_recovery", "save/load should preserve an active recovery event")
	_check(String(stores.finish_repair_interval().get("reason", "")) == "active_event_unresolved", "an unresolved recovery event should block interval closure")
	_check(String(stores.recovery_action_preview("repair_room", "", "gate").get("reason", "")) == "resolve the active event first", "normal recovery actions should not consume the budget reserved for an active event")
	var materials_before: int = stores.materials
	var actions_before: int = stores.repair_actions_remaining
	var released: Dictionary = stores.choose_event_option("release_field_stores")
	_check(bool(released.get("ok", false)) and stores.materials == materials_before + 5 and stores.repair_actions_remaining == actions_before - 1, "field stores should trade one recovery action for five materials")

	var morale: PackKeepState = _start_relief("keep_command_ready")
	_resolve_wave(morale)
	var morale_before: int = morale.morale
	var steadied: Dictionary = morale.choose_event_option("steady_the_refuge")
	_check(bool(steadied.get("ok", false)) and morale.morale == mini(10, morale_before + 1) and morale.repair_actions_remaining == 1, "refuge choice should trade one recovery action for one morale")

	var legacy_payload: Dictionary = stores.serialize()
	legacy_payload.schema_version = 2
	legacy_payload.erase("active_event_id")
	legacy_payload.erase("resolved_event_ids")
	legacy_payload.erase("event_flags")
	legacy_payload.erase("event_history")
	var migrated: PackKeepState = PackKeepState.new(0)
	var loaded: Dictionary = migrated.load_serialized(legacy_payload)
	_check(bool(loaded.get("migrated", false)) and migrated.active_event_id == "relief_road_recovery", "schema-2 recovery save should derive the event required by its current phase")
	var malformed_payload: Dictionary = stores.serialize()
	malformed_payload.active_event_id = "missing_event"
	var untouched: PackKeepState = PackKeepState.new(99)
	var malformed: Dictionary = untouched.load_serialized(malformed_payload)
	_check(not bool(malformed.get("ok", false)) and untouched.seed == 99, "unknown saved event IDs should be rejected before state mutation")
	var malformed_history: Dictionary = stores.serialize()
	malformed_history.event_history = [{"event_id": "missing_event", "choice_id": "missing_choice"}]
	var history_target: PackKeepState = PackKeepState.new(101)
	_check(not bool(history_target.load_serialized(malformed_history).get("ok", false)) and history_target.seed == 101, "malformed saved event history should be rejected before state mutation")

func _test_conclusion_and_replay() -> void:
	var first: PackKeepState = _complete_relief_run("mark_support_lane", "release_field_stores")
	var second: PackKeepState = _complete_relief_run("mark_support_lane", "release_field_stores")
	_check(first.event_history.size() == 3 and first.resolved_event_ids.size() == 3, "Relief Road should resolve the complete three-event chain")
	_check(first.event_history == second.event_history and first.scenario_scorecard() == second.scenario_scorecard(), "same seed and event commands should reproduce history and scorecard")
	var conclusion_changes: Array = first.event_history[2].get("state_changes", [])
	_check(not conclusion_changes.is_empty() and String(conclusion_changes[0].get("outcome", "")).length() > 0, "conclusion event should record the final authoritative outcome")
	_check(String(first.scenario_report().get("status", "")) == "complete", "scenario report should become complete after the conclusion event resolves")
