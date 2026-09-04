extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

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

	await _apply_layout(ui, Vector2i(1280, 720), 1)
	ui._on_start_custom_setup()
	ui._select_option_metadata(ui.commander_option, "castellan")
	ui.keep.select_commander("castellan")
	ui._select_option_metadata(ui.scenario_option, "gatehouse_lock")
	ui.keep.select_scenario("gatehouse_lock")
	ui._refresh_ui()
	ui._on_confirm_setup()
	await process_frame
	await process_frame

	var before_layout: String = JSON.stringify(ui.keep.serialize())
	var snapshot: Dictionary = ui._responsive_layout_snapshot()
	_check(ui.preparation_board_first_active and bool(snapshot.get("preparation_rail_compact", false)), "1280x720 Preparation should use its compact board-first command rail")
	_check(ui.preparation_pack_offer_panel.compact_mode and not ui.preparation_pack_offer_panel.role_label.visible, "compact Preparation should remove the repeated pack question")
	_check(String(ui.preparation_pack_offer_panel.detail_label.text).contains("DOCTRINE — Compact Corridors") and String(ui.preparation_pack_offer_panel.detail_label.text).contains("ADDS — Pike Squad") and String(ui.preparation_pack_offer_panel.detail_label.text).contains("SOLVES —"), "compact pack card should retain doctrine, contents, cost, and purpose")
	_check(not String(ui.preparation_pack_offer_panel.detail_label.text).contains("LIMITATION —") and not String(ui.preparation_pack_offer_panel.detail_label.text).contains("TRADE-OFF —"), "compact pack card should defer secondary doctrine detail")
	_check(String(ui.preparation_context_label.text).contains("CASTELLAN") and String(ui.preparation_context_label.text).contains("COMPACT CORRIDORS") and String(ui.preparation_context_label.text).contains("Gate Assault") and String(ui.preparation_context_label.text).contains("Gate"), "compact rail should join commander, pack doctrine, invasion forecast, and likely target")
	_check(_inside_scroll_view(ui.preparation_context_label, ui.command_scroll), "commander and forecast context should be visible without rail scrolling")
	_check(_inside_scroll_view(ui.preparation_pack_offer_panel, ui.command_scroll), "selected pack answer should be visible without rail scrolling")
	_check(_inside_scroll_view(ui.preparation_placement_stage_label, ui.command_scroll) and _inside_scroll_view(ui.recommended_layout_button, ui.command_scroll), "placement stage and first-plan action should be visible without rail scrolling")
	_check(not ui.recommended_layout_button.disabled and String(ui.recommended_layout_button.text).contains("0/2 placed"), "an empty keep should expose the incomplete first plan as the next placement action")
	_check(_inside_scroll_view(ui.preparation_brief_panel, ui.page_scroll) and _inside_scroll_view(ui.playtest_button, ui.page_scroll), "tactical question, visible answer, accepted risk, and Ready Defense should remain in the first viewport")
	_check(ui.command_scroll.scroll_vertical == 0 and ui.page_scroll.scroll_vertical == 0, "the first Preparation viewport should not depend on initial scroll offsets")
	_check(JSON.stringify(ui.keep.serialize()) == before_layout, "responsive rail composition should not mutate authoritative state")

	ui._toggle_preparation_advanced()
	await process_frame
	_check(not ui.preparation_pack_offer_panel.compact_mode and ui.preparation_pack_offer_panel.role_label.visible, "advanced Preparation should restore the full pack card")
	_check(String(ui.preparation_pack_offer_panel.detail_label.text).contains("LIMITATION —") and String(ui.preparation_pack_offer_panel.detail_label.text).contains("SPACE —") and String(ui.preparation_pack_offer_panel.detail_label.text).contains("TRADE-OFF —"), "expanded card should retain limitation, spatial demand, and trade-off")
	ui._toggle_preparation_advanced()

	ui.recommended_layout_button.pressed.emit()
	await process_frame
	await process_frame
	_check(ui.keep.pieces.size() >= 2 and not ui.playtest_button.disabled, "the first-plan command should establish a legal defense and enable Ready Defense")
	_check(String(ui.preparation_brief_panel.answer_label.text).contains("visible coverage") and String(ui.preparation_brief_panel.plan_label.text).contains("2/2 placed"), "applying the plan should update the visible answer and placement progress")
	_check(ui.recommended_layout_button.disabled and String(ui.recommended_layout_button.text).contains("First plan in place"), "a complete first plan should become a clear state instead of a redundant action")
	_check(_inside_scroll_view(ui.playtest_button, ui.page_scroll) and _inside_scroll_view(ui.recommended_layout_button, ui.command_scroll), "the completed plan and Begin Assault action should remain simultaneously visible")

	await _apply_layout(ui, Vector2i(1600, 900), 1)
	_check(ui.preparation_board_first_active and not ui.preparation_rail_compact_active, "1600x900 should keep the wider board-first rail")
	_check(not ui.preparation_pack_offer_panel.compact_mode and ui.preparation_pack_offer_panel.role_label.visible, "the wider rail should show the complete pack card by default")
	_check(String(ui.preparation_pack_offer_panel.detail_label.text).contains("LIMITATION —") and String(ui.preparation_pack_offer_panel.detail_label.text).contains("TRADE-OFF —"), "the wider pack card should retain full decision detail")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P77 Preparation first viewport: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
