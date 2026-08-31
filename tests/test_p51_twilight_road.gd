extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _place_answer(state: RefCounted, answer: String) -> bool:
	if not bool(state.place_piece("pike_squad", Vector2i(0, 3), "ground").get("ok", false)):
		return false
	if answer == "prepared_routes":
		if not bool(state.open_pack("road_wardens").get("ok", false)) or not bool(state.open_pack("lantern_watch").get("ok", false)):
			return false
		for placement in [
			["stake_line", Vector2i(1, 2), "ground"],
			["hook_guard", Vector2i(4, 3), "ground"],
			["dusk_bow", Vector2i(1, 1), "upper"],
			["lantern_post", Vector2i(7, 1), "upper"],
		]:
			if not bool(state.place_piece(placement[0], placement[1], placement[2]).get("ok", false)):
				return false
		return true
	if not bool(state.open_pack("crossbow_watch").get("ok", false)) or not bool(state.open_pack("runner_network").get("ok", false)):
		return false
	for placement in [
		["crossbow_patrol", Vector2i(1, 1), "upper"],
		["watch_banner", Vector2i(4, 1), "upper"],
		["runner_pair", Vector2i(4, 3), "ground"],
		["supply_cache", Vector2i(6, 3), "ground"],
	]:
		if not bool(state.place_piece(placement[0], placement[1], placement[2]).get("ok", false)):
			return false
	return true

func _run(seed: int, commander_id: String, answer: String, resume: bool = false) -> Dictionary:
	var state: RefCounted = PackKeepState.new(seed)
	state.select_commander(commander_id)
	state.select_scenario("the_twilight_road")
	if not _place_answer(state, answer):
		return {}
	var restored: bool = false
	var combined_state: Dictionary = {}
	for _guard in range(100):
		if state.wave_active and state.wave_index == 3 and state.battle_step == 0 and combined_state.is_empty():
			combined_state = state.forecast().duplicate(true)
		if resume and not restored and state.wave_active and state.wave_index == 3 and state.battle_step == 1:
			var loaded: RefCounted = PackKeepState.new(1)
			_check(bool(loaded.load_serialized(state.serialize()).get("ok", false)), "Twilight Road checkpoint should load")
			state = loaded
			restored = true
		if state.wave_active:
			state.advance_wave(1.0)
			continue
		if state.last_outcome == "collapse" or (state.wave_index >= state.authored_wave_count() and not state.has_next_wave()):
			break
		if state.repair_interval_active:
			state.finish_repair_interval()
		else:
			state.start_wave(state.enemy_doctrine)
	return {"serialized": JSON.stringify(state.serialize()), "waves": state.wave_history.size(), "outcome": state.last_outcome, "restored": restored, "combined": combined_state}

func _initialize() -> void:
	var preview_state: RefCounted = PackKeepState.new(5501)
	preview_state.select_scenario("the_twilight_road")
	var preview: Dictionary = preview_state.scenario_preview()
	_check(preview.get("doctrine_names", []) == ["Rapid Breakthrough", "Veiled Entry", "Twilight Crossing"], "Twilight Road should teach tempo, then visibility, then combine them")
	_check(preview.get("recommended_packs", []) == ["road_wardens", "lantern_watch"] and String(preview.get("lesson", "")).contains("Crossbow Watch plus Runner Network"), "Twilight Road should declare both two-pack plans")

	for answer in ["prepared_routes", "flexible_response"]:
		for commander_id in ["castellan", "warden", "quartermaster"]:
			for seed in [5501, 5502, 5503]:
				var uninterrupted: Dictionary = _run(seed, commander_id, answer)
				var resumed: Dictionary = _run(seed, commander_id, answer, true)
				_check(not uninterrupted.is_empty() and uninterrupted.serialized == resumed.serialized, "Twilight Road replay should survive save/load for %s/%s/%d" % [answer, commander_id, seed])
				_check(bool(resumed.get("restored", false)), "Twilight Road should reach the combined-wave checkpoint for %s/%s/%d" % [answer, commander_id, seed])
				_check(int(uninterrupted.get("waves", 0)) == 3 and String(uninterrupted.get("outcome", "")) != "collapse", "Twilight Road %s plan should remain viable for %s/%d" % [answer, commander_id, seed])
				var combined: Dictionary = uninterrupted.get("combined", {})
				_check(bool(combined.get("momentum_threat", false)) and bool(combined.get("concealment_threat", false)), "combined phase should expose both questions for %s/%s/%d" % [answer, commander_id, seed])
				if answer == "prepared_routes":
					_check(bool(combined.get("momentum_delayed", false)) and bool(combined.get("concealment_revealed", false)), "prepared plan should delay and reveal both routes")
				else:
					_check(not bool(combined.get("momentum_delayed", true)) and not bool(combined.get("concealment_revealed", true)), "flexible plan should preserve live charge and veiled melee interception")

	if failures.is_empty():
		print("P51 Twilight Road: PASS (18 combined two-plan runs plus save-resume parity)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
