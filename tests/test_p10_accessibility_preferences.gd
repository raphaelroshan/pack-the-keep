extends SceneTree

const TEST_SETTINGS := "user://pack_the_keep_settings_test.json"
const TEST_TEMP := "user://pack_the_keep_settings_test.json.tmp"
const TEST_BACKUP := "user://pack_the_keep_settings_test.json.bak"

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
	ui._load_preferences()
	ui._refresh_ui()
	var state_before: String = JSON.stringify(ui.keep.serialize())
	ui._toggle_mute()
	ui._toggle_contrast()
	ui._toggle_reduced_motion()
	ui._set_battle_speed(2)
	_check(JSON.stringify(ui.keep.serialize()) == state_before, "accessibility preferences should not mutate authoritative run state")
	_check(FileAccess.file_exists(TEST_SETTINGS), "preference changes should write the versioned settings file")
	_check(not FileAccess.file_exists(TEST_BACKUP), "successful preference replacement should remove its backup")
	_check(ui.keep_canvas.reduced_motion_mode and is_zero_approx(ui.keep_canvas.feedback_ttl), "reduced motion should suppress transient board feedback")
	_check(String(ui.reduced_motion_button.text).contains("ON") and String(ui.contrast_button.text).contains("ON"), "accessibility controls should display their enabled state")

	var restored: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(restored)
	await process_frame
	restored.settings_path = TEST_SETTINGS
	restored.settings_temp_path = TEST_TEMP
	restored.settings_backup_path = TEST_BACKUP
	restored.preferences_persistence_enabled = true
	restored._load_preferences()
	restored._refresh_ui()
	_check(restored.audio_muted and restored.high_contrast and restored.reduced_motion and restored.battle_speed_index == 2, "a new UI instance should restore saved accessibility preferences")

	var file: FileAccess = FileAccess.open(TEST_SETTINGS, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": 99, "battle_speed_index": 0, "audio_muted": true, "high_contrast": true, "reduced_motion": true}))
	file.close()
	restored._load_preferences()
	_check(not restored.audio_muted and not restored.high_contrast and not restored.reduced_motion and restored.battle_speed_index == 1, "future settings schema should fall back to documented defaults")

	file = FileAccess.open(TEST_SETTINGS, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": 1, "battle_speed_index": "fast", "audio_muted": 1, "high_contrast": [], "reduced_motion": "yes"}))
	file.close()
	restored._load_preferences()
	_check(not restored.audio_muted and not restored.high_contrast and not restored.reduced_motion and restored.battle_speed_index == 1, "invalid setting types should fall back to documented defaults")

	ui.queue_free()
	restored.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P10 accessibility preferences: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
