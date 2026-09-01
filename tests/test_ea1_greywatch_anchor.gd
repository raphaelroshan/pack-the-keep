extends SceneTree

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

func _resolve_wave(ui: Control) -> void:
	if not ui.assault_ready_reason.is_empty():
		ui._on_playtest_primary_action()
		await process_frame
	if not ui.battle_paused:
		ui._toggle_battle_pause()
	var guard: int = 0
	while ui.keep.wave_active and guard < 12:
		ui._on_advance_wave()
		await process_frame
		guard += 1
	_check(guard < 12, "Greywatch assault should resolve inside the deterministic guard")

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false

	root.content_scale_factor = 1.0
	root.size = Vector2i(1280, 720)
	ui.ui_scale_index = 2
	ui._apply_ui_scale()
	ui._on_start_custom_setup()
	ui._select_option_metadata(ui.commander_option, "castellan")
	ui.keep.select_commander("castellan")
	ui._select_option_metadata(ui.scenario_option, "gatehouse_lock")
	ui.keep.select_scenario("gatehouse_lock")
	ui._refresh_ui()
	await process_frame

	_check(ui.screen == "setup" and ui.gameplay_columns.vertical, "PTK-EA-1 should retain the responsive 1280x720 War Council")
	_check(root.gui_get_focus_owner() == ui.setup_confirm_button, "PTK-EA-1 War Council should focus Enter Keep for controller use")
	_check(String(ui.scenario_preview_label.text).contains("Assault phases: 3"), "Greywatch briefing should disclose the complete three-phase journey")

	var greywatch_scenarios: Array[String] = []
	for scenario_id in ui.keep.scenario_ids():
		var scenario: Dictionary = ui.keep.scenario_definition(scenario_id)
		if String(scenario.get("keep_id", "")) == "greywatch_keep":
			greywatch_scenarios.append(scenario_id)
			_check(scenario.get("wave_plans", []).size() == 3, "%s should retain three authored assault phases" % scenario_id)
	_check(greywatch_scenarios.size() >= 6, "Greywatch should exceed the six-scenario Early Access keep floor")
	var keep_definition: Dictionary = ui.keep.keep_definition("greywatch_keep")
	_check(keep_definition.get("rooms", {}).size() == 9, "Greywatch should retain its nine-room graph")
	_check(String(keep_definition.get("spatial_rule", {}).get("id", "")) == "compact_adjacency", "Greywatch should retain its compact-adjacency question")
	_check(int(keep_definition.get("recovery_profile", {}).get("room_repair_condition", 0)) == 30, "Greywatch should retain its deep-repair identity")

	ui._on_confirm_setup()
	ui._on_recommended_layout()
	await process_frame
	var board: Dictionary = ui.keep_canvas.board_presentation_snapshot()
	_check(ui.screen == "preparation" and ui.keep.pieces.size() >= 2, "recommended setup should enter Preparation with a visible defensive answer")
	_check(bool(board.get("authored_actor_assets", false)) and bool(board.get("authored_room_accents", false)) and bool(board.get("authored_effect_assets", false)), "Greywatch should expose its complete authored board-scale visual language")
	_check(not bool(board.get("temporary_actor_assets", true)) and not bool(board.get("temporary_room_accents", true)) and not bool(board.get("temporary_combat_effects", true)), "Greywatch should not depend on borrowed board visuals")

	ui._on_start_wave()
	await process_frame
	_check(ui.screen == "battle" and ui.battle_paused and not ui.assault_ready_reason.is_empty(), "the first assault should open on a readable tick-zero warning")
	for phase in range(1, 4):
		await _resolve_wave(ui)
		_check(ui.screen == "results", "phase %d should produce a Recovery or terminal Results screen" % phase)
		if phase < 3:
			_check(ui.keep.repair_interval_active and ui.keep.repair_actions_remaining > 0, "phase %d should produce a meaningful recovery budget" % phase)
			var continue_button: Button = _find_button(ui, "END LULL — RELEASE PHASE %d/3" % (phase + 1))
			_check(continue_button != null, "phase %d Recovery should expose the next assault action" % phase)
			if continue_button != null:
				continue_button.pressed.emit()
				await process_frame
		else:
			_check(not ui.keep.has_next_wave() and ui.terminal_debrief_panel.visible, "the third assault should end at the complete terminal debrief")
			_check(_find_button(ui, "REVIEW SETUP — PLAY AGAIN") != null, "terminal Results should offer a replay path")

	root.size = Vector2i(1600, 900)
	ui.ui_scale_index = 1
	ui._apply_ui_scale()
	await process_frame
	_check(not ui.gameplay_columns.vertical and ui.terminal_debrief_panel.get_global_rect().end.x <= root.size.x + 1.0, "the terminal Greywatch report should retain the 1600x900 two-column composition")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("PTK-EA-1 Greywatch anchor: PASS (responsive setup, three assaults, two recoveries, terminal replay)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
