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
	ui._set_screen("preparation")
	ui._select_option_metadata(ui.campaign_modifier_option, "roadside_intelligence")
	ui._refresh_campaign_ledger()
	_check(String(ui.campaign_ledger_label.text).contains("LOCKED"), "Campaign Ledger should explain the initial locked modifier")
	_check(ui.campaign_modifier_button.disabled, "locked modifier action should be disabled")

	ui.keep.active_event_id = "relief_road_report"
	ui.keep.resolved_event_ids.append("relief_road_report")
	ui.keep.unlock_modifier("roadside_intelligence", "relief_road_report")
	ui.keep.unlock_modifier("hardened_vanguard", "relief_road_report")
	ui.keep.active_event_id = ""
	ui._refresh_ui()
	await process_frame
	_check(String(ui.campaign_ledger_label.text).contains("UNLOCKED") and not ui.campaign_modifier_button.disabled, "Campaign Ledger should expose the unlocked modifier action")
	ui.campaign_modifier_button.pressed.emit()
	await process_frame
	_check(ui.keep.equipped_modifier_id == "roadside_intelligence" and String(ui.campaign_ledger_label.text).contains("EQUIPPED"), "Campaign Ledger button should equip Roadside Intelligence authoritatively")
	ui._on_reset_run()
	await process_frame
	_check(ui.keep.equipped_modifier_id == "roadside_intelligence" and ui.keep.morale == 5, "New run should retain the equipped modifier and show its morale cost")
	ui._select_option_metadata(ui.scenario_option, "gatehouse_lock")
	ui._on_select_scenario()
	await process_frame
	_check(String(ui.forecast_label.text).contains("Actors: Raider, Raider"), "equipped modifier should expose the next-wave composition in the visible forecast")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P9 Campaign Ledger UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
