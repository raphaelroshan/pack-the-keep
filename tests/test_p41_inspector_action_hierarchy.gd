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

	var initial_state: String = JSON.stringify(ui.keep.serialize())
	var gate: Dictionary = ui.keep.room_definition("gate")
	ui._on_map_clicked(String(gate.get("floor", "ground")), gate.get("origin", Vector2i.ZERO))
	_check(String(ui.inspection_panel.kind_label.text).begins_with("ROOM") and String(ui.inspection_panel.name_label.text) == "Gate", "room selection should render the shared inspection hierarchy")
	_check(String(ui.inspection_panel.condition_label.text).contains("CONDITION") and String(ui.inspection_panel.purpose_label.text).contains("WHY IT MATTERS") and String(ui.inspection_panel.next_action_label.text).contains("NEXT ACTION"), "room card should expose condition, purpose, and next action")
	_check(JSON.stringify(ui.keep.serialize()) == initial_state, "room inspection should not mutate authoritative state")

	ui._on_map_clicked("ground", Vector2i(4, 5))
	_check(String(ui.inspection_panel.kind_label.text).begins_with("DEFENDER") and String(ui.inspection_panel.name_label.text) == "Pike Squad", "defender selection should reuse the same card hierarchy")
	_check(String(ui.inspection_panel.condition_label.text).contains("HEALTH") and String(ui.inspection_panel.purpose_label.text).contains("Skill:"), "defender card should expose health and tactical role")

	ui._on_start_wave()
	await process_frame
	_check(String(ui.inspection_panel.kind_label.text).begins_with("THREAT") and String(ui.inspection_panel.name_label.text).contains("Raider"), "battle focus should render the active threat in the shared card")
	_check(String(ui.inspection_panel.condition_label.text).contains("TARGET") and String(ui.inspection_panel.next_action_label.text).contains("response preview"), "paused threat card should expose target and next inspection action")
	_check(not String(ui.inspector_label.text).contains("pike_squad"), "player-facing threat detail should not expose stable counter IDs")
	var before_refresh: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_inspection_card()
	_check(JSON.stringify(ui.keep.serialize()) == before_refresh, "refreshing the inspection card should not mutate combat state")
	ui._set_ui_scale(2)
	await process_frame
	_check(ui.gameplay_columns.vertical and ui.inspection_panel.visible, "125 percent scale should retain the inspection card in the stacked rail")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P41 inspector action hierarchy: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
