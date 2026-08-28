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
	ui._set_screen("preparation")
	ui._select_option_metadata(ui.scenario_option, "three_bells_at_dusk")
	ui._on_select_scenario()
	_check(String(ui.scenario_preview_label.text).contains("Three Bells at Dusk") and String(ui.scenario_preview_label.text).contains("Assault phases: 3"), "Preparation should expose the three-phase P11 challenge")
	ui.keep.open_pack("bell_guard")
	ui.keep.open_pack("crossbow_watch")
	ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	ui.keep.place_piece("bellkeepers", Vector2i(1, 5), "upper")
	ui.keep.place_piece("signal_beacon", Vector2i(4, 5), "upper")
	ui.keep.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
	ui.keep.place_piece("watch_banner", Vector2i(4, 1), "upper")
	ui.keep.start_wave("shielded_advance")
	ui._set_screen("battle")
	ui._refresh_ui()
	await process_frame
	_check(String(ui.enemy_label.text).contains("Shield Guard") and String(ui.enemy_label.text).contains("Ash Slinger"), "challenge wave one should display both P11 enemy questions")
	_check(String(ui.enemy_label.text).contains("armor 2") and String(ui.enemy_label.text).contains("signal RELAYED"), "challenge roster should expose armor and countered signal state together")
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P11 Three Bells UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
