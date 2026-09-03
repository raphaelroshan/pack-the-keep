extends SceneTree

const TEST_SAVE := "user://pack_the_keep_p37_recovery_test.json"
const TEST_TEMP := "user://pack_the_keep_p37_recovery_test.json.tmp"
const TEST_BACKUP := "user://pack_the_keep_p37_recovery_test.json.bak"

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _inside_viewport(control: Control, viewport_size: Vector2) -> bool:
	var rect: Rect2 = control.get_global_rect()
	return rect.position.x >= -1.0 and rect.end.x <= viewport_size.x + 1.0

func _inside_scroll_view(control: Control, scroll: ScrollContainer) -> bool:
	var rect: Rect2 = control.get_global_rect()
	var viewport_rect: Rect2 = scroll.get_global_rect()
	return rect.position.y >= viewport_rect.position.y - 1.0 and rect.end.y <= viewport_rect.end.y + 1.0

func _apply_layout(ui: Control, viewport_size: Vector2i, scale_index: int) -> void:
	root.content_scale_factor = 1.0
	root.size = viewport_size
	ui.ui_scale_index = scale_index
	ui._apply_ui_scale()
	await process_frame
	await process_frame

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
	_check(not ui.recovery_piece_button.disabled and String(ui.recovery_piece_card_title.text).contains("Narrow Gate"), "Recovery entry should select the brief's damaged defender priority without applying a repair")

	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_recovery_brief()
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "refreshing the Recovery brief should not mutate authoritative state")
	var focus: Control = get_root().gui_get_focus_owner()
	_check(focus in [ui.recovery_room_button, ui.recovery_piece_button, ui.recovery_assign_button, ui.recovery_clear_button, ui.finish_interval_button] and not focus.disabled, "Recovery should focus its first legal command rather than descriptive text")

	await _apply_layout(ui, Vector2i(1280, 720), 1)
	ui._focus_screen_control()
	await process_frame
	var recovery_snapshot: Dictionary = ui._responsive_layout_snapshot()
	_check(not ui.gameplay_columns.vertical and bool(recovery_snapshot.get("recovery_board_first", false)), "1280x720 Recovery should use its board-first two-column composition: %s" % JSON.stringify(recovery_snapshot))
	_check(_inside_viewport(ui.keep_canvas, Vector2(root.size)) and _inside_viewport(ui.command_panel, Vector2(root.size)), "board-first Recovery should keep fortress and command rail horizontally visible")
	var board_rect: Rect2 = ui.keep_canvas.get_global_rect()
	var page_rect: Rect2 = ui.page_scroll.get_global_rect()
	_check(board_rect.intersection(page_rect).size.y >= board_rect.size.y * 0.95, "board-first Recovery should expose at least 95 percent of the damaged fortress")
	var legal_action: Control = ui._first_legal_recovery_control()
	_check(ui.recovery_brief_panel.is_visible_in_tree() and legal_action != null and legal_action != ui.finish_interval_button and _inside_scroll_view(legal_action, ui.command_scroll), "board-first Recovery should expose its causal brief and a useful legal recovery action together")
	_check(root.gui_get_focus_owner() == legal_action and ui.page_scroll.scroll_vertical == 0, "board-first Recovery should keep the page at the fortress while focusing the first legal rail action")
	ui._refresh_ui()
	_check(not ui.main_subtitle_label.visible and not ui.guidance_label.visible and not ui.playtest_button.visible and not ui.playtest_status_label.visible, "normal board-first Recovery should remove repeated main-column instructions and the duplicate End Lull action")

	var authoritative_before_layout: String = JSON.stringify(ui.keep.serialize())
	await _apply_layout(ui, Vector2i(1600, 900), 2)
	_check(not ui.gameplay_columns.vertical and ui.recovery_board_first_active, "1600x900 at 125 percent should retain the board-first Recovery composition")
	await _apply_layout(ui, Vector2i(1280, 720), 3)
	_check(ui.gameplay_columns.vertical and not ui.recovery_board_first_active, "1280x720 at 150 percent should return Recovery to the stacked composition")
	_check(ui.playtest_button.visible and _inside_viewport(ui.command_panel, Vector2(root.size)), "large-text Recovery should restore the main continuation action and keep the rail horizontally visible")
	_check(JSON.stringify(ui.keep.serialize()) == authoritative_before_layout, "responsive Recovery transitions must not mutate authoritative run state")

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
	restored.tutorial.start()
	restored.tutorial.restore_progress({"tutorial_id": "first_watch", "version": 1, "active": true, "step_id": "release_second", "failure_active": false, "failure_message": ""})
	await _apply_layout(restored, Vector2i(1280, 720), 1)
	restored._refresh_ui()
	restored._focus_tutorial_target("primary_action")
	_check(restored.recovery_board_first_active and restored.playtest_button.is_visible_in_tree() and root.gui_get_focus_owner() == restored.playtest_button, "First Watch should retain its explicit Recovery continuation action and focus target in board-first mode")
	restored.tutorial.stop()

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
