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
	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	await process_frame
	await process_frame

	_check(String(ui.preparation_pack_stage_label.text).begins_with("1"), "Preparation should lead with the pack decision")
	_check(String(ui.preparation_placement_stage_label.text).begins_with("2"), "Preparation should follow with placement and inspection")
	_check(String(ui.playtest_button.text).begins_with("3"), "Preparation should finish with the commit action")
	_check(ui.piece_option.get_parent().get_parent() == ui.preparation_controls[0], "piece selection should live with the Preparation placement tools")
	_check(not ui.preparation_advanced_panel.visible and String(ui.preparation_advanced_button.text).contains("Show"), "low-frequency preparation controls should begin collapsed")
	var before_toggle: String = JSON.stringify(ui.keep.serialize())
	ui.preparation_advanced_button.pressed.emit()
	_check(ui.preparation_advanced_panel.visible and ui.pack_option.is_visible_in_tree() and ui.doctrine_option.is_visible_in_tree(), "advanced preparation should expose catalogue and doctrine selectors")
	_check(String(ui.layout_lens_label.text).contains("LAYOUT SUMMARY"), "advanced preparation should retain the full layout analysis")
	ui.preparation_advanced_button.pressed.emit()
	_check(not ui.preparation_advanced_panel.visible and JSON.stringify(ui.keep.serialize()) == before_toggle, "collapsing diagnostics should not mutate authoritative state")
	_check(ui.inspector_label.is_visible_in_tree(), "map inspection should remain visible outside the collapsed diagnostic group")
	ui._set_ui_scale(2)
	await process_frame
	_check(ui.gameplay_columns.vertical and ui.preparation_pack_offer_panel.visible and ui.preparation_advanced_button.visible, "125 percent scaling should preserve the staged Preparation rail")

	ui._start_tutorial()
	ui._on_tutorial_continue()
	ui._on_tutorial_continue()
	ui._on_tutorial_continue()
	ui._on_confirm_setup()
	var gate: Dictionary = ui.keep.room_definition("gate")
	ui._on_map_clicked(String(gate.get("floor", "ground")), gate.get("origin", Vector2i.ZERO))
	await process_frame
	_check(ui.tutorial.current_id() == "open_pike_line" and root.gui_get_focus_owner() == ui.pack_button, "First Watch should retain its authored pack focus through the new hierarchy")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P40 preparation command hierarchy: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
