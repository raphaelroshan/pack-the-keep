extends SceneTree

const ContentCatalog = preload("res://src/core/content_catalog.gd")
const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _piece_instance(state: RefCounted, piece_id: String) -> String:
	for instance_id_value in state.pieces.keys():
		var instance_id: String = String(instance_id_value)
		if String(state.pieces[instance_id].get("piece_id", "")) == piece_id:
			return instance_id
	return ""

func _supply_recovery_gain(commander_id: String) -> int:
	var state: RefCounted = PackKeepState.new(5101)
	state.select_commander(commander_id)
	state.open_pack("runner_network")
	state.place_piece("supply_cache", Vector2i(6, 3), "ground")
	var before: int = state.materials
	state._open_repair_interval("held")
	return state.materials - before

func _quartermaster_ability_fixture(seed: int) -> RefCounted:
	var state: RefCounted = PackKeepState.new(seed)
	state.select_commander("quartermaster")
	state.select_scenario("red_banner_road")
	state.open_pack("crossbow_watch")
	state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
	state.start_wave(state.enemy_doctrine)
	return state

func _initialize() -> void:
	var catalog: RefCounted = ContentCatalog.new()
	var loaded: Dictionary = catalog.load_default(PackKeepState.ROOMS.keys())
	_check(bool(loaded.get("ok", false)), "P51 runtime content should validate")
	_check(catalog.commander_ids() == ["castellan", "warden", "quartermaster"], "Quartermaster should be the third stable commander")
	var definition: Dictionary = catalog.commander_definition("quartermaster")
	_check(String(definition.get("ability", "")) == "resupply", "Quartermaster should expose Resupply")
	_check(String(definition.get("passive_profile", {}).get("kind", "")) == "reserve_economy", "Quartermaster should declare reserve economy authority")
	var malformed: Dictionary = definition.duplicate(true)
	malformed.passive_profile.first_pack_discount = -1
	malformed.ability_profile.kind = "lockdown"
	var malformed_errors: Array[String] = catalog.validate_commander_definition(malformed, "quartermaster")
	_check(malformed_errors.size() >= 2, "commander validation should reject an unbounded discount and mismatched ability profile")

	var economy: RefCounted = PackKeepState.new(5102)
	economy.select_commander("quartermaster")
	var first_preview: Dictionary = economy.pack_preview("pike_line")
	_check(int(first_preview.get("base_cost", -1)) == 4 and int(first_preview.get("cost", -1)) == 2 and int(first_preview.get("discount", -1)) == 2, "first pack preview should expose the exact Measured Stores discount")
	var first_open: Dictionary = economy.open_pack("pike_line")
	_check(bool(first_open.get("ok", false)) and int(first_open.get("cost", -1)) == 2 and economy.materials == 46, "first pack should spend its discounted authoritative cost")
	var second_preview: Dictionary = economy.pack_preview("field_engineers")
	_check(int(second_preview.get("cost", -1)) == 4 and int(second_preview.get("discount", -1)) == 0, "second pack should return to authored cost")
	_check(_supply_recovery_gain("quartermaster") == 7, "Quartermaster Supply Cache should release seven materials")
	_check(_supply_recovery_gain("warden") == 5, "other commanders should retain the five-material Supply Cache contract")

	var ability_state: RefCounted = _quartermaster_ability_fixture(5103)
	var crossbow_id: String = _piece_instance(ability_state, "crossbow_patrol")
	_check(not crossbow_id.is_empty(), "Resupply fixture should contain a Crossbow Patrol")
	var command_before: int = ability_state.command_points
	var no_op: Dictionary = ability_state.use_commander_ability()
	_check(not bool(no_op.get("ok", false)) and ability_state.command_points == command_before and not ability_state.resupply_used, "Resupply should reject a no-op without spending command")
	ability_state._set_piece_health(crossbow_id, 6)
	ability_state.pieces[crossbow_id].ammo = 1
	var resupply: Dictionary = ability_state.use_commander_ability()
	_check(bool(resupply.get("ok", false)) and int(ability_state.pieces[crossbow_id].get("health", 0)) == 8 and int(ability_state.pieces[crossbow_id].get("ammo", 0)) == 3, "Resupply should restore bounded health and ammunition")
	_check(ability_state.command_points == command_before - 1 and ability_state.resupply_used, "Resupply should cost one command and become spent")
	_check(not bool(ability_state.use_commander_ability().get("ok", false)), "Resupply should be limited to once per assault")

	var saved: Dictionary = ability_state.serialize()
	var restored: RefCounted = PackKeepState.new(1)
	var load_result: Dictionary = restored.load_serialized(saved)
	_check(bool(load_result.get("ok", false)) and restored.commander_id == "quartermaster" and restored.resupply_used, "save/load should preserve Quartermaster and spent Resupply state")
	_check(JSON.stringify(restored.serialize()) == JSON.stringify(saved), "Quartermaster mid-assault save should round-trip deterministically")

	if failures.is_empty():
		print("P51 Quartermaster: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
