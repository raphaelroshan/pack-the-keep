extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _resolve_wave(keep: PackKeepState) -> void:
	while keep.wave_active:
		keep.advance_wave(1.0)

func _complete_relief_road() -> PackKeepState:
	var keep: PackKeepState = PackKeepState.new(3307)
	keep.select_scenario("relief_road")
	keep.choose_event_option("keep_command_ready")
	keep.open_pack("runner_network")
	keep.open_pack("fallback_convoy")
	keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	keep.place_piece("runner_pair", Vector2i(4, 3), "ground")
	keep.place_piece("supply_cache", Vector2i(6, 3), "ground")
	keep.place_piece("rear_guard", Vector2i(4, 4), "ground")
	keep.place_piece("breakaway_barricade", Vector2i(3, 3), "ground")
	keep.start_wave("feint_and_flank")
	while keep.wave_active or keep.repair_interval_active:
		if keep.wave_active:
			_resolve_wave(keep)
		elif keep.repair_interval_active:
			if keep.active_event_id == "relief_road_recovery":
				keep.choose_event_option("release_field_stores")
			elif keep.active_event_id == "relief_road_report":
				keep.choose_event_option("record_the_cost")
			var continued: Dictionary = keep.finish_repair_interval()
			if not bool(continued.get("next_wave_started", false)):
				break
	return keep

func _initialize() -> void:
	_test_unlock_equip_and_reset()
	_test_forecast_and_save_migration()
	_test_deterministic_tradeoff()
	if failures.is_empty():
		print("P9 Roadside Intelligence progression: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _test_unlock_equip_and_reset() -> void:
	var locked: PackKeepState = PackKeepState.new(3307)
	var before_locked: String = JSON.stringify(locked.serialize())
	_check(String(locked.equip_modifier("roadside_intelligence").get("reason", "")) == "modifier_locked", "Roadside Intelligence should reject equip before its objective is complete")
	_check(JSON.stringify(locked.serialize()) == before_locked, "rejected modifier equip should not mutate state")

	var keep: PackKeepState = _complete_relief_road()
	_check(keep.unlocked_modifier_ids == ["roadside_intelligence"], "Relief Road conclusion should unlock Roadside Intelligence exactly once")
	var duplicate: Dictionary = keep.unlock_modifier("roadside_intelligence", "relief_road_report")
	_check(bool(duplicate.get("ok", false)) and keep.unlocked_modifier_ids.size() == 1, "repeated unlock should be idempotent")
	var final_morale: int = keep.morale
	_check(bool(keep.equip_modifier("roadside_intelligence").get("ok", false)) and keep.morale == final_morale, "equipping after Results should apply to the next run without rewriting the completed run")
	keep.reset_run(3308)
	_check(keep.unlocked_modifier_ids == ["roadside_intelligence"] and keep.equipped_modifier_id == "roadside_intelligence", "new run should preserve unlocked and equipped progression")
	_check(keep.morale == 5, "equipped Roadside Intelligence should cost the Castellan one starting morale")

func _test_forecast_and_save_migration() -> void:
	var keep: PackKeepState = _complete_relief_road()
	keep.equip_modifier("roadside_intelligence")
	keep.reset_run(3307)
	keep.select_scenario("gatehouse_lock")
	var forecast: Dictionary = keep.forecast()
	_check(bool(forecast.get("composition_revealed", false)) and forecast.get("composition", []) == ["raider", "raider"], "equipped modifier should reveal the authored next-wave composition")
	var baseline: PackKeepState = PackKeepState.new(3307)
	baseline.select_scenario("gatehouse_lock")
	_check(keep.morale == baseline.morale - 1, "modifier information should cost exactly one starting morale")
	var restored: PackKeepState = PackKeepState.new(0)
	_check(bool(restored.load_serialized(keep.serialize()).get("ok", false)) and restored.unlocked_modifier_ids == keep.unlocked_modifier_ids and restored.equipped_modifier_id == keep.equipped_modifier_id, "save/load should preserve unlocked and equipped modifier state")
	var legacy_payload: Dictionary = keep.serialize()
	legacy_payload.schema_version = 3
	legacy_payload.erase("unlocked_modifier_ids")
	legacy_payload.erase("equipped_modifier_id")
	var migrated: PackKeepState = PackKeepState.new(0)
	_check(bool(migrated.load_serialized(legacy_payload).get("migrated", false)) and migrated.unlocked_modifier_ids.is_empty() and migrated.equipped_modifier_id.is_empty(), "schema-3 saves should migrate with safe empty progression defaults")

func _test_deterministic_tradeoff() -> void:
	for run_seed in [3307, 3308]:
		var first: PackKeepState = _run_modifier_case(run_seed)
		var second: PackKeepState = _run_modifier_case(run_seed)
		_check(first.forecast() == second.forecast() and first.scenario_scorecard() == second.scenario_scorecard(), "modifier run should remain deterministic for seed %d" % run_seed)
		_check(not first.last_outcome.is_empty(), "modifier balance run should produce a bounded outcome for seed %d" % run_seed)

func _run_modifier_case(run_seed: int) -> PackKeepState:
	var keep: PackKeepState = _complete_relief_road()
	keep.equip_modifier("roadside_intelligence")
	keep.reset_run(run_seed)
	keep.select_scenario("open_yard_net")
	keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	keep.start_wave("area_pressure")
	_resolve_wave(keep)
	return keep
