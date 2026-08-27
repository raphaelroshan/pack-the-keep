extends SceneTree

const TEST_SETTINGS := "user://pack_the_keep_controller_settings_test.json"
const TEST_TEMP := "user://pack_the_keep_controller_settings_test.json.tmp"
const TEST_BACKUP := "user://pack_the_keep_controller_settings_test.json.bak"

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _remove_test_files() -> void:
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		return
	for path in [TEST_SETTINGS, TEST_TEMP, TEST_BACKUP]:
		if FileAccess.file_exists(path):
			directory.remove(path.get_file())

func _has_joypad_binding(action: String, button_index: int = -1) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and (button_index < 0 or event.button_index == button_index):
			return true
	return false

func _has_joypad_path(action: String) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			return true
	return false

func _initialize() -> void:
	_remove_test_files()
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.settings_path = TEST_SETTINGS
	ui.settings_temp_path = TEST_TEMP
	ui.settings_backup_path = TEST_BACKUP
	ui.preferences_persistence_enabled = true
	ui._load_preferences()
	ui._refresh_ui()
	var state_before: String = JSON.stringify(ui.keep.serialize())

	_check(_has_joypad_path("ui_accept"), "Godot UI focus navigation should expose a controller accept path")
	_check(_has_joypad_path("ui_down"), "Godot UI focus navigation should expose a controller directional path")
	for action in ui.REMAPPABLE_ACTIONS:
		_check(not InputMap.action_get_events(action).is_empty(), "%s should retain at least one usable binding" % action)
		_check(_has_joypad_binding(action), "%s should have a project-default controller path" % action)
	ui._set_ui_scale(2)
	_check(ui.ui_scale_index == 2 and is_equal_approx(root.content_scale_factor, 1.25), "125 percent UI scale should apply immediately")
	_check(ui.gameplay_columns.vertical, "125 percent UI scale should stack the board and command rail instead of clipping them side by side")
	var arm_event: InputEventJoypadButton = InputEventJoypadButton.new()
	arm_event.button_index = 10
	arm_event.pressed = true
	ui._unhandled_input(arm_event)
	_check(ui.placement_mode, "controller placement binding should arm the selected piece")
	var cancel_event: InputEventJoypadButton = InputEventJoypadButton.new()
	cancel_event.button_index = 1
	cancel_event.pressed = true
	ui._unhandled_input(cancel_event)
	_check(not ui.placement_mode, "controller cancel binding should leave placement mode")
	ui._set_screen("preparation")
	await process_frame
	await process_frame
	_check(root.gui_get_focus_owner() == ui.pack_option, "preparation should focus the pack selector for controller navigation")

	ui._begin_rebind("battle_pause")
	var reserved_navigation: InputEventJoypadButton = InputEventJoypadButton.new()
	reserved_navigation.button_index = 0
	reserved_navigation.pressed = true
	ui._unhandled_input(reserved_navigation)
	_check(ui.rebind_waiting_action == "battle_pause" and not _has_joypad_binding("battle_pause", 0), "controller navigation buttons should not be captured as global command bindings")
	var replacement: InputEventJoypadButton = InputEventJoypadButton.new()
	replacement.button_index = 10
	replacement.pressed = true
	ui._unhandled_input(replacement)
	_check(_has_joypad_binding("battle_pause", 10), "controller capture should replace the selected action's controller binding")
	_check(not _has_joypad_binding("placement_arm", 10), "captured controller buttons should be removed from conflicting actions")
	for action in ui.REMAPPABLE_ACTIONS:
		_check(not InputMap.action_get_events(action).is_empty(), "%s should remain usable after conflict resolution" % action)
	var saved_payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEST_SETTINGS))
	_check(saved_payload is Dictionary and int(saved_payload.get("schema_version", 0)) == 3 and saved_payload.get("input_bindings") is Dictionary, "controller and scale preferences should persist in the current settings schema")
	_check(JSON.stringify(ui.keep.serialize()) == state_before, "scaling and rebinding should not mutate authoritative run state")

	ui._on_place_piece()
	ui._on_start_wave()
	await process_frame
	await process_frame
	_check(ui.battle_paused, "new invasion should start paused before controller dispatch")
	_check(root.gui_get_focus_owner() == ui.pause_button, "battle should focus the pause control for controller navigation")
	ui._unhandled_input(replacement)
	_check(not ui.battle_paused, "remapped controller event should dispatch through the named pause action")

	ui._set_screen("title")
	await process_frame
	await process_frame
	_check(root.gui_get_focus_owner() == ui.quick_test_button, "title screen should expose a controller-ready primary focus")

	var restored: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(restored)
	await process_frame
	restored.settings_path = TEST_SETTINGS
	restored.settings_temp_path = TEST_TEMP
	restored.settings_backup_path = TEST_BACKUP
	restored.preferences_persistence_enabled = true
	restored._load_preferences()
	_check(restored.ui_scale_index == 2 and _has_joypad_binding("battle_pause", 10), "a new UI should restore scale and custom controller bindings")

	var file: FileAccess = FileAccess.open(TEST_SETTINGS, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": 1, "battle_speed_index": 2, "audio_muted": true, "high_contrast": true, "reduced_motion": true}))
	file.close()
	restored._load_preferences()
	_check(restored.ui_scale_index == 1 and restored.audio_muted and restored.high_contrast and restored.reduced_motion, "schema-1 settings should migrate with default scale and preserved accessibility values")

	restored._reset_input_bindings()
	_check(_has_joypad_binding("battle_pause") and not _has_joypad_binding("battle_pause", 10) and _has_joypad_binding("placement_arm", 10), "reset should restore project-default controller bindings")
	_check(String(restored.ui_scale_button.text).contains("100%"), "scale control should expose the current preset as text")

	root.content_scale_factor = 1.0
	ui.queue_free()
	restored.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P10 controller and scaling: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
