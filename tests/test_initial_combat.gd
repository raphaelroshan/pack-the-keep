extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _prepare_area_pressure(state: PackKeepState) -> String:
	state.open_pack("firekeepers")
	var placement: Dictionary = state.place_piece("fire_team", Vector2i(1, 1), "upper")
	_check(bool(placement.get("ok", false)), "Fire Team placement failed for area-pressure test")
	var instance_id: String = String(placement.get("piece_instance", ""))
	var wave: Dictionary = state.start_wave("area_pressure")
	_check(bool(wave.get("ok", false)), "Area-pressure wave did not start")
	return instance_id

func _run() -> void:
	var state: PackKeepState = PackKeepState.new(811)
	var fire_id: String = _prepare_area_pressure(state)
	_check(int(state.pieces[fire_id].get("max_ammo", -1)) == 4, "Fire Team did not initialize with four rounds")
	_check(int(state.pieces[fire_id].get("ammo", -1)) == 4, "Fire Team did not start fully loaded")
	state.advance_wave(1.0)
	_check(int(state.pieces[fire_id].get("ammo", -1)) == 3, "ranged response did not spend exactly one round")
	_check(int(state.combat_metrics.get("ammo_spent", 0)) == 1, "ammo metric did not record the first ranged shot")
	for _step in range(3):
		state.advance_wave(1.0)
	_check(int(state.pieces[fire_id].get("ammo", -1)) == 0, "ranged defender did not stop firing at empty ammunition")
	_check(int(state.combat_metrics.get("ammo_spent", 0)) == 4, "ammo metric did not cap at the four-round magazine")
	while state.wave_active:
		state.advance_wave(1.0)
	_check(state.repair_interval_active, "area-pressure run did not enter deterministic recovery")
	state.finish_repair_interval()
	_check(int(state.pieces[fire_id].get("ammo", -1)) == 4, "recovery interval did not reload surviving ranged defender")

	var melee: PackKeepState = PackKeepState.new(812)
	var pike: Dictionary = melee.place_piece("pike_squad", Vector2i(1, 1), "ground")
	_check(bool(pike.get("ok", false)), "Pike Squad placement failed")
	var pike_id: String = String(pike.get("piece_instance", ""))
	_check(int(melee.pieces[pike_id].get("max_ammo", -1)) == 0, "melee Pike Squad unexpectedly has ammunition")
	var melee_wave: Dictionary = melee.start_wave("gate_assault")
	_check(bool(melee_wave.get("ok", false)), "gate assault did not start for melee test")
	melee.advance_wave(1.0)
	_check(int(melee.combat_metrics.get("ammo_spent", 0)) == 0, "melee response incorrectly spent ammunition")

	var courtyard_state: PackKeepState = PackKeepState.new(813)
	var courtyard_piece: Dictionary = courtyard_state.place_piece("pike_squad", Vector2i(3, 2), "ground")
	_check(String(courtyard_piece.get("placement_zone", "")) == "courtyard", "courtyard placement zone was not classified")
	courtyard_state.start_wave("gate_assault")
	courtyard_state.advance_wave(1.0)
	var keep_state: PackKeepState = PackKeepState.new(814)
	var keep_piece: Dictionary = keep_state.place_piece("pike_squad", Vector2i(2, 2), "ground")
	_check(String(keep_piece.get("placement_zone", "")) == "keep", "interior placement zone was not classified")
	keep_state.start_wave("gate_assault")
	keep_state.advance_wave(1.0)
	_check(int(courtyard_state.combat_metrics.get("damage_dealt", 0)) > int(keep_state.combat_metrics.get("damage_dealt", 0)), "courtyard Pike Squad did not receive its close-defense response bonus")

	var replay_a: PackKeepState = PackKeepState.new(901)
	var replay_b: PackKeepState = PackKeepState.new(901)
	_prepare_area_pressure(replay_a)
	_prepare_area_pressure(replay_b)
	while replay_a.wave_active:
		replay_a.advance_wave(1.0)
	while replay_b.wave_active:
		replay_b.advance_wave(1.0)
	_check(replay_a.serialize() == replay_b.serialize(), "same-seed auto-battle replay diverged")

func _initialize() -> void:
	_run()
	if failures.is_empty():
		print("PASS: Pack the Keep initial real-time auto-battle tests")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL: Pack the Keep initial real-time auto-battle tests (%d)" % failures.size())
		quit(1)
