extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")
const BoardVisualRegistry = preload("res://src/ui/board_visual_registry.gd")

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

func _test_breadth_and_keep_distribution() -> void:
	var state: RefCounted = PackKeepState.new(6101)
	var status: Dictionary = state.content_catalog_status()
	_check(bool(status.get("ok", false)), "Early Access runtime catalog should load cleanly")
	_check(int(status.get("keep_count", 0)) == 3, "Early Access should contain three keeps")
	_check(int(status.get("commander_count", 0)) == 4, "Early Access should contain four commanders")
	_check(int(status.get("pack_count", 0)) == 15, "Early Access should contain fifteen packs")
	_check(int(status.get("piece_count", 0)) == 29, "Early Access should contain twenty-nine pieces")
	_check(int(status.get("enemy_count", 0)) == 12, "Early Access should contain twelve enemies")
	_check(int(status.get("scenario_count", 0)) == 20, "Early Access should contain twenty scenarios")
	_check(int(status.get("event_count", 0)) == 14, "Early Access should contain fourteen events")
	var counts: Dictionary = {}
	for scenario_id in state.scenario_ids():
		var keep_id: String = String(state.scenario_definition(scenario_id).get("keep_id", ""))
		counts[keep_id] = int(counts.get(keep_id, 0)) + 1
	_check(int(counts.get("greywatch_keep", 0)) >= 6, "Greywatch should retain at least six scenarios")
	_check(int(counts.get("ash_ford_redoubt", 0)) >= 6, "Ash Ford should expose at least six scenarios")
	_check(int(counts.get("twinwatch_bastion", 0)) >= 6, "Twinwatch should expose at least six scenarios")
	for commander_id in state.commander_ids():
		for keep_id in state.keep_ids():
			_check(not state.commander_definition(commander_id).is_empty() and not state.keep_definition(keep_id).is_empty(), "%s/%s should be an available commander/keep start" % [commander_id, keep_id])

func _assigned_marshal_fixture() -> RefCounted:
	var state: RefCounted = PackKeepState.new(6102)
	state.select_commander("marshal")
	state.open_pack("pike_line")
	state.place_piece("pike_squad", Vector2i(0, 3), "ground")
	state.start_wave(state.enemy_doctrine)
	while state.wave_active:
		state.advance_wave(1.0)
	var pike_id: String = _piece_instance(state, "pike_squad")
	state.assign_piece_to_room(pike_id, "gate")
	state.finish_repair_interval()
	return state

func _test_marshal_command_network() -> void:
	var state: RefCounted = _assigned_marshal_fixture()
	var pike_id: String = _piece_instance(state, "pike_squad")
	var projection: Dictionary = state._defender_attack_projection(pike_id, "raider")
	_check(int(projection.get("damage", 0)) == 7, "Posted Orders should add one response to the assigned Gate Pike")
	state._set_piece_health(pike_id, 8)
	_check(bool(state.start_wave(state.enemy_doctrine).get("ok", false)), "Marshal fixture should start an assault")
	_check(bool(state.commander_ability_preview().get("ok", false)), "Relief Order should be ready for a damaged assigned defender")
	var before_command: int = state.command_points
	var result: Dictionary = state.use_commander_ability()
	_check(bool(result.get("ok", false)) and int(state.pieces[pike_id].get("health", 0)) == 12, "Relief Order should restore four assigned health")
	_check(state.relief_order_used and state.command_points == before_command - 1, "Relief Order should spend one command and become used")
	var saved: Dictionary = state.serialize()
	var restored: RefCounted = PackKeepState.new(1)
	var load_result: Dictionary = restored.load_serialized(saved)
	_check(bool(load_result.get("ok", false)) and restored.relief_order_used, "Marshal state should survive save/load: %s" % String(load_result.get("reason", "")))
	_check(JSON.stringify(restored.serialize()) == JSON.stringify(saved), "Marshal save should round-trip byte-for-byte")

func _test_new_enemy_counterplay() -> void:
	var state: RefCounted = PackKeepState.new(6103)
	state.open_pack("crossbow_watch")
	state.open_pack("ridge_company")
	_check(bool(state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper").get("ok", false)), "Crossbow Patrol should place for Harrier fixture")
	_check(bool(state.place_piece("ridge_sentinel", Vector2i(4, 1), "upper").get("ok", false)), "Ridge Sentinel should place for Harrier fixture")
	var crossbow_id: String = _piece_instance(state, "crossbow_patrol")
	var sentinel_id: String = _piece_instance(state, "ridge_sentinel")
	state.pieces[crossbow_id].ammo = 1
	state.pieces[sentinel_id].ammo = 4
	_check(state._choose_piece_target(state.enemy_definition("harrier")) == crossbow_id, "Harrier should target the lowest ammunition ratio, then stable ties")
	var mason_state: RefCounted = PackKeepState.new(6104)
	mason_state.select_commander("quartermaster")
	mason_state.open_pack("mason_train")
	mason_state.place_piece("mason_crew", Vector2i(0, 3), "ground")
	var mason_id: String = _piece_instance(mason_state, "mason_crew")
	_check(int(mason_state._defender_attack_projection(mason_id, "battering_ram").get("damage", 0)) == 4, "Mason Crew should pierce Battering Ram armor")
	var ram_visual: Dictionary = BoardVisualRegistry.enemy_profile("battering_ram", "demolition")
	var harrier_visual: Dictionary = BoardVisualRegistry.enemy_profile("harrier", "ranged")
	_check(String(ram_visual.get("asset_status", "")) == "authored_original" and FileAccess.file_exists(String(ram_visual.get("sprite_path", ""))), "Battering Ram should use an authored silhouette")
	_check(String(harrier_visual.get("asset_status", "")) == "authored_original" and FileAccess.file_exists(String(harrier_visual.get("sprite_path", ""))), "Harrier should use an authored silhouette")

func _test_authored_event_branches() -> void:
	var flood: RefCounted = PackKeepState.new(6105)
	flood.select_scenario("flood_mark")
	_check(flood.active_event_id == "flood_mark_choice", "Flood Mark should open its preparation event")
	var materials_before: int = flood.materials
	_check(bool(flood.choose_event_option("release_stone_wagon").get("ok", false)), "Flood Mark material branch should resolve")
	_check(flood.materials == materials_before + 3 and bool(flood.event_flags.get("flood_stone_released", false)), "Flood Mark branch should persist its visible consequence")
	var twin: RefCounted = PackKeepState.new(6106)
	twin.select_commander("marshal")
	twin.select_scenario("two_fires")
	_check(twin.active_event_id == "twinwatch_signal", "Two Fires should open its forecast event")
	_check(bool(twin.choose_event_option("reserve_relief_signal").get("ok", false)), "Twinwatch command branch should resolve")
	_check(bool(twin.event_flags.get("relief_signal_reserved", false)), "Twinwatch command branch should persist")

func _initialize() -> void:
	_test_breadth_and_keep_distribution()
	_test_marshal_command_network()
	_test_new_enemy_counterplay()
	_test_authored_event_branches()
	if failures.is_empty():
		print("PTK Early Access campaign: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
