extends Node

const REPORT_PATH := "user://packaged_smoke_report.json"
const SAVE_PATH := "user://packaged_smoke_run.save"
const SAVE_TEMP_PATH := "user://packaged_smoke_run.save.tmp"
const SAVE_BACKUP_PATH := "user://packaged_smoke_run.save.bak"
const SETTINGS_PATH := "user://packaged_smoke_settings.json"
const SETTINGS_TEMP_PATH := "user://packaged_smoke_settings.json.tmp"
const SETTINGS_BACKUP_PATH := "user://packaged_smoke_settings.json.bak"

func _record_error(errors: Array[String], condition: bool, message: String) -> void:
	if not condition:
		errors.append(message)

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}

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

func run(ui: Control) -> void:
	var errors: Array[String] = []
	var phase: String = OS.get_environment("PACK_THE_KEEP_SMOKE_PHASE")
	if phase.is_empty():
		phase = "initial"
	var reinstall_phase: bool = phase == "reinstall"
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
	var profile_files_present: bool = FileAccess.file_exists(SAVE_PATH) and FileAccess.file_exists(SETTINGS_PATH)
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
	var expected_counts: Dictionary = {"commander_count": 2, "piece_count": 17, "pack_count": 9, "enemy_count": 7, "doctrine_count": 8, "scenario_count": 8, "event_count": 3, "modifier_count": 2}
	for count_key in expected_counts:
		_record_error(errors, int(catalog_status.get(count_key, 0)) == int(expected_counts[count_key]), "exported runtime content has the wrong %s" % count_key)
	var ui_scale_ready: bool = false
	var controller_remap_ready: bool = false
	var initial_pause_ready: bool = false
	var paused_state_frozen: bool = false
	var remapped_pause_ready: bool = false
	var manual_step_ready: bool = false
	var restored_run_ready: bool = false
	var restored_scale_ready: bool = false
	var restored_remap_ready: bool = false
	if reinstall_phase:
		_record_error(errors, profile_files_present, "reinstalled build could not see the existing profile files")
		ui._load_preferences()
		ui._on_load()
		restored_run_ready = ui.keep.wave_active and ui.keep.battle_step == 1
		restored_scale_ready = ui.ui_scale_index == 2 and is_equal_approx(get_tree().root.content_scale_factor, 1.25) and ui.gameplay_columns.vertical
		restored_remap_ready = _has_joypad_binding("battle_pause", 10) and not _has_joypad_binding("placement_arm", 10)
		_record_error(errors, restored_run_ready, "reinstalled build did not restore the saved battle")
		_record_error(errors, restored_scale_ready, "reinstalled build did not restore 125 percent stacked scale")
		_record_error(errors, restored_remap_ready, "reinstalled build did not restore the controller remap")
	else:
		_record_error(errors, not profile_files_present, "initial packaged profile was not clean")
		ui._set_ui_scale(2)
		ui_scale_ready = ui.ui_scale_index == 2 and is_equal_approx(get_tree().root.content_scale_factor, 1.25) and ui.gameplay_columns.vertical
		_record_error(errors, ui_scale_ready, "125 percent packaged UI scale did not apply the stacked layout")
		ui._begin_rebind("battle_pause")
		ui._unhandled_input(replacement)
		controller_remap_ready = _has_joypad_binding("battle_pause", 10) and not _has_joypad_binding("placement_arm", 10)
		_record_error(errors, controller_remap_ready, "packaged controller remap did not resolve the button conflict")
		ui._set_screen("preparation")
		var placed: Dictionary = ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
		_record_error(errors, bool(placed.get("ok", false)), "starter placement failed")
		ui._on_start_wave()
		initial_pause_ready = ui.keep.wave_active and ui.battle_paused and ui.screen == "battle"
		_record_error(errors, initial_pause_ready, "packaged battle did not begin paused on the Battle screen")
		var paused_step_before: int = ui.keep.battle_step
		ui._process(2.0)
		paused_state_frozen = ui.keep.battle_step == paused_step_before
		_record_error(errors, paused_state_frozen, "paused packaged presentation advanced authoritative battle state")
		ui._unhandled_input(replacement)
		var remapped_resume_ready: bool = not ui.battle_paused
		ui._unhandled_input(replacement)
		remapped_pause_ready = remapped_resume_ready and ui.battle_paused
		_record_error(errors, remapped_pause_ready, "remapped controller pause did not toggle packaged battle state")
		ui._on_advance_wave()
		manual_step_ready = ui.battle_paused and ui.keep.battle_step == paused_step_before + 1
		_record_error(errors, manual_step_ready, "manual packaged step did not advance exactly once while paused")
		ui._on_save()
		_record_error(errors, FileAccess.file_exists(SAVE_PATH), "run save was not written to user data")
		_record_error(errors, ui._save_preferences(), "settings were not written to user data")
		_record_error(errors, FileAccess.file_exists(SETTINGS_PATH), "settings file is missing")
	var save_payload: Dictionary = _read_json(SAVE_PATH)
	var settings_payload: Dictionary = _read_json(SETTINGS_PATH)
	_record_error(errors, String(save_payload.get("game_id", "")) == "pack-the-keep", "run save has the wrong game ID")
	_record_error(errors, int(save_payload.get("schema_version", 0)) == 4, "run save has the wrong schema version")
	_record_error(errors, int(settings_payload.get("schema_version", 0)) == 4, "settings have the wrong schema version")
	var settings_scale_ready: bool = int(settings_payload.get("ui_scale_index", -1)) == 2
	var settings_remap_ready: bool = _settings_has_joypad_binding(settings_payload, "battle_pause", 10)
	if not reinstall_phase:
		_record_error(errors, settings_scale_ready, "packaged settings did not persist 125 percent scale")
		_record_error(errors, settings_remap_ready, "packaged settings did not persist the controller remap")

	ui.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	var main_scene_freed: bool = not is_instance_valid(ui)
	_record_error(errors, main_scene_freed, "main scene did not free cleanly")
	var report: Dictionary = {
		"schema_version": 1,
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
		"initial_pause_ready": initial_pause_ready,
		"paused_state_frozen": paused_state_frozen,
		"remapped_pause_ready": remapped_pause_ready,
		"manual_step_ready": manual_step_ready,
		"profile_files_present": profile_files_present,
		"restored_run_ready": restored_run_ready,
		"restored_scale_ready": restored_scale_ready,
		"restored_remap_ready": restored_remap_ready,
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
