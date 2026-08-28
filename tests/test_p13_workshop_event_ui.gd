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
	ui.keep.select_scenario("gatehouse_lock")
	ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	ui.keep.open_pack("field_engineers")
	ui.keep.place_piece("repair_station", Vector2i(4, 6), "ground")
	ui.keep.wave_index = 2
	ui.keep.enemy_doctrine = "distributed_sabotage"
	ui.keep.last_outcome = "partial_breach"
	ui.keep.repair_interval_active = true
	ui.keep.repair_actions_remaining = 2
	ui.keep.rooms.workshop.condition = 55
	ui.keep._update_room_state("workshop")
	ui.keep._refresh_active_event()
	ui._set_screen("results")
	await process_frame

	_check(ui.authored_event_panel.visible, "damaged Workshop recovery should show the authored event panel")
	_check(String(ui.authored_event_title.text).contains("The Workshop Can Wait"), "Workshop event title should be visible")
	_check(ui.authored_event_choice_buttons.size() == 2 and ui.authored_event_choice_buttons[0].visible and ui.authored_event_choice_buttons[1].visible, "Workshop event should expose both choices")
	_check(not ui.authored_event_choice_buttons[0].disabled and not ui.authored_event_choice_buttons[1].disabled, "both Workshop choices should be legal for the prepared fixture")
	var state_before_refresh: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_ui()
	_check(JSON.stringify(ui.keep.serialize()) == state_before_refresh, "rendering the Workshop event should not mutate authoritative state")

	ui.authored_event_choice_buttons[0].pressed.emit()
	await process_frame
	_check(ui.keep.room_condition("workshop") == 85 and not ui.authored_event_panel.visible, "the repair choice button should invoke the authoritative event command")
	_check(String(ui.scorecard_label.text).contains("Workshop Can Wait") and String(ui.scorecard_label.text).contains("Workshop can support"), "Results should show the Workshop event consequence")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P13 Workshop Can Wait UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
