extends SceneTree

const ContentCatalog = preload("res://src/core/content_catalog.gd")
const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _place_loadout(state: RefCounted, loadout: String) -> void:
	state.place_piece("pike_squad", Vector2i(0, 3), "ground")
	if loadout == "precision":
		state.open_pack("crossbow_watch")
		state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
		state.place_piece("watch_banner", Vector2i(4, 1), "upper")
	else:
		state.open_pack("fallback_convoy")
		state.place_piece("rear_guard", Vector2i(4, 4), "ground")
		state.place_piece("breakaway_barricade", Vector2i(3, 3), "ground")

func _run_scenario(seed: int, commander_id: String, loadout: String, resume: bool = false) -> Dictionary:
	var state: RefCounted = PackKeepState.new(seed)
	state.select_commander(commander_id)
	state.select_scenario("the_cut_standard")
	_place_loadout(state, loadout)
	var restored: bool = false
	for _guard in range(100):
		if resume and not restored and state.wave_active and state.wave_index == 2 and state.battle_step == 1:
			var loaded: RefCounted = PackKeepState.new(1)
			var result: Dictionary = loaded.load_serialized(state.serialize())
			_check(bool(result.get("ok", false)), "The Cut Standard checkpoint should load")
			state = loaded
			restored = true
		if not state.wave_active:
			if state.last_outcome == "collapse" or (state.wave_index >= state.authored_wave_count() and not state.has_next_wave()):
				break
			if state.repair_interval_active:
				state.finish_repair_interval()
			else:
				state.start_wave(state.enemy_doctrine)
		if state.wave_active:
			state.advance_wave(1.0)
	return {
		"serialized": JSON.stringify(state.serialize()),
		"waves": state.wave_history.size(),
		"outcome": state.last_outcome,
		"restored": restored,
	}

func _initialize() -> void:
	var catalog: RefCounted = ContentCatalog.new()
	var loaded: Dictionary = catalog.load_default(PackKeepState.ROOMS.keys())
	_check(bool(loaded.get("ok", false)), "K6 runtime catalog should validate")
	var cutter: Dictionary = catalog.enemy_definition("standard_cutter")
	_check(bool(cutter.get("targets_assigned_first", false)), "Standard Cutter should declare assigned-specialist priority")
	_check(String(cutter.get("counter", "")) == "crossbow_patrol", "Standard Cutter should name its precision counter")
	_check(catalog.scenario_definition("the_cut_standard").get("recommended_packs", []) == ["crossbow_watch", "fallback_convoy"], "authored scenario should present two distinct answers")
	var malformed: Dictionary = cutter.duplicate(true)
	malformed.targets_assigned_first = "yes"
	_check(not catalog.validate_enemy_definition(malformed, "standard_cutter", PackKeepState.ROOMS.keys(), catalog.doctrine_ids()).is_empty(), "catalog should reject a non-boolean assigned-first contract")

	var targeted: RefCounted = PackKeepState.new(7711)
	targeted.open_pack("field_engineers")
	targeted.open_pack("crossbow_watch")
	targeted.place_piece("pike_squad", Vector2i(0, 3), "ground")
	targeted.place_piece("repair_station", Vector2i(4, 6), "ground")
	targeted.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
	targeted.repair_interval_active = true
	targeted.repair_actions_remaining = 2
	_check(bool(targeted.assign_piece_to_room("pike_squad_0", "gate").get("ok", false)), "targeting fixture should assign the Pike Squad")
	targeted._set_piece_health("repair_station_1", 2)
	_check(String(targeted._choose_target("standard_cutter")) == "pike_squad_0", "assigned specialist should outrank a weaker preferred-category target")
	targeted.pieces["pike_squad_0"].assignment = ""
	targeted.assigned_rooms.clear()
	_check(String(targeted._choose_target("standard_cutter")) == "repair_station_1", "without an assignment the Cutter should choose the weakest vulnerable specialist")
	targeted._set_piece_health("repair_station_1", 0)
	targeted._set_piece_health("crossbow_patrol_2", 0)
	_check(String(targeted._choose_target("standard_cutter")) == "pike_squad_0", "without preferred specialists the Cutter should still hunt a living unit, never a room")

	for loadout in ["precision", "mobile"]:
		for commander_id in ["castellan", "warden"]:
			for seed in [7711, 7712, 7713]:
				var uninterrupted: Dictionary = _run_scenario(seed, commander_id, loadout)
				var resumed: Dictionary = _run_scenario(seed, commander_id, loadout, true)
				_check(uninterrupted.serialized == resumed.serialized, "K6 replay should survive wave-two save/load for %s/%s/%d" % [loadout, commander_id, seed])
				_check(bool(resumed.restored), "K6 replay should reach its checkpoint for %s/%s/%d" % [loadout, commander_id, seed])
				_check(int(uninterrupted.waves) == 3, "K6 scenario should resolve all waves for %s/%s/%d" % [loadout, commander_id, seed])
				_check(String(uninterrupted.outcome) != "collapse", "K6 %s answer should remain viable for %s/%d" % [loadout, commander_id, seed])

	if failures.is_empty():
		print("K6 Standard Cutter: PASS (12 deterministic two-answer scenario replays plus save-resume parity)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
