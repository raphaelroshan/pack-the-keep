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
	ui.save_path = "user://p46_navigation.save"
	ui.save_temp_path = "user://p46_navigation.save.tmp"
	ui.save_backup_path = "user://p46_navigation.save.bak"

	ui._on_start_quick_playtest()
	ui._on_back_requested()
	_check(ui.screen == "title" and not ui.navigation_confirm_layer.visible, "War Council back should return directly to Main Menu")

	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	var preparation_state: String = JSON.stringify(ui.keep.serialize())
	ui._on_back_requested()
	_check(ui.screen == "preparation" and ui.navigation_confirm_layer.visible, "unsaved Preparation should request confirmation before leaving")
	_check(String(ui.navigation_confirm_label.text).contains("not stored") and JSON.stringify(ui.keep.serialize()) == preparation_state, "confirmation should explain unsaved progress without mutating the run")
	ui._on_back_requested()
	_check(not ui.navigation_confirm_layer.visible and ui.screen == "preparation", "Escape on the confirmation should stay with the defense")

	ui._arm_selected_piece()
	var cancel_event: InputEventAction = InputEventAction.new()
	cancel_event.action = "placement_cancel"
	cancel_event.pressed = true
	ui._handle_named_action(cancel_event)
	_check(not ui.placement_mode and not ui.navigation_confirm_layer.visible, "Escape should cancel active placement before requesting navigation")

	ui._on_back_requested()
	ui._confirm_navigation()
	_check(ui.screen == "setup" and not ui.keep.scenario_active, "confirmed leave should reset the in-memory run and return to War Council")

	ui._on_confirm_setup()
	ui._on_open_settings()
	ui._on_back_requested()
	_check(ui.screen == "preparation" and not ui.navigation_confirm_layer.visible, "Settings back should return directly to its originating screen")
	ui._on_save()
	_check(not ui._has_unsaved_run_progress(), "a successful save should establish the current run signature")
	ui._on_back_requested()
	_check(ui.screen == "setup" and not ui.navigation_confirm_layer.visible, "saved gameplay state should leave without an unsaved-progress confirmation")

	var directory: DirAccess = DirAccess.open("user://")
	for path in [ui.save_path, ui.save_temp_path, ui.save_backup_path]:
		if FileAccess.file_exists(path):
			directory.remove(path.get_file())
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P46 navigation safety: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
