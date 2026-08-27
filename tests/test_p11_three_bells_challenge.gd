extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _place_loadout(state: RefCounted, loadout: String) -> void:
	state.open_pack("bell_guard")
	state.place_piece("pike_squad", Vector2i(0, 3), "ground")
	state.place_piece("bellkeepers", Vector2i(1, 5), "upper")
	state.place_piece("signal_beacon", Vector2i(4, 5), "upper")
	if loadout == "precision_signal":
		state.open_pack("crossbow_watch")
		state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
		state.place_piece("watch_banner", Vector2i(4, 1), "upper")
	else:
		state.open_pack("shieldwall")
		state.place_piece("shield_wardens", Vector2i(3, 3), "ground")
		state.place_piece("emergency_shutters", Vector2i(6, 2), "ground")

func _run(seed: int, commander_id: String, loadout: String) -> Dictionary:
	var state = PackKeepState.new(seed)
	state.select_commander(commander_id)
	state.select_scenario("three_bells_at_dusk")
	_place_loadout(state, loadout)
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
	for loadout in ["precision_signal", "anchored_signal"]:
		for commander_id in ["castellan", "warden"]:
			for seed in [6607, 6608, 6609]:
				var first: Dictionary = _run(seed, commander_id, loadout)
				var second: Dictionary = _run(seed, commander_id, loadout)
				_check(first.serialized == second.serialized, "Three Bells replay should be deterministic for %s, %s, seed %d" % [loadout, commander_id, seed])
				_check(int(first.waves) == 3, "Three Bells should resolve all waves for %s and %s" % [loadout, commander_id])
				_check(String(first.outcome) != "collapse", "Three Bells baseline should retain a viable %s path for %s" % [loadout, commander_id])
	if failures.is_empty():
		print("P11 Three Bells challenge: PASS (12 deterministic cross-pair replays)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
