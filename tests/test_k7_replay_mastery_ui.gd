extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _resolve_phase(ui: Control) -> void:
	if not ui.assault_ready_reason.is_empty():
		ui._on_playtest_primary_action()
	if not ui.battle_paused:
		ui._toggle_battle_pause()
	while ui.keep.wave_active:
		ui._on_advance_wave()

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._on_start_custom_setup()
	ui._select_option_metadata(ui.scenario_option, "the_cut_standard")
	ui._on_select_scenario()
	ui._refresh_ui()
	await process_frame
	var variation: Dictionary = ui.keep.scenario_variation_preview()
	_check(String(ui.war_council_choice_panel.summary_label.text).contains("OPENING PRESSURE — %s:" % String(variation.get("label", ""))), "War Council should state the concrete opening variation before entry")

	ui._on_confirm_setup()
	ui.keep.open_pack("crossbow_watch")
	ui.keep.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
	ui.keep.place_piece("watch_banner", Vector2i(4, 1), "upper")
	ui._on_start_wave()
	_resolve_phase(ui)
	while ui.keep.has_next_wave():
		if ui.keep.repair_interval_active:
			for instance_id_value in ui.keep.pieces.keys():
				var instance_id: String = String(instance_id_value)
				if float(ui.keep.pieces[instance_id].get("condition", 1.0)) < 1.0 and ui.keep.materials >= 6:
					ui.keep.repair_piece(instance_id)
					break
		ui._on_finish_interval()
		_resolve_phase(ui)
	await process_frame
	ui._refresh_terminal_debrief()
	var mastery_text: String = String(ui.terminal_debrief_panel.causal_label.text)
	_check(mastery_text.contains("THIS ASSAULT") and mastery_text.contains("WHAT THE PLAN COVERED") and mastery_text.contains("RECOVERY CHOICES") and mastery_text.contains("DEFENSE BROUGHT"), "terminal debrief should lead into a complete replay comparison")
	_check(ui.terminal_debrief_panel.replay_label.get_parent().get_index() < ui.terminal_debrief_panel.timeline_box.get_index(), "the concrete replay experiment should appear before chronology")
	_check(String(ui.terminal_debrief_panel.replay_label.text).contains("Gate Assault"), "terminal replay action should address uncovered pressure")

	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	root.size = Vector2i(1280, 720)
	ui.ui_scale_index = 3
	ui._apply_ui_scale()
	ui._toggle_contrast()
	ui._toggle_reduced_motion()
	await process_frame
	await process_frame
	_check(ui.terminal_debrief_panel.visible and ui.terminal_debrief_panel.primary_button.is_visible_in_tree(), "large-text Results should keep mastery evidence and its replay action reachable")
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "K7 responsive and accessibility presentation must not mutate authoritative state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("K7 replay mastery UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
