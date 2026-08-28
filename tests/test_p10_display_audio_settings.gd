extends SceneTree

const TEST_SETTINGS := "user://pack_the_keep_display_settings_test.json"
const TEST_TEMP := "user://pack_the_keep_display_settings_test.json.tmp"
const TEST_BACKUP := "user://pack_the_keep_display_settings_test.json.bak"

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
	ui.display_application_enabled = false
	ui._load_preferences()
	ui._refresh_ui()
	var state_before: String = JSON.stringify(ui.keep.serialize())

	ui._set_window_size(3)
	ui.size = Vector2(2560, 1440)
	ui._apply_responsive_layout()
	_check(ui.ui_scale_index == 2, "2560x1440 should promote undersized UI preferences to the 125 percent readability baseline")
	_check(not ui.gameplay_columns.vertical and ui.command_panel.custom_minimum_size.x >= 360.0 and ui.keep_canvas.custom_minimum_size.y >= 420.0, "2560x1440 should retain side-by-side gameplay with an expanded fort canvas")
	ui._toggle_fullscreen()
	ui._set_effects_volume(1)
	ui._toggle_mute()
	_check(ui.window_size_index == 3 and ui.WINDOW_SIZE_PRESETS[3] == Vector2i(2560, 1440) and ui.fullscreen_enabled, "display controls should retain the 2560x1440 windowed size while fullscreen is active")
	_check(is_equal_approx(ui._effects_gain(), 0.5), "effects volume index 1 should produce 50 percent gain")
	_check(ui.audio_muted, "mute should remain an independent override at the selected effects gain")
	_check(String(ui.window_mode_button.text).contains("Fullscreen") and String(ui.resolution_button.text).contains("2560×1440") and String(ui.effects_volume_button.text).contains("50%"), "display and volume controls should expose current values as text")
	_check(JSON.stringify(ui.keep.serialize()) == state_before, "display and audio settings should not mutate authoritative run state")
	var payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEST_SETTINGS))
	_check(payload is Dictionary and int(payload.get("schema_version", 0)) == 4, "display and audio preferences should write the current settings schema")

	var restored: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(restored)
	await process_frame
	restored.settings_path = TEST_SETTINGS
	restored.settings_temp_path = TEST_TEMP
	restored.settings_backup_path = TEST_BACKUP
	restored.preferences_persistence_enabled = true
	restored.display_application_enabled = false
	restored._load_preferences()
	restored._refresh_ui()
	_check(restored.window_size_index == 3 and restored.fullscreen_enabled and restored.effects_volume_index == 1, "a new UI should restore 2560x1440 and effects-volume preferences")

	var file: FileAccess = FileAccess.open(TEST_SETTINGS, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": 2, "battle_speed_index": 2, "audio_muted": true, "high_contrast": true, "reduced_motion": true, "ui_scale_index": 2, "input_bindings": {}}))
	file.close()
	restored._load_preferences()
	_check(not restored.fullscreen_enabled and restored.window_size_index == 1 and restored.effects_volume_index == 3, "schema-2 settings should migrate with the 1600x900 display default and documented audio default")
	_check(restored.battle_speed_index == 2 and restored.audio_muted and restored.high_contrast and restored.reduced_motion and restored.ui_scale_index == 2, "schema-2 migration should preserve existing presentation preferences")

	root.content_scale_factor = 1.0
	ui.queue_free()
	restored.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P10 display and audio settings: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
