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
	ui.keep.select_scenario("gatehouse_lock")
	ui.keep.rooms.gate.condition = 82
	ui.keep.rooms.supply_room.condition = 75
	ui.keep._update_room_state("gate")
	ui.keep._update_room_state("supply_room")
	ui.keep.last_outcome = "held"
	ui.keep.wave_index = ui.keep.authored_wave_count()
	ui.keep.repair_interval_active = true
	ui.keep.repair_actions_remaining = 2
	ui.keep.finish_repair_interval()
	ui._set_screen("results")
	ui._refresh_ui()
	await process_frame

	var before: String = JSON.stringify(ui.keep.serialize())
	_check(String(ui.campaign_ledger_label.text).contains("REGIONAL REPORT — Low Mill [CONNECTED]"), "Campaign Ledger should show Low Mill's political state")
	_check(String(ui.campaign_ledger_label.text).contains("Miller's Road: OPEN"), "Campaign Ledger should name the route and route state")
	_check(String(ui.campaign_ledger_label.text).contains("+3 starting materials pending"), "Campaign Ledger should explain the bounded next-scenario effect")
	_check(String(ui.scorecard_label.text).contains("REGIONAL REPORT — Low Mill [CONNECTED]"), "Results should include the same regional consequence")
	ui._refresh_campaign_ledger()
	ui._refresh_result_explanation()
	_check(JSON.stringify(ui.keep.serialize()) == before, "regional report inspection should not mutate or consume pending support")

	ui.keep.reset_run(8201)
	ui.keep.select_scenario("ash_ford_crossing")
	ui._refresh_campaign_ledger()
	_check(String(ui.campaign_ledger_label.text).contains("Support applied to Ash Ford Crossing: +3 starting materials"), "Ledger should show where one-shot support was consumed")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P15 Low Mill regional UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
