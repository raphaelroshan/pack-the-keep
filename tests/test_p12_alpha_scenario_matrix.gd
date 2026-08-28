extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

const SCENARIOS: Array[String] = [
	"gatehouse_lock",
	"wrong_wall",
	"open_yard_net",
	"relief_road",
	"red_banner_road",
	"ash_at_the_bell",
	"the_splintered_gate",
	"three_bells_at_dusk",
]
const COMMANDERS: Array[String] = ["castellan", "warden"]
const SEEDS: Array[int] = [3307, 3308, 3309]

var failures: Array[String] = []
var outcome_counts: Dictionary = {}

func _check_command(result: Dictionary, label: String) -> bool:
	if bool(result.get("ok", false)):
		return true
	failures.append("%s failed: %s" % [label, String(result.get("reason", result.get("message", "unknown")))])
	return false

func _setup_baseline(state: RefCounted, scenario_id: String) -> bool:
	if not _check_command(state.place_piece("pike_squad", Vector2i(0, 3), "ground"), "%s starter placement" % scenario_id):
		return false
	match scenario_id:
		"gatehouse_lock", "wrong_wall", "open_yard_net":
			if not _check_command(state.open_pack("field_engineers"), "%s Field Engineers" % scenario_id):
				return false
			if not _check_command(state.place_piece("repair_station", Vector2i(4, 3), "ground"), "%s Repair Station" % scenario_id):
				return false
			return _check_command(state.place_piece("brace", Vector2i(6, 2), "ground"), "%s Brace" % scenario_id)
		"relief_road":
			if not _check_command(state.choose_event_option("keep_command_ready"), "Relief Road warning"):
				return false
			if not _check_command(state.open_pack("runner_network"), "Relief Road Runner Network"):
				return false
			if not _check_command(state.open_pack("fallback_convoy"), "Relief Road Fallback Convoy"):
				return false
			if not _check_command(state.place_piece("runner_pair", Vector2i(4, 3), "ground"), "Relief Road Runner Pair"):
				return false
			if not _check_command(state.place_piece("supply_cache", Vector2i(6, 3), "ground"), "Relief Road Supply Cache"):
				return false
			if not _check_command(state.place_piece("rear_guard", Vector2i(4, 4), "ground"), "Relief Road Rear Guard"):
				return false
			return _check_command(state.place_piece("breakaway_barricade", Vector2i(3, 3), "ground"), "Relief Road Breakaway Barricade")
		"red_banner_road":
			if not _check_command(state.open_pack("crossbow_watch"), "Red Banner Road Crossbow Watch"):
				return false
			if not _check_command(state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper"), "Red Banner Road Crossbow Patrol"):
				return false
			return _check_command(state.place_piece("watch_banner", Vector2i(4, 1), "upper"), "Red Banner Road Watch Banner")
		"ash_at_the_bell":
			if not _check_command(state.open_pack("bell_guard"), "Ash at the Bell Bell Guard"):
				return false
			if not _check_command(state.place_piece("bellkeepers", Vector2i(1, 1), "upper"), "Ash at the Bell Bellkeepers"):
				return false
			return _check_command(state.place_piece("signal_beacon", Vector2i(4, 1), "upper"), "Ash at the Bell Signal Beacon")
		"the_splintered_gate":
			if not _check_command(state.open_pack("shieldwall"), "The Splintered Gate Shieldwall"):
				return false
			if not _check_command(state.place_piece("shield_wardens", Vector2i(3, 3), "ground"), "The Splintered Gate Shield Wardens"):
				return false
			return _check_command(state.place_piece("emergency_shutters", Vector2i(6, 2), "ground"), "The Splintered Gate Emergency Shutters")
		"three_bells_at_dusk":
			if not _check_command(state.open_pack("bell_guard"), "Three Bells Bell Guard"):
				return false
			if not _check_command(state.open_pack("crossbow_watch"), "Three Bells Crossbow Watch"):
				return false
			if not _check_command(state.place_piece("bellkeepers", Vector2i(1, 5), "upper"), "Three Bells Bellkeepers"):
				return false
			if not _check_command(state.place_piece("signal_beacon", Vector2i(4, 5), "upper"), "Three Bells Signal Beacon"):
				return false
			if not _check_command(state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper"), "Three Bells Crossbow Patrol"):
				return false
			return _check_command(state.place_piece("watch_banner", Vector2i(4, 1), "upper"), "Three Bells Watch Banner")
	failures.append("unknown scenario fixture: %s" % scenario_id)
	return false

func _resolve_event(state: RefCounted, label: String) -> bool:
	match state.active_event_id:
		"relief_road_warning":
			return _check_command(state.choose_event_option("keep_command_ready"), "%s warning event" % label)
		"relief_road_recovery":
			return _check_command(state.choose_event_option("release_field_stores"), "%s recovery event" % label)
		"relief_road_report":
			return _check_command(state.choose_event_option("record_the_cost"), "%s report event" % label)
	failures.append("%s reached unhandled event %s" % [label, state.active_event_id])
	return false

func _run_case(seed: int, commander_id: String, scenario_id: String) -> Dictionary:
	var label: String = "%s/%s/%d" % [scenario_id, commander_id, seed]
	var state: RefCounted = PackKeepState.new(seed)
	if not _check_command(state.select_commander(commander_id), "%s commander selection" % label):
		return {}
	if not _check_command(state.select_scenario(scenario_id), "%s scenario selection" % label):
		return {}
	if not _setup_baseline(state, scenario_id):
		return {}
	var guard: int = 0
	while guard < 100:
		guard += 1
		if not state.active_event_id.is_empty():
			if not _resolve_event(state, label):
				break
			continue
		if state.wave_active:
			if state.battle_step == 0:
				_check_command(state.use_commander_ability(), "%s wave %d commander ability" % [label, state.wave_index])
			state.advance_wave(1.0)
			continue
		if state.last_outcome == "collapse":
			break
		if state.repair_interval_active:
			if not _check_command(state.finish_repair_interval(), "%s recovery closure" % label):
				break
			continue
		if state.wave_index >= state.authored_wave_count() and not state.has_next_wave():
			break
		if not _check_command(state.start_wave(state.enemy_doctrine), "%s wave start" % label):
			break
	var scorecard: Dictionary = state.scenario_scorecard()
	return {
		"serialized": JSON.stringify(state.serialize()),
		"waves": state.wave_history.size(),
		"outcome": state.last_outcome,
		"repair_open": state.repair_interval_active,
		"event_open": not state.active_event_id.is_empty(),
		"replay_key": String(scorecard.get("replay_key", "")),
		"guard": guard,
	}

func _initialize() -> void:
	var completed_cases: int = 0
	for scenario_id in SCENARIOS:
		for commander_id in COMMANDERS:
			for seed in SEEDS:
				var label: String = "%s/%s/%d" % [scenario_id, commander_id, seed]
				var first: Dictionary = _run_case(seed, commander_id, scenario_id)
				var second: Dictionary = _run_case(seed, commander_id, scenario_id)
				if first.is_empty() or second.is_empty():
					continue
				if first.serialized != second.serialized:
					failures.append("%s replay should be deterministic" % label)
				if int(first.waves) != 3:
					failures.append("%s should resolve all three authored waves" % label)
				if not ["held", "partial_breach"].has(String(first.outcome)):
					failures.append("%s should retain a viable non-collapse outcome" % label)
				if bool(first.repair_open) or bool(first.event_open):
					failures.append("%s should close final recovery and event state" % label)
				if String(first.replay_key) != label:
					failures.append("%s should retain its canonical replay key" % label)
				if int(first.guard) >= 100:
					failures.append("%s should finish inside the bounded simulation guard" % label)
				outcome_counts[first.outcome] = int(outcome_counts.get(first.outcome, 0)) + 1
				completed_cases += 1
	if failures.is_empty():
		print("P12 alpha scenario matrix: PASS (%d deterministic viable cases; %d simulation executions)" % [completed_cases, completed_cases * 2])
		print("P12 alpha scenario outcomes: %s" % outcome_counts)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
