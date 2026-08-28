extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _selected_seed() -> int:
	for run_seed in [3307, 3308, 3309]:
		var state: RefCounted = PackKeepState.new(run_seed)
		state.select_scenario("open_yard_net")
		state.wave_index = 2
		state.last_outcome = "held"
		state.repair_interval_active = true
		state._refresh_active_event()
		if state.active_event_id == "old_drain_opens":
			return run_seed
	return 3307

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui.keep.reset_run(_selected_seed())
	ui.keep.select_scenario("open_yard_net")
	ui.keep.wave_index = 2
	ui.keep.last_outcome = "held"
	ui.keep.repair_interval_active = true
	ui.keep.repair_actions_remaining = 2
	ui.keep._refresh_active_event()
	ui._set_screen("results")
	await process_frame
	_check(ui.authored_event_panel.visible and String(ui.authored_event_title.text).contains("Old Drain Opens"), "selected rare occurrence should use the generic event panel")
	_check(not ui.authored_event_choice_buttons[0].disabled and not ui.authored_event_choice_buttons[1].disabled, "both Old Drain choices should remain legal")
	ui.authored_event_choice_buttons[1].pressed.emit()
	await process_frame
	_check(String(ui.campaign_ledger_label.text).contains("Old Drain Escape Open: yes") and String(ui.scorecard_label.text).contains("every existing defensive counter stays available"), "rare occurrence consequence should be visible in Ledger and Results")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P13 Old Drain rare occurrence UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
