extends SceneTree

const ContentCatalog = preload("res://src/core/content_catalog.gd")
const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _load_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func _sorted_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(String(value))
	result.sort()
	return result

func _initialize() -> void:
	var catalog: RefCounted = ContentCatalog.new()
	var loaded: Dictionary = catalog.load_default(PackKeepState.ROOMS.keys())
	_check(bool(loaded.get("ok", false)), "runtime catalog rejected the P14 event contract: %s" % "; ".join(loaded.get("errors", [])))

	var schema: Dictionary = _load_json("res://content/event_schema.json")
	var contract: Dictionary = catalog.event_schema_contract()
	_check(int(schema.get("schema_version", 0)) == 1, "event schema version is missing")
	_check(_sorted_strings(schema.get("required_event_fields", [])) == _sorted_strings(contract.get("required_event_fields", [])), "event schema required fields drifted from the runtime validator")
	_check(_sorted_strings(schema.get("required_choice_fields", [])) == _sorted_strings(contract.get("required_choice_fields", [])), "event schema choice fields drifted from the runtime validator")
	_check(_sorted_strings(schema.get("selection", {}).get("required_fields", [])) == _sorted_strings(contract.get("selection", {}).get("required_fields", [])), "event schema selection fields drifted from the runtime validator")
	_check(_sorted_strings(schema.get("selection", {}).get("repeat_policies", [])) == _sorted_strings(contract.get("selection", {}).get("repeat_policies", [])), "event schema repeat policies drifted from the runtime validator")
	_check(int(schema.get("selection", {}).get("maximum_cooldown_waves", -1)) == int(contract.get("selection", {}).get("maximum_cooldown_waves", -2)), "event schema cooldown bound drifted from the runtime validator")
	_check(int(schema.get("selection", {}).get("maximum_occurrences", -1)) == int(contract.get("selection", {}).get("maximum_occurrences", -2)), "event schema occurrence bound drifted from the runtime validator")
	_check(_sorted_strings(schema.get("requirements", {}).keys()) == _sorted_strings(contract.get("requirements", [])), "event schema requirement operations drifted from the runtime validator")
	for requirement_id in schema.get("requirements", {}).keys():
		if String(requirement_id) != "piece_available":
			_check(_sorted_strings(schema.requirements[requirement_id]) == _sorted_strings(contract.get("requirement_operators", [])), "event schema operators drifted for %s" % String(requirement_id))
	_check(schema.get("effects", {}) == contract.get("effects", {}), "event schema effect payloads drifted from the runtime validator")

	var malformed: Dictionary = catalog.event_definition("relief_road_warning")
	malformed.selection = {"stream": "Not Stable", "repeat_policy": "repeat_after_cooldown", "cooldown_waves": 0, "max_occurrences": 4, "surprise": true}
	malformed.choices[0].effects = [{"op": "set_flag", "flag": "safe_flag", "prose": "true"}]
	var validation_errors: Array[String] = catalog.validate_event_definition(malformed, "relief_road_warning")
	var joined_errors: String = "; ".join(validation_errors)
	for expected in ["stream must be snake_case", "repeat_after_cooldown", "max_occurrences", "unsupported field: surprise", "missing required field: value", "unsupported field: prose"]:
		_check(joined_errors.contains(expected), "runtime validator did not report %s" % expected)

	var state: RefCounted = PackKeepState.new(4401)
	var repeatable: Dictionary = {
		"id": "repeatable_test",
		"selection": {"stream": "repeatable_test", "repeat_policy": "repeat_after_cooldown", "cooldown_waves": 1, "max_occurrences": 2}
	}
	state.wave_index = 1
	state.repair_interval_active = true
	state.event_history.clear()
	state.event_history.append({"event_id": "repeatable_test", "wave": 1, "phase": "recovery"})
	state.resolved_event_ids.clear()
	state.resolved_event_ids.append("repeatable_test")
	_check(not state._event_repeat_policy_allows(repeatable), "repeatable event reopened at its original trigger point")
	state.wave_index = 2
	_check(not state._event_repeat_policy_allows(repeatable), "repeatable event ignored its one-wave cooldown")
	state.wave_index = 3
	_check(state._event_repeat_policy_allows(repeatable), "repeatable event did not reopen after its cooldown")
	state.event_history.append({"event_id": "repeatable_test", "wave": 3, "phase": "recovery"})
	_check(not state._event_repeat_policy_allows(repeatable), "repeatable event exceeded max_occurrences")

	var once: Dictionary = {
		"id": "once_test",
		"selection": {"stream": "once_test", "repeat_policy": "once_per_run", "cooldown_waves": 0, "max_occurrences": 1}
	}
	state.event_history.clear()
	state.resolved_event_ids.clear()
	state.resolved_event_ids.append("once_test")
	_check(not state._event_repeat_policy_allows(once), "once-per-run event reopened after resolution")

	if failures.is_empty():
		print("P14 event authoring safety: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
