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
	_check(String(ui.war_council_presentation_snapshot.get("commander", {}).get("question", "")).contains("Which functions"), "commander projection should preserve the first strategic question when compact layout defers it")
	_check(String(panel.scenario_name_label.text).contains("Gatehouse Lock"), "defense card should name the selected scenario")
	_check(not String(ui.war_council_presentation_snapshot.get("scenario", {}).get("question", "")).is_empty(), "defense projection should preserve its teaching question when compact layout defers it")
	_check(String(panel.scenario_objective_label.text).contains("Layered Masonry compounds Greywatch"), "defense card should explain how the selected commander fits the keep geometry")
	_check(String(panel.scenario_arc_label.text).contains("Pack: Pike Line") and String(panel.scenario_risk_label.text).contains("RISK —"), "defense card should name a compatible opening and its risk")
	_check(String(panel.scenario_risk_label.text).contains("Gate Assault") and String(panel.scenario_risk_label.text).contains("Feint and Flank"), "defense card should expose the authored pressure arc")
	_check(int(ui.war_council_presentation_snapshot.get("scenario", {}).get("wave_count", 0)) == 3, "defense projection should preserve what becomes fixed on entry")
	_check(String(panel.summary_label.text).contains("PAIRING — The Castellan leads Gatehouse Lock at Greywatch Keep."), "War Council should state the selected commander/defense relationship")
	_check(String(panel.summary_label.text).contains("OPENING PRESSURE —") and String(panel.summary_label.text).contains("FOCUS —"), "War Council should expose concise opening pressure and preparation focus")
	_check(not ui.setup_advanced_panel.visible and not ui.commander_option.is_visible_in_tree() and not ui.scenario_option.is_visible_in_tree(), "advanced dropdown selectors should begin collapsed behind the game-facing cards")
	_check(String(ui.setup_pairing_summary_label.text).contains("CURRENT DEFENSE") and String(ui.setup_pairing_summary_label.text).contains("The Castellan leads Gatehouse Lock"), "the command rail should keep a compact synchronized pairing summary visible")
	var disclosure_state_before: String = JSON.stringify(ui.keep.serialize())
	ui.setup_advanced_button.pressed.emit()
	_check(ui.setup_advanced_panel.visible and ui.commander_option.is_visible_in_tree() and ui.scenario_option.is_visible_in_tree(), "advanced selection should reveal direct catalogue controls on request")
	_check(ui.campaign_ledger_panel.is_visible_in_tree() and String(ui.setup_advanced_button.text).contains("Hide"), "advanced selection should reveal campaign controls and expose a reversible label")
	ui.setup_advanced_button.pressed.emit()
	_check(not ui.setup_advanced_panel.visible and JSON.stringify(ui.keep.serialize()) == disclosure_state_before, "collapsing advanced selection should leave authoritative state unchanged")
	_check(not ui.commander_portrait.visible and not ui.commander_profile_label.visible, "the command rail should not duplicate the primary commander card")

	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_war_council_cards()
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "refreshing War Council cards should not mutate authoritative state")

	panel.commander_next_button.pressed.emit()
	_check(ui._selected_id(ui.commander_option) == "warden" and ui.keep.commander_id == "warden", "commander card navigation should use the existing authoritative selection path")
	_check(String(panel.commander_name_label.text).contains("Warden") and String(panel.commander_strength_label.text).contains("Open Lanes"), "commander card should refresh for the Warden")
	_check(String(panel.scenario_objective_label.text).contains("Open Lanes turns Greywatch") and String(panel.scenario_arc_label.text).contains("Pack: Firekeepers"), "changing commander should update the read-only geometry recommendation")
	_check(String(ui.setup_pairing_summary_label.text).contains("The Warden leads"), "compact pairing summary should follow card navigation")
	panel.commander_next_button.pressed.emit()
	_check(ui._selected_id(ui.commander_option) == "quartermaster" and ui.keep.commander_id == "quartermaster", "commander card navigation should reach the Quartermaster")
	_check(String(panel.commander_name_label.text).contains("Quartermaster") and String(panel.commander_strength_label.text).contains("Measured Stores"), "commander card should explain the Quartermaster reserve lens")
	panel.commander_next_button.pressed.emit()
	_check(ui._selected_id(ui.commander_option) == "marshal", "commander card navigation should reach the Marshal")
	_check(String(panel.commander_name_label.text).contains("Marshal") and String(panel.commander_strength_label.text).contains("Posted Orders"), "commander card should explain the Marshal assignment lens")
	panel.commander_next_button.pressed.emit()
	_check(ui._selected_id(ui.commander_option) == "castellan", "commander card navigation should wrap through all four leaders")

	var starting_scenario: String = ui._selected_id(ui.scenario_option)
	panel.scenario_next_button.pressed.emit()
	var next_scenario: String = ui._selected_id(ui.scenario_option)
	_check(next_scenario != starting_scenario and ui.keep.scenario_id == next_scenario, "defense card navigation should select another authored scenario")
	_check(String(panel.scenario_name_label.text) == String(ui.keep.scenario_preview().get("name", "")), "defense card and authoritative scenario should stay synchronized")
	ui._select_option_metadata(ui.scenario_option, "ash_ford_crossing")
	ui.keep.select_scenario("ash_ford_crossing")
	ui._refresh_war_council_cards()
	_check(String(panel.scenario_objective_label.text).contains("cannot copy Greywatch") and String(panel.scenario_arc_label.text).contains("marked crossing"), "Ash Ford should explain why the compact Greywatch plan cannot be copied")
	ui._select_option_metadata(ui.scenario_option, next_scenario)
	ui.keep.select_scenario(next_scenario)
	ui._refresh_war_council_cards()
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
