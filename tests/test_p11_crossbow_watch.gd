extends SceneTree

const ContentCatalog = preload("res://src/core/content_catalog.gd")
const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _shield_damage_with(piece_ids: Array[String]) -> int:
	var state = PackKeepState.new(3307)
	var opened: Dictionary = state.open_pack("crossbow_watch")
	_check(bool(opened.get("ok", false)), "Crossbow Watch should open during Preparation")
	for piece_id in piece_ids:
		var origin: Vector2i = Vector2i(1 + state.pieces.size() * 3, 1)
		var placed: Dictionary = state.place_piece(piece_id, origin, "upper")
		_check(bool(placed.get("ok", false)), "%s should place on the upper wall" % piece_id)
	var started: Dictionary = state.start_wave("shielded_advance")
	_check(bool(started.get("ok", false)), "Shielded Advance should start with Crossbow Watch pieces")
	state.advance_wave(1.0)
	return int(state.enemies[0].get("damage_taken", 0))

func _run_scenario(seed: int, commander_id: String) -> Dictionary:
	var state = PackKeepState.new(seed)
	state.select_commander(commander_id)
	state.select_scenario("red_banner_road")
	state.open_pack("crossbow_watch")
	state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
	state.place_piece("watch_banner", Vector2i(4, 1), "upper")
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
	var catalog_state = PackKeepState.new(3307)
	var status: Dictionary = catalog_state.content_catalog_status()
	_check(bool(status.get("ok", false)), "P11 content catalog should validate")
	_check(int(status.get("pack_count", 0)) == 7 and int(status.get("piece_count", 0)) == 14 and int(status.get("enemy_count", 0)) == 5 and int(status.get("doctrine_count", 0)) == 6 and int(status.get("scenario_count", 0)) == 5, "P11 catalog counts should include the complete teaching pair")
	_check(catalog_state.pack_definition("crossbow_watch").get("contents", []) == ["crossbow_patrol", "watch_banner"], "Crossbow Watch should expose both doctrine pieces")
	_check(int(catalog_state.enemy_definition("shield_guard").get("armor", 0)) == 2, "Shield Guard should author two armor")
	var catalog = ContentCatalog.new()
	catalog.load_default(PackKeepState.ROOMS.keys())
	var malformed_armor: Dictionary = catalog.enemy_definition("shield_guard")
	malformed_armor.armor_counter_tag = ""
	var armor_errors: Array[String] = catalog.validate_enemy_definition(malformed_armor, "shield_guard", PackKeepState.ROOMS.keys(), catalog.doctrine_ids())
	_check(not armor_errors.is_empty(), "catalog validation should reject armored enemies without a counter tag")

	var pike_state = PackKeepState.new(3307)
	var pike_placed: Dictionary = pike_state.place_piece("pike_squad", Vector2i(1, 1), "ground")
	_check(bool(pike_placed.get("ok", false)), "Pike armor fixture should place")
	_check(bool(pike_state.start_wave("shielded_advance").get("ok", false)), "Pike armor fixture should start")
	pike_state.advance_wave(1.0)
	_check(int(pike_state.enemies[0].get("damage_taken", 0)) == 2, "Shield Guard armor should reduce Pike Squad's four damage to two")
	_check(pike_state.battle_report.has("Shield Guard armor absorbed 2 damage from non-piercing defenders."), "the causal report should explain Shield Guard armor reduction")

	_check(_shield_damage_with(["crossbow_patrol"]) == 3, "Crossbow Patrol should ignore Shield Guard armor")
	_check(_shield_damage_with(["crossbow_patrol", "watch_banner"]) == 4, "a nearby Watch Banner should add one non-stacking ranged response")

	var active = PackKeepState.new(3307)
	active.open_pack("crossbow_watch")
	active.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
	active.place_piece("watch_banner", Vector2i(4, 1), "upper")
	active.start_wave("shielded_advance")
	active.advance_wave(1.0)
	var restored = PackKeepState.new(1)
	var loaded: Dictionary = restored.load_serialized(active.serialize())
	_check(bool(loaded.get("ok", false)) and JSON.stringify(restored.serialize()) == JSON.stringify(active.serialize()), "save/load should preserve the active Crossbow Watch defense and Shield Guard state")

	for commander_id in ["castellan", "warden"]:
		for seed in [3307, 3308, 3309]:
			var first: Dictionary = _run_scenario(seed, commander_id)
			var second: Dictionary = _run_scenario(seed, commander_id)
			_check(first.serialized == second.serialized, "Red Banner Road replay should be deterministic for %s seed %d" % [commander_id, seed])
			_check(int(first.waves) == 3, "Red Banner Road should resolve all three authored waves")
			_check(["held", "partial_breach"].has(String(first.outcome)), "Crossbow Watch baseline should survive without collapsing")

	if failures.is_empty():
		print("P11 Crossbow Watch: PASS (6 deterministic three-wave Red Banner Road replays)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
