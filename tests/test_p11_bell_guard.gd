extends SceneTree

const ContentCatalog = preload("res://src/core/content_catalog.gd")
const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _new_smoke_state(piece_ids: Array[String]) -> RefCounted:
	var state = PackKeepState.new(4407)
	state.select_commander("castellan")
	state.select_scenario("ash_at_the_bell")
	state.open_pack("bell_guard")
	state.place_piece("pike_squad", Vector2i(5, 3), "ground")
	for piece_id in piece_ids:
		var origin: Vector2i = Vector2i(1 + piece_ids.find(piece_id) * 3, 1)
		state.place_piece(piece_id, origin, "upper")
	return state

func _run_scenario(seed: int, commander_id: String) -> Dictionary:
	var state = PackKeepState.new(seed)
	state.select_commander(commander_id)
	state.select_scenario("ash_at_the_bell")
	state.open_pack("bell_guard")
	state.place_piece("pike_squad", Vector2i(5, 3), "ground")
	state.place_piece("bellkeepers", Vector2i(1, 1), "upper")
	state.place_piece("signal_beacon", Vector2i(4, 1), "upper")
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
	var catalog_state = PackKeepState.new(4407)
	var status: Dictionary = catalog_state.content_catalog_status()
	_check(bool(status.get("ok", false)), "P11 Bell Guard catalog should validate")
	_check(int(status.get("pack_count", 0)) == 9 and int(status.get("piece_count", 0)) == 17 and int(status.get("enemy_count", 0)) == 7 and int(status.get("doctrine_count", 0)) == 8 and int(status.get("scenario_count", 0)) == 8, "P11 catalog counts should include all teaching pairs and the challenge")
	var catalog = ContentCatalog.new()
	catalog.load_default(PackKeepState.ROOMS.keys())
	var malformed_disruption: Dictionary = catalog.enemy_definition("ash_slinger")
	malformed_disruption.disruption_profile.arrival_step_delta = -3
	malformed_disruption.disruption_profile.relay_modifier = ""
	var disruption_errors: Array[String] = catalog.validate_enemy_definition(malformed_disruption, "ash_slinger", PackKeepState.ROOMS.keys(), catalog.doctrine_ids())
	_check(disruption_errors.size() >= 2, "catalog validation should reject incomplete or excessive signal disruption")

	var unlinked = _new_smoke_state([])
	var obscured: Dictionary = unlinked.forecast()
	_check(bool(obscured.get("signal_disrupted", false)) and String(obscured.get("likely_target", "")) == "obscured by smoke", "Ash Slinger should obscure an unprotected forecast")
	var informed = PackKeepState.new(4407)
	informed.unlocked_modifier_ids.append("roadside_intelligence")
	informed.equip_modifier("roadside_intelligence")
	informed.select_scenario("ash_at_the_bell")
	var informed_but_obscured: Dictionary = informed.forecast()
	_check(bool(informed_but_obscured.get("composition_revealed", false)) and bool(informed_but_obscured.get("signal_disrupted", false)) and String(informed_but_obscured.get("uncertainty", "")).contains("smoke"), "Roadside Intelligence should reveal composition without bypassing smoke-obscured targeting")
	_check(bool(unlinked.start_wave("smoke_and_signal").get("ok", false)), "unlinked smoke fixture should start")
	_check(int(unlinked.inspect_enemy(0).get("arrival_step", 0)) == 2, "uncountered Ash Slinger should arrive one step early")
	unlinked.advance_wave(1.0)
	unlinked.advance_wave(1.0)
	_check(unlinked.room_condition("barracks") < 100.0, "uncountered smoke should create early Barracks contact")
	_check(unlinked.battle_report.has("Ash Slinger smoke broke the warning chain; contact advances from step 3 to step 2."), "causal report should explain early smoke contact")

	var lone_bell = _new_smoke_state(["bellkeepers"])
	_check(bool(lone_bell.forecast().get("signal_disrupted", false)), "Bellkeepers without a relay should not counter smoke")
	var lone_beacon = _new_smoke_state(["signal_beacon"])
	_check(bool(lone_beacon.forecast().get("signal_disrupted", false)), "a lone Signal Beacon should not counter smoke")
	var distant_link = _new_smoke_state(["bellkeepers", "signal_beacon"])
	distant_link.pieces["signal_beacon_2"].origin = Vector2i(10, 1)
	_check(bool(distant_link.forecast().get("signal_disrupted", false)), "an out-of-range signal pair should not counter smoke")
	var cross_floor_link = _new_smoke_state(["bellkeepers", "signal_beacon"])
	cross_floor_link.pieces["signal_beacon_2"].floor = "ground"
	_check(bool(cross_floor_link.forecast().get("signal_disrupted", false)), "a cross-floor signal pair should not counter smoke")
	var disabled_link = _new_smoke_state(["bellkeepers", "signal_beacon"])
	disabled_link.pieces["signal_beacon_2"].disabled = true
	_check(bool(disabled_link.forecast().get("signal_disrupted", false)), "a disabled relay should not counter smoke")

	var linked = _new_smoke_state(["bellkeepers", "signal_beacon"])
	var clear_forecast: Dictionary = linked.forecast()
	_check(not bool(clear_forecast.get("signal_disrupted", true)) and bool(clear_forecast.get("signal_network_active", false)), "a nearby same-floor Bell Guard link should preserve the forecast")
	linked.start_wave("smoke_and_signal")
	_check(int(linked.inspect_enemy(0).get("arrival_step", 0)) == 3 and not bool(linked.inspect_enemy(0).get("signal_disrupted", true)), "linked Bell Guard should preserve authored arrival timing")
	linked.advance_wave(1.0)
	var restored = PackKeepState.new(1)
	var loaded: Dictionary = restored.load_serialized(linked.serialize())
	_check(bool(loaded.get("ok", false)) and JSON.stringify(restored.serialize()) == JSON.stringify(linked.serialize()), "save/load should preserve the active Bell Guard and Ash Slinger timing state")

	for commander_id in ["castellan", "warden"]:
		for seed in [4407, 4408, 4409]:
			var first: Dictionary = _run_scenario(seed, commander_id)
			var second: Dictionary = _run_scenario(seed, commander_id)
			_check(first.serialized == second.serialized, "Ash at the Bell replay should be deterministic for %s seed %d" % [commander_id, seed])
			_check(int(first.waves) == 3, "Ash at the Bell should resolve all three authored waves")
			_check(["held", "partial_breach"].has(String(first.outcome)), "Bell Guard baseline should survive without collapsing")

	if failures.is_empty():
		print("P11 Bell Guard: PASS (6 deterministic three-wave Ash at the Bell replays)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
