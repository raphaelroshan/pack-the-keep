extends SceneTree

const ContentCatalog = preload("res://src/core/content_catalog.gd")
const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var catalog: RefCounted = ContentCatalog.new()
	var loaded: Dictionary = catalog.load_default(PackKeepState.ROOMS.keys())
	_check(bool(loaded.get("ok", false)), "active runtime catalog did not load cleanly: %s" % "; ".join(loaded.get("errors", [])))
	var known_doctrines: Array = catalog.doctrine_ids()
	_check(known_doctrines == ["gate_assault", "distributed_sabotage", "feint_and_flank", "area_pressure", "rolling_breach", "shielded_advance", "smoke_and_signal", "break_the_line"], "doctrine catalog order or active IDs changed")
	var expected_doctrines: Dictionary = {
		"gate_assault": {"composition": ["raider", "raider"], "target": "gate", "pressure": "Gate concentration"},
		"distributed_sabotage": {"composition": ["raider", "sapper"], "target": "workshop or supply_room", "pressure": "Workshop and Supply Room support chain"},
		"feint_and_flank": {"composition": ["raider", "climber"], "target": "north_tower or old_chapel", "pressure": "North Tower and upper response lane"},
		"area_pressure": {"composition": ["siege_beast"], "target": "inner_yard or outer_wall", "pressure": "Inner Yard and adjacent support rooms"},
		"rolling_breach": {"composition": ["raider", "sapper", "siege_beast"], "target": "gate, then the weakest support room", "pressure": "Gate, support chain, and fallback space"},
		"shielded_advance": {"composition": ["shield_guard", "shield_guard"], "target": "barracks or gate", "pressure": "Barracks and Gate response organization"},
		"smoke_and_signal": {"composition": ["ash_slinger", "ash_slinger"], "target": "gate, barracks, or north tower", "pressure": "Warning network and response timing"},
		"break_the_line": {"composition": ["shieldbreaker"], "target": "strongest frontline or fortification", "pressure": "Frontline concentration and protected room edges"}
	}
	for doctrine_id in expected_doctrines.keys():
		var doctrine: Dictionary = catalog.doctrine_definition(String(doctrine_id))
		_check(doctrine.get("composition", []) == expected_doctrines[doctrine_id].composition, "%s composition changed during externalization" % doctrine_id)
		_check(String(doctrine.get("likely_target", "")) == String(expected_doctrines[doctrine_id].target), "%s forecast target changed during externalization" % doctrine_id)
		_check(String(doctrine.get("principal_pressure", "")) == String(expected_doctrines[doctrine_id].pressure), "%s pressure summary changed during externalization" % doctrine_id)
	var copied_doctrine: Dictionary = catalog.doctrine_definition("gate_assault")
	copied_doctrine.composition.append("sapper")
	_check(catalog.doctrine_definition("gate_assault").get("composition", []).size() == 2, "callers can mutate the catalog's stored doctrine definition")
	var malformed_doctrine: Dictionary = catalog.doctrine_definition("gate_assault")
	malformed_doctrine.erase("question")
	malformed_doctrine.composition = ["missing_enemy"]
	malformed_doctrine.counter_families = ["only_one"]
	var doctrine_errors: Array[String] = catalog.validate_doctrine_definition(malformed_doctrine, "wrong_filename", catalog.enemy_ids())
	_check(doctrine_errors.size() >= 4, "catalog validator did not reject missing fields, ID mismatch, enemy references, and incomplete counters")
	_check(catalog.keep_ids() == ["greywatch_keep", "ash_ford_redoubt"], "keep catalog order or active IDs changed")
	_check(catalog.region_ids() == ["low_mill"], "regional catalog order or active IDs changed")
	_check(catalog.scenario_ids() == ["gatehouse_lock", "wrong_wall", "open_yard_net", "relief_road", "red_banner_road", "ash_at_the_bell", "the_splintered_gate", "three_bells_at_dusk", "ash_ford_crossing", "last_stand"], "scenario catalog order or active IDs changed")
	_check(catalog.event_ids() == ["relief_road_warning", "relief_road_recovery", "relief_road_report", "workshop_can_wait", "mara_second_door", "old_drain_opens", "the_bell_has_a_pattern", "the_gate_is_not_the_keep", "wrong_wall_report"], "event catalog order or active IDs changed")
	_check(catalog.modifier_ids() == ["roadside_intelligence", "hardened_vanguard"], "modifier catalog order or active IDs changed")
	var intelligence: Dictionary = catalog.modifier_definition("roadside_intelligence")
	_check(String(intelligence.get("unlock_event", "")) == "relief_road_report" and int(intelligence.get("starting_morale_cost", 0)) == 1, "Roadside Intelligence did not load its unlock source and tradeoff")
	var hardened: Dictionary = catalog.modifier_definition("hardened_vanguard")
	_check(String(hardened.get("effect", "")) == "enemy_health_bonus" and int(hardened.get("enemy_health_bonus", 0)) == 2, "Hardened Vanguard did not load its bounded challenge effect")
	var malformed_modifier: Dictionary = intelligence.duplicate(true)
	malformed_modifier.effect = "raw_power"
	malformed_modifier.unlock_event = "missing_event"
	malformed_modifier.starting_morale_cost = -1
	var modifier_errors: Array[String] = catalog.validate_modifier_definition(malformed_modifier, "wrong_filename")
	_check(modifier_errors.size() >= 4, "catalog validator did not reject modifier ID, unlock, effect, and morale-cost failures")
	var malformed_hardened: Dictionary = hardened.duplicate(true)
	malformed_hardened.enemy_health_bonus = 9
	_check(not catalog.validate_modifier_definition(malformed_hardened, "hardened_vanguard").is_empty(), "catalog validator did not reject an out-of-bounds enemy health bonus")
	var mismatched_intelligence: Dictionary = intelligence.duplicate(true)
	mismatched_intelligence.enemy_health_bonus = 2
	_check(not catalog.validate_modifier_definition(mismatched_intelligence, "roadside_intelligence").is_empty(), "catalog validator accepted a health bonus on the information effect")
	var warning_event: Dictionary = catalog.event_definition("relief_road_warning")
	_check(String(warning_event.get("scenario", "")) == "relief_road" and warning_event.get("choices", []).size() == 2, "Relief Road warning event did not load its authored choices")
	var copied_event: Dictionary = catalog.event_definition("relief_road_warning")
	copied_event.choices.clear()
	_check(catalog.event_definition("relief_road_warning").get("choices", []).size() == 2, "callers can mutate the catalog's stored event definition")
	var malformed_event: Dictionary = catalog.event_definition("relief_road_warning")
	malformed_event.trigger = {"phase": "missing", "wave": 7}
	malformed_event.choices[0].effects = [{"op": "run_script", "code": "unsafe"}]
	malformed_event.choices.append(malformed_event.choices[0].duplicate(true))
	malformed_event.follow_up = "relief_road_warning"
	var event_errors: Array[String] = catalog.validate_event_definition(malformed_event, "wrong_filename")
	_check(event_errors.size() >= 5, "catalog validator did not reject event ID, trigger, effect, duplicate choice, and self-follow-up failures")
	var gatehouse: Dictionary = catalog.scenario_definition("gatehouse_lock")
	_check(String(gatehouse.get("starting_doctrine", "")) == "gate_assault" and gatehouse.get("wave_plans", []).size() == 3, "Gatehouse Lock sequence changed during externalization")
	_check(gatehouse.get("variations", []).size() == 3 and String(gatehouse.variations[1].get("id", "")) == "thin_supply", "Gatehouse Lock variations changed during externalization")
	var copied_scenario: Dictionary = catalog.scenario_definition("wrong_wall")
	copied_scenario.wave_plans.clear()
	_check(catalog.scenario_definition("wrong_wall").get("wave_plans", []).size() == 3, "callers can mutate the catalog's stored scenario definition")
	var malformed_scenario: Dictionary = catalog.scenario_definition("open_yard_net")
	malformed_scenario.erase("lesson")
	malformed_scenario.doctrines = ["missing_doctrine"]
	malformed_scenario.wave_plans = [["missing_enemy"]]
	malformed_scenario.variations = [{"id": "bad variation", "materials": 0.5, "morale": 0, "target_room": "missing_room"}]
	var scenario_errors: Array[String] = catalog.validate_scenario_definition(malformed_scenario, "wrong_filename", PackKeepState.ROOMS.keys())
	_check(scenario_errors.size() >= 6, "catalog validator did not reject missing fields, ID mismatch, wave shape, variation ID/value, and room references")
	_check(catalog.enemy_ids() == ["raider", "sapper", "climber", "siege_beast", "shield_guard", "ash_slinger", "shieldbreaker"], "enemy catalog order or active IDs changed")
	var expected_enemies: Dictionary = {
		"raider": {"health": 8, "damage": 2, "arrival": 2, "route": "gate_road", "targets": ["gate"], "doctrine": "gate_assault", "counter": "pike_squad"},
		"sapper": {"health": 5, "damage": 3, "arrival": 3, "route": "service_lane", "targets": ["workshop", "supply_room", "armory"], "doctrine": "distributed_sabotage", "counter": "scout_post"},
		"climber": {"health": 6, "damage": 2, "arrival": 2, "route": "north_tower_line", "targets": ["north_tower", "old_chapel"], "doctrine": "feint_and_flank", "counter": "fire_team"},
		"siege_beast": {"health": 16, "damage": 3, "arrival": 3, "route": "outer_approach", "targets": ["inner_yard", "outer_wall", "old_chapel", "workshop"], "doctrine": "area_pressure", "counter": "fire_team"},
		"shield_guard": {"health": 12, "damage": 2, "arrival": 3, "route": "gate_road", "targets": ["barracks", "gate", "inner_yard"], "doctrine": "shielded_advance", "counter": "crossbow_patrol"},
		"ash_slinger": {"health": 12, "damage": 2, "arrival": 3, "route": "gate_road", "targets": ["gate", "barracks", "north_tower"], "doctrine": "smoke_and_signal", "counter": "bellkeepers"},
		"shieldbreaker": {"health": 14, "damage": 3, "arrival": 2, "route": "gate_road", "targets": ["gate", "barracks", "inner_yard"], "doctrine": "break_the_line", "counter": "shield_wardens"}
	}
	for enemy_id in expected_enemies.keys():
		var enemy: Dictionary = catalog.enemy_definition(String(enemy_id))
		_check(int(enemy.get("health", -1)) == int(expected_enemies[enemy_id].health) and int(enemy.get("damage", -1)) == int(expected_enemies[enemy_id].damage), "%s health or damage changed during externalization" % enemy_id)
		_check(int(enemy.get("arrival_step", -1)) == int(expected_enemies[enemy_id].arrival) and String(enemy.get("route", "")) == String(expected_enemies[enemy_id].route), "%s timing or route changed during externalization" % enemy_id)
		_check(enemy.get("target_rooms", []) == expected_enemies[enemy_id].targets and String(enemy.get("doctrine", "")) == String(expected_enemies[enemy_id].doctrine), "%s targets or doctrine changed during externalization" % enemy_id)
		_check(String(enemy.get("counter", "")) == String(expected_enemies[enemy_id].counter), "%s counter changed during externalization" % enemy_id)
	var copied_enemy: Dictionary = catalog.enemy_definition("siege_beast")
	copied_enemy.health = 1
	_check(int(catalog.enemy_definition("siege_beast").get("health", -1)) == 16, "callers can mutate the catalog's stored enemy definition")
	var malformed_enemy: Dictionary = catalog.enemy_definition("sapper")
	malformed_enemy.erase("telegraph")
	malformed_enemy.health = 0
	malformed_enemy.target_rooms = ["missing_room"]
	malformed_enemy.doctrine = "missing_doctrine"
	malformed_enemy.counter = "missing_piece"
	malformed_enemy.counter_families = ["only_one"]
	var enemy_errors: Array[String] = catalog.validate_enemy_definition(malformed_enemy, "wrong_filename", PackKeepState.ROOMS.keys(), known_doctrines)
	_check(enemy_errors.size() >= 7, "catalog validator did not reject missing fields, ID mismatch, stats, room, doctrine, counter, and counter-family errors")
	var known_piece_targets: Array = catalog.enemy_ids()
	for doctrine in known_doctrines:
		if not known_piece_targets.has(doctrine):
			known_piece_targets.append(doctrine)
	_check(catalog.piece_ids() == ["pike_squad", "repair_station", "fire_team", "scout_post", "narrow_gate", "brace", "fire_brazier", "signal_beacon", "runner_pair", "supply_cache", "rear_guard", "breakaway_barricade", "crossbow_patrol", "watch_banner", "bellkeepers", "shield_wardens", "emergency_shutters"], "piece catalog order or active IDs changed")
	var expected_pieces: Dictionary = {
		"pike_squad": {"size": Vector2i(2, 1), "cost": 8, "health": 14, "ammo": 0, "attack": 4, "availability": "starter", "assignment": "gate"},
		"repair_station": {"size": Vector2i(2, 1), "cost": 10, "health": 10, "ammo": 0, "attack": 0, "availability": "field_engineers", "assignment": "workshop"},
		"fire_team": {"size": Vector2i(2, 1), "cost": 9, "health": 12, "ammo": 4, "attack": 3, "availability": "firekeepers", "assignment": "inner_yard"},
		"scout_post": {"size": Vector2i(1, 1), "cost": 6, "health": 8, "ammo": 0, "attack": 0, "availability": "scouts", "assignment": "north_tower"},
		"narrow_gate": {"size": Vector2i(1, 2), "cost": 7, "health": 18, "ammo": 0, "attack": 0, "availability": "starter", "assignment": ""},
		"brace": {"size": Vector2i(1, 1), "cost": 5, "health": 16, "ammo": 0, "attack": 0, "availability": "field_engineers", "assignment": ""},
		"fire_brazier": {"size": Vector2i(1, 1), "cost": 6, "health": 12, "ammo": 3, "attack": 1, "availability": "firekeepers", "assignment": ""},
		"signal_beacon": {"size": Vector2i(1, 1), "cost": 5, "health": 8, "ammo": 0, "attack": 0, "availability": "scouts", "assignment": ""},
		"crossbow_patrol": {"size": Vector2i(2, 1), "cost": 9, "health": 10, "ammo": 5, "attack": 3, "availability": "crossbow_watch", "assignment": ""},
		"watch_banner": {"size": Vector2i(1, 1), "cost": 6, "health": 10, "ammo": 0, "attack": 0, "availability": "crossbow_watch", "assignment": ""},
		"bellkeepers": {"size": Vector2i(1, 1), "cost": 6, "health": 8, "ammo": 0, "attack": 0, "availability": "bell_guard", "assignment": ""},
		"shield_wardens": {"size": Vector2i(2, 1), "cost": 10, "health": 16, "ammo": 0, "attack": 3, "availability": "shieldwall", "assignment": ""},
		"emergency_shutters": {"size": Vector2i(1, 1), "cost": 7, "health": 14, "ammo": 0, "attack": 0, "availability": "shieldwall", "assignment": ""}
	}
	for piece_id in expected_pieces.keys():
		var piece: Dictionary = catalog.piece_definition(String(piece_id))
		var assignment: Dictionary = piece.get("assignment_rule", {}) if piece.get("assignment_rule") is Dictionary else {}
		_check(piece.get("size", Vector2i.ZERO) == expected_pieces[piece_id].size, "%s footprint changed during externalization" % piece_id)
		_check(int(piece.get("cost", -1)) == int(expected_pieces[piece_id].cost) and int(piece.get("max_health", -1)) == int(expected_pieces[piece_id].health), "%s cost or health changed during externalization" % piece_id)
		_check(int(piece.get("max_ammo", -1)) == int(expected_pieces[piece_id].ammo) and int(piece.get("attack", -1)) == int(expected_pieces[piece_id].attack), "%s combat profile changed during externalization" % piece_id)
		_check(String(piece.get("availability", "")) == String(expected_pieces[piece_id].availability), "%s availability changed during externalization" % piece_id)
		_check(String(assignment.get("room", "")) == String(expected_pieces[piece_id].assignment), "%s assignment rule changed during externalization" % piece_id)
	var copied_piece: Dictionary = catalog.piece_definition("fire_team")
	copied_piece.attack = 999
	_check(int(catalog.piece_definition("fire_team").get("attack", -1)) == 3, "callers can mutate the catalog's stored piece definition")
	var malformed_piece: Dictionary = catalog.piece_definition("fire_team")
	malformed_piece.erase("question")
	malformed_piece.footprint = [0, 1]
	malformed_piece.allowed_floors = ["roof"]
	malformed_piece.allowed_zones = []
	malformed_piece.availability = "missing_pack"
	malformed_piece.attack_profile.targets = ["missing_enemy"]
	malformed_piece.assignment_rule = {"room": "missing_room", "effect": "bad reference"}
	var piece_errors: Array[String] = catalog.validate_piece_definition(malformed_piece, "wrong_filename", PackKeepState.ROOMS.keys(), known_piece_targets)
	_check(piece_errors.size() >= 8, "catalog validator did not reject missing fields, ID mismatch, footprint, floor, zone, availability, enemy, and room references")
	_check(catalog.commander_ids() == ["castellan", "warden"], "commander catalog order or active IDs changed")
	var expected_commanders: Dictionary = {
		"castellan": {"materials": 60, "morale": 6, "ability": "lockdown"},
		"warden": {"materials": 52, "morale": 7, "ability": "rally"}
	}
	for commander_id in expected_commanders.keys():
		var commander: Dictionary = catalog.commander_definition(String(commander_id))
		_check(int(commander.get("starting_materials", -1)) == int(expected_commanders[commander_id].materials), "%s starting materials changed during externalization" % commander_id)
		_check(int(commander.get("starting_morale", -1)) == int(expected_commanders[commander_id].morale), "%s starting morale changed during externalization" % commander_id)
		_check(String(commander.get("ability", "")) == String(expected_commanders[commander_id].ability), "%s ability changed during externalization" % commander_id)
		_check(not String(commander.get("question", "")).is_empty() and commander.get("favored_pack_families", []) is Array, "%s is missing the P6 authoring fields" % commander_id)
	var copied_commander: Dictionary = catalog.commander_definition("warden")
	copied_commander.starting_materials = 999
	_check(int(catalog.commander_definition("warden").get("starting_materials", -1)) == 52, "callers can mutate the catalog's stored commander definition")
	var malformed_commander: Dictionary = catalog.commander_definition("warden")
	malformed_commander.erase("question")
	malformed_commander.starting_morale = 11
	malformed_commander.favored_pack_families = ["missing_family"]
	var commander_errors: Array[String] = catalog.validate_commander_definition(malformed_commander, "wrong_filename")
	_check(commander_errors.size() >= 4, "catalog validator did not reject missing fields, ID mismatch, invalid morale, and unknown pack families")
	_check(catalog.pack_ids() == ["pike_line", "field_engineers", "firekeepers", "scouts", "runner_network", "fallback_convoy", "crossbow_watch", "bell_guard", "shieldwall"], "pack catalog order or active IDs changed")
	var expected: Dictionary = {
		"pike_line": {"cost": 4, "contents": ["pike_squad", "narrow_gate"], "doctrine": "compact_corridors"},
		"field_engineers": {"cost": 4, "contents": ["repair_station", "brace"], "doctrine": "redundancy"},
		"firekeepers": {"cost": 5, "contents": ["fire_team", "fire_brazier"], "doctrine": "denial_zones"},
		"scouts": {"cost": 3, "contents": ["scout_post", "signal_beacon"], "doctrine": "early_warning"},
		"runner_network": {"cost": 4, "contents": ["runner_pair", "supply_cache"], "doctrine": "rapid_redeployment"},
		"fallback_convoy": {"cost": 4, "contents": ["rear_guard", "breakaway_barricade"], "doctrine": "controlled_fallback"},
		"crossbow_watch": {"cost": 5, "contents": ["crossbow_patrol", "watch_banner"], "doctrine": "layered_crossfire"},
		"bell_guard": {"cost": 4, "contents": ["bellkeepers", "signal_beacon"], "doctrine": "coordinated_response"},
		"shieldwall": {"cost": 5, "contents": ["shield_wardens", "emergency_shutters"], "doctrine": "anchored_gates"}
	}
	for pack_id in expected.keys():
		var definition: Dictionary = catalog.pack_definition(String(pack_id))
		_check(int(definition.get("cost", -1)) == int(expected[pack_id].cost), "%s material cost changed during externalization" % pack_id)
		_check(definition.get("contents", []) == expected[pack_id].contents, "%s contents changed during externalization" % pack_id)
		_check(String(definition.get("doctrine", "")) == String(expected[pack_id].doctrine), "%s doctrine changed during externalization" % pack_id)
		_check(not String(definition.get("question", "")).is_empty() and definition.get("spatial_demand", {}) is Dictionary, "%s is missing the P6 authoring fields" % pack_id)
	var copied_definition: Dictionary = catalog.pack_definition("pike_line")
	copied_definition.cost = 999
	_check(int(catalog.pack_definition("pike_line").get("cost", -1)) == 4, "callers can mutate the catalog's stored pack definition")
	var malformed: Dictionary = catalog.pack_definition("pike_line")
	malformed.erase("question")
	malformed.contents = ["missing_piece"]
	var validation_errors: Array[String] = catalog.validate_pack_definition(malformed, "wrong_filename", catalog.piece_ids())
	_check(validation_errors.size() >= 3, "catalog validator did not reject missing fields, ID mismatch, and unknown piece references")

	var first: PackKeepState = PackKeepState.new(3307)
	var second: PackKeepState = PackKeepState.new(3307)
	_check(bool(first.content_catalog_status().get("ok", false)) and int(first.content_catalog_status().get("keep_count", 0)) == 2 and int(first.content_catalog_status().get("region_count", 0)) == 1 and int(first.content_catalog_status().get("pack_count", 0)) == 9 and int(first.content_catalog_status().get("commander_count", 0)) == 2 and int(first.content_catalog_status().get("piece_count", 0)) == 17 and int(first.content_catalog_status().get("enemy_count", 0)) == 7 and int(first.content_catalog_status().get("doctrine_count", 0)) == 8 and int(first.content_catalog_status().get("scenario_count", 0)) == 10 and int(first.content_catalog_status().get("event_count", 0)) == 9 and int(first.content_catalog_status().get("modifier_count", 0)) == 2, "KeepState did not expose the complete P30 runtime catalog")
	_check(first.piece_ids() == catalog.piece_ids(), "KeepState did not preserve stable piece order")
	_check(first.enemy_ids() == catalog.enemy_ids(), "KeepState did not preserve stable enemy order")
	_check(first.doctrine_ids() == catalog.doctrine_ids(), "KeepState did not preserve stable doctrine order")
	_check(first.scenario_ids() == catalog.scenario_ids(), "KeepState did not preserve stable scenario order")
	_check(first.commander_ids() == ["castellan", "warden"], "KeepState did not preserve stable commander order")
	var selected_warden: Dictionary = first.select_commander("warden")
	_check(bool(selected_warden.get("ok", false)) and first.materials == 52 and first.morale == 7, "externalized Warden did not preserve starting resources")
	_check(String(first.commander_definition("warden").get("ability", "")) == "rally", "externalized Warden did not preserve Rally")
	first.select_commander("castellan")
	var first_preview: Dictionary = first.pack_preview("field_engineers")
	var second_preview: Dictionary = second.pack_preview("field_engineers")
	_check(first_preview == second_preview, "same catalog input did not produce an identical pack preview")
	_check(int(first_preview.get("cost", -1)) == 4 and first_preview.get("pieces", []).size() == 2, "Field Engineers preview no longer matches the previous behavior")
	var opened: Dictionary = first.open_pack("field_engineers")
	_check(bool(opened.get("ok", false)) and first.materials == 56, "externalized pack did not preserve opening cost")
	_check(first.available_pieces.has("repair_station") and first.available_pieces.has("brace"), "externalized pack did not preserve piece unlocks")

	if failures.is_empty():
		print("P6 runtime content catalog: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		printerr("P6 runtime content catalog: FAIL (%d)" % failures.size())
		quit(1)
