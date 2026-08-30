extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _resolve_wave(ui: Control) -> void:
	if not ui.assault_ready_reason.is_empty():
		ui._on_playtest_primary_action()
	if not ui.battle_paused:
		ui._toggle_battle_pause()
	var guard: int = 0
	while ui.keep.wave_active and guard < 16:
		ui._on_advance_wave()
		guard += 1
	_check(guard < 16, "K5 fixture should resolve each phase inside the deterministic guard")

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	ui._on_start_wave()
	_resolve_wave(ui)
	await process_frame

	var recovery_before: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_recovery_presentation()
	var brief: Dictionary = ui.recovery_presentation_snapshot.get("brief", {})
	_check(not String(brief.get("priority", "")).is_empty(), "Recovery should name one first priority")
	_check(String(brief.get("sacrifice", "")).contains("only 1 action remains"), "first Recovery choice should name the remaining one-action opportunity cost")
	_check(String(ui.recovery_brief_panel.priority_label.text).contains("FIRST PRIORITY") and String(ui.recovery_brief_panel.priority_label.text).contains("SACRIFICE") and String(ui.recovery_brief_panel.priority_label.text).contains("TRADE-OFF"), "Recovery panel should separate recommendation, sacrifice, and rationale")
	_check(JSON.stringify(ui.keep.serialize()) == recovery_before, "Recovery distinction projection should not mutate authoritative state")

	while ui.keep.has_next_wave():
		ui._on_finish_interval()
		_resolve_wave(ui)
	await process_frame
	var results_before: String = JSON.stringify(ui.keep.serialize())
	var result_view: Dictionary = ui._terminal_debrief_view_model()
	_check(String(result_view.get("causal_summary", "")).contains("DECISIVE PATTERN") and String(result_view.get("causal_summary", "")).contains("REMAINING COST"), "terminal Results should summarize one success and one remaining cost")
	ui._refresh_terminal_debrief()
	_check(String(ui.terminal_debrief_panel.causal_label.text).begins_with(String(result_view.get("causal_summary", ""))), "terminal causal panel should lead with the run-specific summary")
	_check(ui.terminal_debrief_panel.visible and not ui.recovery_actions_panel.visible, "terminal Results should remain visually and interactively distinct from Recovery")
	_check(not String(result_view.get("replay_experiment", "")).is_empty() and String(ui.terminal_debrief_panel.replay_label.text).contains("TRY NEXT"), "terminal Results should retain one concrete replay experiment")
	_check(JSON.stringify(ui.keep.serialize()) == results_before, "Results distinction projection should not mutate authoritative state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("K5 Recovery and Results distinction: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
