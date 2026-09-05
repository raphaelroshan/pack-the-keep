extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _all_defenders_disabled(state: PackKeepState) -> bool:
	if state.pieces.is_empty():
		return false
	for piece in state.pieces.values():
		if not bool(piece.get("disabled", false)) or int(piece.get("health", 0)) > 0:
			return false
	return true

func _initialize() -> void:
	var state: PackKeepState = PackKeepState.new(3307)
	var preview: Dictionary = state.scenario_preview("last_stand")
	_check(bool(preview.get("ok", false)), "The Last Bell should be available in the scenario catalogue")
	_check(String(preview.get("difficulty", "")) == "overwhelming", "Last Stand should declare overwhelming difficulty")
	_check(bool(preview.get("collapse_on_defender_wipe", false)), "Last Stand should declare a terminal defender wipe")
	_check(int(preview.get("peak_wave_size", 0)) == 7, "Last Stand should preview its seven-attacker peak")
	_check(preview.get("enemy_roster", []).has("Siege Beast") and preview.get("enemy_roster", []).has("Shieldbreaker"), "Last Stand should preview its mixed threat roster")

	_check(bool(state.select_scenario("last_stand").get("ok", false)), "Last Stand should be selectable")
	_check(bool(state.place_piece("pike_squad", Vector2i(4, 5), "ground").get("ok", false)), "Last Stand fixture should place Pike Squad")
	_check(bool(state.place_piece("narrow_gate", Vector2i(2, 5), "ground").get("ok", false)), "Last Stand fixture should place Narrow Gate")
	var start: Dictionary = state.start_wave("break_the_line")
	_check(bool(start.get("ok", false)) and start.get("composition", []).size() == 5, "Last Stand should begin with an overwhelming five-attacker wave")
	var resolution: Dictionary = {}
	while state.wave_active:
		resolution = state.advance_wave(1.0)
	_check(_all_defenders_disabled(state), "the overwhelming wave should disable every defender without test-only health mutation")
	_check(String(resolution.get("outcome", "")) == "collapse" and state.last_outcome == "collapse", "a Last Stand defender wipe should resolve as collapse")
	_check(not state.repair_interval_active and not state.has_next_wave(), "terminal defender wipe should not open recovery or another wave")
	_check(state.battle_step < 6, "Last Stand should end as soon as the final defender is disabled")
	_check(not bool(state.start_wave("break_the_line").get("ok", false)), "a collapsed Last Stand should reject another wave")
	var report: Dictionary = state.scenario_report()
	_check(String(report.get("status", "")) == "complete", "defender-wipe collapse should produce a complete scenario report")
	_check(" ".join(report.get("what_failed", [])).contains("Every defender was disabled"), "the report should state the actual defender-wipe cause")

	var restored: PackKeepState = PackKeepState.new(0)
	_check(bool(restored.load_serialized(state.serialize()).get("ok", false)), "terminal Last Stand state should load")
	_check(restored.last_outcome == "collapse" and not restored.has_next_wave() and _all_defenders_disabled(restored), "save/load should preserve the terminal wipe exactly")

	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._set_screen("setup")
	ui._select_option_metadata(ui.scenario_option, "last_stand")
	ui._on_select_scenario()
	var selection_text: String = String(ui.scenario_preview_label.text)
	var scenario_ids: Array[String] = state.scenario_ids()
	var last_stand_index: int = scenario_ids.find("last_stand")
	var expected_position: String = "SCENARIO %d/%d" % [last_stand_index + 1, scenario_ids.size()]
	_check(selection_text.contains(expected_position) and selection_text.contains("The Last Bell"), "scenario briefing should expose catalogue position and title")
	_check(selection_text.contains("OVERWHELMING") and selection_text.contains("Peak pressure: 7 attackers"), "scenario briefing should expose difficulty and peak pressure")
	_check(selection_text.contains("Enemy roster:") and selection_text.contains("Siege Beast"), "scenario briefing should expose the threat roster")
	_check(selection_text.contains("A routed garrison ends the defense"), "scenario briefing should warn about the terminal rule")
	_check(String(ui.setup_overview_label.text).contains("OVERWHELMING · a routed garrison ends the defense"), "briefing summary should repeat the decisive risk without requiring command-panel scrolling")
	_check(ui.scenario_previous_button.visible and ui.scenario_next_button.visible, "scenario browser controls should be visible during briefing")
	ui._cycle_scenario(-1)
	_check(ui._selected_id(ui.scenario_option) == scenario_ids[last_stand_index - 1], "previous scenario should move backward through the authored catalogue")
	ui._cycle_scenario(1)
	_check(ui._selected_id(ui.scenario_option) == "last_stand", "next scenario should return to Last Stand")
	ui._cycle_scenario(1)
	var next_scenario_index: int = (last_stand_index + 1) % scenario_ids.size()
	_check(ui._selected_id(ui.scenario_option) == scenario_ids[next_scenario_index], "scenario navigation should advance without losing selection")
	ui.queue_free()
	await process_frame

	if failures.is_empty():
		print("P30 Last Stand end state and scenario selection: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
