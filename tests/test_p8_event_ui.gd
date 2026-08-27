extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _resolve_wave(ui: Control) -> void:
	var safety: int = 0
	while ui.keep.wave_active and safety < 12:
		ui._on_advance_wave()
		await process_frame
		safety += 1

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame

	ui._set_screen("preparation")
	ui._select_option_metadata(ui.scenario_option, "relief_road")
	ui._on_select_scenario()
	await process_frame
	_check(ui.authored_event_panel.visible, "Relief Road preparation did not expose its authored forecast event")
	_check(String(ui.authored_event_title.text).contains("The Bell Has a Pattern"), "forecast event title was not visible")
	_check(ui.authored_event_choice_buttons[0].visible and not ui.authored_event_choice_buttons[0].disabled, "forecast event did not expose its first legal choice")
	var command_before: int = ui.keep.command_points
	ui.authored_event_choice_buttons[0].pressed.emit()
	await process_frame
	_check(ui.keep.command_points == command_before - 1 and not ui.authored_event_panel.visible, "forecast choice button did not invoke the authoritative event command")

	ui.keep.open_pack("runner_network")
	ui.keep.open_pack("fallback_convoy")
	ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	ui.keep.place_piece("runner_pair", Vector2i(4, 3), "ground")
	ui.keep.place_piece("supply_cache", Vector2i(6, 3), "ground")
	ui.keep.place_piece("rear_guard", Vector2i(4, 4), "ground")
	ui.keep.place_piece("breakaway_barricade", Vector2i(3, 3), "ground")
	ui.keep.start_wave("feint_and_flank")
	ui._set_screen("battle")
	await _resolve_wave(ui)
	_check(ui.screen == "results" and ui.authored_event_panel.visible, "wave one Results did not expose the recovery event")
	_check(String(ui.authored_event_title.text).contains("The Workshop Can Wait"), "recovery event title was not visible")
	_check(ui.finish_interval_button.disabled and ui.recovery_room_button.disabled, "active recovery event did not block competing recovery actions and continuation")
	var materials_before: int = ui.keep.materials
	var actions_before: int = ui.keep.repair_actions_remaining
	ui.authored_event_choice_buttons[0].pressed.emit()
	await process_frame
	_check(ui.keep.materials == materials_before + 5 and ui.keep.repair_actions_remaining == actions_before - 1, "recovery event UI did not trade one action for five materials")
	ui._on_finish_interval()
	await process_frame
	await _resolve_wave(ui)
	ui._on_finish_interval()
	await process_frame
	await _resolve_wave(ui)
	_check(ui.screen == "results" and ui.authored_event_panel.visible, "terminal Results did not expose the consequence event")
	_check(String(ui.scorecard_label.text).contains("RUN SO FAR"), "scenario report should remain in progress until the conclusion event resolves")
	ui.authored_event_choice_buttons[0].pressed.emit()
	await process_frame
	_check(not ui.authored_event_panel.visible, "conclusion choice did not close the active event")
	_check(String(ui.scorecard_label.text).contains("SCENARIO REPORT") and String(ui.scorecard_label.text).contains("EVENT CONSEQUENCES"), "final Results did not include the resolved event chain")
	_check(String(ui.scorecard_label.text).contains("Relief Road Warning") and String(ui.scorecard_label.text).contains("Relief Road Report"), "final Results did not name the forecast and conclusion consequences")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P8 authored event UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		printerr("P8 authored event UI: FAIL (%d)" % failures.size())
		quit(1)
