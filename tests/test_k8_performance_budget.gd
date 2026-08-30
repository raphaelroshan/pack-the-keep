extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _load_budget() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://content/k8_private_alpha_gate.json"))
	return parsed.get("performance_budget", {}) if parsed is Dictionary else {}

func _finish_run(state: RefCounted) -> bool:
	var guard: int = 0
	while guard < 100:
		guard += 1
		if state.wave_active:
			state.advance_wave(1.0)
			continue
		if state.last_outcome == "collapse" or (state.wave_index >= state.authored_wave_count() and not state.has_next_wave()):
			return true
		if state.repair_interval_active:
			state.finish_repair_interval()
			continue
		state.start_wave(state.enemy_doctrine)
	return false

func _initialize() -> void:
	var budget: Dictionary = _load_budget()
	var simulation_runs: int = int(budget.get("simulation_runs", 0))
	var simulation_budget_ms: int = int(budget.get("simulation_budget_ms", 0))
	var simulation_started: int = Time.get_ticks_msec()
	for index in range(simulation_runs):
		var state: RefCounted = PackKeepState.new(9100 + index)
		state.select_scenario("the_cut_standard")
		state.open_pack("crossbow_watch")
		state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
		state.place_piece("watch_banner", Vector2i(4, 1), "upper")
		_check(_finish_run(state), "performance workload run %d should reach a terminal state" % index)
	var simulation_elapsed: int = Time.get_ticks_msec() - simulation_started
	_check(simulation_runs > 0 and simulation_budget_ms > 0, "simulation performance budget should be configured")
	_check(simulation_elapsed <= simulation_budget_ms, "simulation workload exceeded %d ms budget: %d ms" % [simulation_budget_ms, simulation_elapsed])

	root.size = Vector2i(2560, 1440)
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._on_start_custom_setup()
	ui._set_ui_scale(3)
	var authoritative_before: String = JSON.stringify(ui.keep.serialize())
	var ui_refreshes: int = int(budget.get("ui_refreshes", 0))
	var ui_budget_ms: int = int(budget.get("ui_budget_ms", 0))
	var ui_started: int = Time.get_ticks_msec()
	for index in range(ui_refreshes):
		ui._refresh_ui()
		if index % 20 == 0:
			await process_frame
	var ui_elapsed: int = Time.get_ticks_msec() - ui_started
	_check(ui_refreshes > 0 and ui_budget_ms > 0, "UI performance budget should be configured")
	_check(ui_elapsed <= ui_budget_ms, "2560x1440 large-text UI refresh exceeded %d ms budget: %d ms" % [ui_budget_ms, ui_elapsed])
	_check(JSON.stringify(ui.keep.serialize()) == authoritative_before, "performance refresh workload must not mutate authoritative state")
	ui.queue_free()
	await process_frame

	if failures.is_empty():
		print("K8 performance budget: PASS (%d runs in %d ms; %d UI refreshes in %d ms)" % [simulation_runs, simulation_elapsed, ui_refreshes, ui_elapsed])
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
