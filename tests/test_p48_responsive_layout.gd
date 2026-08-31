extends SceneTree

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

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false

	_check(ui._fit_window_size(Vector2i(1600, 900), Vector2i(1280, 720)) == Vector2i(1280, 720), "a 1600x900 request should fit proportionally inside a 1280x720 display")
	_check(ui._fit_window_size(Vector2i(2560, 1440), Vector2i(1920, 1080)) == Vector2i(1920, 1080), "a 2560x1440 request should fit proportionally inside a 1920x1080 display")
	_check(ui._fit_window_size(Vector2i(1280, 720), Vector2i(2560, 1440)) == Vector2i(1280, 720), "window fitting should never enlarge an already supported request")

	await _apply_layout(ui, Vector2i(1600, 900), 1)
	ui._on_start_custom_setup()
	await process_frame
	await process_frame
	var wide_snapshot: Dictionary = ui._responsive_layout_snapshot()
	_check(not ui.gameplay_columns.vertical, "1600x900 at 100 percent should retain the intentional two-column composition: %s" % JSON.stringify(wide_snapshot))
	_check(ui.setup_overview_panel.visible, "wide War Council should retain the authored overview when it has room")
	_check(_inside_viewport(ui.gameplay_main_column, Vector2(root.size)), "wide War Council main content should remain horizontally inside the viewport")
	_check(_inside_viewport(ui.command_panel, Vector2(root.size)), "wide War Council command rail should remain horizontally inside the viewport")

	await _apply_layout(ui, Vector2i(1280, 720), 1)
	_check(ui.gameplay_columns.vertical, "1280x720 should stack the main surface and command rail")
	_check(not ui.setup_overview_panel.visible, "stacked War Council should remove the redundant overview from the priority path")
	_check(not ui.war_council_choice_panel.choice_row.vertical, "1280x720 should retain side-by-side choice cards when their content still fits")
	_check(_inside_viewport(ui.gameplay_main_column, Vector2(root.size)), "narrow War Council main content should remain horizontally inside the viewport")
	_check(_inside_viewport(ui.command_panel, Vector2(root.size)), "stacked War Council command rail should remain horizontally inside the viewport")
	_check(ui.setup_confirm_button.is_visible_in_tree(), "the War Council commit action should remain reachable in the stacked flow")
	_check(root.gui_get_focus_owner() == ui.setup_confirm_button, "responsive War Council should preserve its controller-first Enter Keep action")
	_check(_inside_scroll_view(ui.setup_confirm_button, ui.page_scroll), "the 1280x720 War Council commit action should remain inside the first viewport")
	_check(_inside_scroll_view(ui.war_council_choice_panel.commander_next_button, ui.page_scroll) and _inside_scroll_view(ui.war_council_choice_panel.scenario_next_button, ui.page_scroll), "the 1280x720 War Council should expose both next-choice controls without scrolling")
	_check(String(ui.setup_overview_label.text).contains("PAIRING —") and String(ui.setup_overview_label.text).contains("SEED —"), "the prioritized War Council summary should state pairing and seeded pressure")

	await _apply_layout(ui, Vector2i(1280, 720), 3)
	_check(ui.gameplay_columns.vertical and ui.war_council_choice_panel.choice_row.vertical, "150 percent UI scale should use the compact single-column choice-card fallback")
	_check(not ui.menu_buttons.setup.visible and ui.menu_buttons.settings.visible, "large text should hide decorative phase tabs while retaining Settings")
	_check(_inside_viewport(ui.war_council_choice_panel, Vector2(root.size)), "large-text War Council cards should remain horizontally inside the viewport")
	var page_rect: Rect2 = ui.page_scroll.get_global_rect()
	var setup_focus_rect: Rect2 = ui.setup_confirm_button.get_global_rect()
	_check(setup_focus_rect.position.y >= page_rect.position.y and setup_focus_rect.end.y <= page_rect.end.y, "large-text War Council should scroll only enough to keep the focused Enter Keep action visible")

	await _apply_layout(ui, Vector2i(1600, 900), 2)
	_check(ui.gameplay_columns.vertical, "1600x900 at 125 percent should stack before the command rail clips")
	ui._on_start_quick_playtest()
	await process_frame
	ui._on_confirm_setup()
	await process_frame
	await process_frame
	_check(ui.screen == "preparation", "responsive flow should still enter Preparation through the authoritative setup command")
	_check(_inside_viewport(ui.gameplay_main_column, Vector2(root.size)), "Preparation main content should remain horizontally inside the viewport")
	_check(_inside_viewport(ui.command_panel, Vector2(root.size)), "Preparation command rail should remain horizontally inside the viewport")
	_check(ui.playtest_button.is_visible_in_tree() and ui.preparation_pack_offer_panel.is_visible_in_tree(), "Preparation should retain pack context and its primary commit action")
	_check(not ui.main_subtitle_label.visible, "stacked Preparation should remove the repeated generic subtitle")
	_check(String(ui.status_label.text).contains("leads") and String(ui.status_label.text).contains("Greywatch Keep"), "Preparation should carry the commander/defense/keep relationship forward")
	_check(String(ui.preparation_brief_panel.question_label.text).contains(String(ui.keep.scenario_definition(ui.keep.scenario_id).get("question", ""))), "Preparation should use the concise authored strategic question")
	var focus: Control = root.gui_get_focus_owner()
	_check(focus == ui.playtest_button, "guided Preparation should focus its visible Ready Defense action; focus=%s disabled=%s" % [focus.name if focus != null else "none", ui.playtest_button.disabled])
	_check(ui.page_scroll.scroll_vertical == 0, "guided Preparation should open at the board-first summary rather than the lower command rail; scroll=%d" % ui.page_scroll.scroll_vertical)
	_check(_inside_scroll_view(ui.playtest_button, ui.page_scroll), "stacked Preparation should keep Ready Defense visible in the first viewport")
	_check(ui.keep_canvas.get_global_rect().position.y < ui.page_scroll.get_global_rect().end.y, "stacked Preparation should keep the fort reachable at the bottom of the first viewport")

	await _apply_layout(ui, Vector2i(1280, 720), 3)
	_check(ui.gameplay_columns.vertical and ui.preparation_brief_panel.summary_row.vertical, "large-text Preparation should use the deliberate single-column brief")
	_check(_inside_viewport(ui.preparation_brief_panel, Vector2(root.size)), "large-text Preparation should remain horizontally inside the viewport")
	_check(_inside_scroll_view(ui.playtest_button, ui.page_scroll), "large-text Preparation should keep the focused Ready Defense action visible")

	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	await _apply_layout(ui, Vector2i(1280, 720), 1)
	await _apply_layout(ui, Vector2i(1600, 900), 2)
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "responsive layout changes must not mutate authoritative run state")

	root.content_scale_factor = 1.0
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P48 responsive layout: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
