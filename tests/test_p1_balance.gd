extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []
var completed_runs: int = 0
var outcome_counts: Dictionary = {}
var layout_outcomes: Dictionary = {}

func _initialize() -> void:
	for commander_id in ["castellan", "warden"]:
		for scenario_id in ["gatehouse_lock", "wrong_wall", "open_yard_net"]:
			for layout_name in ["compact", "recovery", "open_yard"]:
				for run_seed in [3307, 3308]:
					_run_case(String(commander_id), String(scenario_id), String(layout_name), int(run_seed))
	for layout_name in ["compact", "recovery", "open_yard"]:
		var outcomes: Dictionary = layout_outcomes.get(layout_name, {})
		if int(outcomes.get("collapse", 0)) != 0:
			failures.append("%s opening should remain viable across the Greywatch seed matrix" % layout_name)
		if int(outcomes.get("held", 0)) == 0 or int(outcomes.get("partial_breach", 0)) == 0:
			failures.append("%s opening should expose both strength and recovery cost instead of dominating every seed" % layout_name)
	if failures.is_empty():
		print("PASS: Pack the Keep P1 balance harness (%d bounded runs)" % completed_runs)
		print("P1 outcomes: %s" % outcome_counts)
		print("P1 opening outcomes: %s" % layout_outcomes)
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
	if not _resolve_active_event(keep, "%s/%s/%s/%d" % [commander_id, scenario_id, layout_name, run_seed]):
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
		if not _resolve_active_event(keep, "%s/%s/%s/%d" % [commander_id, scenario_id, layout_name, run_seed]):
			return
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
			_resolve_active_event(keep, "%s/%s/%s/%d" % [commander_id, scenario_id, layout_name, run_seed])
			break
	_resolve_active_event(keep, "%s/%s/%s/%d" % [commander_id, scenario_id, layout_name, run_seed])
	var scorecard: Dictionary = keep.scenario_scorecard()
	if int(scorecard.get("completed_waves", 0)) != keep.wave_history.size() or keep.wave_history.size() > 3:
		failures.append("%s/%s/%s/%d: scorecard history is inconsistent" % [commander_id, scenario_id, layout_name, run_seed])
	if keep.last_outcome != "collapse" and int(scorecard.get("completed_waves", 0)) != 3:
		failures.append("%s/%s/%s/%d: non-collapse run did not complete all three waves" % [commander_id, scenario_id, layout_name, run_seed])
	completed_runs += 1
	outcome_counts[keep.last_outcome] = int(outcome_counts.get(keep.last_outcome, 0)) + 1
	if not layout_outcomes.has(layout_name):
		layout_outcomes[layout_name] = {}
	var plan_outcomes: Dictionary = layout_outcomes[layout_name]
	plan_outcomes[keep.last_outcome] = int(plan_outcomes.get(keep.last_outcome, 0)) + 1

func _resolve_active_event(keep: PackKeepState, label: String) -> bool:
	while not keep.active_event_id.is_empty():
		var choice_id: String = ""
		match keep.active_event_id:
			"the_bell_has_a_pattern":
				choice_id = "hold_gate_command"
			"the_gate_is_not_the_keep":
				choice_id = "defer_workshop"
			"wrong_wall_report":
				choice_id = "record_wrong_wall"
			"old_drain_opens":
				choice_id = "seal_old_drain"
			_:
				failures.append("%s: unhandled event %s" % [label, keep.active_event_id])
				return false
		var result: Dictionary = keep.choose_event_option(choice_id)
		if not bool(result.get("ok", false)):
			failures.append("%s: event %s failed" % [label, keep.active_event_id])
			return false
	return true
