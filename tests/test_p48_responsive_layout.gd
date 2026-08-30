extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _inside_viewport(control: Control, viewport_size: Vector2) -> bool:
	var rect: Rect2 = control.get_global_rect()
	return rect.position.x >= -1.0 and rect.end.x <= viewport_size.x + 1.0

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
	_check(_inside_viewport(ui.gameplay_main_column, Vector2(root.size)), "wide War Council main content should remain horizontally inside the viewport")
	_check(_inside_viewport(ui.command_panel, Vector2(root.size)), "wide War Council command rail should remain horizontally inside the viewport")

	await _apply_layout(ui, Vector2i(1280, 720), 1)
	_check(ui.gameplay_columns.vertical, "1280x720 should stack the main surface and command rail")
	_check(not ui.war_council_choice_panel.choice_row.vertical, "1280x720 should retain side-by-side choice cards when their content still fits")
	_check(_inside_viewport(ui.gameplay_main_column, Vector2(root.size)), "narrow War Council main content should remain horizontally inside the viewport")
	_check(_inside_viewport(ui.command_panel, Vector2(root.size)), "stacked War Council command rail should remain horizontally inside the viewport")
	_check(ui.setup_confirm_button.is_visible_in_tree(), "the War Council commit action should remain reachable in the stacked flow")
	_check(root.gui_get_focus_owner() == ui.setup_confirm_button, "responsive War Council should preserve its controller-first Enter Keep action")

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
	var focus: Control = root.gui_get_focus_owner()
	_check(focus == ui.playtest_button, "guided Preparation should focus its visible Ready Defense action; focus=%s disabled=%s" % [focus.name if focus != null else "none", ui.playtest_button.disabled])
	_check(ui.page_scroll.scroll_vertical == 0, "guided Preparation should open at the board-first summary rather than the lower command rail; scroll=%d" % ui.page_scroll.scroll_vertical)

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
