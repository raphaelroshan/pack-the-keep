extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _place_answer(state: RefCounted, answer: String) -> bool:
	if not bool(state.place_piece("pike_squad", Vector2i(0, 3), "ground").get("ok", false)):
		return false
	if answer == "anchored":
		if not bool(state.open_pack("shieldwall").get("ok", false)):
			return false
		return bool(state.place_piece("shield_wardens", Vector2i(8, 3), "ground").get("ok", false))
	if not bool(state.open_pack("runner_network").get("ok", false)):
		return false
	return bool(state.place_piece("runner_pair", Vector2i(9, 3), "ground").get("ok", false))

func _run(seed: int, commander_id: String, answer: String, resume: bool = false) -> Dictionary:
	var state: RefCounted = PackKeepState.new(seed)
	state.select_commander(commander_id)
	state.select_scenario("the_divided_bell")
	if not _place_answer(state, answer):
		return {}
	var restored: bool = false
	for _guard in range(100):
		if resume and not restored and state.wave_active and state.wave_index == 2 and state.battle_step == 1:
			var loaded: RefCounted = PackKeepState.new(1)
			_check(bool(loaded.load_serialized(state.serialize()).get("ok", false)), "Twinwatch checkpoint should load")
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
	return {"serialized": JSON.stringify(state.serialize()), "waves": state.wave_history.size(), "outcome": state.last_outcome, "restored": restored}

func _initialize() -> void:
	var twinwatch: RefCounted = PackKeepState.new(5201)
	_check(twinwatch.keep_ids() == ["greywatch_keep", "ash_ford_redoubt", "twinwatch_bastion"], "P51 should expose three stable defensive identities")
	_check(bool(twinwatch.select_scenario("the_divided_bell").get("ok", false)), "The Divided Bell should be selectable")
	_check(twinwatch.keep_id == "twinwatch_bastion", "scenario selection should activate Twinwatch Bastion")
	_check(String(twinwatch.room_definition("gate").get("name", "")) == "West Gatehouse" and String(twinwatch.room_definition("armory").get("name", "")) == "East Arsenal", "Twinwatch should expose two named ground anchors")
	_check(not bool(twinwatch.spatial_rule_state().get("active", true)), "paired watch should begin inactive without defenders")
	_check(bool(twinwatch.place_piece("pike_squad", Vector2i(0, 3), "ground").get("ok", false)), "west anchor defender should be placeable")
	_check(not bool(twinwatch.spatial_rule_state().get("active", true)), "one staffed bastion should not activate shared protection")
	twinwatch.open_pack("runner_network")
	_check(bool(twinwatch.place_piece("runner_pair", Vector2i(9, 3), "ground").get("ok", false)), "east mobile defender should be placeable")
	_check(bool(twinwatch.spatial_rule_state().get("active", false)), "both staffed bastions should activate shared protection")
	twinwatch._apply_room_damage("raider", "gate", 3, false, false)
	_check(twinwatch.room_condition("gate") == 70, "paired bastions should reduce three damage to two")
	var runner_id: String = "runner_pair_1"
	twinwatch._set_piece_health(runner_id, 0)
	_check(not bool(twinwatch.spatial_rule_state().get("active", true)), "disabling either anchor defender should turn off shared protection")
	twinwatch._apply_room_damage("raider", "armory", 3, false, false)
	_check(twinwatch.room_condition("armory") == 55, "an unstaffed paired watch should take unreduced damage")

	twinwatch.rooms.gate.condition = 40
	twinwatch._update_room_state("gate")
	twinwatch.repair_interval_active = true
	twinwatch.repair_actions_remaining = 2
	twinwatch.materials = 7
	var repair_preview: Dictionary = twinwatch.recovery_action_preview("repair_room", "", "gate")
	_check(int(repair_preview.get("material_cost", 0)) == 7 and String(repair_preview.get("benefit", "")).contains("25"), "Twinwatch should expose its medium-depth repair profile")
	_check(bool(twinwatch.repair_room("gate").get("ok", false)) and twinwatch.room_condition("gate") == 65, "Twinwatch repair should restore exactly twenty-five condition")

	var snapshot: Dictionary = twinwatch.serialize()
	var restored_state: RefCounted = PackKeepState.new(1)
	_check(bool(restored_state.load_serialized(snapshot).get("ok", false)), "Twinwatch save should load")
	_check(restored_state.keep_id == "twinwatch_bastion" and JSON.stringify(restored_state.serialize()) == JSON.stringify(snapshot), "Twinwatch identity and state should round-trip exactly")

	for answer in ["anchored", "mobile"]:
		for commander_id in ["castellan", "warden", "quartermaster"]:
			for seed in [5201, 5202, 5203]:
				var uninterrupted: Dictionary = _run(seed, commander_id, answer)
				var resumed: Dictionary = _run(seed, commander_id, answer, true)
				_check(not uninterrupted.is_empty() and uninterrupted.serialized == resumed.serialized, "Twinwatch replay should survive save/load for %s/%s/%d" % [answer, commander_id, seed])
				_check(bool(resumed.get("restored", false)), "Twinwatch replay should reach its checkpoint for %s/%s/%d" % [answer, commander_id, seed])
				_check(int(uninterrupted.get("waves", 0)) == 3 and String(uninterrupted.get("outcome", "")) != "collapse", "Twinwatch %s answer should remain viable for %s/%d" % [answer, commander_id, seed])

	if failures.is_empty():
		print("P51 Twinwatch identity: PASS (18 two-answer runs plus save-resume parity)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
