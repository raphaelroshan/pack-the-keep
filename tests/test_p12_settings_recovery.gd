extends SceneTree

const TEST_SETTINGS := "user://pack_the_keep_p12_settings_recovery.json"
const TEST_TEMP := "user://pack_the_keep_p12_settings_recovery.json.tmp"
const TEST_BACKUP := "user://pack_the_keep_p12_settings_recovery.json.bak"

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

func _write(path: String, payload: Variant) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	_check(file != null, "settings recovery fixture should be writable: %s" % path)
	if file != null:
		file.store_string(payload if payload is String else JSON.stringify(payload))
		file.close()

func _settings(speed: int, muted: bool, scale: int) -> Dictionary:
	return {
		"schema_version": 4,
		"battle_speed_index": speed,
		"audio_muted": muted,
		"high_contrast": muted,
		"reduced_motion": muted,
		"ui_scale_index": scale,
		"input_bindings": {},
		"window_size_index": 0,
		"fullscreen_enabled": false,
		"effects_volume_index": 3,
		"event_feed_retention_index": 0,
		"auto_pause_on_threat": muted
	}

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

	_write(TEST_SETTINGS, "{malformed")
	_write(TEST_BACKUP, _settings(2, true, 2))
	ui._load_preferences()
	_check(ui.battle_speed_index == 2 and ui.audio_muted and ui.high_contrast and ui.reduced_motion and ui.ui_scale_index == 2 and ui.auto_pause_on_threat, "malformed primary settings should recover the valid backup")

	_remove_test_files()
	_write(TEST_BACKUP, _settings(0, true, 0))
	ui._load_preferences()
	_check(ui.battle_speed_index == 0 and ui.audio_muted and ui.ui_scale_index == 0, "missing primary settings should recover a crash-stranded backup")

	_remove_test_files()
	_write(TEST_SETTINGS, _settings(2, false, 2))
	_write(TEST_TEMP, _settings(0, true, 0))
	ui._load_preferences()
	_check(ui.battle_speed_index == 2 and not ui.audio_muted and ui.ui_scale_index == 2, "a stranded settings temp should not replace a valid primary")

	_remove_test_files()
	_write(TEST_TEMP, _settings(0, true, 0))
	ui._load_preferences()
	_check(ui.battle_speed_index == 1 and not ui.audio_muted and ui.ui_scale_index == 1, "temporary settings alone should fall back to documented defaults")

	_remove_test_files()
	_write(TEST_SETTINGS, {"schema_version": 99})
	_write(TEST_BACKUP, "{bad")
	ui._load_preferences()
	_check(ui.battle_speed_index == 1 and not ui.audio_muted and ui.ui_scale_index == 1, "two invalid settings candidates should preserve documented defaults")

	root.content_scale_factor = 1.0
	ui.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P12 settings recovery: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
