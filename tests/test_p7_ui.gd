extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _resolve_wave(ui: Control) -> void:
	var safety: int = 0
	while ui.keep.wave_active and safety < 12:
		ui._on_advance_wave()
		await process_frame
		safety += 1

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame

	ui._set_screen("preparation")
	ui._select_option_metadata(ui.scenario_option, "relief_road")
	ui._on_select_scenario()
	ui._select_option_metadata(ui.pack_option, "runner_network")
	ui._on_open_pack()
	ui._select_option_metadata(ui.pack_option, "fallback_convoy")
	ui._on_open_pack()
	ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	ui.keep.place_piece("runner_pair", Vector2i(4, 3), "ground")
	ui.keep.place_piece("supply_cache", Vector2i(6, 3), "ground")
	ui.keep.place_piece("rear_guard", Vector2i(4, 4), "ground")
	ui.keep.place_piece("breakaway_barricade", Vector2i(3, 3), "ground")
	ui._refresh_ui()
	await process_frame

	_check(String(ui.scenario_preview_label.text).contains("The Relief Road"), "preparation did not show the Relief Road scenario card")
	_check(String(ui.availability_label.text).contains("Runner Pair") and String(ui.availability_label.text).contains("Rear Guard"), "preparation did not expose both mobile-response packs")
	ui._on_map_clicked("ground", Vector2i(6, 3))
	_check(String(ui.inspector_label.text).contains("Reserve: READY"), "Supply Cache did not expose its READY state in the inspector")
	ui.keep.rooms.gate.condition = 70
	ui.keep._update_room_state("gate")
	ui._on_map_clicked("ground", Vector2i(4, 4))
	_check(String(ui.inspector_label.text).contains("Fallback: ENGAGED"), "Rear Guard did not expose its ENGAGED fallback state in the inspector")
	ui.keep.rooms.gate.condition = 100
	ui.keep._update_room_state("gate")

	var started: Dictionary = ui.keep.start_wave("feint_and_flank")
	_check(bool(started.get("ok", false)), "Relief Road wave one did not start from preparation")
	ui._set_screen("battle")
	await process_frame
	_check(String(ui.forecast_label.text).contains("feint and flank"), "battle did not show the Relief Road opening doctrine")
	_check(String(ui.enemy_label.text).contains("Climber"), "battle did not show the scenario's opening mobile-response target")
	await _resolve_wave(ui)
	ui._set_screen("results")
	ui._on_map_clicked("ground", Vector2i(6, 3))
	_check(String(ui.inspector_label.text).contains("Reserve: SPENT"), "recovery did not expose the Supply Cache SPENT state")
	_check(String(ui.scorecard_label.text).contains("The Relief Road") and String(ui.scorecard_label.text).contains("W1"), "first-wave Results did not identify Relief Road and its scorecard row")

	while ui.keep.has_next_wave():
		var continued: Dictionary = ui.keep.finish_repair_interval()
		_check(bool(continued.get("next_wave_started", false)), "Relief Road recovery did not start the next authored wave")
		ui._set_screen("battle")
		await _resolve_wave(ui)
		ui._set_screen("results")
	if ui.keep.repair_interval_active:
		ui.keep.finish_repair_interval()
	ui._set_screen("results")
	await process_frame
	_check(String(ui.scorecard_label.text).contains("Rolling Breach") and String(ui.scorecard_label.text).contains("W3"), "terminal Results did not capture the Rolling Breach finale")
	_check(String(ui.scorecard_label.text).contains("SCENARIO REPORT"), "terminal Relief Road Results did not expose the completed report")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P7 preparation/battle/results UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		printerr("P7 preparation/battle/results UI: FAIL (%d)" % failures.size())
		quit(1)
