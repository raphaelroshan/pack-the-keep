extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _room_option_names(ui: Control) -> Array[String]:
	var names: Array[String] = []
	for index in range(ui.room_option.item_count):
		names.append(ui.room_option.get_item_text(index))
	return names

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._set_screen("preparation")
	ui._select_option_metadata(ui.scenario_option, "ash_ford_crossing")
	ui._on_select_scenario()
	await process_frame

	_check(String(ui.scenario_preview_label.text).contains("Ash Ford Redoubt / Ash Ford Crossing"), "scenario preview should name the active keep and scenario")
	_check(String(ui.scenario_preview_label.text).contains("Runner Network + Field Engineers"), "scenario preview should expose the intended pack doctrine")
	var room_names: Array[String] = _room_option_names(ui)
	_check(room_names.has("West Bridgehead") and room_names.has("Open Causeway") and not room_names.has("Gate"), "room controls should switch to Ash Ford labels")
	_check(String(ui.status_label.text).contains("Ash Ford Redoubt"), "status header should expose the active defensive identity")
	_check(String(ui.layout_lens_label.text).contains("Spatial rule [ACTIVE]") and String(ui.layout_lens_label.text).contains("causeway"), "layout lens should teach the clear-causeway rule")

	ui.keep.place_piece("pike_squad", Vector2i(3, 3), "ground")
	ui._refresh_ui()
	await process_frame
	_check(String(ui.layout_lens_label.text).contains("Spatial rule [INACTIVE]"), "layout lens should show when a footprint blocks the causeway")
	_check(String(ui.layout_lens_label.text).contains("room-damage reduction is inactive"), "layout warnings should explain the blocked-causeway consequence")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P15 Ash Ford UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
