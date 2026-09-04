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
	ui._select_option_metadata(ui.scenario_option, "the_splintered_gate")
	ui._on_select_scenario()
	ui._select_option_metadata(ui.pack_option, "shieldwall")
	ui._refresh_pack_preview()
	_check(String(ui.scenario_preview_label.text).contains("The Splintered Gate"), "Preparation should expose The Splintered Gate")
	_check(String(ui.preparation_pack_offer_panel.name_label.text) == "Shieldwall" and String(ui.pack_preview_label.text).contains("Shield Wardens") and String(ui.pack_preview_label.text).contains("Emergency Shutters"), "Preparation should explain the Shieldwall pack")
	ui._on_open_pack()
	ui.keep.place_piece("shield_wardens", Vector2i(3, 3), "ground")
	ui.keep.place_piece("emergency_shutters", Vector2i(6, 2), "ground")
	ui.keep.start_wave("break_the_line")
	ui.keep.advance_wave(1.0)
	ui.keep.advance_wave(1.0)
	ui._set_screen("battle")
	ui._refresh_ui()
	ui._select_enemy_focus(0, "P11 Shieldwall UI test")
	await process_frame
	_check(String(ui.forecast_label.text).contains("Break The Line"), "Battle forecast should name Break the Line")
	_check(String(ui.enemy_label.text).contains("Shieldbreaker") and String(ui.enemy_label.text).contains("protection PIERCING"), "Battle roster should expose protection piercing")
	_check(String(ui.inspector_label.text).contains("protection PIERCING") and String(ui.inspector_label.text).contains("Shield Wardens") and not String(ui.inspector_label.text).contains("shield_wardens_0"), "Inspector should expose the friendly Shieldbreaker target and bypass rule")
	_check(String(ui.response_preview_label.text).contains("Shield Wardens"), "Response preview should name Shield Wardens")
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P11 Shieldwall UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
