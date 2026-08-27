extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []
var completed_runs: int = 0
var outcome_counts: Dictionary = {}

func _initialize() -> void:
	var catalog_keep: PackKeepState = PackKeepState.new(3307)
	for commander_id in ["castellan", "warden"]:
		for scenario_id in catalog_keep.scenario_ids():
			for layout_name in ["compact", "recovery", "open_yard"]:
				for run_seed in [3307, 3308]:
					_run_case(String(commander_id), String(scenario_id), String(layout_name), int(run_seed))
	if failures.is_empty():
		print("PASS: Pack the Keep P1 balance harness (%d bounded runs)" % completed_runs)
		print("P1 outcomes: %s" % outcome_counts)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _run_case(commander_id: String, scenario_id: String, layout_name: String, run_seed: int) -> void:
	var keep: PackKeepState = PackKeepState.new(run_seed)
	if not bool(keep.select_commander(commander_id).get("ok", false)):
		failures.append("%s/%s/%s/%d: commander selection failed" % [commander_id, scenario_id, layout_name, run_seed])
		return
	if not bool(keep.select_scenario(scenario_id).get("ok", false)):
		failures.append("%s/%s/%s/%d: scenario selection failed" % [commander_id, scenario_id, layout_name, run_seed])
		return
	var placed: Dictionary = keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	if not bool(placed.get("ok", false)):
		failures.append("%s/%s/%s/%d: starter placement failed" % [commander_id, scenario_id, layout_name, run_seed])
		return
	if layout_name == "compact":
		keep.place_piece("narrow_gate", Vector2i(2, 3), "ground")
	elif layout_name == "recovery":
		keep.open_pack("field_engineers")
		keep.place_piece("repair_station", Vector2i(4, 3), "ground")
		keep.place_piece("brace", Vector2i(6, 2), "ground")
	elif layout_name == "open_yard":
		keep.open_pack("firekeepers")
		keep.place_piece("fire_team", Vector2i(4, 3), "ground")
	for wave_number in range(3):
		if keep.repair_interval_active:
			var continued: Dictionary = keep.finish_repair_interval()
			if not bool(continued.get("next_wave_started", false)) and wave_number < 2:
				failures.append("%s/%s/%s/%d: recovery did not start wave %d automatically" % [commander_id, scenario_id, layout_name, run_seed, wave_number + 1])
				return
		var started: Dictionary = {"ok": keep.wave_active}
		if wave_number == 0 and not keep.wave_active:
			started = keep.start_wave("gate_assault")
		if not bool(started.get("ok", false)):
			failures.append("%s/%s/%s/%d: wave %d failed to start" % [commander_id, scenario_id, layout_name, run_seed, wave_number + 1])
			return
		keep.use_commander_ability()
		for _step in range(6):
			if keep.wave_active:
				keep.advance_wave(1.0)
		if keep.last_outcome.is_empty():
			failures.append("%s/%s/%s/%d: wave %d had no bounded outcome" % [commander_id, scenario_id, layout_name, run_seed, wave_number + 1])
			return
		if keep.last_outcome == "collapse":
			break
	var scorecard: Dictionary = keep.scenario_scorecard()
	if int(scorecard.get("completed_waves", 0)) != keep.wave_history.size() or keep.wave_history.size() > 3:
		failures.append("%s/%s/%s/%d: scorecard history is inconsistent" % [commander_id, scenario_id, layout_name, run_seed])
	if keep.last_outcome != "collapse" and int(scorecard.get("completed_waves", 0)) != 3:
		failures.append("%s/%s/%s/%d: non-collapse run did not complete all three waves" % [commander_id, scenario_id, layout_name, run_seed])
	completed_runs += 1
	outcome_counts[keep.last_outcome] = int(outcome_counts.get(keep.last_outcome, 0)) + 1
