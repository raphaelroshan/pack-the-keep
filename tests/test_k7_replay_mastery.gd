extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")
const ResultsPresentationSnapshot = preload("res://src/ui/results_presentation_snapshot.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _build_precision_run(seed: int) -> RefCounted:
	var state: RefCounted = PackKeepState.new(seed)
	state.select_scenario("the_cut_standard")
	state.open_pack("crossbow_watch")
	state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
	state.place_piece("watch_banner", Vector2i(4, 1), "upper")
	return state

func _finish_run(state: RefCounted) -> void:
	var guard: int = 0
	while guard < 100:
		guard += 1
		if state.wave_active:
			state.advance_wave(1.0)
			continue
		if state.last_outcome == "collapse" or (state.wave_index >= state.authored_wave_count() and not state.has_next_wave()):
			break
		if state.repair_interval_active:
			var repaired: bool = false
			for instance_id_value in state.pieces.keys():
				var instance_id: String = String(instance_id_value)
				if float(state.pieces[instance_id].get("condition", 1.0)) < 1.0 and state.materials >= 6:
					state.repair_piece(instance_id)
					repaired = true
					break
			state.finish_repair_interval()
			continue
		state.start_wave(state.enemy_doctrine)
	_check(guard < 100, "K7 fixture should finish inside the bounded simulation guard")

func _initialize() -> void:
	var first: RefCounted = _build_precision_run(7712)
	var variation_before: String = JSON.stringify(first.scenario_variation_preview())
	var state_before: String = JSON.stringify(first.serialize())
	var setup_mastery: Dictionary = first.replay_mastery_summary()
	_check(String(setup_mastery.get("coverage_text", "")).contains("2/3"), "precision-only setup should cover both Cut the Chain phases but expose Gate Assault")
	_check(setup_mastery.get("uncovered_doctrines", []) == ["gate_assault"], "mastery summary should name the first uncovered doctrine")
	_check(JSON.stringify(first.serialize()) == state_before, "variation and mastery previews must not mutate authoritative state")

	var duplicate: RefCounted = _build_precision_run(7712)
	_check(JSON.stringify(duplicate.scenario_variation_preview()) == variation_before, "same seed should derive the same bounded variation summary")
	var alternate: RefCounted = _build_precision_run(7713)
	_check(JSON.stringify(alternate.scenario_variation_preview()) != variation_before, "neighboring seed should expose a different authored variation summary")

	_finish_run(first)
	var report: Dictionary = first.scenario_report()
	var mastery: Dictionary = report.get("mastery", {})
	_check(String(mastery.get("variation", {}).get("summary", "")).contains(String(first.scenario_variation_id).replace("_", " ").capitalize()), "terminal report should retain the selected variation")
	_check(int(mastery.get("phase_count", 0)) == 3 and int(mastery.get("covered_phases", 0)) == 2, "terminal report should compare chosen defense families with all three phases")
	_check(int(mastery.get("recovery_capacity", 0)) == 4 and int(mastery.get("recovery_actions_used", 0)) > 0, "terminal report should compare recovery commitment with the four-action opportunity")
	_check(mastery.get("recovery_branch", {}).is_empty(), "non-Twilight scenarios should not invent a route-choice mastery branch")
	_check(String(report.get("suggested_experiment", "")).contains("Gate Assault") and String(report.get("suggested_experiment", "")).contains("frontline"), "replay experiment should point at the first uncovered pressure and a viable family")

	var view: Dictionary = ResultsPresentationSnapshot.build(first, false, false, "")
	_check(String(view.get("mastery_summary", "")).contains("SEED PRESSURE") and String(view.get("mastery_summary", "")).contains("DOCTRINE FIT") and String(view.get("mastery_summary", "")).contains("RECOVERY COMMITMENT") and String(view.get("mastery_summary", "")).contains("PACK PLAN"), "Results snapshot should compose the replay-mastery comparison")
	var restored: RefCounted = PackKeepState.new(1)
	_check(bool(restored.load_serialized(first.serialize()).get("ok", false)), "terminal K7 state should load")
	_check(JSON.stringify(restored.replay_mastery_summary()) == JSON.stringify(first.replay_mastery_summary()), "save/load should rederive the exact same mastery summary")

	if failures.is_empty():
		print("K7 replay mastery: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
