extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _resolve_active_wave(ui: Control) -> void:
	while ui.keep.wave_active:
		ui.keep.advance_wave(1.0)
	ui._refresh_ui()
	await process_frame

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._set_screen("preparation")

	ui._select_option_metadata(ui.scenario_option, "the_twilight_road")
	ui._on_select_scenario()
	_check(String(ui.scenario_preview_label.text).contains("The Twilight Road"), "War Council should expose the combined scenario")
	_check(String(ui.scenario_preview_label.text).contains("Road Wardens + Lantern Watch") and String(ui.scenario_preview_label.text).contains("Crossbow Watch plus Runner Network"), "War Council should expose both two-pack plans")

	for pack_id in ["road_wardens", "lantern_watch"]:
		ui._select_option_metadata(ui.pack_option, pack_id)
		ui._on_open_pack()
	ui.keep.place_piece("stake_line", Vector2i(1, 2), "ground")
	ui.keep.place_piece("hook_guard", Vector2i(4, 3), "ground")
	ui.keep.place_piece("dusk_bow", Vector2i(1, 1), "upper")
	ui.keep.place_piece("lantern_post", Vector2i(7, 1), "upper")
	ui.keep.start_wave("rapid_breakthrough")
	await _resolve_active_wave(ui)
	ui.keep.finish_repair_interval()
	await _resolve_active_wave(ui)
	ui.keep.finish_repair_interval()
	ui._set_screen("battle")
	ui._refresh_ui()
	await process_frame

	_check(ui.keep.wave_index == 3 and ui.keep.enemy_doctrine == "twilight_crossing", "UI fixture should reach the combined final phase")
	_check(String(ui.forecast_label.text).contains("Twilight Crossing") and String(ui.forecast_label.text).contains("Charge: DELAYED") and String(ui.forecast_label.text).contains("Visibility: REVEALED"), "combined forecast should expose tempo and visibility together")
	_check(String(ui.enemy_label.text).contains("Outrider") and String(ui.enemy_label.text).contains("Gloam Knife"), "combined Battle roster should name both enemy families")
	var first_origin: Vector2 = ui.keep_canvas._enemy_origin(0)
	for enemy_index in range(1, ui.keep.enemies.size()):
		_check(first_origin.distance_to(ui.keep_canvas._enemy_origin(enemy_index)) >= 24.0, "combined approach markers should remain visually separated")
	var arrivals: Array = ui.keep_canvas.assault_timeline_snapshot().get("arrivals", {}).get("3", [])
	for marker_index in range(1, arrivals.size()):
		var previous: Vector2 = ui.keep_canvas._timeline_marker_origin(3, marker_index - 1, arrivals.size())
		var current: Vector2 = ui.keep_canvas._timeline_marker_origin(3, marker_index, arrivals.size())
		_check(previous.distance_to(current) >= 18.0, "combined timeline markers should not overlap")
	var authoritative_before_focus: String = JSON.stringify(ui.keep.serialize())
	ui._select_enemy_focus(0, "P51 Twilight Road UI test")
	await process_frame
	_check(String(ui.inspector_label.text).contains("Outrider"), "combined threat focus should inspect the first family")
	ui._cycle_enemy_focus(1)
	await process_frame
	_check(String(ui.inspector_label.text).contains("Gloam Knife"), "combined threat focus should cycle to the second family")
	_check(JSON.stringify(ui.keep.serialize()) == authoritative_before_focus, "combined inspection should not mutate authoritative state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P51 Twilight Road UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
