extends SceneTree

const TEST_SAVE := "user://pack_the_keep_p32_terminal.save"
const TEST_TEMP := "user://pack_the_keep_p32_terminal.save.tmp"
const TEST_BACKUP := "user://pack_the_keep_p32_terminal.save.bak"

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _find_button(node: Node, target_text: String) -> Button:
	for child in node.get_children():
		if child is Button and String(child.text) == target_text:
			return child
		var nested: Button = _find_button(child, target_text)
		if nested != null:
			return nested
	return null

func _remove_test_files() -> void:
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		return
	for path in [TEST_SAVE, TEST_TEMP, TEST_BACKUP]:
		if FileAccess.file_exists(path):
			directory.remove(path.get_file())

func _configure_paths(ui: Control) -> void:
	ui.save_path = TEST_SAVE
	ui.save_temp_path = TEST_TEMP
	ui.save_backup_path = TEST_BACKUP
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false

func _resolve_wave(ui: Control) -> void:
	if not ui.assault_ready_reason.is_empty():
		ui._on_playtest_primary_action()
	var guard: int = 0
	while ui.keep.wave_active and guard < 12:
		ui._on_advance_wave()
		guard += 1
	_check(guard < 12, "terminal debrief fixture wave should resolve inside the deterministic guard")

func _reach_terminal(ui: Control) -> void:
	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	ui._on_start_wave()
	_resolve_wave(ui)
	while ui.keep.has_next_wave():
		ui._on_finish_interval()
		_resolve_wave(ui)

func _terminal_fingerprint(ui: Control) -> Dictionary:
	var rooms: Dictionary = {}
	var room_ids: Array[String] = []
	for room_id_value in ui.keep.rooms.keys():
		room_ids.append(String(room_id_value))
	room_ids.sort()
	for room_id in room_ids:
		rooms[room_id] = {"condition": ui.keep.room_condition(room_id), "state": ui.keep.room_state(room_id)}
	var pieces: Dictionary = {}
	var piece_ids: Array[String] = []
	for instance_id_value in ui.keep.pieces.keys():
		piece_ids.append(String(instance_id_value))
	piece_ids.sort()
	for instance_id in piece_ids:
		var piece: Dictionary = ui.keep.pieces[instance_id]
		pieces[instance_id] = {"piece_id": String(piece.get("piece_id", "")), "health": int(piece.get("health", 0)), "max_health": int(piece.get("max_health", 0)), "disabled": bool(piece.get("disabled", false)), "assignment": String(piece.get("assignment", ""))}
	return {"scenario_id": ui.keep.scenario_id, "commander_id": ui.keep.commander_id, "wave_index": ui.keep.wave_index, "last_outcome": ui.keep.last_outcome, "materials": ui.keep.materials, "morale": ui.keep.morale, "breach_level": ui.keep.breach_level, "report": ui.keep.scenario_report(), "rooms": rooms, "pieces": pieces}

func _initialize() -> void:
	_remove_test_files()
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	_configure_paths(ui)

	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	ui._on_start_wave()
	_resolve_wave(ui)
	_check(ui.screen == "results" and ui.keep.has_next_wave(), "fixture should first reach inter-wave Recovery")
	_check(not ui.terminal_debrief_panel.visible and ui.recovery_actions_panel.visible, "inter-wave Recovery should retain its action panel instead of showing the terminal debrief")

	while ui.keep.has_next_wave():
		ui._on_finish_interval()
		_resolve_wave(ui)
	await process_frame
	await process_frame
	_check(ui.screen == "results" and ui._is_terminal_result(), "three resolved phases should reach terminal Results")
	_check(ui.terminal_debrief_panel.visible and not ui.command_panel.visible, "terminal Results should replace the ordinary command rail with the dedicated debrief")
	_check(ui.keep_canvas.visible, "terminal Results should preserve the keep board as visual evidence")
	_check(not ui.recovery_actions_panel.visible and not ui.result_explain_label.visible and not ui.scorecard_label.visible, "terminal Results should not reuse recovery or legacy report composition")
	_check(String(ui.terminal_debrief_panel.outcome_label.text).contains("HOLDS") or String(ui.terminal_debrief_panel.outcome_label.text).contains("ENDURES"), "debrief should acknowledge the final outcome")
	_check(ui.terminal_debrief_panel.timeline_box.get_child_count() == 3, "debrief should show the complete three-phase timeline")
	_check(String(ui.terminal_debrief_panel.causal_label.text).contains("WHAT HELD") and String(ui.terminal_debrief_panel.causal_label.text).contains("WHAT GAVE WAY"), "debrief should expose a causal chain")
	_check(String(ui.terminal_debrief_panel.replay_label.text).contains("TRY NEXT"), "debrief should offer a concrete replay experiment")
	_check(_find_button(ui.terminal_debrief_panel, "REVIEW SETUP — PLAY AGAIN") != null, "debrief should expose one dominant replay action")
	_check(_find_button(ui.terminal_debrief_panel, "Save Result") != null and _find_button(ui.terminal_debrief_panel, "Return to Main Menu") != null, "debrief should expose secondary persistence and exit actions")
	_check(get_root().gui_get_focus_owner() == ui.terminal_debrief_panel.primary_button, "terminal debrief should focus its primary action")

	var before_refresh: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_terminal_debrief()
	_check(JSON.stringify(ui.keep.serialize()) == before_refresh, "rendering the terminal debrief should not mutate authoritative state")
	ui.terminal_debrief_panel.save_button.pressed.emit()
	_check(FileAccess.file_exists(TEST_SAVE), "Save Result should use the existing atomic run-save path")

	var restored: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(restored)
	await process_frame
	await process_frame
	_configure_paths(restored)
	restored._on_continue_saved_run()
	await process_frame
	_check(restored.screen == "results" and restored.terminal_debrief_panel.visible, "loading a terminal save should restore the dedicated debrief")
	_check(JSON.stringify(_terminal_fingerprint(restored)) == JSON.stringify(_terminal_fingerprint(ui)), "terminal save/load should restore the same authoritative outcome, fortress, and report state")
	_check(String(restored.terminal_debrief_panel.replay_label.text) == String(ui.terminal_debrief_panel.replay_label.text), "loaded terminal state should derive the same replay experiment")

	restored._set_ui_scale(2)
	_check(is_equal_approx(get_root().content_scale_factor, 1.25), "terminal debrief should retain supported 125 percent scaling")
	_check(restored.terminal_debrief_panel.custom_minimum_size.x >= 340.0, "scaled debrief should retain a readable bounded width")

	ui.queue_free()
	restored.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P32 terminal debrief: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
