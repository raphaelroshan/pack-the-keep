extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _prepare_terminal(state: RefCounted, gate_condition: int, supply_condition: int, outcome: String) -> void:
	state.select_scenario("gatehouse_lock")
	state.rooms.gate.condition = gate_condition
	state.rooms.supply_room.condition = supply_condition
	state._update_room_state("gate")
	state._update_room_state("supply_room")
	state.last_outcome = outcome
	state.wave_index = state.authored_wave_count()
	state.repair_interval_active = outcome != "collapse"
	state.repair_actions_remaining = 2 if state.repair_interval_active else 0

func _initialize() -> void:
	var connected = PackKeepState.new(8201)
	_check(connected.region_ids() == ["low_mill"], "P15 should expose one bounded regional definition")
	_prepare_terminal(connected, 85, 74, "held")
	_check(bool(connected.finish_repair_interval().get("ok", false)), "terminal recovery should close")
	var connected_result: Dictionary = connected.regional_consequence()
	_check(String(connected_result.get("consequence_id", "")) == "council_commits_grain", "healthy route anchors should commit Low Mill grain")
	_check(String(connected_result.get("route_status", "")) == "open" and String(connected_result.get("settlement_status", "")) == "connected", "healthy anchors should leave Low Mill connected by an open route")
	_check(int(connected_result.get("next_run_materials", 0)) == 3 and bool(connected_result.get("pending_support", false)), "open route should queue exactly three materials")
	_check(connected.scenario_report().get("regional_consequence", {}) == connected_result, "scenario report should expose the authoritative regional consequence")

	var pending_snapshot: Dictionary = connected.serialize()
	var restored = PackKeepState.new(1)
	_check(bool(restored.load_serialized(pending_snapshot).get("ok", false)), "pending regional support should load")
	_check(restored.regional_consequence() == connected_result, "pending regional state should round-trip")
	restored.reset_run(8201)
	_check(restored.current_regional_consequence().is_empty(), "a prior regional report should not masquerade as the new run's result")
	var baseline = PackKeepState.new(8201)
	baseline.select_scenario("ash_ford_crossing")
	var expected_materials: int = baseline.materials
	restored.select_scenario("ash_ford_crossing")
	_check(restored.materials == expected_materials + 3, "Low Mill support should apply once to the next selected scenario")
	_check(restored.current_regional_consequence().is_empty(), "applied support should remain Ledger history until the new defense resolves")
	_check(not bool(restored.regional_state.get("pending_support", true)) and String(restored.regional_state.get("applied_to_scenario_id", "")) == "ash_ford_crossing", "applied support should record its target scenario")
	restored.select_commander("warden")
	_check(restored.materials == int(restored.commander_definition("warden").get("starting_materials", 0)) + restored.variation_materials + 3, "changing commander before placement should preserve applied regional support")
	var gatehouse_baseline = PackKeepState.new(8201)
	gatehouse_baseline.select_commander("warden")
	gatehouse_baseline.select_scenario("gatehouse_lock")
	restored.select_scenario("gatehouse_lock")
	_check(restored.materials == gatehouse_baseline.materials, "regional support should not apply to a second scenario selection")

	var cautious = PackKeepState.new(8202)
	_prepare_terminal(cautious, 65, 40, "partial_breach")
	cautious.finish_repair_interval()
	var cautious_result: Dictionary = cautious.regional_consequence()
	_check(String(cautious_result.get("consequence_id", "")) == "council_guards_its_stores" and int(cautious_result.get("next_run_materials", 0)) == 1, "functional but strained anchors should produce one cautious cart")

	var withdrawn = PackKeepState.new(8203)
	_prepare_terminal(withdrawn, 100, 100, "collapse")
	withdrawn._record_regional_consequence()
	var withdrawn_result: Dictionary = withdrawn.regional_consequence()
	_check(String(withdrawn_result.get("consequence_id", "")) == "council_turns_inward", "collapse should override healthy anchors and close the political route")
	_check(int(withdrawn_result.get("next_run_materials", -1)) == 0 and not bool(withdrawn_result.get("pending_support", true)), "closed route should inform without a compounding material penalty")

	var malformed: Dictionary = connected.serialize()
	malformed.regional_state = connected.regional_consequence()
	malformed.regional_state.consequence_id = "unknown_consequence"
	var rejected = PackKeepState.new(1)
	_check(not bool(rejected.load_serialized(malformed).get("ok", true)), "unknown saved regional consequences should be rejected before mutation")

	if failures.is_empty():
		print("P15 Low Mill regional consequence: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
