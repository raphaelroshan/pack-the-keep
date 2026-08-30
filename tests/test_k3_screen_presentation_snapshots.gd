extends SceneTree

const WarCouncilSnapshot = preload("res://src/ui/war_council_presentation_snapshot.gd")
const RecoverySnapshot = preload("res://src/ui/recovery_presentation_snapshot.gd")
const ResultsSnapshot = preload("res://src/ui/results_presentation_snapshot.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _resolve_wave(ui: Control) -> void:
	if not ui.assault_ready_reason.is_empty():
		ui._on_playtest_primary_action()
	var guard: int = 0
	while ui.keep.wave_active and guard < 16:
		ui._on_advance_wave()
		guard += 1
	_check(guard < 16, "terminal fixture wave should resolve inside the deterministic guard")

func _reach_terminal(ui: Control) -> void:
	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	ui._on_start_wave()
	_resolve_wave(ui)
	while ui.keep.has_next_wave():
		ui._on_finish_interval()
		_resolve_wave(ui)

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false

	ui._on_start_custom_setup()
	var commander_id: String = String(ui.commander_option.get_item_metadata(ui.commander_option.selected))
	var scenario_id: String = String(ui.scenario_option.get_item_metadata(ui.scenario_option.selected))
	var before_war_council: String = JSON.stringify(ui.keep.serialize())
	var council_first: Dictionary = WarCouncilSnapshot.build(ui.keep, commander_id, scenario_id, false, false)
	var council_second: Dictionary = WarCouncilSnapshot.build(ui.keep, commander_id, scenario_id, false, false)
	_check(JSON.stringify(council_first) == JSON.stringify(council_second), "War Council projection should be deterministic")
	_check(JSON.stringify(ui.keep.serialize()) == before_war_council, "War Council projection should not mutate authoritative state")
	ui._refresh_war_council_cards()
	_check(JSON.stringify(ui.war_council_presentation_snapshot) == JSON.stringify(council_first), "War Council UI should retain the exact snapshot it renders")
	_check(String(ui.war_council_choice_panel.commander_name_label.text) == String(council_first.get("commander", {}).get("name", "")), "commander card should render from the snapshot")
	_check(String(ui.war_council_choice_panel.scenario_name_label.text) == String(council_first.get("scenario", {}).get("name", "")), "scenario card should render from the snapshot")

	ui.keep.reset_run(3307)
	ui.keep.place_piece("pike_squad", Vector2i(3, 3), "ground")
	ui.keep.rooms["gate"].condition = 40
	ui.keep._update_room_state("gate")
	ui.keep._set_piece_health("pike_squad_0", 7)
	ui.keep.repair_interval_active = true
	ui.keep.repair_actions_remaining = 2
	ui.keep.repair_interval_reason = "Choose what Greywatch restores before the next warning."
	ui._set_screen("results")
	ui._on_map_clicked("ground", Vector2i(3, 3))
	ui._on_map_clicked("ground", Vector2i(1, 3))
	var before_recovery: String = JSON.stringify(ui.keep.serialize())
	var recovery_first: Dictionary = RecoverySnapshot.build(ui.keep, "pike_squad_0", "gate")
	var recovery_second: Dictionary = RecoverySnapshot.build(ui.keep, "pike_squad_0", "gate")
	_check(JSON.stringify(recovery_first) == JSON.stringify(recovery_second), "Recovery projection should be deterministic")
	_check(JSON.stringify(ui.keep.serialize()) == before_recovery, "Recovery projection should not mutate authoritative state")
	ui._refresh_recovery_action_cards()
	ui._refresh_recovery_brief()
	ui._refresh_recovery_priorities()
	_check(JSON.stringify(ui.recovery_presentation_snapshot) == JSON.stringify(recovery_first), "Recovery UI should retain the exact snapshot it renders")
	_check(String(ui.recovery_stage_label.text) == String(recovery_first.get("stage_text", "")), "Recovery stage should render from the snapshot")
	_check(String(ui.recovery_room_card_title.text) == String(recovery_first.get("cards", {}).get("room", {}).get("title", "")), "Recovery room card should render from the snapshot")
	_check(String(ui.recovery_priority_label.text) == String(recovery_first.get("priorities_text", "")), "Recovery priorities should render from the snapshot")

	_reach_terminal(ui)
	var before_results: String = JSON.stringify(ui.keep.serialize())
	var results_first: Dictionary = ResultsSnapshot.build(ui.keep, false, false, "")
	var results_second: Dictionary = ResultsSnapshot.build(ui.keep, false, false, "")
	_check(JSON.stringify(results_first) == JSON.stringify(results_second), "Results projection should be deterministic")
	_check(JSON.stringify(ui.keep.serialize()) == before_results, "Results projection should not mutate authoritative state")
	ui._refresh_terminal_debrief()
	_check(JSON.stringify(ui.results_presentation_snapshot) == JSON.stringify(results_first), "Results UI should retain the exact snapshot it renders")
	_check(String(ui.terminal_debrief_panel.outcome_label.text) == String(results_first.get("outcome_title", "")), "terminal outcome should render from the snapshot")
	_check(String(ui.terminal_debrief_panel.primary_button.text) == String(results_first.get("primary_label", "")), "terminal primary action should render from the snapshot")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("K3 screen presentation snapshots: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
