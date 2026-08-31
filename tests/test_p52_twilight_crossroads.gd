extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _place_mixed_answer(state: RefCounted, choice_id: String) -> bool:
	if not bool(state.place_piece("pike_squad", Vector2i(0, 3), "ground").get("ok", false)):
		return false
	if choice_id == "carry_lamp_oil":
		for pack_id in ["road_wardens", "crossbow_watch"]:
			if not bool(state.open_pack(pack_id).get("ok", false)):
				return false
		for placement in [
			["stake_line", Vector2i(1, 2), "ground"],
			["hook_guard", Vector2i(4, 3), "ground"],
			["crossbow_patrol", Vector2i(1, 1), "upper"],
			["watch_banner", Vector2i(4, 1), "upper"],
		]:
			if not bool(state.place_piece(placement[0], placement[1], placement[2]).get("ok", false)):
				return false
		return true
	for pack_id in ["lantern_watch", "runner_network"]:
		if not bool(state.open_pack(pack_id).get("ok", false)):
			return false
	for placement in [
		["dusk_bow", Vector2i(1, 1), "upper"],
		["lantern_post", Vector2i(7, 1), "upper"],
		["runner_pair", Vector2i(4, 3), "ground"],
		["supply_cache", Vector2i(6, 3), "ground"],
	]:
		if not bool(state.place_piece(placement[0], placement[1], placement[2]).get("ok", false)):
			return false
	return true

func _run(seed: int, commander_id: String, choice_id: String, resume: bool = false) -> Dictionary:
	var state: RefCounted = PackKeepState.new(seed)
	state.select_commander(commander_id)
	state.select_scenario("the_twilight_road")
	if not _place_mixed_answer(state, choice_id):
		return {}
	var restored: bool = false
	var event_actions_before: int = -1
	var selected_forecast: Dictionary = {}
	var final_enemies: Array = []
	for _guard in range(120):
		if state.active_event_id == "twilight_crossroads":
			event_actions_before = state.repair_actions_remaining
			if resume and not restored:
				var loaded: RefCounted = PackKeepState.new(1)
				_check(bool(loaded.load_serialized(state.serialize()).get("ok", false)), "active Twilight Crossroads checkpoint should load")
				state = loaded
				restored = true
			var unprepared: Dictionary = state.forecast()
			if choice_id == "replant_road_stakes":
				_check(not bool(unprepared.get("momentum_delayed", false)), "stakes branch should expose live momentum before the recovery choice")
			else:
				_check(not bool(unprepared.get("concealment_revealed", false)), "lamp branch should expose veiled attackers before the recovery choice")
			_check(bool(state.choose_event_option(choice_id).get("ok", false)), "Twilight Crossroads choice should resolve")
			_check(state.repair_actions_remaining == event_actions_before - 1, "Twilight Crossroads should consume exactly one recovery action")
			selected_forecast = state.forecast().duplicate(true)
			continue
		if state.wave_active:
			if state.wave_index == 3 and state.battle_step == 0 and final_enemies.is_empty():
				final_enemies = state.enemies.duplicate(true)
			state.advance_wave(1.0)
			continue
		if state.last_outcome == "collapse" or (state.wave_index >= state.authored_wave_count() and not state.has_next_wave()):
			break
		if state.repair_interval_active:
			state.finish_repair_interval()
		else:
			state.start_wave(state.enemy_doctrine)
	return {
		"serialized": JSON.stringify(state.serialize()),
		"waves": state.wave_history.size(),
		"outcome": state.last_outcome,
		"restored": restored,
		"actions_before": event_actions_before,
		"forecast": selected_forecast,
		"enemies": final_enemies,
		"flags": state.event_flags.duplicate(true),
		"history": state.event_history.duplicate(true),
		"report": state.scenario_report(),
		"variation_id": state.scenario_variation_id,
	}

