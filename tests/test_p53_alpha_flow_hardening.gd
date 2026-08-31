extends SceneTree

const TEST_SAVE := "user://pack_the_keep_p53_flow.save"
const TEST_TEMP := "user://pack_the_keep_p53_flow.save.tmp"
const TEST_BACKUP := "user://pack_the_keep_p53_flow.save.bak"

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _remove_test_files() -> void:
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		return
	for path in [TEST_SAVE, TEST_TEMP, TEST_BACKUP]:
		if FileAccess.file_exists(path):
			directory.remove(path.get_file())

func _inside_horizontal_viewport(control: Control) -> bool:
	var rect: Rect2 = control.get_global_rect()
	return rect.position.x >= -1.0 and rect.end.x <= float(root.size.x) + 1.0

func _resolve_wave(ui: Control) -> void:
	if not ui.assault_ready_reason.is_empty():
		ui._toggle_battle_pause()
	while ui.keep.wave_active:
		ui._on_advance_wave()

func _save_reload_parity(ui: Control, label: String) -> void:
	var expected: Variant = JSON.parse_string(JSON.stringify(ui.keep.serialize()))
	ui._on_save()
	_check(FileAccess.file_exists(TEST_SAVE), "%s should write an isolated atomic save" % label)
	ui.keep.reset_run(9191)
	ui._on_load()
	var restored: Variant = JSON.parse_string(JSON.stringify(ui.keep.serialize()))
	_check(restored == expected, "%s should restore equivalent authoritative state" % label)
	_check(not FileAccess.file_exists(TEST_TEMP) and not FileAccess.file_exists(TEST_BACKUP), "%s should leave no temporary or backup file after a clean save" % label)

func _initialize() -> void:
	_remove_test_files()
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui.save_path = TEST_SAVE
	ui.save_temp_path = TEST_TEMP
	ui.save_backup_path = TEST_BACKUP

	root.content_scale_factor = 1.0
	root.size = Vector2i(2560, 1440)
	ui.ui_scale_index = 3
	ui._apply_ui_scale()
	ui._toggle_contrast()
	ui._toggle_reduced_motion()
	ui._toggle_mute()
	await process_frame
	var untouched_state: String = JSON.stringify(ui.keep.serialize())
	_check(ui.high_contrast and ui.reduced_motion and ui.audio_muted, "large-text accessibility profile should apply together")
	_check(ui.keep_canvas.high_contrast_mode and ui.keep_canvas.reduced_motion_mode, "board presentation should receive accessibility state")
	_check(JSON.stringify(ui.keep.serialize()) == untouched_state, "presentation settings must not mutate authoritative state")

	ui._on_start_custom_setup()
	ui._select_option_metadata(ui.scenario_option, "the_twilight_road")
	ui._on_select_scenario()
	ui._refresh_ui()
	await process_frame
	_check(ui.screen == "setup" and root.gui_get_focus_owner() == ui.setup_confirm_button, "War Council should expose its controller-first commit action")
	_check(String(ui.war_council_choice_panel.summary_label.text).contains("final pressure") and String(ui.war_council_choice_panel.summary_label.text).contains("preparation focus"), "War Council should disclose the seeded adaptation")

	ui._on_confirm_setup()
	ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	for pack_id in ["road_wardens", "crossbow_watch"]:
		ui.keep.open_pack(pack_id)
	for placement in [
		["stake_line", Vector2i(1, 2), "ground"],
		["hook_guard", Vector2i(4, 3), "ground"],
		["crossbow_patrol", Vector2i(1, 1), "upper"],
		["watch_banner", Vector2i(4, 1), "upper"],
	]:
		ui.keep.place_piece(placement[0], placement[1], placement[2])
	ui._refresh_ui()
	await process_frame
	_check(ui.screen == "preparation" and _inside_horizontal_viewport(ui.keep_canvas), "large-text Preparation should keep the fortress horizontally contained")

	ui._on_start_wave()
	await process_frame
	_check(ui.screen == "battle" and ui.battle_paused and not ui.assault_ready_reason.is_empty(), "Battle should open at the explicit readiness beat")
	_check(root.gui_get_focus_owner() == ui.pause_button, "Battle readiness should focus the primary controller action")
	_check(ui.last_cue_id == "warning" and String(ui.feedback_cue_label.text).contains("WARNING"), "muted assault start should retain a visible semantic warning")
	_resolve_wave(ui)
	await process_frame
	_check(ui.screen == "results" and ui.keep.repair_interval_active and ui.keep.wave_index == 1, "phase one should enter ordinary Recovery")
	_save_reload_parity(ui, "ordinary recovery")
	ui._refresh_ui()
	ui._on_finish_interval()
	_resolve_wave(ui)
	await process_frame
	_check(ui.screen == "results" and ui.keep.active_event_id == "twilight_crossroads", "phase two should enter the authored route decision")
	_save_reload_parity(ui, "authored recovery decision")
	ui._refresh_ui()
	await process_frame
	ui._focus_screen_control()
	_check(root.gui_get_focus_owner() == ui.authored_event_choice_buttons[0], "the restored route decision should retain a controller-reachable first choice")
	ui._on_authored_event_choice_id("carry_lamp_oil")
	_check(ui.keep.repair_actions_remaining == 1 and ui.recovery_actions_panel.visible, "route preparation should return to ordinary Recovery with one action")
	ui._on_finish_interval()
	_check(ui.screen == "battle" and ui.keep.wave_index == 3, "Recovery completion should enter the final assault")
	_check(ui.keep.enemies.size() == 4, "the final assault should retain its disclosed four-threat budget")
	_resolve_wave(ui)
	await process_frame
	await process_frame

	_check(ui.screen == "results" and ui.terminal_debrief_panel.visible, "the full flow should reach terminal Results")
	_check(ui.last_cue_id == "hold" and String(ui.feedback_cue_label.text).contains("HOLD"), "muted terminal success should retain a visible semantic outcome cue")
	var mastery: String = String(ui.terminal_debrief_panel.causal_label.text)
	_check(mastery.contains("final pressure") and mastery.contains("preparation focus") and mastery.contains("RECOVERY BRANCH") and mastery.contains("FORGONE PREPARATION"), "terminal Results should retain seed and recovery mastery")
	_check(ui.gameplay_columns.vertical and _inside_horizontal_viewport(ui.terminal_debrief_panel), "large-text 1440p terminal Results should stack without horizontal clipping")
	ui._focus_screen_control()
	await process_frame
	var page_rect: Rect2 = ui.page_scroll.get_global_rect()
	var replay_rect: Rect2 = ui.terminal_debrief_panel.primary_button.get_global_rect()
	_check(root.gui_get_focus_owner() == ui.terminal_debrief_panel.primary_button, "terminal replay should own controller focus")
	_check(replay_rect.position.y >= page_rect.position.y and replay_rect.end.y <= page_rect.end.y, "terminal replay action should be visible after focus scrolling")

	root.content_scale_factor = 1.0
	ui.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P53 alpha flow hardening: PASS (large text, accessibility, focus, audio, and two save boundaries)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
