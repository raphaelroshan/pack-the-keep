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

	_check(ui.campaign_modifier_option.item_count == 3, "Campaign Ledger should list None and both authored modifiers")
	ui._select_option_metadata(ui.campaign_modifier_option, "hardened_vanguard")
	ui._refresh_campaign_ledger()
	_check(String(ui.campaign_ledger_label.text).contains("LOCKED") and String(ui.campaign_ledger_label.text).contains("+2 health"), "locked Hardened Vanguard should expose its challenge rule")
	_check(ui.campaign_modifier_button.disabled, "locked challenge modifier should not be equippable")

	ui.keep.active_event_id = "relief_road_report"
	ui.keep.unlock_modifier("roadside_intelligence", "relief_road_report")
	ui.keep.unlock_modifier("hardened_vanguard", "relief_road_report")
	ui.keep.active_event_id = ""
	ui._refresh_ui()
	ui.campaign_modifier_button.pressed.emit()
	await process_frame
	_check(ui.keep.equipped_modifier_id == "hardened_vanguard" and ui.keep.morale == 6, "Campaign Ledger should equip Hardened Vanguard without changing starting morale")
	_check(String(ui.campaign_ledger_label.text).contains("EQUIPPED"), "equipped challenge modifier should be explicit")

	ui._select_option_metadata(ui.scenario_option, "gatehouse_lock")
	ui._on_select_scenario()
	ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	ui.keep.start_wave("gate_assault")
	ui._set_screen("battle")
	ui._refresh_ui()
	await process_frame
	_check(String(ui.enemy_label.text).contains("10/10 hp"), "battle UI should show the challenge-adjusted Raider health")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P11 Hardened Vanguard UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