func _initialize() -> void:
	for choice_id in ["carry_lamp_oil", "replant_road_stakes"]:
		for commander_id in ["castellan", "warden", "quartermaster"]:
			for seed in [5601, 5602, 5603]:
				var uninterrupted: Dictionary = _run(seed, commander_id, choice_id)
				var resumed: Dictionary = _run(seed, commander_id, choice_id, true)
				var label: String = "%s/%s/%d" % [choice_id, commander_id, seed]
				_check(not uninterrupted.is_empty() and uninterrupted.serialized == resumed.serialized, "recovery branch should survive save/load for %s" % label)
				_check(bool(resumed.get("restored", false)), "recovery branch should reach the active-event checkpoint for %s" % label)
				_check(int(uninterrupted.get("actions_before", -1)) == 2, "recovery event should open with two actions for %s" % label)
				_check(int(uninterrupted.get("waves", 0)) == 3 and String(uninterrupted.get("outcome", "")) != "collapse", "mixed answer should remain viable for %s" % label)
				var forecast: Dictionary = uninterrupted.get("forecast", {})
				var final_enemies: Array = uninterrupted.get("enemies", [])
				_check(final_enemies.size() == 4, "final combined wave should retain four threats for %s" % label)
				var enemy_counts: Dictionary = {"outrider": 0, "gloam_knife": 0}
				for enemy in final_enemies:
					var enemy_id: String = String(enemy.get("enemy_id", ""))
					enemy_counts[enemy_id] = int(enemy_counts.get(enemy_id, 0)) + 1
					if String(enemy.get("enemy_id", "")) == "outrider":
						_check(bool(enemy.get("momentum_delayed", false)), "mixed answer should delay final Outriders for %s" % label)
					if String(enemy.get("enemy_id", "")) == "gloam_knife":
						_check(bool(enemy.get("concealment_revealed", false)), "mixed answer should reveal final Gloam Knives for %s" % label)
				var variation_id: String = String(uninterrupted.get("variation_id", ""))
				var expected_counts: Dictionary = {"outrider": 2, "gloam_knife": 2} if variation_id == "standard_bell" else {"outrider": 1, "gloam_knife": 3} if variation_id == "fading_light" else {"outrider": 3, "gloam_knife": 1}
				_check(enemy_counts == expected_counts, "final composition should match disclosed %s pressure for %s" % [variation_id, label])
				_check(bool(forecast.get("momentum_delayed", false)) and bool(forecast.get("concealment_revealed", false)), "selected recovery branch should complete the mixed answer for %s" % label)
				var spent_flag: String = "twilight_lamps_ready" if choice_id == "carry_lamp_oil" else "twilight_stakes_ready"
				_check(not bool(uninterrupted.flags.get(spent_flag, true)), "selected route preparation should be spent at final-wave start for %s" % label)
				_check(uninterrupted.history.size() == 1 and String(uninterrupted.history[0].get("choice_id", "")) == choice_id, "event history should preserve the recovery branch for %s" % label)
				var report: Dictionary = uninterrupted.get("report", {})
				var recovery_branch: Dictionary = report.get("mastery", {}).get("recovery_branch", {})
				_check(String(recovery_branch.get("choice_id", "")) == choice_id and String(recovery_branch.get("fit_text", "")).contains("COMPLEMENTARY"), "terminal mastery should identify the mixed recovery branch for %s" % label)
				var opposite_route: String = "road stakes" if choice_id == "carry_lamp_oil" else "stair lamps"
				_check(String(report.get("suggested_experiment", "")).contains(opposite_route), "terminal replay guidance should propose the opposite branch for %s" % label)

	var redundant: RefCounted = PackKeepState.new(5601)
	redundant.select_scenario("the_twilight_road")
	redundant.open_pack("road_wardens")
	redundant.open_pack("lantern_watch")
	redundant.event_history.append({"event_id": "twilight_crossroads", "choice_id": "carry_lamp_oil", "wave": 2, "phase": "recovery", "visible_result": "", "state_changes": []})
	_check(String(redundant.replay_mastery_summary().get("recovery_branch", {}).get("fit_text", "")).contains("REDUNDANT"), "mastery should identify duplicated route preparation without granting a stacking bonus")

	var expected_variations: Dictionary = {
		5601: ["standard_bell", ["outrider", "outrider", "gloam_knife", "gloam_knife"]],
		5602: ["fading_light", ["outrider", "gloam_knife", "gloam_knife", "gloam_knife"]],
		5603: ["long_twilight", ["outrider", "outrider", "outrider", "gloam_knife"]],
	}
	for variation_seed in expected_variations.keys():
		var preview_state: RefCounted = PackKeepState.new(int(variation_seed))
		preview_state.select_scenario("the_twilight_road")
		var before_preview: String = JSON.stringify(preview_state.serialize())
		var preview: Dictionary = preview_state.scenario_variation_preview()
		_check(String(preview.get("id", "")) == expected_variations[variation_seed][0], "seed %d should select its stable Twilight variation" % variation_seed)
		_check(preview.get("final_wave_plan", []) == expected_variations[variation_seed][1], "seed %d should disclose its final-wave override" % variation_seed)
		_check(String(preview.get("summary", "")).contains("final pressure"), "every variation should disclose final pressure before entry")
		_check(String(preview.get("summary", "")).contains("preparation focus"), "every variation should translate pressure into a preparation emphasis")
		_check(JSON.stringify(preview_state.serialize()) == before_preview, "variation preview must not mutate authoritative state")

	if failures.is_empty():
		print("P52 Twilight Crossroads: PASS (18 mixed-plan recovery runs, save parity, and branch-aware debrief)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
