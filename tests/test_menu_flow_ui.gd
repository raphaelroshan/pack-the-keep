extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _find_button(node: Node, target_text: String) -> Button:
	for child in node.get_children():
		if child is Button and String(child.text) == target_text:
			return child
		var nested: Button = _find_button(child, target_text)
		if nested != null:
			return nested
	return null

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame

	_check(ui.screen == "title", "flow should begin at the main menu")
	_check(ui.title_card.visible and ui.art_banner.visible, "main menu should show the hero presentation")
	_check(not ui.gameplay_columns.visible, "main menu should not expose gameplay controls")
	_check(_find_button(ui, "New Game") != null, "main menu should expose the campaign entry")
	_check(_find_button(ui, "Learn to Play") != null, "main menu should expose the tutorial route")
	_check(_find_button(ui, "Skirmish") != null, "main menu should expose custom setup")
	_check(_find_button(ui, "Settings") != null, "main menu should expose settings")

	ui._on_start_custom_setup()
	await process_frame
	_check(ui.screen == "setup", "custom defense should open the briefing screen")
	_check(ui.setup_summary_panel.visible and String(ui.setup_overview_label.text).contains("PAIRING —"), "briefing should show its selected-loadout relationship summary")
	_check(not ui.keep_canvas.visible, "briefing should not compete visually with the keep board")
	_check(ui.setup_controls[0].visible, "briefing controls should be visible")
	_check(not ui.preparation_controls[0].visible and not ui.battle_controls[0].visible, "briefing should hide preparation and battle tools")
	_check(ui.menu_buttons["battle"].disabled and ui.menu_buttons["results"].disabled, "future phases should remain unavailable from briefing")

	ui._on_open_settings()
	await process_frame
	_check(ui.screen == "settings", "settings action should open a separate settings screen")
	_check(ui.settings_overview_panel.visible and ui.settings_controls[0].visible, "settings should show only presentation controls")
	_check(not ui.setup_controls[0].visible and not ui.keep_canvas.visible, "settings should not expose setup or board controls")
	ui._on_close_settings()
	await process_frame
	_check(ui.screen == "setup", "settings back action should return to the prior screen")

	ui._on_confirm_setup()
	await process_frame
	_check(ui.screen == "preparation", "confirming custom setup should enter Preparation")
	_check(ui.keep_canvas.visible and ui.preparation_controls[0].visible, "Preparation should show the fort and build tools")
	_check(not ui.setup_controls[0].visible and not ui.battle_controls[0].visible and not ui.settings_controls[0].visible, "Preparation should hide unrelated control groups")
	_check(String(ui.playtest_button.text) == "3  READY DEFENSE — ENTER ASSAULT", "Preparation should expose one clear numbered assault-entry action")

	ui._on_recommended_layout()
	ui.playtest_button.pressed.emit()
	await process_frame
	_check(ui.screen == "battle" and ui.keep.wave_active and ui.keep.battle_step == 0 and ui.battle_paused and not ui.assault_ready_reason.is_empty(), "primary action should enter Battle at tick zero with a readable ready beat")
	_check(ui.battle_controls[0].visible and not ui.preparation_controls[0].visible, "Battle should replace build tools with battle controls")
	_check(String(ui.playtest_button.text).contains("SOUND THE BELL"), "Battle should expose the ready confirmation as its primary action")
	ui.playtest_button.pressed.emit()
	await process_frame
	_check(not ui.battle_paused and String(ui.playtest_button.text) == "PAUSE — INSPECT", "sounding the bell should begin continuous combat and expose pause")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("Menu-to-playtest flow UI: PASS")
	else:
		for failure in failures:
			push_error(failure)
		printerr("Menu-to-playtest flow UI: FAIL (%d)" % failures.size())
	quit(0 if failures.is_empty() else 1)
