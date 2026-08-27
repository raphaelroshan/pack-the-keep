extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _unlock_modifiers(state: PackKeepState) -> void:
	state.active_event_id = "relief_road_report"
	state.unlock_modifier("roadside_intelligence", "relief_road_report")
	state.unlock_modifier("hardened_vanguard", "relief_road_report")
	state.active_event_id = ""

func _place_three_bells_loadout(state: PackKeepState) -> void:
	state.open_pack("bell_guard")
	state.open_pack("crossbow_watch")
	state.place_piece("pike_squad", Vector2i(0, 3), "ground")
	state.place_piece("bellkeepers", Vector2i(1, 5), "upper")
	state.place_piece("signal_beacon", Vector2i(4, 5), "upper")
	state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
	state.place_piece("watch_banner", Vector2i(4, 1), "upper")

func _run_challenge(seed: int, commander_id: String) -> Dictionary:
	var state: PackKeepState = PackKeepState.new(seed)
	_unlock_modifiers(state)
	state.equip_modifier("hardened_vanguard")
	state.select_commander(commander_id)
	state.select_scenario("three_bells_at_dusk")
	_place_three_bells_loadout(state)
	for _guard in range(100):
		if not state.wave_active:
			if state.last_outcome == "collapse" or (state.wave_index >= state.authored_wave_count() and not state.has_next_wave()):
				break
			if state.repair_interval_active:
				state.finish_repair_interval()
			else:
				state.start_wave(state.enemy_doctrine)
		if state.wave_active:
			state.advance_wave(1.0)
	return {"serialized": JSON.stringify(state.serialize()), "waves": state.wave_history.size(), "outcome": state.last_outcome}

func _initialize() -> void:
	_test_selection_and_wave_application()
	_test_active_wave_save_load()
	_test_bounded_challenge_replays()
	if failures.is_empty():
		print("P11 Hardened Vanguard challenge modifier: PASS (20 deterministic challenge cases)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _test_selection_and_wave_application() -> void:
	var locked: PackKeepState = PackKeepState.new(6707)
	_check(String(locked.equip_modifier("hardened_vanguard").get("reason", "")) == "modifier_locked", "Hardened Vanguard should reject equip before The Relief Road unlock")

	var state: PackKeepState = PackKeepState.new(6707)
	_unlock_modifiers(state)
	_check(bool(state.equip_modifier("roadside_intelligence").get("ok", false)) and state.morale == 5, "Roadside Intelligence should retain its one-morale trade-off")
	_check(bool(state.equip_modifier("hardened_vanguard").get("ok", false)) and state.equipped_modifier_id == "hardened_vanguard" and state.morale == 6, "selecting Hardened Vanguard should replace the information modifier and restore baseline morale")
	state.select_scenario("gatehouse_lock")
	state.place_piece("pike_squad", Vector2i(0, 3), "ground")
	state.start_wave("gate_assault")
	_check(state.enemies.size() == 2 and int(state.enemies[0].max_health) == 10 and int(state.enemies[0].hp) == 10, "Hardened Vanguard should add exactly two current and maximum health at wave creation")
	_check(state.battle_report.has("Hardened Vanguard hardens the vanguard; every enemy begins with +2 health."), "the battle report should name the challenge health change causally")
	_check(String(state.equip_modifier("").get("reason", "")) == "modifier_change_requires_between_runs", "modifier selection should remain locked during an active run")

	var baseline: PackKeepState = PackKeepState.new(6707)
	baseline.select_scenario("gatehouse_lock")
	baseline.place_piece("pike_squad", Vector2i(0, 3), "ground")
	baseline.start_wave("gate_assault")
	_check(int(baseline.enemies[0].max_health) == 8, "the no-modifier baseline should retain authored enemy health")

func _test_active_wave_save_load() -> void:
	var state: PackKeepState = PackKeepState.new(6708)
	_unlock_modifiers(state)
	state.equip_modifier("hardened_vanguard")
	state.select_scenario("gatehouse_lock")
	state.place_piece("pike_squad", Vector2i(0, 3), "ground")
	state.start_wave("gate_assault")
	state.advance_wave(1.0)
	var restored: PackKeepState = PackKeepState.new(0)
	_check(bool(restored.load_serialized(state.serialize()).get("ok", false)), "active Hardened Vanguard wave should load")
	_check(restored.equipped_modifier_id == "hardened_vanguard" and restored.enemies == state.enemies, "save/load should preserve the equipped challenge and already-applied enemy health")
	state.advance_wave(1.0)
	restored.advance_wave(1.0)
	_check(JSON.stringify(restored.serialize()) == JSON.stringify(state.serialize()), "loaded challenge wave should continue deterministically")

func _test_bounded_challenge_replays() -> void:
	for commander_id in ["castellan", "warden"]:
		for seed in range(6707, 6717):
			var first: Dictionary = _run_challenge(seed, commander_id)
			var second: Dictionary = _run_challenge(seed, commander_id)
			_check(first.serialized == second.serialized, "Hardened Vanguard replay should be deterministic for %s seed %d" % [commander_id, seed])
			_check(int(first.waves) == 3 and String(first.outcome) != "collapse", "Hardened Vanguard should retain a viable Three Bells path for %s seed %d" % [commander_id, seed])
