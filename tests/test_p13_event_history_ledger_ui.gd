extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _entry(event_id: String, choice_id: String, result: String) -> Dictionary:
	return {"event_id": event_id, "choice_id": choice_id, "wave": 2, "phase": "recovery", "visible_result": result, "state_changes": []}

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	for entry in [
		_entry("relief_road_warning", "oldest", "Oldest consequence"),
		_entry("relief_road_recovery", "second", "Second consequence"),
		_entry("relief_road_report", "third", "Third consequence"),
		_entry("workshop_can_wait", "fourth", "Fourth consequence"),
		_entry("relief_road_warning", "fifth", "Fifth consequence"),
		_entry("workshop_can_wait", "newest", "Newest consequence")
	]:
		ui.keep.event_history.append(entry)
	ui.keep.event_flags = {"signal_read": true, "refuge_steadied": false}
	ui.keep.last_outcome = "partial_breach"
	var before: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_ui()
	var ledger_text: String = ui.campaign_ledger_label.text
	_check(ledger_text.contains("RECENT EVENTS — newest 5 of 6"), "Campaign Ledger should label bounded newest-first history")
	_check(ledger_text.find("Newest consequence") < ledger_text.find("Fifth consequence"), "Campaign Ledger should list newest consequences first")
	_check(not ledger_text.contains("Oldest consequence"), "Campaign Ledger should omit entries beyond the display bound")
	_check(ledger_text.contains("RUN FLAGS") and ledger_text.contains("Refuge Steadied: no") and ledger_text.contains("Signal Read: yes"), "Campaign Ledger should expose sorted explicit run flags")
	ui._set_screen("results")
	await process_frame
	var result_text: String = ui.scorecard_label.text
	_check(result_text.contains("EVENT CONSEQUENCES — newest 5 of 6"), "Results should label bounded event consequences")
	_check(result_text.find("Newest consequence") < result_text.find("Fifth consequence") and not result_text.contains("Oldest consequence"), "Results should reuse the newest-first bounded event projection")
	ui._toggle_contrast()
	ui._refresh_ui()
	_check(JSON.stringify(ui.keep.serialize()) == before, "Ledger inspection, Results rendering, and display toggles should not mutate authoritative state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P13 event history Ledger/Results UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
