extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")
const ContentCatalog = preload("res://src/core/content_catalog.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _recovery_fixture(material_count: int = 60, workshop_condition: int = 55) -> RefCounted:
	var state: RefCounted = PackKeepState.new(3307)
	state.select_scenario("wrong_wall")
	state.choose_event_option("hold_gate_command")
	state.wave_index = 1
	state.last_outcome = "partial_breach"
	state.repair_interval_active = true
	state.repair_actions_remaining = 2
	state.materials = material_count
	state.rooms.workshop.condition = workshop_condition
	state._update_room_state("workshop")
	state._refresh_active_event()
	return state

func _initialize() -> void:
	var catalog = ContentCatalog.new()
	catalog.load_default(PackKeepState.ROOMS.keys())
	var malformed_report: Dictionary = catalog.event_definition("wrong_wall_report")
	malformed_report.trigger.wave = [1, 1, 4]
	var trigger_errors: Array[String] = catalog.validate_event_definition(malformed_report, "wrong_wall_report", PackKeepState.ROOMS.keys())
	_check(trigger_errors.size() >= 2, "event validation should reject duplicate and out-of-range trigger waves")

	var opening: RefCounted = PackKeepState.new(3307)
	opening.select_scenario("wrong_wall")
	_check(opening.active_event_id == "the_bell_has_a_pattern", "Wrong Wall should open its forecast event in Preparation")
	var command_before: int = opening.command_points
	opening.choose_event_option("hold_gate_command")
	_check(opening.command_points == command_before and bool(opening.event_flags.get("wrong_wall_warning_declined", false)), "forecast decline should preserve command and record the explicit path")

	var scarce: RefCounted = _recovery_fixture(7)
	_check(scarce.active_event_id == "the_gate_is_not_the_keep", "wave-one recovery should open the second Wrong Wall beat")
	_check(String(scarce.event_choice_preview("repair_workshop").get("reason", "")) == "event_requirement_materials", "scarcity should block Workshop repair with a stable reason")
	_check(bool(scarce.event_choice_preview("defer_workshop").get("ok", false)), "the decline path should remain legal when repair is unaffordable")
	var scarce_before: String = JSON.stringify(scarce.serialize())
	var restored: RefCounted = PackKeepState.new(1)
	_check(bool(restored.load_serialized(scarce.serialize()).get("ok", false)) and JSON.stringify(restored.serialize()) == scarce_before and restored.active_event_id == "the_gate_is_not_the_keep", "an active Wrong Wall recovery event should save and load exactly")
	restored.choose_event_option("defer_workshop")
	_check(bool(restored.event_flags.get("wrong_wall_workshop_deferred", false)) and restored.materials == 7 and restored.repair_actions_remaining == 2, "declining recovery should preserve scarce resources and record the consequence")

	var repaired: RefCounted = _recovery_fixture()
	var repaired_result: Dictionary = repaired.choose_event_option("repair_workshop")
	_check(bool(repaired_result.get("ok", false)) and repaired.room_condition("workshop") == 85 and repaired.materials == 52 and repaired.repair_actions_remaining == 1, "the recovery choice should reuse authoritative Workshop repair costs and condition")

	var collapsed: RefCounted = _recovery_fixture()
	collapsed.choose_event_option("defer_workshop")
	collapsed.repair_interval_active = false
	collapsed.repair_actions_remaining = 0
	collapsed.last_outcome = "collapse"
	collapsed._refresh_active_event()
	_check(collapsed.active_event_id == "wrong_wall_report", "the conclusion report should open after an early collapse")
	_check(bool(collapsed.choose_event_option("record_wrong_wall").get("ok", false)) and collapsed.active_event_id.is_empty(), "the collapse-safe report should resolve without resources")

	var complete: RefCounted = _recovery_fixture()
	complete.choose_event_option("repair_workshop")
	complete.wave_index = 3
	complete.last_outcome = "held"
	complete.repair_interval_active = true
	complete._refresh_active_event()
	_check(complete.active_event_id == "wrong_wall_report", "the conclusion report should open after the authored third wave")
	complete.choose_event_option("record_wrong_wall")
	_check(complete.event_history.size() == 3 and String(complete.event_history.back().get("choice_id", "")) == "record_wrong_wall", "the full three-event chain should enter report history")

	var replay_a: RefCounted = _recovery_fixture()
	var replay_b: RefCounted = _recovery_fixture()
	replay_a.choose_event_option("defer_workshop")
	replay_b.choose_event_option("defer_workshop")
	_check(JSON.stringify(replay_a.serialize()) == JSON.stringify(replay_b.serialize()), "Wrong Wall choices should replay deterministically")

	if failures.is_empty():
		print("P13 Wrong Wall chain: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
