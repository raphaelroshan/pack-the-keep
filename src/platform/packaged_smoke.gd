extends Node

const REPORT_PATH := "user://packaged_smoke_report.json"
const SAVE_PATH := "user://packaged_smoke_run.save"
const SAVE_TEMP_PATH := "user://packaged_smoke_run.save.tmp"
const SAVE_BACKUP_PATH := "user://packaged_smoke_run.save.bak"
const SETTINGS_PATH := "user://packaged_smoke_settings.json"
const SETTINGS_TEMP_PATH := "user://packaged_smoke_settings.json.tmp"
const SETTINGS_BACKUP_PATH := "user://packaged_smoke_settings.json.bak"
const FORCED_CLOSE_READY_PATH := "user://packaged_forced_close_ready"

func _record_error(errors: Array[String], condition: bool, message: String) -> void:
	if not condition:
		errors.append(message)

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}

func _write_text(path: String, value: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(value)
	file.flush()
	file.close()
	return true

func _copy_text(source: String, destination: String) -> bool:
	if not FileAccess.file_exists(source):
		return false
	return _write_text(destination, FileAccess.get_file_as_string(source))

func _has_joypad_binding(action: String, button_index: int = -1) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and (button_index < 0 or event.button_index == button_index):
			return true
	return false

func _settings_has_joypad_binding(settings_payload: Dictionary, action: String, button_index: int) -> bool:
	var bindings: Variant = settings_payload.get("input_bindings", {})
	if not bindings is Dictionary:
		return false
	var records: Variant = bindings.get(action, [])
	if not records is Array:
		return false
	for record in records:
		if record is Dictionary and String(record.get("type", "")) == "joypad_button" and int(record.get("button_index", -1)) == button_index:
			return true
	return false

func _profile_file_status(save_paths: Array, settings_paths: Array) -> Dictionary:
	var files_present: bool = false
	for path in save_paths + settings_paths:
		files_present = files_present or FileAccess.file_exists(String(path))
	return {
		"present": files_present,
		"complete": FileAccess.file_exists(String(save_paths[0])) and FileAccess.file_exists(String(settings_paths[0]))
	}

func run(ui: Control) -> void:
	var errors: Array[String] = []
	var phase: String = OS.get_environment("PACK_THE_KEEP_SMOKE_PHASE")
	if phase.is_empty():
		phase = "clean_install"
	var supported_phases: Array[String] = ["clean_install", "reinstall", "stale_backup", "missing_profile", "upgrade", "forced_close_prepare", "forced_close_recovery"]
	_record_error(errors, supported_phases.has(phase), "unknown packaged smoke phase: %s" % phase)
	await get_tree().process_frame
	await get_tree().process_frame
	ui.preferences_persistence_enabled = true
	ui.display_application_enabled = false
	ui.save_path = SAVE_PATH
	ui.save_temp_path = SAVE_TEMP_PATH
	ui.save_backup_path = SAVE_BACKUP_PATH
	ui.settings_path = SETTINGS_PATH
	ui.settings_temp_path = SETTINGS_TEMP_PATH
	ui.settings_backup_path = SETTINGS_BACKUP_PATH
	var profile_status: Dictionary = _profile_file_status(
		[SAVE_PATH, SAVE_TEMP_PATH, SAVE_BACKUP_PATH],
		[SETTINGS_PATH, SETTINGS_TEMP_PATH, SETTINGS_BACKUP_PATH]
	)
	var profile_files_present: bool = bool(profile_status.present)
	var profile_files_complete: bool = bool(profile_status.complete)
	var profile_backups_complete: bool = FileAccess.file_exists(SAVE_BACKUP_PATH) and FileAccess.file_exists(SETTINGS_BACKUP_PATH)
	var controller_navigation_ready: bool = _has_joypad_binding("ui_accept") and _has_joypad_binding("ui_down")
	_record_error(errors, controller_navigation_ready, "packaged UI navigation lost its controller path")
	var controller_defaults_ready: bool = true
	for action in ui.REMAPPABLE_ACTIONS:
		controller_defaults_ready = controller_defaults_ready and _has_joypad_binding(String(action))
	_record_error(errors, controller_defaults_ready, "packaged gameplay actions lost a default controller binding")
	var replacement: InputEventJoypadButton = InputEventJoypadButton.new()
	replacement.button_index = 10
	replacement.pressed = true
	var catalog_status: Dictionary = ui.keep.content_catalog_status()
	_record_error(errors, bool(catalog_status.get("ok", false)), "runtime content catalog failed after export")
	var expected_counts: Dictionary = {"keep_count": 3, "region_count": 1, "commander_count": 3, "piece_count": 19, "pack_count": 10, "enemy_count": 9, "doctrine_count": 10, "scenario_count": 13, "event_count": 9, "modifier_count": 2}
	for count_key in expected_counts:
		_record_error(errors, int(catalog_status.get(count_key, 0)) == int(expected_counts[count_key]), "exported runtime content has the wrong %s" % count_key)
	var ui_scale_ready: bool = false
	var controller_remap_ready: bool = false
	var initial_realtime_ready: bool = false
	var paused_state_frozen: bool = false
	var remapped_pause_ready: bool = false
	var manual_step_ready: bool = false
	var restored_run_ready: bool = false
	var restored_scale_ready: bool = false
	var restored_remap_ready: bool = false
	var primary_preferred_ready: bool = false
	var missing_profile_defaults_ready: bool = false
	var missing_profile_state_unchanged: bool = false
	var legacy_profile_detected: bool = false
	var upgrade_run_migrated: bool = false
	var upgrade_settings_ready: bool = false
	var upgraded_files_current: bool = false
	var forced_close_detected: bool = false
	var forced_close_run_recovered: bool = false
	var forced_close_settings_recovered: bool = false
	var forced_close_files_current: bool = false
	var authoritative_before_settings: String = JSON.stringify(ui.keep.serialize())
	var settings_state_unchanged: bool = false
	if phase == "forced_close_prepare":
		_record_error(errors, profile_files_complete, "forced-close preparation needs the existing run and settings")
		ui._load_preferences()
		ui._on_load()
		_record_error(errors, ui.keep.seed == 3307 and ui.keep.wave_active and ui.keep.battle_step == 1, "forced-close preparation could not load the baseline run")
		_record_error(errors, ui.ui_scale_index == 2 and _has_joypad_binding("battle_pause", 10), "forced-close preparation could not load the baseline settings")
		_record_error(errors, _copy_text(SAVE_PATH, SAVE_BACKUP_PATH), "forced-close preparation could not protect the run backup")
		_record_error(errors, _copy_text(SETTINGS_PATH, SETTINGS_BACKUP_PATH), "forced-close preparation could not protect the settings backup")
		_record_error(errors, _write_text(SAVE_PATH, "{\"schema_version\":"), "forced-close preparation could not strand the run primary")
		_record_error(errors, _write_text(SETTINGS_PATH, "{\"schema_version\":"), "forced-close preparation could not strand the settings primary")
		if not errors.is_empty():
			for error in errors:
				push_error(error)
			get_tree().quit(1)
			return
		if not _write_text(FORCED_CLOSE_READY_PATH, "ready"):
			push_error("forced-close preparation could not publish readiness")
			get_tree().quit(1)
			return
		while true:
			await get_tree().create_timer(1.0).timeout
	elif phase == "forced_close_recovery":
		forced_close_detected = profile_files_complete and profile_backups_complete
		_record_error(errors, forced_close_detected, "forced-close recovery needs malformed primaries and valid backups")
		ui._load_preferences()
		settings_state_unchanged = JSON.stringify(ui.keep.serialize()) == authoritative_before_settings
		forced_close_settings_recovered = ui.ui_scale_index == 2 and ui.window_size_index == 3 and _has_joypad_binding("battle_pause", 10)
		ui._on_load()
		forced_close_run_recovered = ui.keep.seed == 3307 and ui.keep.wave_active and ui.keep.battle_step == 1
		_record_error(errors, forced_close_settings_recovered, "forced-close recovery did not restore settings from backup")
		_record_error(errors, forced_close_run_recovered, "forced-close recovery did not restore the run from backup")
		ui._on_save()
		_record_error(errors, ui._save_preferences(), "forced-close recovery could not rewrite settings")
		forced_close_files_current = int(_read_json(SAVE_PATH).get("schema_version", 0)) == 4 and int(_read_json(SETTINGS_PATH).get("schema_version", 0)) == 5
		_record_error(errors, forced_close_files_current, "forced-close recovery did not rewrite current primary files")
	elif phase == "reinstall":
		_record_error(errors, profile_files_complete, "reinstalled build could not see both existing profile files")
		ui._load_preferences()
		settings_state_unchanged = JSON.stringify(ui.keep.serialize()) == authoritative_before_settings
		ui._on_load()
		restored_run_ready = ui.keep.wave_active and ui.keep.battle_step == 1
		restored_scale_ready = ui.ui_scale_index == 2 and is_equal_approx(get_tree().root.content_scale_factor, 1.25) and ui.window_size_index == 3
		restored_remap_ready = _has_joypad_binding("battle_pause", 10) and not _has_joypad_binding("placement_arm", 10)
		_record_error(errors, restored_run_ready, "reinstalled build did not restore the saved battle")
		_record_error(errors, restored_scale_ready, "reinstalled build did not restore 125 percent scale and the 2560x1440 preset")
		_record_error(errors, restored_remap_ready, "reinstalled build did not restore the controller remap")
	elif phase == "stale_backup":
		_record_error(errors, profile_files_complete and profile_backups_complete, "stale-backup phase needs complete primary and backup files")
		ui._load_preferences()
		settings_state_unchanged = JSON.stringify(ui.keep.serialize()) == authoritative_before_settings
		ui._on_load()
		primary_preferred_ready = ui.keep.seed == 3307 and ui.keep.wave_active and ui.keep.battle_step == 1 and ui.ui_scale_index == 2 and _has_joypad_binding("battle_pause", 10)
		_record_error(errors, primary_preferred_ready, "valid primary files did not outrank stale backups")
	elif phase == "missing_profile":
		_record_error(errors, not profile_files_present, "missing-profile phase unexpectedly found persistence files")
		var state_before_missing_load: String = JSON.stringify(ui.keep.serialize())
		ui._load_preferences()
		settings_state_unchanged = JSON.stringify(ui.keep.serialize()) == authoritative_before_settings
		ui._on_load()
		missing_profile_defaults_ready = ui.battle_speed_index == 1 and not ui.audio_muted and ui.ui_scale_index == 1 and ui.event_feed_retention_index == 0 and not ui.auto_pause_on_threat
		missing_profile_state_unchanged = JSON.stringify(ui.keep.serialize()) == state_before_missing_load
		_record_error(errors, missing_profile_defaults_ready, "missing profile did not retain documented presentation defaults")
		_record_error(errors, missing_profile_state_unchanged, "missing profile load mutated authoritative state")
	elif phase == "upgrade":
		var legacy_save_payload: Dictionary = _read_json(SAVE_PATH)
		var legacy_settings_payload: Dictionary = _read_json(SETTINGS_PATH)
		legacy_profile_detected = int(legacy_save_payload.get("schema_version", 0)) == 3 and int(legacy_settings_payload.get("schema_version", 0)) == 3
		_record_error(errors, legacy_profile_detected, "upgrade phase did not receive schema-3 profile files")
		ui._load_preferences()
		settings_state_unchanged = JSON.stringify(ui.keep.serialize()) == authoritative_before_settings
		ui._on_load()
		upgrade_run_migrated = ui.keep.wave_active and ui.keep.battle_step == 1 and String(ui.event_label.text).contains("legacy migration")
		upgrade_settings_ready = ui.ui_scale_index == 2 and _has_joypad_binding("battle_pause", 10) and ui.event_feed_retention_index == 0 and not ui.auto_pause_on_threat
		_record_error(errors, upgrade_run_migrated, "legacy run did not load through the migration boundary")
		_record_error(errors, upgrade_settings_ready, "legacy settings did not preserve supported values and default new fields")
		ui._on_save()
		_record_error(errors, ui._save_preferences(), "upgraded settings could not be rewritten")
		upgraded_files_current = int(_read_json(SAVE_PATH).get("schema_version", 0)) == 4 and int(_read_json(SETTINGS_PATH).get("schema_version", 0)) == 5
		_record_error(errors, upgraded_files_current, "legacy profile was not rewritten at current schemas")
	elif phase == "clean_install":
		_record_error(errors, not profile_files_present, "initial packaged profile was not clean")
		ui._set_ui_scale(2)
		ui._set_window_size(3)
		ui_scale_ready = ui.ui_scale_index == 2 and is_equal_approx(get_tree().root.content_scale_factor, 1.25) and ui.window_size_index == 3 and ui.WINDOW_SIZE_PRESETS[3] == Vector2i(2560, 1440)
		_record_error(errors, ui_scale_ready, "packaged display did not retain 125 percent scale with the 2560x1440 preset")
		ui._begin_rebind("battle_pause")
		ui._unhandled_input(replacement)
		controller_remap_ready = _has_joypad_binding("battle_pause", 10) and not _has_joypad_binding("placement_arm", 10)
		_record_error(errors, controller_remap_ready, "packaged controller remap did not resolve the button conflict")
		settings_state_unchanged = JSON.stringify(ui.keep.serialize()) == authoritative_before_settings
		ui._set_screen("preparation")
		var placed: Dictionary = ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
		_record_error(errors, bool(placed.get("ok", false)), "starter placement failed")
		ui._on_start_wave()
		initial_realtime_ready = ui.keep.wave_active and ui.battle_paused and not ui.assault_ready_reason.is_empty() and ui.screen == "battle" and ui.keep.battle_step == 0
		_record_error(errors, initial_realtime_ready, "packaged assault did not open in tick-zero readiness on the Battle screen")
		ui._unhandled_input(replacement)
		_record_error(errors, not ui.battle_paused and ui.assault_ready_reason.is_empty(), "remapped controller pause did not sound the bell from packaged readiness")
		ui._unhandled_input(replacement)
		var paused_step_before: int = ui.keep.battle_step
		ui._process(2.0)
		paused_state_frozen = ui.keep.battle_step == paused_step_before
		_record_error(errors, paused_state_frozen, "paused packaged presentation advanced authoritative battle state")
		ui._on_advance_wave()
		manual_step_ready = ui.battle_paused and ui.keep.battle_step == paused_step_before + 1
		_record_error(errors, manual_step_ready, "manual packaged step did not advance exactly once while paused")
		ui._unhandled_input(replacement)
		var remapped_resume_ready: bool = not ui.battle_paused
		ui._unhandled_input(replacement)
		remapped_pause_ready = remapped_resume_ready and ui.battle_paused
		_record_error(errors, remapped_pause_ready, "remapped controller pause did not toggle packaged battle state")
		ui._on_save()
		_record_error(errors, FileAccess.file_exists(SAVE_PATH), "run save was not written to user data")
		_record_error(errors, ui._save_preferences(), "settings were not written to user data")
		_record_error(errors, FileAccess.file_exists(SETTINGS_PATH), "settings file is missing")
	_record_error(errors, settings_state_unchanged, "presentation settings changed authoritative keep state")
	var save_payload: Dictionary = _read_json(SAVE_PATH)
	var settings_payload: Dictionary = _read_json(SETTINGS_PATH)
	if phase != "missing_profile":
		_record_error(errors, String(save_payload.get("game_id", "")) == "pack-the-keep", "run save has the wrong game ID")
		_record_error(errors, int(save_payload.get("schema_version", 0)) == 4, "run save has the wrong schema version")
		_record_error(errors, int(settings_payload.get("schema_version", 0)) == 5, "settings have the wrong schema version")
	var settings_scale_ready: bool = int(settings_payload.get("ui_scale_index", -1)) == 2 and int(settings_payload.get("window_size_index", -1)) == 3
	var settings_remap_ready: bool = _settings_has_joypad_binding(settings_payload, "battle_pause", 10)
	if phase == "clean_install":
		_record_error(errors, settings_scale_ready, "packaged settings did not persist 125 percent scale")
		_record_error(errors, settings_remap_ready, "packaged settings did not persist the controller remap")

	ui.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	var main_scene_freed: bool = not is_instance_valid(ui)
	_record_error(errors, main_scene_freed, "main scene did not free cleanly")
	var report: Dictionary = {
		"schema_version": 2,
		"ok": errors.is_empty(),
		"errors": errors,
		"phase": phase,
		"build_version": String(ProjectSettings.get_setting("application/config/version", "")),
		"executable_path": OS.get_executable_path(),
		"editor_feature": OS.has_feature("editor"),
		"user_data_dir": OS.get_user_data_dir(),
		"save_path": ProjectSettings.globalize_path(SAVE_PATH),
		"settings_path": ProjectSettings.globalize_path(SETTINGS_PATH),
		"save_schema_version": int(save_payload.get("schema_version", 0)),
		"settings_schema_version": int(settings_payload.get("schema_version", 0)),
		"battle_step": int(save_payload.get("battle_step", 0)),
		"content_status": catalog_status,
		"controller_navigation_ready": controller_navigation_ready,
		"controller_defaults_ready": controller_defaults_ready,
		"controller_remap_ready": controller_remap_ready,
		"ui_scale_ready": ui_scale_ready,
		"settings_scale_ready": settings_scale_ready,
		"settings_remap_ready": settings_remap_ready,
		"initial_realtime_ready": initial_realtime_ready,
		"paused_state_frozen": paused_state_frozen,
		"remapped_pause_ready": remapped_pause_ready,
		"manual_step_ready": manual_step_ready,
		"profile_files_present": profile_files_present,
		"profile_files_complete": profile_files_complete,
		"profile_backups_complete": profile_backups_complete,
		"restored_run_ready": restored_run_ready,
		"restored_scale_ready": restored_scale_ready,
		"restored_remap_ready": restored_remap_ready,
		"primary_preferred_ready": primary_preferred_ready,
		"missing_profile_defaults_ready": missing_profile_defaults_ready,
		"missing_profile_state_unchanged": missing_profile_state_unchanged,
		"legacy_profile_detected": legacy_profile_detected,
		"upgrade_run_migrated": upgrade_run_migrated,
		"upgrade_settings_ready": upgrade_settings_ready,
		"upgraded_files_current": upgraded_files_current,
		"forced_close_detected": forced_close_detected,
		"forced_close_run_recovered": forced_close_run_recovered,
		"forced_close_settings_recovered": forced_close_settings_recovered,
		"forced_close_files_current": forced_close_files_current,
		"settings_state_unchanged": settings_state_unchanged,
		"main_scene_freed": main_scene_freed,
		"smoke_guard": OS.get_environment("PACK_THE_KEEP_PACKAGED_SMOKE") == "1",
		"offline_proxy_guard": OS.get_environment("HTTPS_PROXY").contains("127.0.0.1:9")
	}
	var report_file: FileAccess = FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if report_file == null:
		push_error("packaged smoke report could not be written")
		get_tree().quit(1)
		return
	report_file.store_string(JSON.stringify(report, "  "))
	report_file.flush()
	report_file.close()
	if errors.is_empty():
		print("P12 packaged smoke: PASS — %s" % OS.get_user_data_dir())
		get_tree().quit(0)
	else:
		for error in errors:
			push_error(error)
		get_tree().quit(1)
