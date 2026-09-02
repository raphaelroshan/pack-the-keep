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
	var state_before_badge: String = JSON.stringify(ui.keep.serialize())
	var clear_badge: Dictionary = ui.keep_canvas.spatial_rule_badge_snapshot()
	_check(bool(clear_badge.get("visible", false)) and bool(clear_badge.get("active", false)) and String(clear_badge.get("text", "")) == "CLEAR CAUSEWAY", "Ash Ford should compose its active spatial rule into one board badge")
	var clear_badge_rect: Rect2 = clear_badge.get("rect", Rect2())
	_check(clear_badge_rect.position.y < ui.keep_canvas.MAP_ORIGIN.y + ui.keep_canvas.CELL_Y and clear_badge_rect.end.x <= ui.keep_canvas.MAP_ORIGIN.x + ui.keep_canvas.MAP_SIZE.x, "Ash Ford's spatial badge should stay in the board's reserved upper band")
	_check(JSON.stringify(ui.keep.serialize()) == state_before_badge, "spatial rule badge projection should not mutate authoritative state")

	ui.keep.place_piece("pike_squad", Vector2i(3, 3), "ground")
	ui._refresh_ui()
	await process_frame
	_check(String(ui.layout_lens_label.text).contains("Spatial rule [INACTIVE]"), "layout lens should show when a footprint blocks the causeway")
	_check(String(ui.layout_lens_label.text).contains("room-damage reduction is inactive"), "layout warnings should explain the blocked-causeway consequence")
	var blocked_badge: Dictionary = ui.keep_canvas.spatial_rule_badge_snapshot()
	_check(not bool(blocked_badge.get("active", true)) and String(blocked_badge.get("text", "")) == "CAUSEWAY BLOCKED", "Ash Ford's board badge should expose the blocked trade-off without free-floating map text")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P15 Ash Ford UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
