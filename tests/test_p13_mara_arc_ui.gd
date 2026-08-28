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
	ui.keep.select_commander("warden")
	ui.keep.select_scenario("gatehouse_lock")
	ui.keep.wave_index = 2
	ui.keep.last_outcome = "partial_breach"
	ui.keep.repair_interval_active = true
	ui.keep.repair_actions_remaining = 2
	ui.keep.rooms.workshop.condition = 55
	ui.keep._update_room_state("workshop")
	ui.keep._refresh_active_event()
	ui.keep.choose_event_option("repair_workshop")
	ui.keep.wave_index = 3
	ui.keep.last_outcome = "held"
	ui.keep.repair_interval_active = true
	ui.keep._refresh_active_event()
	ui._set_screen("results")
	await process_frame
	_check(ui.authored_event_panel.visible and String(ui.authored_event_setup.text).contains("Warden"), "Mara's event panel should render the Warden setup variant")
	_check(String(ui.authored_event_choice_buttons[0].text).contains("response lane") and String(ui.authored_event_choice_buttons[1].text).contains("outside"), "Mara's event panel should render Warden-specific choice labels")
	var before: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_ui()
	_check(JSON.stringify(ui.keep.serialize()) == before, "rendering commander variants should not mutate authoritative state")
	ui.authored_event_choice_buttons[0].pressed.emit()
	await process_frame
	_check(bool(ui.keep.event_flags.get("mara_second_door_open", false)) and String(ui.campaign_ledger_label.text).contains("Mara Second Door Open: yes"), "the chosen Mara consequence should appear in the existing Ledger")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P13 Mara Venn arc UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
