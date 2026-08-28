extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []
var balance_runs: int = 0
var balance_outcomes: Dictionary = {}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	_test_runner_open_lane_response()
	_test_runner_blocked_lane_response()
	_test_supply_cache_recovery()
	_test_supply_cache_sapper_target()
	_test_rear_guard_fallback_bonus()
	_test_breakaway_barricade_sacrifice()
	_test_relief_road_replay()
	_test_relief_road_balance_matrix()
	if failures.is_empty():
		print("P7 mobile response: PASS (%d bounded Relief Road runs)" % balance_runs)
		print("P7 outcomes: %s" % balance_outcomes)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _test_runner_open_lane_response() -> void:
	var keep: PackKeepState = PackKeepState.new(3307)
	keep.open_pack("runner_network")
	var placed: Dictionary = keep.place_piece("runner_pair", Vector2i(4, 3), "ground")
	_check(bool(placed.get("ok", false)), "Runner Pair should place after opening Runner Network")
	keep.start_wave("feint_and_flank")
	keep.advance_wave(1.0)
	var climber: Dictionary = keep.enemies[1]
	_check(int(climber.get("hp", 0)) == 2, "Runner Pair should deal four response damage to a Climber with an open lane")

func _test_runner_blocked_lane_response() -> void:
	var keep: PackKeepState = PackKeepState.new(3307)
	keep.open_pack("runner_network")
	keep.open_pack("scouts")
	keep.place_piece("runner_pair", Vector2i(4, 3), "ground")
	keep.place_piece("supply_cache", Vector2i(3, 3), "ground")
	keep.place_piece("supply_cache", Vector2i(5, 3), "ground")
	keep.place_piece("signal_beacon", Vector2i(4, 2), "ground")
	keep.place_piece("signal_beacon", Vector2i(4, 4), "ground")
	keep.start_wave("feint_and_flank")
	keep.advance_wave(1.0)
	var climber: Dictionary = keep.enemies[1]
	_check(int(climber.get("hp", 0)) == 6, "Runner Pair should lose its response damage when every adjacent lane is occupied")

func _test_supply_cache_recovery() -> void:
	var keep: PackKeepState = PackKeepState.new(3307)
	keep.open_pack("runner_network")
	keep.open_pack("firekeepers")
	keep.place_piece("supply_cache", Vector2i(4, 3), "ground")
	keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	keep.place_piece("fire_team", Vector2i(6, 3), "ground")
	keep.start_wave("gate_assault")
	keep.advance_wave(6.0)
	_check(bool(keep.pieces["supply_cache_0"].get("supply_spent", false)), "Supply Cache should become spent at the first recovery interval")
	_check(keep.log.has("Supply Cache released its field reserve: +5 materials. The cache is now spent."), "Supply Cache should report its bounded recovery benefit")
	var restored: PackKeepState = PackKeepState.new(0)
	_check(bool(restored.load_serialized(keep.serialize()).get("ok", false)), "Supply Cache recovery state should load from a valid save")
	_check(bool(restored.pieces["supply_cache_0"].get("supply_spent", false)), "Supply Cache spent state should survive save/load")

func _test_supply_cache_sapper_target() -> void:
	var keep: PackKeepState = PackKeepState.new(3307)
	keep.open_pack("runner_network")
	keep.place_piece("supply_cache", Vector2i(4, 3), "ground")
	keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	keep.start_wave("distributed_sabotage")
	keep.advance_wave(3.0)
	_check(String(keep.enemies[1].get("target", "")) == "supply_cache_0", "Sapper should prefer an exposed Supply Cache over an equally healthy room")
	_check(int(keep.pieces["supply_cache_0"].get("health", 0)) == 7, "Sapper contact should visibly subtract its damage from Supply Cache health")

func _test_rear_guard_fallback_bonus() -> void:
	var baseline: PackKeepState = PackKeepState.new(3307)
	baseline.open_pack("fallback_convoy")
	baseline.place_piece("rear_guard", Vector2i(4, 3), "ground")
	baseline.start_wave("gate_assault")
	baseline.advance_wave(1.0)
	var baseline_hp: int = int(baseline.enemies[0].hp)
	var fallback: PackKeepState = PackKeepState.new(3307)
	fallback.open_pack("fallback_convoy")
	fallback.place_piece("rear_guard", Vector2i(4, 3), "ground")
	fallback.rooms.gate.condition = 70
	fallback.rooms.gate.state = "strained"
	fallback.start_wave("gate_assault")
	fallback.advance_wave(1.0)
	_check(int(fallback.enemies[0].hp) == baseline_hp - 2, "Rear Guard should gain two response damage after a room is strained")

