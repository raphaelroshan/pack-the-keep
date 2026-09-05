extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _inside_scroll_view(control: Control, scroll: ScrollContainer) -> bool:
	var rect: Rect2 = control.get_global_rect()
	var viewport_rect: Rect2 = scroll.get_global_rect()
	return control.is_visible_in_tree() and rect.position.y >= viewport_rect.position.y - 1.0 and rect.end.y <= viewport_rect.end.y + 1.0

func _apply_layout(ui: Control, viewport_size: Vector2i, scale_index: int) -> void:
	root.content_scale_factor = 1.0
	root.size = viewport_size
	ui.ui_scale_index = scale_index
	ui._apply_ui_scale()
	await process_frame
	await process_frame

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false

	await _apply_layout(ui, Vector2i(1280, 720), 1)
	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	ui._on_start_wave()
	await process_frame
	await process_frame
	var state_before: String = JSON.stringify(ui.keep.serialize())
	_check(ui.battle_board_first_active and ui.battle_focus_panel.is_visible_in_tree(), "1280x720 Assault should show the board-first threat dossier")
	_check(not ui.input_help_label.visible and not ui.battle_inspection_label.visible and not ui.response_preview_label.visible, "compact Assault should defer duplicate command and response prose")
	_check(not ui.inspect_enemy_button.visible and not ui.inspection_panel.is_visible_in_tree(), "compact Assault should not repeat the already-focused threat in a second inspector")
	for control: Control in [ui.battle_state_label, ui.pause_button, ui.commander_ability_button, ui.battle_focus_panel, ui.battle_tactical_button]:
		_check(_inside_scroll_view(control, ui.command_scroll), "core Assault control should fit without rail scrolling: %s" % control.name)
	_check(ui.command_scroll.scroll_vertical == 0 and ui.page_scroll.scroll_vertical == 0, "Assault should open with both scroll surfaces at the top")
	_check(String(ui.battle_focus_panel.condition_label.text).contains("HEALTH 8/8") and String(ui.battle_focus_panel.target_label.text).contains("TARGET — Not locked yet") and String(ui.battle_focus_panel.target_label.text).contains("ROUTE — Gate Road"), "the dossier should expose health, target-lock state, and route")
	_check(String(ui.battle_focus_panel.timing_label.text).contains("next T2") and String(ui.battle_focus_panel.response_label.text).contains("Pike Squad") and String(ui.battle_focus_panel.counter_label.text).contains("Lockdown available"), "the dossier should expose next strike, committed defender, counter, and intervention")
	_check(String(ui.battle_focus_panel.action_label.text).begins_with("FORECAST —"), "tick-zero dossier should lead to the explicit start action")
	_check(JSON.stringify(ui.keep.serialize()) == state_before, "rendering the dossier must not mutate authoritative state")

	ui._toggle_battle_pause()
	ui.battle_paused = true
	ui._on_advance_wave()
	await process_frame
	await process_frame
	_check(ui.keep.battle_step == 1 and String(ui.battle_focus_panel.action_label.text).begins_with("PAUSED —"), "post-contact pause should update the dossier's next action")
	_check(String(ui.battle_focus_panel.condition_label.text).contains("HEALTH 3/8") and String(ui.battle_focus_panel.response_label.text).contains("projected 0 hp"), "post-contact dossier should reflect authoritative damage and next response")
	ui._on_advance_wave()
	await process_frame
	_check(String(ui.enemy_label.text).contains("Narrow Gate") and not String(ui.enemy_label.text).contains("narrow_gate_"), "the active-threat roster should use the player-facing target name instead of an internal instance ID: %s" % String(ui.enemy_label.text))
	var before_resize: String = JSON.stringify(ui.keep.serialize())
	await _apply_layout(ui, Vector2i(1600, 900), 1)
	_check(ui.battle_board_first_active and _inside_scroll_view(ui.battle_focus_panel, ui.command_scroll), "1600x900 should retain the complete focused-threat dossier")
	_check(JSON.stringify(ui.keep.serialize()) == before_resize, "responsive dossier layout must not mutate combat state")

	await _apply_layout(ui, Vector2i(1280, 720), 3)
	_check(ui.gameplay_columns.vertical and not ui.battle_focus_panel.visible, "150 percent text should retain the established detailed stacked Assault")
	_check(ui.battle_inspection_label.visible and ui.response_preview_label.visible and ui.inspect_enemy_button.visible, "large-text fallback should preserve the full inspection path")

	root.content_scale_factor = 1.0
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P80 Assault threat dossier: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
