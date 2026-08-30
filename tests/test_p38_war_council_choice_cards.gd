extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._on_start_custom_setup()
	await process_frame
	await process_frame

	var panel: WarCouncilChoicePanel = ui.war_council_choice_panel
	_check(panel != null and panel.visible, "War Council should show its dedicated choice-card panel")
	_check(String(panel.commander_name_label.text).contains("Castellan"), "commander card should name the selected leader")
	_check(String(panel.commander_strength_label.text).contains("Layered Masonry"), "commander card should explain the passive strength")
	_check(String(panel.commander_limitation_label.text).contains("Dense layouts"), "commander card should expose the limitation before commitment")
	_check(String(panel.commander_question_label.text).contains("Which functions"), "commander card should expose the first strategic question")
	_check(String(panel.scenario_name_label.text).contains("Gatehouse Lock"), "defense card should name the selected scenario")
	_check(String(panel.scenario_identity_label.text).contains("FIRST QUESTION"), "defense card should expose its teaching question")
	_check(String(panel.scenario_arc_label.text).contains("Gate Assault") and String(panel.scenario_arc_label.text).contains("Feint and Flank"), "defense card should expose the authored pressure arc")
	_check(String(panel.scenario_fixed_label.text).contains("3 authored phases") and String(panel.summary_label.text).contains("seeded variation"), "War Council should explain what becomes fixed on entry")
	_check(ui.commander_option.visible and ui.scenario_option.visible, "advanced dropdown selectors should remain available as a fallback")
	_check(not ui.commander_portrait.visible and not ui.commander_profile_label.visible, "the command rail should not duplicate the primary commander card")

	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_war_council_cards()
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "refreshing War Council cards should not mutate authoritative state")

	panel.commander_next_button.pressed.emit()
	_check(ui._selected_id(ui.commander_option) == "warden" and ui.keep.commander_id == "warden", "commander card navigation should use the existing authoritative selection path")
	_check(String(panel.commander_name_label.text).contains("Warden") and String(panel.commander_strength_label.text).contains("Open Lanes"), "commander card should refresh for the Warden")
	panel.commander_next_button.pressed.emit()
	_check(ui._selected_id(ui.commander_option) == "castellan", "commander card navigation should wrap through both leaders")

	var starting_scenario: String = ui._selected_id(ui.scenario_option)
	panel.scenario_next_button.pressed.emit()
	var next_scenario: String = ui._selected_id(ui.scenario_option)
	_check(next_scenario != starting_scenario and ui.keep.scenario_id == next_scenario, "defense card navigation should select another authored scenario")
	_check(String(panel.scenario_name_label.text) == String(ui.keep.scenario_preview().get("name", "")), "defense card and authoritative scenario should stay synchronized")
	panel.scenario_previous_button.pressed.emit()
	_check(ui._selected_id(ui.scenario_option) == starting_scenario, "defense card navigation should return through the authored catalogue")

	ui._set_screen("setup")
	await process_frame
	var focus: Control = root.gui_get_focus_owner()
	_check(focus == ui.setup_confirm_button, "ordinary War Council controller focus should begin on the primary Enter Keep action")
	ui._set_ui_scale(2)
	await process_frame
	_check(panel.choice_row.vertical and panel.custom_minimum_size.x >= 800.0, "125 percent UI scale should stack the cards instead of compressing them")

	ui._start_tutorial()
	ui._on_tutorial_continue()
	ui._on_tutorial_continue()
	ui._on_tutorial_continue()
	await process_frame
	_check(ui.screen == "setup" and ui.tutorial.active, "First Watch should still reach the War Council")
	_check(panel.lock_label.visible and panel.commander_next_button.disabled and panel.scenario_next_button.disabled, "First Watch should visibly lock both card choices")
	_check(ui.commander_option.disabled and ui.scenario_option.disabled, "First Watch should also lock the advanced fallback selectors")
	var locked_before: String = JSON.stringify(ui.keep.serialize())
	panel.commander_next_requested.emit()
	panel.scenario_next_requested.emit()
	_check(ui.keep.commander_id == "castellan" and ui.keep.scenario_id == "gatehouse_lock", "locked card signals should not change First Watch choices")
	_check(JSON.stringify(ui.keep.serialize()) == locked_before, "locked War Council navigation should not mutate tutorial run state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P38 War Council choice cards: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