func _test_breakaway_barricade_sacrifice() -> void:
	var keep: PackKeepState = PackKeepState.new(3307)
	keep.open_pack("fallback_convoy")
	keep.place_piece("breakaway_barricade", Vector2i(3, 3), "ground")
	keep.start_wave("area_pressure")
	keep.advance_wave(3.0)
	_check(bool(keep.pieces["breakaway_barricade_0"].get("disabled", false)), "Breakaway Barricade should disable itself after absorbing contact")
	_check(keep.room_condition("inner_yard") == 85, "Breakaway Barricade should reduce the primary area hit from three damage to one")

func _test_relief_road_replay() -> void:
	var first: PackKeepState = PackKeepState.new(3311)
	var second: PackKeepState = PackKeepState.new(3311)
	_check(bool(first.select_scenario("relief_road").get("ok", false)), "Relief Road should be selectable")
	second.select_scenario("relief_road")
	_check(first.scenario_preview() == second.scenario_preview(), "Relief Road variation should be deterministic for the same seed")
	_check(first.authored_wave_count() == 3 and String(first.scenario_definition("relief_road").doctrines[2]) == "rolling_breach", "Relief Road should teach three waves ending in Rolling Breach")

func _test_relief_road_balance_matrix() -> void:
	for commander_id in ["castellan", "warden"]:
		for layout_name in ["open_response", "fallback_line", "layered_response"]:
			for run_seed in [3307, 3308]:
				var first: PackKeepState = _run_relief_road(String(commander_id), String(layout_name), int(run_seed))
				var second: PackKeepState = _run_relief_road(String(commander_id), String(layout_name), int(run_seed))
				var label: String = "%s/%s/%d" % [commander_id, layout_name, run_seed]
				_check(first.scenario_scorecard() == second.scenario_scorecard(), "%s should reproduce the same scorecard" % label)
				_check(first.wave_history == second.wave_history, "%s should reproduce the same wave history" % label)
				_check(not first.last_outcome.is_empty() and first.wave_history.size() <= 3, "%s should resolve within three bounded waves" % label)
				if first.last_outcome != "collapse":
					_check(first.wave_history.size() == 3, "%s should complete all three waves unless the keep collapses" % label)
				balance_runs += 1
				balance_outcomes[first.last_outcome] = int(balance_outcomes.get(first.last_outcome, 0)) + 1

func _run_relief_road(commander_id: String, layout_name: String, run_seed: int) -> PackKeepState:
	var keep: PackKeepState = PackKeepState.new(run_seed)
	keep.select_commander(commander_id)
	keep.select_scenario("relief_road")
	keep.choose_event_option("keep_command_ready")
	keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	if layout_name == "open_response" or layout_name == "layered_response":
		keep.open_pack("runner_network")
		keep.place_piece("runner_pair", Vector2i(4, 3), "ground")
		keep.place_piece("supply_cache", Vector2i(6, 3), "ground")
	if layout_name == "fallback_line" or layout_name == "layered_response":
		keep.open_pack("fallback_convoy")
		keep.place_piece("rear_guard", Vector2i(4, 4), "ground")
		keep.place_piece("breakaway_barricade", Vector2i(3, 3), "ground")
	keep.start_wave("feint_and_flank")
	while keep.wave_active or keep.repair_interval_active:
		if keep.wave_active:
			keep.use_commander_ability()
			while keep.wave_active:
				keep.advance_wave(1.0)
		elif keep.repair_interval_active:
			if keep.active_event_id == "relief_road_recovery":
				keep.choose_event_option("release_field_stores")
			elif keep.active_event_id == "relief_road_report":
				keep.choose_event_option("record_the_cost")
			var continuation: Dictionary = keep.finish_repair_interval()
			if not bool(continuation.get("next_wave_started", false)):
				break
	return keep
