extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _inside_viewport(control: Control, viewport_size: Vector2) -> bool:
	var rect: Rect2 = control.get_global_rect()
	return rect.position.x >= -1.0 and rect.end.x <= viewport_size.x + 1.0

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._on_start_custom_setup()
	await process_frame

	ui._select_option_metadata(ui.commander_option, "marshal")
	ui._on_select_commander()
	ui._select_option_metadata(ui.scenario_option, "two_fires")
	ui._on_select_scenario()
	await process_frame
	var panel: WarCouncilChoicePanel = ui.war_council_choice_panel
	_check(String(panel.commander_name_label.text).contains("Marshal"), "War Council should present the fourth commander")
	_check(String(panel.commander_strength_label.text).contains("Posted Orders"), "War Council should explain the Marshal passive")
	_check(String(panel.commander_ability_label.text).contains("Relief Order"), "War Council should explain the Marshal intervention")
	_check(String(panel.scenario_name_label.text).contains("Two Fires"), "War Council should present a Twinwatch scenario")
	_check(String(panel.summary_label.text).contains("Twinwatch Bastion"), "War Council should name the selected keep")

	root.size = Vector2i(1280, 720)
	ui.ui_scale_index = 3
	ui._apply_ui_scale()
	await process_frame
	_check(ui.gameplay_columns.vertical and panel.choice_row.vertical, "large-text Early Access setup should use the stacked composition")
	_check(_inside_viewport(panel, Vector2(root.size)), "Marshal and Twinwatch cards should remain inside the 1280x720 viewport")

	ui._on_confirm_setup()
	await process_frame
	await process_frame
	_check(ui.screen == "preparation" and ui.keep.keep_id == "twinwatch_bastion", "the selected Twinwatch defense should enter Preparation")
	_check(ui.keep.active_event_id == "twinwatch_signal", "Twinwatch's authored forecast decision should appear in Preparation")
	_check(ui.authored_event_panel.visible and String(ui.authored_event_panel.title_label.text).contains("Which Fire Answers"), "the keep event should render as a game-facing choice")
	ui.keep.choose_event_option("reserve_relief_signal")
	ui._refresh_ui()
	_check(ui.keep_canvas.keep.keep_id == "twinwatch_bastion", "the board should render the selected keep identity")
	_check(String(ui.preparation_brief_panel.question_label.text).contains("Can both posts"), "Preparation should carry the Twinwatch strategic question")

	ui._toggle_reduced_motion()
	_check(ui.reduced_motion and ui.keep_canvas.reduced_motion_mode, "reduced motion should apply to the expanded campaign board")
	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	root.size = Vector2i(2560, 1440)
	ui.ui_scale_index = 2
	ui._apply_ui_scale()
	await process_frame
	_check(_inside_viewport(ui.gameplay_main_column, Vector2(root.size)) and _inside_viewport(ui.command_panel, Vector2(root.size)), "the expanded campaign should remain in bounds at 2560x1440")
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "resizing and accessibility presentation must not mutate campaign state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("PTK Early Access campaign UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
