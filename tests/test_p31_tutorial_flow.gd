extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _enemy_index(ui: Control, enemy_id: String) -> int:
	for index in range(ui.keep.enemies.size()):
		if String(ui.keep.enemies[index].get("enemy_id", "")) == enemy_id:
			return index
	return -1

func _resolve_wave(ui: Control) -> void:
	if not ui.battle_paused:
		ui._toggle_battle_pause()
	var guard: int = 0
	while ui.keep.wave_active and guard < 10:
		guard += 1
		ui._on_advance_wave()
	_check(guard < 10, "tutorial wave should resolve inside the deterministic guard")

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false

	_check(String(ui.quick_test_button.text) == "New Game", "main menu should use game-facing New Game language")
	_check(ui.title_learn_button != null and String(ui.title_learn_button.text) == "Learn to Play", "main menu should expose a replayable tutorial")
	ui._start_tutorial()
	_check(ui.tutorial.active and ui.tutorial.current_id() == "intro_keep", "First Watch should begin with the fortress introduction")
	_check(ui.tutorial_panel.visible and String(ui.tutorial_speaker_label.text).contains("CASTELLAN"), "tutorial should use an in-world coach card")
	ui._on_tutorial_continue()
	ui._on_tutorial_continue()
	ui._on_tutorial_continue()
	_check(ui.screen == "setup" and ui.tutorial.current_id() == "war_council", "introduction should lead to the War Council")
	_check(ui.commander_option.disabled and ui.scenario_option.disabled, "strict tutorial should lock its commander and scenario")

	ui._on_confirm_setup()
	_check(ui.screen == "preparation" and ui.tutorial.current_id() == "inspect_gate", "War Council confirmation should enter the fortress lesson")
	var gate: Dictionary = ui.keep.room_definition("gate")
	ui._on_map_clicked(String(gate.get("floor", "ground")), gate.get("origin", Vector2i.ZERO))
	_check(ui.tutorial.current_id() == "open_pike_line", "inspecting Gate should advance to the pack lesson")
	ui._on_open_pack()
	_check(ui.tutorial.current_id() == "place_pike", "opening Pike Line should advance to placement")
	ui._on_map_clicked("ground", Vector2i(0, 3))
	_check(ui.tutorial.current_id() == "place_gate" and ui.keep.pieces.size() == 1, "Pike Squad placement should be authoritative")
	ui._on_map_clicked("ground", Vector2i(2, 5))
	_check(ui.tutorial.current_id() == "inspect_pike" and ui.keep.pieces.size() == 2, "Narrow Gate placement should complete the starter line")
	ui._on_map_clicked("ground", Vector2i(0, 3))
	_check(ui.tutorial.current_id() == "forecast" and String(ui.inspector_label.text).contains("Pike Squad"), "unit inspection should explain Pike Squad")
	ui._on_tutorial_continue()
	ui._on_playtest_primary_action()
	_check(ui.keep.wave_active and ui.battle_paused and ui.tutorial.current_id() == "inspect_raider", "first assault should open paused for enemy analysis")
	ui._select_enemy_focus(_enemy_index(ui, "raider"), "tutorial test")
	_check(ui.tutorial.current_id() == "resume_first", "Raider inspection should unlock resume")
	ui._on_playtest_primary_action()
	_check(not ui.battle_paused and ui.tutorial.current_id() == "observe_first", "resuming should enter the observation lesson")
	_resolve_wave(ui)
	_check(ui.screen == "results" and ui.tutorial.current_id() == "repair_defender", "phase one should end in the defender-repair lesson")
	_check(bool(ui.keep.recovery_action_preview("repair_piece", ui._selected_piece_instance()).get("ok", false)), "phase one should leave a real damaged defender to repair")
	var repaired_piece_id: String = ui._selected_piece_instance()
	var piece_health_before: int = int(ui.keep.pieces[repaired_piece_id].get("health", 0))
	ui._on_repair_piece()
	var piece_repair_effect: Dictionary = ui.keep_canvas.repair_effect_snapshot()
	_check(bool(piece_repair_effect.get("active", false)) and String(piece_repair_effect.get("target_kind", "")) == "piece" and String(piece_repair_effect.get("target_id", "")) == repaired_piece_id, "successful defender repair should produce localized feedback on that defender")
	_check(int(piece_repair_effect.get("amount", 0)) == int(ui.keep.pieces[repaired_piece_id].get("health", piece_health_before)) - piece_health_before and bool(piece_repair_effect.get("texture_loaded", false)), "defender repair feedback should expose the authoritative restored amount and a loadable texture")
	_check(ui.tutorial.current_id() == "assign_gate", "successful defender repair should advance to assignment")
	ui._on_assign_piece()
	_check(ui.tutorial.current_id() == "release_second", "Pike assignment should advance to phase two")
	ui._on_playtest_primary_action()
	_check(ui.keep.wave_index == 2 and ui.battle_paused and ui.tutorial.current_id() == "inspect_sapper", "phase two should open paused on the Sapper lesson")
	ui._select_enemy_focus(_enemy_index(ui, "sapper"), "tutorial test")
	ui._on_playtest_primary_action()
	_resolve_wave(ui)
	var damaged_room_id: String = ui._selected_id(ui.room_option)
	_check(ui.tutorial.current_id() == "repair_room" and ui.keep.room_condition(damaged_room_id) < 100, "Sapper phase should lead to a real room repair")
	var room_condition_before: int = ui.keep.room_condition(damaged_room_id)
	ui._on_repair_room()
	var room_repair_effect: Dictionary = ui.keep_canvas.repair_effect_snapshot()
	_check(bool(room_repair_effect.get("active", false)) and String(room_repair_effect.get("target_kind", "")) == "room" and String(room_repair_effect.get("target_id", "")) == damaged_room_id, "successful room repair should produce localized feedback on that room")
	_check(int(room_repair_effect.get("amount", 0)) == ui.keep.room_condition(damaged_room_id) - room_condition_before and bool(room_repair_effect.get("texture_loaded", false)), "room repair feedback should expose the authoritative restored amount and a loadable texture")
	var serialized_after_repair: String = JSON.stringify(ui.keep.serialize())
	ui.keep_canvas.repair_effect_snapshot()
	_check(JSON.stringify(ui.keep.serialize()) == serialized_after_repair, "reading repair presentation feedback should not mutate authoritative state")
	_check(ui.tutorial.current_id() == "release_final", "Workshop repair should unlock the final phase")
	ui._on_playtest_primary_action()
	_check(ui.keep.wave_index == 3 and ui.battle_paused and ui.tutorial.current_id() == "inspect_climber", "final phase should open paused on the bypass lesson")
	ui._select_enemy_focus(_enemy_index(ui, "climber"), "tutorial test")
	ui._on_use_ability()
	_check(ui.tutorial.current_id() == "resume_final" and ui.keep.lockdown_used, "Lockdown should be a real required command")
	ui._on_playtest_primary_action()
	_resolve_wave(ui)
	_check(ui.keep.last_outcome != "collapse" and ui.tutorial.current_id() == "complete", "prescribed First Watch should finish without collapse")
	_check(ui.terminal_debrief_panel.visible and String(ui.terminal_debrief_panel.primary_button.text) == "COMPLETE FIRST WATCH", "Final Debrief should present one clear tutorial victory action")
	_check(not ui.metrics_label.visible and not ui.log_label.visible, "normal game UI should hide diagnostic metrics and raw event feed")
	ui.terminal_debrief_panel.primary_button.pressed.emit()
	_check(ui.tutorial_completed and not ui.tutorial.active and ui.screen == "setup", "finishing First Watch should persist completion and return to War Council")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P31 First Watch tutorial flow: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
