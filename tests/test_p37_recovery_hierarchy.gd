extends SceneTree

const TEST_SAVE := "user://pack_the_keep_p37_recovery_test.json"
const TEST_TEMP := "user://pack_the_keep_p37_recovery_test.json.tmp"
const TEST_BACKUP := "user://pack_the_keep_p37_recovery_test.json.bak"

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _configure_paths(ui: Control) -> void:
	ui.save_path = TEST_SAVE
	ui.save_temp_path = TEST_TEMP
	ui.save_backup_path = TEST_BACKUP
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false

func _remove_test_files() -> void:
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		return
	for path in [TEST_SAVE, TEST_TEMP, TEST_BACKUP]:
		if FileAccess.file_exists(path):
			directory.remove(path.get_file())

func _resolve_first_wave(ui: Control) -> void:
	ui._on_start_wave()
	if not ui.assault_ready_reason.is_empty():
		ui._on_playtest_primary_action()
	if not ui.battle_paused:
		ui._toggle_battle_pause()
	var guard: int = 0
	while ui.keep.wave_active and guard < 12:
		ui._on_advance_wave()
		guard += 1
	_check(guard < 12, "recovery fixture should resolve phase one inside the deterministic guard")

func _brief_fingerprint(ui: Control) -> Dictionary:
	return {
		"heading": ui.recovery_brief_panel.heading_label.text,
		"changed": ui.recovery_brief_panel.changed_label.text,
		"matters": ui.recovery_brief_panel.matters_label.text,
		"next": ui.recovery_brief_panel.next_label.text,
		"priority": ui.recovery_brief_panel.priority_label.text
	}

func _initialize() -> void:
	_remove_test_files()
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	_configure_paths(ui)
	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	_resolve_first_wave(ui)
	await process_frame
	await process_frame

	_check(ui.screen == "results" and ui.keep.repair_interval_active, "phase one should enter inter-wave Recovery")
	_check(ui.recovery_brief_panel.visible and not ui.terminal_debrief_panel.visible, "Recovery should use its compact brief instead of terminal debrief")
	_check(String(ui.recovery_brief_panel.heading_label.text).contains("2 ACTIONS LEFT") and String(ui.recovery_brief_panel.heading_label.text).contains("MATERIALS"), "Recovery header should expose its bounded action and material budgets")
	_check(String(ui.recovery_brief_panel.changed_label.text).contains("WHAT CHANGED") and String(ui.recovery_brief_panel.changed_label.text).contains("Phase 1"), "Recovery should summarize the resolved phase")
	_check(String(ui.recovery_brief_panel.matters_label.text).contains("WHY IT MATTERS"), "Recovery should explain the most consequential current condition")
	_check(String(ui.recovery_brief_panel.next_label.text).contains("NEXT PRESSURE") and String(ui.recovery_brief_panel.next_label.text).contains("Distributed Sabotage"), "Recovery should preview the next authored doctrine")
	_check(String(ui.recovery_brief_panel.priority_label.text).contains("FIRST PRIORITY") and String(ui.recovery_brief_panel.priority_label.text).contains("TRADE-OFF"), "Recovery should name one advisory priority and its cost")
	_check(String(ui.recovery_stage_label.text).contains("CHOICE 1 OF 2") and ui.recovery_actions_panel.visible, "the command rail should retain exact recovery actions beneath the new hierarchy")

	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_recovery_brief()
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "refreshing the Recovery brief should not mutate authoritative state")
	var focus: Control = get_root().gui_get_focus_owner()
	_check(focus in [ui.recovery_room_button, ui.recovery_piece_button, ui.recovery_assign_button, ui.recovery_clear_button, ui.finish_interval_button] and not focus.disabled, "Recovery should focus its first legal command rather than descriptive text")

	var expected_brief: Dictionary = _brief_fingerprint(ui)
	ui._on_save()
	var restored: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(restored)
	await process_frame
	await process_frame
	_configure_paths(restored)
	restored._on_continue_saved_run()
	await process_frame
	_check(restored.screen == "results" and restored.recovery_brief_panel.visible, "loading an inter-wave save should restore the Recovery hierarchy")
	_check(_brief_fingerprint(restored) == expected_brief, "recovery save/load should derive the same explanatory brief")
	restored._set_ui_scale(2)
	await process_frame
	_check(restored.gameplay_columns.vertical and restored.recovery_brief_panel.size.x >= 780.0, "125 percent scale should retain the Recovery brief while stacking the command rail")

	restored.keep.repair_interval_active = false
	restored._refresh_recovery_brief()
	_check(not restored.recovery_brief_panel.visible, "Recovery brief should disappear outside an active inter-wave interval")

	ui.queue_free()
	restored.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P37 recovery hierarchy: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
