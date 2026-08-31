extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var ash = PackKeepState.new(7401)
	_check(ash.keep_ids() == ["greywatch_keep", "ash_ford_redoubt", "twinwatch_bastion"], "the keep catalog should preserve Ash Ford and expose the later Twinwatch identity")
	_check(bool(ash.select_scenario("ash_ford_crossing").get("ok", false)), "Ash Ford scenario should be selectable")
	_check(ash.keep_id == "ash_ford_redoubt", "Ash Ford scenario should activate its own keep")
	_check(String(ash.room_definition("gate").get("name", "")) == "West Bridgehead", "Ash Ford should rename the gate function")
	_check(ash.room_definition("gate").get("origin") == Vector2i(0, 3), "Ash Ford should use its distinct room position")
	_check(ash.keep_definition().get("connections", []) != ash.keep_definition("greywatch_keep").get("connections", []), "Ash Ford should use a distinct room graph")
	_check(ash.scenario_preview().get("recommended_packs", []) == ["runner_network", "field_engineers"], "Ash Ford should teach the mobile-repair pack pairing")

	var clear_rule: Dictionary = ash.spatial_rule_state()
	_check(bool(clear_rule.get("active", false)), "Ash Ford causeway should begin clear")
	ash._apply_room_damage("raider", "gate", 3, false, false)
	_check(ash.room_condition("gate") == 70, "clear causeway should reduce three damage to two before condition loss")
	_check(int(ash.combat_metrics.get("room_damage", 0)) == 30, "clear causeway mitigation should be reflected in authoritative metrics")

	var blocked = PackKeepState.new(7401)
	blocked.select_scenario("ash_ford_crossing")
	_check(bool(blocked.place_piece("pike_squad", Vector2i(3, 3), "ground").get("ok", false)), "a deliberate causeway blocker should be a legal trade-off")
	_check(not bool(blocked.spatial_rule_state().get("active", true)), "a footprint on a marked causeway cell should disable the keep rule")
	blocked._apply_room_damage("raider", "gate", 3, false, false)
	_check(blocked.room_condition("gate") == 55, "blocked causeway should take the unreduced three damage")

	ash.rooms.gate.condition = 40
	ash._update_room_state("gate")
	ash.repair_interval_active = true
	ash.repair_actions_remaining = 2
	ash.materials = 5
	var ash_repair_preview: Dictionary = ash.recovery_action_preview("repair_room", "", "gate")
	_check(int(ash_repair_preview.get("material_cost", 0)) == 5 and String(ash_repair_preview.get("benefit", "")).contains("20"), "Ash Ford should expose shallow five-material repairs")
	_check(bool(ash.repair_room("gate").get("ok", false)) and ash.room_condition("gate") == 60 and ash.materials == 0, "Ash Ford room repair should restore exactly twenty condition")

	var greywatch = PackKeepState.new(7401)
	greywatch.select_scenario("gatehouse_lock")
	greywatch.rooms.gate.condition = 40
	greywatch._update_room_state("gate")
	greywatch.repair_interval_active = true
	greywatch.repair_actions_remaining = 2
	greywatch.materials = 8
	var greywatch_preview: Dictionary = greywatch.recovery_action_preview("repair_room", "", "gate")
	_check(int(greywatch_preview.get("material_cost", 0)) == 8, "Greywatch should preserve its deep eight-material repair")
	_check(bool(greywatch.repair_room("gate").get("ok", false)) and greywatch.room_condition("gate") == 70, "Greywatch should preserve its thirty-condition repair")

	var snapshot: Dictionary = ash.serialize()
	var restored = PackKeepState.new(1)
	_check(bool(restored.load_serialized(snapshot).get("ok", false)), "Ash Ford save should load")
	_check(restored.keep_id == "ash_ford_redoubt" and String(restored.room_definition("gate").get("name", "")) == "West Bridgehead", "save/load should restore the scenario-derived keep identity")
	_check(JSON.stringify(restored.serialize()) == JSON.stringify(snapshot), "Ash Ford save should round-trip byte-for-byte")

	if failures.is_empty():
		print("P15 Ash Ford identity: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
