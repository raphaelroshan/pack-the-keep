extends SceneTree

const TEST_SETTINGS := "user://pack_the_keep_feed_settings_test.json"
const TEST_TEMP := "user://pack_the_keep_feed_settings_test.json.tmp"
const TEST_BACKUP := "user://pack_the_keep_feed_settings_test.json.bak"

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

func _configure_test_settings(ui: Control) -> void:
	ui.settings_path = TEST_SETTINGS
	ui.settings_temp_path = TEST_TEMP
	ui.settings_backup_path = TEST_BACKUP
	ui.preferences_persistence_enabled = true
	ui.display_application_enabled = false

func _initialize() -> void:
	_remove_test_files()
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	_configure_test_settings(ui)
	ui._load_preferences()
	ui._refresh_ui()
	var state_before: String = JSON.stringify(ui.keep.serialize())

	ui._set_event_feed_retention(2)
	ui._toggle_auto_pause_on_threat()
	_check(ui.event_feed_retention_index == 2 and ui.auto_pause_on_threat, "feed retention and auto-pause controls should update")
	_check(String(ui.event_feed_button.text).contains("16") and String(ui.auto_pause_button.text).contains("ON"), "feed and auto-pause controls should expose current values as text")
	_check(JSON.stringify(ui.keep.serialize()) == state_before, "feed and auto-pause preferences should not mutate authoritative run state")

	ui.keep.battle_report.clear()
	for index in range(20):
		ui.keep.battle_report.append("event_%02d" % index)
	ui._refresh_ui()
	_check(String(ui.log_label.text).contains("event_19") and String(ui.log_label.text).contains("event_04"), "bounded feed should show the newest retained entries")
	_check(not String(ui.log_label.text).contains("event_03"), "bounded feed should hide entries older than the retention preference")
	var payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEST_SETTINGS))
	_check(payload is Dictionary and int(payload.get("schema_version", 0)) == 4, "feed preferences should write settings schema 4")

	ui.keep.reset_run(3307)
	ui.last_log_size = 0
	ui._on_place_piece()
	ui.keep._set_piece_health("pike_squad_0", 0)
	ui.keep.rooms["workshop"].condition = 40
	ui.keep._update_room_state("workshop")
	for index in range(ui.doctrine_option.item_count):
		if String(ui.doctrine_option.get_item_metadata(index)) == "distributed_sabotage":
			ui.doctrine_option.select(index)
			break
	ui._on_start_wave()
	ui._set_battle_speed(2)
	var baseline: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(baseline)
	await process_frame
	baseline._on_place_piece()
	baseline.keep._set_piece_health("pike_squad_0", 0)
	baseline.keep.rooms["workshop"].condition = 40
	baseline.keep._update_room_state("workshop")
	for index in range(baseline.doctrine_option.item_count):
		if String(baseline.doctrine_option.get_item_metadata(index)) == "distributed_sabotage":
			baseline.doctrine_option.select(index)
			break
	baseline._on_start_wave()
	var baseline_result: Dictionary = baseline.keep.advance_wave(1.0)
	_check(bool(baseline_result.get("ok", false)), "baseline deterministic step should resolve")
	ui.battle_paused = false
	ui._process(1.0)
	_check(ui.battle_paused, "auto-pause should stop real-time presentation after the first new threat")
	_check(ui.keep.battle_step == 1, "auto-pause should stop after one atomic step even at 2x presentation speed")
	_check(JSON.stringify(ui.keep.serialize()) == JSON.stringify(baseline.keep.serialize()), "auto-pause should preserve the exact authoritative one-step result")
	var paused_on_breach: bool = false
	while ui.keep.wave_active and ui.keep.battle_step < 20:
		var breach_before: int = ui.keep.breach_level
		ui.battle_paused = false
		ui._process(1.0)
		if ui.keep.breach_level > breach_before:
			paused_on_breach = ui.battle_paused
			break
	_check(paused_on_breach, "auto-pause should stop real-time presentation after a new breach")

	var restored: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(restored)
	await process_frame
	_configure_test_settings(restored)
	restored._load_preferences()
	restored._refresh_ui()
	_check(restored.event_feed_retention_index == 2 and restored.auto_pause_on_threat, "a new UI should restore feed and auto-pause preferences")

	var file: FileAccess = FileAccess.open(TEST_SETTINGS, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": 3, "battle_speed_index": 1, "audio_muted": false, "high_contrast": false, "reduced_motion": false, "ui_scale_index": 1, "input_bindings": {}, "window_size_index": 0, "fullscreen_enabled": false, "effects_volume_index": 3}))
	file.close()
	restored._load_preferences()
	_check(restored.event_feed_retention_index == 0 and not restored.auto_pause_on_threat, "schema-3 settings should migrate with documented feed defaults")

	root.content_scale_factor = 1.0
	ui.queue_free()
	baseline.queue_free()
	restored.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P10 event feed and auto-pause: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
