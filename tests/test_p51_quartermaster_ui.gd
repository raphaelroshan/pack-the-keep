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

	var panel: WarCouncilChoicePanel = ui.war_council_choice_panel
	panel.commander_next_button.pressed.emit()
	panel.commander_next_button.pressed.emit()
	_check(ui.keep.commander_id == "quartermaster", "War Council navigation should select the Quartermaster through the authoritative path")
	_check(String(panel.commander_name_label.text).contains("Quartermaster"), "commander card should name the Quartermaster")
	_check(String(panel.commander_strength_label.text).contains("Measured Stores") and String(panel.commander_ability_label.text).contains("Resupply"), "commander card should explain both reserve tools")
	_check(String(panel.commander_limitation_label.text).contains("48 materials") and String(panel.commander_question_label.text).contains("Which reserve"), "commander card should expose the opening cost and strategic question")

	ui._on_confirm_setup()
	await process_frame
	await process_frame
	_check(ui.screen == "preparation", "Quartermaster setup should enter Preparation through the ordinary flow")
	_check(String(ui.preparation_pack_offer_panel.detail_label.text).contains("COST — 2") and String(ui.preparation_pack_offer_panel.detail_label.text).contains("Measured Stores"), "Preparation should show the discounted first-pack price before purchase")
	var before_refresh: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_preparation_presentation()
	_check(JSON.stringify(ui.keep.serialize()) == before_refresh, "Quartermaster presentation refresh should not mutate authoritative state")

	ui.keep.open_pack("crossbow_watch")
	ui.keep.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
	ui.keep.start_wave(ui.keep.enemy_doctrine)
	ui._refresh_ui()
	_check(ui.commander_ability_button.disabled and String(ui.commander_ability_button.tooltip_text).contains("missing health or ammunition"), "Resupply should visibly explain why it is unavailable before losses")
	var crossbow_id: String = ""
	for instance_id_value in ui.keep.pieces.keys():
		var instance_id: String = String(instance_id_value)
		if String(ui.keep.pieces[instance_id].get("piece_id", "")) == "crossbow_patrol":
			crossbow_id = instance_id
	ui.keep.pieces[crossbow_id].ammo = 1
	ui._refresh_ui()
	_check(not ui.commander_ability_button.disabled and String(ui.commander_ability_button.text).contains("READY"), "Resupply should become visibly ready after ammunition is spent")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P51 Quartermaster UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
