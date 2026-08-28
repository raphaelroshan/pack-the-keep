extends SceneTree

const ContentCatalog = preload("res://src/core/content_catalog.gd")
const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _fixture(with_station: bool = true, workshop_condition: int = 55) -> RefCounted:
	var state: RefCounted = PackKeepState.new(3307)
	state.select_scenario("gatehouse_lock")
	state.place_piece("pike_squad", Vector2i(0, 3), "ground")
	if with_station:
		state.open_pack("field_engineers")
		state.place_piece("repair_station", Vector2i(4, 6), "ground")
	state.wave_index = 2
	state.enemy_doctrine = "distributed_sabotage"
	state.last_outcome = "partial_breach"
	state.repair_interval_active = true
	state.repair_actions_remaining = 2
	state.rooms.workshop.condition = workshop_condition
	state._update_room_state("workshop")
	state._refresh_active_event()
	return state

func _initialize() -> void:
	var catalog_state: RefCounted = PackKeepState.new(3307)
	var catalog_status: Dictionary = catalog_state.content_catalog_status()
	_check(bool(catalog_status.get("ok", false)) and int(catalog_status.get("event_count", 0)) == 4, "P13 should load four runtime events")
	var event: Dictionary = catalog_state.event_definition("workshop_can_wait")
	_check(String(event.get("scenario", "")) == "gatehouse_lock" and event.get("choices", []).size() == 2, "Workshop Can Wait should be a two-choice Gatehouse Lock event")

	var catalog = ContentCatalog.new()
	catalog.load_default(PackKeepState.ROOMS.keys())
	var malformed: Dictionary = event.duplicate(true)
	malformed.eligibility.room_condition.room = "missing_room"
	malformed.choices[0].effects = [{"op": "repair_room", "room": "missing_room"}]
	malformed.choices[1].requirements.piece_available = "missing_piece"
	var validation_errors: Array[String] = catalog.validate_event_definition(malformed, "workshop_can_wait", PackKeepState.ROOMS.keys())
	_check(validation_errors.size() >= 3, "event validation should reject unknown eligibility, repair, and piece references")

	var stable: RefCounted = _fixture(true, 100)
	_check(stable.active_event_id.is_empty(), "a stable Workshop should not open the recovery event")

	var repair: RefCounted = _fixture()
	_check(repair.active_event_id == "workshop_can_wait", "a damaged Workshop should open the wave-two recovery event")
	_check(String(repair.finish_repair_interval().get("reason", "")) == "active_event_unresolved", "the unresolved Workshop event should block recovery closure")
	_check(String(repair.recovery_action_preview("repair_room", "", "workshop").get("reason", "")) == "resolve the active event first", "ordinary recovery controls should remain blocked by the event")
	var repair_preview: Dictionary = repair.event_choice_preview("repair_workshop")
	_check(bool(repair_preview.get("ok", false)), "Workshop repair should be a legal event choice")
	var repair_materials: int = repair.materials
	var repaired: Dictionary = repair.choose_event_option("repair_workshop")
	_check(bool(repaired.get("ok", false)) and repair.room_condition("workshop") == 85, "Workshop repair should restore 30 condition")
	_check(repair.materials == repair_materials - 8 and repair.repair_actions_remaining == 1, "Workshop repair should use normal material and action costs")
	_check(String(repair.event_history.back().get("choice_id", "")) == "repair_workshop", "Workshop repair should enter event history")

	var assign: RefCounted = _fixture()
	var assignment_preview: Dictionary = assign.event_choice_preview("assign_repair_station")
	_check(bool(assignment_preview.get("ok", false)), "an adjacent Repair Station should make the assignment choice legal")
	var assigned: Dictionary = assign.choose_event_option("assign_repair_station")
	_check(bool(assigned.get("ok", false)) and String(assign.assigned_rooms.get("workshop", "")) == "repair_station_1", "event assignment should use the stable eligible Repair Station instance")
	_check(String(assign.pieces["repair_station_1"].get("assignment", "")) == "workshop" and assign.repair_actions_remaining == 1, "event assignment should use normal assignment state and action cost")

	var absent: RefCounted = _fixture(false)
	var before_rejection: String = JSON.stringify(absent.serialize())
	var unavailable: Dictionary = absent.choose_event_option("assign_repair_station")
	_check(not bool(unavailable.get("ok", false)) and String(unavailable.get("reason", "")) == "event_requirement_piece_available", "assignment should reject a missing Repair Station with a stable reason")
	_check(JSON.stringify(absent.serialize()) == before_rejection, "a rejected Workshop choice should not mutate state")

	var active: RefCounted = _fixture()
	var restored: RefCounted = PackKeepState.new(1)
	var loaded: Dictionary = restored.load_serialized(active.serialize())
	_check(bool(loaded.get("ok", false)) and restored.active_event_id == "workshop_can_wait", "an active Workshop event should survive save/load")
	_check(JSON.stringify(restored.serialize()) == JSON.stringify(active.serialize()), "Workshop event save/load should round-trip exactly")

	var replay_a: RefCounted = _fixture()
	var replay_b: RefCounted = _fixture()
	replay_a.choose_event_option("repair_workshop")
	replay_b.choose_event_option("repair_workshop")
	_check(JSON.stringify(replay_a.serialize()) == JSON.stringify(replay_b.serialize()), "the Workshop event should replay deterministically")
	_check(String(replay_a.scenario_report().get("event_history", [])[0].get("visible_result", "")).contains("Workshop"), "the scenario report should expose the visible Workshop consequence")

	if failures.is_empty():
		print("P13 Workshop Can Wait: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
