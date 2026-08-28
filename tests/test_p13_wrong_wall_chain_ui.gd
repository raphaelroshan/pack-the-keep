extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui.keep.select_scenario("wrong_wall")
	ui._set_screen("preparation")
	await process_frame
	_check(ui.authored_event_panel.visible and String(ui.authored_event_title.text).contains("Bell Has a Pattern"), "Wrong Wall forecast should use the generic event panel")
	ui.authored_event_choice_buttons[1].pressed.emit()
	await process_frame
	ui.keep.wave_index = 1
	ui.keep.last_outcome = "partial_breach"
	ui.keep.repair_interval_active = true
	ui.keep.repair_actions_remaining = 2
	ui.keep.materials = 7
	ui.keep.rooms.workshop.condition = 55
	ui.keep._update_room_state("workshop")
	ui.keep._refresh_active_event()
	ui._set_screen("results")
	await process_frame
	_check(String(ui.authored_event_title.text).contains("Gate Is Not the Keep"), "Wrong Wall recovery should use the generic Results event panel")
	_check(ui.authored_event_choice_buttons[0].disabled and not ui.authored_event_choice_buttons[1].disabled, "scarcity should visibly block repair while leaving defer legal")
	ui.authored_event_choice_buttons[1].pressed.emit()
	await process_frame
	ui.keep.repair_interval_active = false
	ui.keep.repair_actions_remaining = 0
	ui.keep.last_outcome = "collapse"
	ui.keep._refresh_active_event()
	ui._refresh_ui()
	await process_frame
	_check(String(ui.authored_event_title.text).contains("The Wrong Wall"), "collapse should expose the terminal report in the same panel")
	ui.authored_event_choice_buttons[0].pressed.emit()
	await process_frame
	_check(not ui.authored_event_panel.visible and String(ui.scorecard_label.text).contains("EVENT CONSEQUENCES") and String(ui.scorecard_label.text).contains("Wrong Wall Report"), "terminal Results should show the resolved three-beat consequence history")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P13 Wrong Wall chain UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
