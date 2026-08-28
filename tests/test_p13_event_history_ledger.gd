extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _history_entry(event_id: String, choice_id: String, wave: int) -> Dictionary:
	return {
		"event_id": event_id,
		"choice_id": choice_id,
		"wave": wave,
		"phase": "recovery",
		"visible_result": "%s consequence" % choice_id,
		"state_changes": []
	}

func _initialize() -> void:
	var state: RefCounted = PackKeepState.new(3307)
	for entry in [
		_history_entry("relief_road_warning", "read_signal", 0),
		_history_entry("relief_road_recovery", "release_field_stores", 1),
		_history_entry("relief_road_report", "record_the_cost", 3),
		_history_entry("workshop_can_wait", "repair_workshop", 2)
	]:
		state.event_history.append(entry)
	state.event_flags = {"signal_read": true, "refuge_steadied": false}
	var before: String = JSON.stringify(state.serialize())
	var ledger: Dictionary = state.event_ledger_snapshot(3)
	var entries: Array = ledger.get("entries", [])
	var flags: Array = ledger.get("flags", [])
	_check(int(ledger.get("total", 0)) == 4 and bool(ledger.get("truncated", false)), "ledger snapshot should report bounded history metadata")
	_check(entries.size() == 3, "ledger snapshot should honor the requested limit")
	_check(String(entries[0].get("event_id", "")) == "workshop_can_wait" and String(entries[1].get("event_id", "")) == "relief_road_report", "ledger history should be newest-first")
	_check(String(entries[0].get("title", "")) == "The Workshop Can Wait", "ledger entries should expose authored event titles")
	_check(flags.size() == 2 and String(flags[0].get("id", "")) == "refuge_steadied" and not bool(flags[0].get("value", true)) and String(flags[1].get("id", "")) == "signal_read", "ledger flags should be stable-ID sorted with explicit values")
	_check(JSON.stringify(state.serialize()) == before, "ledger projection should not mutate authoritative state")

	if failures.is_empty():
		print("P13 event history ledger: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
