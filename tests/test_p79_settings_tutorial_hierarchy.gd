extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _inside_scroll_view(control: Control, scroll: ScrollContainer) -> bool:
	var rect: Rect2 = control.get_global_rect()
	var viewport_rect: Rect2 = scroll.get_global_rect()
	return control.is_visible_in_tree() and rect.position.x >= viewport_rect.position.x - 1.0 and rect.end.x <= viewport_rect.end.x + 1.0 and rect.position.y >= viewport_rect.position.y - 1.0 and rect.end.y <= viewport_rect.end.y + 1.0

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
	var state_before: String = JSON.stringify(ui.keep.serialize())
	ui._on_open_settings()
	await process_frame
	await process_frame
	_check(ui.screen == "settings" and ui.settings_hub_panel.visible and not ui.command_panel.visible, "Settings should own a dedicated main surface instead of the gameplay command rail")
	_check(not ui.settings_columns.vertical and ui.settings_columns.get_child_count() == 3, "1280x720 Settings should use three purpose-led columns")
	for group: Control in [ui.settings_readability_group, ui.settings_display_group, ui.settings_battle_group, ui.settings_input_group, ui.settings_session_group]:
		_check(_inside_scroll_view(group, ui.page_scroll), "every Settings group should fit in the 1280x720 first viewport: %s" % group.name)
	for control: Control in [ui.contrast_button, ui.reduced_motion_button, ui.ui_scale_button, ui.mute_button, ui.window_mode_button, ui.resolution_button, ui.effects_volume_button, ui.event_feed_button, ui.auto_pause_button, ui.rebind_action_option, ui.rebind_button, ui.reset_bindings_button, ui.local_metrics_button, ui.local_metrics_export_button, ui.settings_back_button]:
		_check(_inside_scroll_view(control, ui.page_scroll), "Settings control should be visible without scrolling: %s" % control.name)
	_check(ui.page_scroll.scroll_vertical == 0 and root.gui_get_focus_owner() == ui.ui_scale_button, "Settings should open at the top with UI scale focused")
	_check(JSON.stringify(ui.keep.serialize()) == state_before, "opening and laying out Settings must not mutate authoritative state")

	await _apply_layout(ui, Vector2i(1600, 900), 1)
	_check(not ui.settings_columns.vertical and _inside_scroll_view(ui.settings_back_button, ui.page_scroll), "1600x900 should retain the complete three-column Settings surface")

	await _apply_layout(ui, Vector2i(1280, 720), 3)
	_check(ui.settings_columns.vertical, "150 percent text should stack Settings groups")
	_check(ui.settings_hub_panel.get_global_rect().end.x <= root.size.x + 1.0, "large-text Settings should remain horizontally in bounds")

	await _apply_layout(ui, Vector2i(1280, 720), 1)
	ui._on_close_settings()
	ui._start_tutorial()
	await process_frame
	await process_frame
	var tutorial_state_before: String = JSON.stringify(ui.keep.serialize())
	_check(ui.screen == "title" and ui.tutorial_scope_row.visible, "First Watch should begin with its lesson scope visible")
	_check(String(ui.tutorial_stage_label.text) == "FIRST WATCH · BRIEFING 1 OF 3", "First Watch should show briefing progress")
	_check(not ui.tutorial_help_button.visible and ui.tutorial_continue_button.visible and ui.tutorial_skip_button.visible, "passive briefing steps should show only Continue and Skip Tutorial")
	_check(_inside_scroll_view(ui.tutorial_panel, ui.page_scroll), "the complete 1280x720 First Watch briefing should fit without scrolling")
	_check(ui.tutorial_panel.custom_minimum_size.x <= 920.0 and is_equal_approx(ui.art_banner.custom_minimum_size.y, 190.0), "title tutorial should use the centered briefing frame and expanded keep banner")

	ui._on_tutorial_continue()
	_check(String(ui.tutorial_stage_label.text) == "FIRST WATCH · BRIEFING 2 OF 3", "resource briefing should advance the visible progress marker")
	ui._on_tutorial_continue()
	_check(String(ui.tutorial_stage_label.text) == "FIRST WATCH · BRIEFING 3 OF 3", "defense-cycle briefing should complete the visible progress marker")
	ui._on_tutorial_continue()
	await process_frame
	await process_frame
	_check(ui.screen == "setup" and not ui.tutorial_scope_row.visible, "interactive tutorial steps should return space to the active game screen")
	_check(String(ui.tutorial_stage_label.text) == "FIRST WATCH · WAR COUNCIL", "interactive tutorial should name its current phase")
	_check(ui.tutorial_help_button.visible and String(ui.tutorial_help_button.text) == "Refocus Objective", "interactive tutorial should offer a truthful focus-recovery action")
	_check(_inside_scroll_view(ui.setup_confirm_button, ui.page_scroll), "tutorial War Council should keep Enter Keep visible")
	_check(JSON.stringify(ui.keep.serialize()) == tutorial_state_before, "tutorial framing and passive briefing steps must not mutate authoritative state")

	root.content_scale_factor = 1.0
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P79 Settings and tutorial hierarchy: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
