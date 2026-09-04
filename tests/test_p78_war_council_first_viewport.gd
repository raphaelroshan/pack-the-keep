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

func _select_pairing(ui: Control, commander_id: String, scenario_id: String) -> void:
	ui._select_option_metadata(ui.commander_option, commander_id)
	ui.keep.select_commander(commander_id)
	ui._select_option_metadata(ui.scenario_option, scenario_id)
	ui.keep.select_scenario(scenario_id)
	ui._refresh_ui()
	await process_frame
	await process_frame

func _check_first_viewport(ui: Control, label: String) -> void:
	var panel: WarCouncilChoicePanel = ui.war_council_choice_panel
	_check(ui.war_council_first_viewport_active and panel.first_viewport_mode, "%s should use the choice-first War Council composition" % label)
	_check(ui.page_scroll.scroll_vertical == 0, "%s should open without a page scroll offset" % label)
	_check(not ui.main_subtitle_label.visible and is_equal_approx(ui.art_banner.custom_minimum_size.y, 72.0), "%s should remove repeated framing and keep a compact authored banner" % label)
	_check(_inside_scroll_view(panel.summary_label, ui.page_scroll) and _inside_scroll_view(panel.confirm_button, ui.page_scroll), "%s should keep pairing, seed, focus, and Enter Keep visible" % label)
	_check(_inside_scroll_view(panel.commander_card, ui.page_scroll) and _inside_scroll_view(panel.scenario_card, ui.page_scroll), "%s should expose both complete choice cards without page scrolling" % label)
	_check(_inside_scroll_view(panel.commander_previous_button, ui.page_scroll) and _inside_scroll_view(panel.commander_next_button, ui.page_scroll), "%s should expose commander browsing" % label)
	_check(_inside_scroll_view(panel.scenario_previous_button, ui.page_scroll) and _inside_scroll_view(panel.scenario_next_button, ui.page_scroll), "%s should expose defense browsing" % label)
	_check(String(panel.commander_strength_label.text).begins_with("DOCTRINE —") and String(panel.commander_ability_label.text).begins_with("INTERVENTION —") and String(panel.commander_limitation_label.text).begins_with("TRADE-OFF —"), "%s should retain the commander's doctrine, intervention, and trade-off" % label)
	_check(String(panel.scenario_objective_label.text).begins_with("KEEP RULE —") and String(panel.scenario_arc_label.text).begins_with("OPENING —") and String(panel.scenario_risk_label.text).contains("PRESSURE —") and String(panel.scenario_risk_label.text).contains("OBJECTIVE —") and String(panel.scenario_risk_label.text).contains("RISK —"), "%s should retain geometry, opening, pressure, objective, and accepted risk" % label)
	_check(not panel.commander_question_label.visible and not panel.scenario_fixed_label.visible, "%s should defer repeated secondary card detail" % label)

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false

	await _apply_layout(ui, Vector2i(1280, 720), 1)
	ui._on_start_custom_setup()
	await process_frame
	await process_frame
	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	_check_first_viewport(ui, "Greywatch at 1280x720")
	_check(root.gui_get_focus_owner() == ui.setup_confirm_button, "choice-first War Council should retain Enter Keep as controller focus")

	await _select_pairing(ui, "quartermaster", "the_twilight_road")
	_check_first_viewport(ui, "long-form Twilight Road at 1280x720")
	_check(String(ui.war_council_choice_panel.summary_label.text).contains("final pressure") and String(ui.war_council_choice_panel.summary_label.text).contains("FOCUS —"), "choice-first summary should retain concrete seeded adaptation")
	_check(JSON.stringify(ui.keep.serialize()) != serialized_before, "authoritative selection should still change through the existing War Council path")

	var selected_before_resize: String = JSON.stringify(ui.keep.serialize())
	await _apply_layout(ui, Vector2i(1600, 900), 1)
	_check(not ui.war_council_first_viewport_active and not ui.war_council_choice_panel.first_viewport_mode, "1600x900 should retain the full War Council cards")
	_check(ui.main_subtitle_label.visible and ui.war_council_choice_panel.commander_question_label.visible and ui.war_council_choice_panel.scenario_fixed_label.visible, "wide War Council should restore its complete explanatory detail")
	_check(String(ui.war_council_choice_panel.scenario_identity_label.text).contains("FIRST QUESTION —") and String(ui.war_council_choice_panel.scenario_risk_label.text).begins_with("RUN RULE"), "wide defense card should retain question and run-rule detail")
	_check(JSON.stringify(ui.keep.serialize()) == selected_before_resize, "responsive War Council changes must not mutate authoritative state")

	await _apply_layout(ui, Vector2i(1280, 720), 3)
	_check(not ui.war_council_first_viewport_active and ui.war_council_choice_panel.choice_row.vertical, "150 percent text should retain the established stacked detailed fallback")
	_check(ui.war_council_choice_panel.commander_question_label.visible and ui.war_council_choice_panel.scenario_fixed_label.visible, "large-text fallback should preserve complete card detail")

	root.content_scale_factor = 1.0
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P78 War Council first viewport: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
