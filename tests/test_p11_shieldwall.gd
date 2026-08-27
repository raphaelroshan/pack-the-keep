extends SceneTree

const ContentCatalog = preload("res://src/core/content_catalog.gd")
const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _run_scenario(seed: int, commander_id: String) -> Dictionary:
	var state = PackKeepState.new(seed)
	state.select_commander(commander_id)
	state.select_scenario("the_splintered_gate")
	state.open_pack("shieldwall")
	state.place_piece("pike_squad", Vector2i(0, 3), "ground")
	state.place_piece("shield_wardens", Vector2i(3, 3), "ground")
	state.place_piece("emergency_shutters", Vector2i(6, 2), "ground")
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
	var catalog_state = PackKeepState.new(5507)
	var status: Dictionary = catalog_state.content_catalog_status()
	_check(bool(status.get("ok", false)), "P11 Shieldwall catalog should validate")
	_check(int(status.get("pack_count", 0)) == 9 and int(status.get("piece_count", 0)) == 17 and int(status.get("enemy_count", 0)) == 7 and int(status.get("doctrine_count", 0)) == 8 and int(status.get("scenario_count", 0)) == 8, "P11 catalog counts should include all teaching pairs and the challenge")
	var catalog = ContentCatalog.new()
	catalog.load_default(PackKeepState.ROOMS.keys())
	var malformed_breaker: Dictionary = catalog.enemy_definition("shieldbreaker")
	malformed_breaker.target_piece_categories = []
	malformed_breaker.target_piece_preference = "random"
	malformed_breaker.ignores_protection = "yes"
	var breaker_errors: Array[String] = catalog.validate_enemy_definition(malformed_breaker, "shieldbreaker", PackKeepState.ROOMS.keys(), catalog.doctrine_ids())
	_check(breaker_errors.size() >= 3, "catalog validation should reject malformed Shieldbreaker targeting and protection flags")

	var guarded = PackKeepState.new(5507)
	guarded.open_pack("field_engineers")
	guarded.open_pack("shieldwall")
	guarded.place_piece("repair_station", Vector2i(1, 1), "upper")
	guarded.place_piece("shield_wardens", Vector2i(3, 1), "upper")
	guarded._apply_enemy_damage("sapper", "repair_station_0")
	_check(int(guarded.pieces["repair_station_0"].health) == 5, "adjacent Shield Wardens should reduce ordinary piece damage by one")

	var pierced = PackKeepState.new(5507)
	pierced.open_pack("field_engineers")
	pierced.open_pack("shieldwall")
	pierced.place_piece("repair_station", Vector2i(1, 1), "upper")
	pierced.place_piece("shield_wardens", Vector2i(3, 1), "upper")
	pierced._apply_enemy_damage("shieldbreaker", "repair_station_0")
	_check(int(pierced.pieces["repair_station_0"].health) == 2, "Shieldbreaker should ignore adjacent piece protection")
	_check(pierced.battle_report.has("Shieldbreaker ignored 1 adjacent guard protecting Repair Station."), "causal report should explain ignored adjacent protection")

	var shuttered = PackKeepState.new(5507)
	shuttered.open_pack("shieldwall")
	shuttered.place_piece("emergency_shutters", Vector2i(3, 3), "ground")
	shuttered._apply_enemy_damage("raider", "gate")
	_check(shuttered.room_condition("gate") == 100, "Emergency Shutters should absorb two ordinary room damage")
	var broken = PackKeepState.new(5507)
	broken.open_pack("shieldwall")
	broken.open_pack("fallback_convoy")
	broken.place_piece("emergency_shutters", Vector2i(3, 3), "ground")
	broken.place_piece("breakaway_barricade", Vector2i(3, 5), "ground")
	broken._apply_enemy_damage("shieldbreaker", "gate")
	_check(broken.room_condition("gate") == 55 and not bool(broken.pieces["breakaway_barricade_1"].disabled), "Shieldbreaker should bypass shutters and preserve an untriggered Breakaway Barricade")

	var targeted = PackKeepState.new(5507)
	targeted.open_pack("shieldwall")
	targeted.place_piece("shield_wardens", Vector2i(3, 3), "ground")
	targeted.start_wave("break_the_line")
	targeted.advance_wave(1.0)
	targeted.advance_wave(1.0)
	_check(String(targeted.enemies[0].get("target", "")) == "shield_wardens_0", "Shieldbreaker should target the strongest eligible frontline piece")
	var restored = PackKeepState.new(1)
	var loaded: Dictionary = restored.load_serialized(targeted.serialize())
	_check(bool(loaded.get("ok", false)) and JSON.stringify(restored.serialize()) == JSON.stringify(targeted.serialize()), "save/load should preserve Shieldbreaker target and Shieldwall state")

	for commander_id in ["castellan", "warden"]:
		for seed in [5507, 5508, 5509]:
			var first: Dictionary = _run_scenario(seed, commander_id)
			var second: Dictionary = _run_scenario(seed, commander_id)
			_check(first.serialized == second.serialized, "The Splintered Gate replay should be deterministic for %s seed %d" % [commander_id, seed])
			_check(int(first.waves) == 3, "The Splintered Gate should resolve all three authored waves")
			_check(String(first.outcome) == "held", "the tested Shieldwall baseline should hold while absorbing frontline attrition")

	if failures.is_empty():
		print("P11 Shieldwall: PASS (6 deterministic three-wave Splintered Gate replays)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
