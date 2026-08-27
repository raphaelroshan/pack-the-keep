extends RefCounted

## Presentation-independent simulation for the Pack the Keep first battle slice.
## The same seed, keep layout, doctrine, and commands produce the same report.

const GRID_SIZE := Vector2i(12, 8)
const FLOORS := ["ground", "upper"]
const ACTIVE_COMMANDER := "castellan"
const STARTER_PIECES := ["pike_squad", "narrow_gate"]
const SAVE_SCHEMA_VERSION := 2
const GAME_ID := "pack-the-keep"

const ROOMS: Dictionary = {
	"gate": {"name": "Gate", "floor": "ground", "origin": Vector2i(1, 3), "size": Vector2i(2, 2), "critical": true, "role": "shortest entrance"},
	"outer_wall": {"name": "Outer Wall", "floor": "upper", "origin": Vector2i(1, 2), "size": Vector2i(4, 1), "critical": false, "role": "time-buying boundary"},
	"inner_yard": {"name": "Inner Yard", "floor": "ground", "origin": Vector2i(4, 3), "size": Vector2i(3, 2), "critical": false, "role": "response space"},
	"armory": {"name": "Armory", "floor": "ground", "origin": Vector2i(7, 3), "size": Vector2i(2, 2), "critical": true, "role": "pack staging"},
	"workshop": {"name": "Workshop", "floor": "ground", "origin": Vector2i(4, 6), "size": Vector2i(2, 2), "critical": true, "role": "repair support"},
	"barracks": {"name": "Barracks", "floor": "ground", "origin": Vector2i(7, 6), "size": Vector2i(2, 2), "critical": false, "role": "defender assignment"},
	"supply_room": {"name": "Supply Room", "floor": "ground", "origin": Vector2i(10, 5), "size": Vector2i(2, 2), "critical": true, "role": "materials reserve"},
	"north_tower": {"name": "North Tower", "floor": "upper", "origin": Vector2i(8, 1), "size": Vector2i(2, 2), "critical": false, "role": "information"},
	"old_chapel": {"name": "Old Chapel", "floor": "upper", "origin": Vector2i(8, 5), "size": Vector2i(3, 2), "critical": false, "role": "refuge and evacuation"}
}

const COMMANDERS: Dictionary = {
	"castellan": {
		"name": "The Castellan",
		"passive": "Layered Masonry: adjacent pieces gain +1 defense and repair reach.",
		"ability": "lockdown",
		"ability_name": "Lockdown",
		"ability_text": "For the next battle step, halve room damage and restore a little condition to every placed piece.",
		"limitation": "Dense layouts are efficient but slow to reposition.",
		"starting_materials": 60,
		"starting_morale": 6
	},
	"warden": {
		"name": "The Warden",
		"passive": "Open Lanes: pieces with an empty adjacent cell gain +1 response damage; signals reach farther.",
		"ability": "rally",
		"ability_name": "Rally",
		"ability_text": "Restore 1 morale and coordinate the next battle step: non-specialist defenders gain +1 response and the first room hit is reduced.",
		"limitation": "Spread Thin: starts with fewer materials and loses value when every lane is packed.",
		"starting_materials": 52,
		"starting_morale": 7
	}
}

const PACKS: Dictionary = {
	"pike_line": {"name": "Pike Line", "pieces": ["pike_squad", "narrow_gate"], "doctrine": "compact_corridors", "cost": 4},
	"field_engineers": {"name": "Field Engineers", "pieces": ["repair_station", "brace"], "doctrine": "redundancy", "cost": 4},
	"firekeepers": {"name": "Firekeepers", "pieces": ["fire_team", "fire_brazier"], "doctrine": "denial_zones", "cost": 5},
	"scouts": {"name": "Scouts", "pieces": ["scout_post", "signal_beacon"], "doctrine": "early_warning", "cost": 3}
}

const PACK_EXPLANATIONS: Dictionary = {
	"pike_line": {"solves": "Gate pressure and raider contact", "asks": "A committed ground-floor corridor", "preview": "Reliable front-line control; strongest when Pike Squad reaches Gate Road."},
	"field_engineers": {"solves": "Room damage and partial-breach recovery", "asks": "Materials and a safe Workshop footprint", "preview": "Turns surviving the first hit into a repair decision instead of a restart."},
	"firekeepers": {"solves": "Climber approaches and denial zones", "asks": "Power and a response-space position", "preview": "Punishes upper-floor feints; less efficient against support-room sabotage."},
	"scouts": {"solves": "Forecast uncertainty and upper-floor targets", "asks": "A visible North Tower post", "preview": "Improves agency before contact, but contributes little direct damage."}
}

const PIECES: Dictionary = {
	"pike_squad": {"name": "Pike Squad", "size": Vector2i(2, 1), "cost": 8, "role": "holds Gate Road", "skill": "Brace the Gate: melee contact control gains +2 against Gate Road Raiders when assigned to Gate.", "combat_style": "melee", "attack": 4, "defense": 2, "max_health": 14, "max_ammo": 0, "attack_interval": 1, "range": 1, "availability": "starter", "targets": ["raider"]},
	"repair_station": {"name": "Repair Station", "size": Vector2i(2, 1), "cost": 10, "role": "restores nearby structures", "skill": "Field Repair: restores the lowest-condition room after defender attacks.", "combat_style": "support", "attack": 0, "defense": 1, "max_health": 10, "max_ammo": 0, "attack_interval": 1, "range": 1, "availability": "field_engineers", "targets": ["sapper", "area_pressure"]},
	"fire_team": {"name": "Fire Team", "size": Vector2i(2, 1), "cost": 9, "role": "controls an approach zone", "skill": "Denial Zone: ranged counter fire is strongest from the upper floor or Inner Yard assignment.", "combat_style": "ranged", "attack": 3, "defense": 1, "max_health": 12, "max_ammo": 4, "attack_interval": 1, "range": 2, "availability": "firekeepers", "targets": ["climber", "raider", "siege_beast"]},
	"scout_post": {"name": "Scout Post", "size": Vector2i(1, 1), "cost": 6, "role": "reveals target and arrival", "skill": "Early Warning: reveals target timing and improves the keeper’s read of the next contact.", "combat_style": "support", "attack": 0, "defense": 0, "max_health": 8, "max_ammo": 0, "attack_interval": 1, "range": 3, "availability": "scouts", "targets": ["all"]},
	"narrow_gate": {"name": "Narrow Gate", "size": Vector2i(1, 2), "cost": 7, "role": "concentrates Gate pressure", "skill": "Choke Point: increases the Gate’s defensive hold without dealing direct damage.", "combat_style": "fortification", "attack": 0, "defense": 3, "max_health": 18, "max_ammo": 0, "attack_interval": 1, "range": 1, "availability": "starter", "targets": ["raider"]},
	"brace": {"name": "Wall Brace", "size": Vector2i(1, 1), "cost": 5, "role": "reduces adjacent room damage", "skill": "Bracework: reduces damage to an adjacent room by one.", "combat_style": "fortification", "attack": 0, "defense": 2, "max_health": 16, "max_ammo": 0, "attack_interval": 1, "range": 1, "availability": "field_engineers", "targets": ["all"]},
	"fire_brazier": {"name": "Fire Brazier", "size": Vector2i(1, 1), "cost": 6, "role": "extends Fire Team denial", "skill": "Signal Flame: extends the Fire Team denial lane on the upper floor.", "combat_style": "ranged", "attack": 1, "defense": 0, "max_health": 12, "max_ammo": 3, "attack_interval": 1, "range": 2, "availability": "firekeepers", "targets": ["climber"]},
	"signal_beacon": {"name": "Signal Beacon", "size": Vector2i(1, 1), "cost": 5, "role": "improves warning time", "skill": "Signal Relay: expands Warden signal coverage without direct damage.", "combat_style": "support", "attack": 0, "defense": 0, "max_health": 8, "max_ammo": 0, "attack_interval": 1, "range": 3, "availability": "scouts", "targets": ["all"]}
}

const ENEMIES: Dictionary = {
	"raider": {"name": "Raider", "health": 8, "damage": 2, "arrival_step": 2, "route": "gate_road", "target_rooms": ["gate"], "doctrine": "gate_assault", "counter": "pike_squad"},
	"sapper": {"name": "Sapper", "health": 5, "damage": 3, "arrival_step": 3, "route": "service_lane", "target_rooms": ["workshop", "supply_room", "armory"], "doctrine": "distributed_sabotage", "counter": "scout_post"},
	"climber": {"name": "Climber", "health": 6, "damage": 2, "arrival_step": 2, "route": "north_tower_line", "target_rooms": ["north_tower", "old_chapel"], "doctrine": "feint_and_flank", "counter": "fire_team"},
	"siege_beast": {"name": "Siege Beast", "health": 16, "damage": 3, "arrival_step": 3, "route": "outer_approach", "target_rooms": ["inner_yard", "outer_wall", "old_chapel", "workshop"], "doctrine": "area_pressure", "counter": "fire_team"}
}

const WAVE_COMPOSITIONS: Dictionary = {
	"gate_assault": ["raider", "raider"],
	"distributed_sabotage": ["raider", "sapper"],
	"feint_and_flank": ["raider", "climber"],
	"area_pressure": ["siege_beast"]
}

const SCENARIOS: Dictionary = {
	"gatehouse_lock": {"name": "Gatehouse Lock", "objective": "Hold Gate without abandoning the response yard.", "lesson": "Concentrate strength, but preserve one interior route.", "starting_doctrine": "gate_assault", "doctrines": ["gate_assault", "distributed_sabotage", "feint_and_flank"], "wave_plans": [["raider", "raider"], ["raider", "sapper"], ["raider", "climber", "sapper"]]},
	"wrong_wall": {"name": "The Wrong Wall", "objective": "Keep Workshop and North Tower functional through the mixed pressure.", "lesson": "Protect the dependency, not only the obvious wall.", "starting_doctrine": "distributed_sabotage", "doctrines": ["distributed_sabotage", "feint_and_flank", "distributed_sabotage"], "wave_plans": [["raider", "sapper"], ["raider", "climber", "sapper"], ["climber", "sapper", "raider", "sapper"]]},
	"open_yard_net": {"name": "Open Yard Net", "objective": "Preserve Old Chapel and response space while area pressure lands.", "lesson": "A scarred perimeter can be a successful refuge if movement survives.", "starting_doctrine": "area_pressure", "doctrines": ["feint_and_flank", "distributed_sabotage", "area_pressure"], "wave_plans": [["raider", "climber"], ["raider", "climber", "sapper"], ["siege_beast", "raider", "climber"]]}
}

const SCENARIO_VARIATIONS: Dictionary = {
	"gatehouse_lock": [
		{"id": "standard_bell", "materials": 0, "morale": 0, "target_room": ""},
		{"id": "thin_supply", "materials": -4, "morale": 1, "target_room": "supply_room"},
		{"id": "late_warning", "materials": 3, "morale": -1, "target_room": "gate"}
	],
	"wrong_wall": [
		{"id": "standard_bell", "materials": 0, "morale": 0, "target_room": ""},
		{"id": "workshop_first", "materials": -3, "morale": 1, "target_room": "workshop"},
		{"id": "tower_first", "materials": 2, "morale": -1, "target_room": "north_tower"}
	],
	"open_yard_net": [
		{"id": "standard_bell", "materials": 0, "morale": 0, "target_room": ""},
		{"id": "chapel_pressure", "materials": -4, "morale": 1, "target_room": "old_chapel"},
		{"id": "outer_pressure", "materials": 2, "morale": -1, "target_room": "inner_yard"}
	]
}

const DOCTRINE_QUESTIONS: Dictionary = {
	"gate_assault": "Can the keep concentrate strength at the obvious entrance?",
	"distributed_sabotage": "Can support rooms survive while the front is under pressure?",
	"feint_and_flank": "Has the player left an upper response lane?",
	"area_pressure": "Can the keep preserve recovery when one impact reaches several rooms?"
}

const DOCTRINE_PRESSURES: Dictionary = {
	"gate_assault": "Gate concentration",
	"distributed_sabotage": "Workshop and Supply Room support chain",
	"feint_and_flank": "North Tower and upper response lane",
	"area_pressure": "Inner Yard and adjacent support rooms"
}

const ASSIGNMENT_RULES: Dictionary = {
	"pike_squad": {"room": "gate", "effect": "Gate Road hold bonus +2"},
	"repair_station": {"room": "workshop", "effect": "repair amount +4 and Workshop priority"},
	"fire_team": {"room": "inner_yard", "effect": "denial zone reaches the response space"},
	"scout_post": {"room": "north_tower", "effect": "secondary target revealed before contact"}
}

var seed: int = 3307
var commander_id: String = ACTIVE_COMMANDER
var materials: int = 60
var command_points: int = 3
var morale: int = 6
var scenario_id: String = "gatehouse_lock"
var scenario_active: bool = false
var scenario_variation_id: String = "standard_bell"
var variation_target_room: String = ""
var variation_materials: int = 0
var variation_morale: int = 0
var wave_index: int = 0
var wave_active: bool = false
var wave_progress: float = 0.0
var battle_step: int = 0
var battle_clock: float = 0.0
var breach_level: int = 0
var enemy_doctrine: String = "gate_assault"
var pieces: Dictionary = {}
var owned_packs: Array[String] = []
var offered_packs: Array[String] = ["pike_line", "field_engineers", "firekeepers"]
var available_pieces: Array[String] = ["pike_squad", "narrow_gate"]
var pack_openings_this_preparation: int = 0
var reserved_pack_id: String = ""
var enemies: Array[Dictionary] = []
var rooms: Dictionary = {}
var log: Array[String] = []
var battle_report: Array[String] = []
var lockdown_pending: bool = false
var lockdown_used: bool = false
var rally_pending: bool = false
var rally_used: bool = false
var last_outcome: String = ""
var repair_interval_active: bool = false
var repair_actions_remaining: int = 0
var repair_interval_reason: String = ""
var assigned_rooms: Dictionary = {}
var combat_metrics: Dictionary = {}
var wave_history: Array[Dictionary] = []
var _last_attackers: Array[String] = []
var _last_attack_damage: Dictionary = {}

func _init(keep_seed: int = 3307) -> void:
	reset_run(keep_seed)

func _reset_rooms() -> void:
	rooms.clear()
	for room_id in ROOMS.keys():
		rooms[room_id] = {"condition": 100, "state": "stable"}

func reset_run(new_seed: int = 3307) -> void:
	seed = new_seed
	commander_id = ACTIVE_COMMANDER
	materials = int(COMMANDERS[ACTIVE_COMMANDER].starting_materials)
	command_points = 3
	morale = int(COMMANDERS[ACTIVE_COMMANDER].starting_morale)
	scenario_id = "gatehouse_lock"
	scenario_active = false
	scenario_variation_id = "standard_bell"
	variation_target_room = ""
	variation_materials = 0
	variation_morale = 0
	wave_index = 0
	wave_active = false
	wave_progress = 0.0
	battle_step = 0
	battle_clock = 0.0
	breach_level = 0
	enemy_doctrine = "gate_assault"
	pieces.clear()
	owned_packs.clear()
	available_pieces.clear()
	for piece_id in STARTER_PIECES:
		available_pieces.append(String(piece_id))
	reserved_pack_id = ""
	enemies.clear()
	_reset_rooms()
	log.clear()
	battle_report.clear()
	lockdown_pending = false
	lockdown_used = false
	rally_pending = false
	rally_used = false
	last_outcome = ""
	repair_interval_active = false
	repair_actions_remaining = 0
	repair_interval_reason = ""
	assigned_rooms.clear()
	_reset_combat_metrics()
	wave_history.clear()
	_log("Greywatch Keep is quiet. The Castellan waits for a first doctrine.")

func _reset_combat_metrics() -> void:
	combat_metrics = {
		"battle_steps": 0,
		"unit_attacks": 0,
		"damage_dealt": 0,
		"enemy_attacks": 0,
		"room_damage": 0,
		"piece_damage": 0,
		"repairs": 0,
		"disabled_units": 0,
		"defeated_enemies": 0,
		"ammo_spent": 0
	}

func _preparation_pack_limit() -> int:
	return 2 if wave_index == 0 else 1

func _rebuild_available_pieces() -> void:
	available_pieces.clear()
	for piece_id in STARTER_PIECES:
		available_pieces.append(String(piece_id))
	for pack_id in owned_packs:
		if not PACKS.has(pack_id):
			continue
		for piece_id in PACKS[pack_id].pieces:
			if not available_pieces.has(String(piece_id)):
				available_pieces.append(String(piece_id))

func _log(message: String) -> void:
	log.append(message)

func _battle_log(message: String) -> void:
	battle_report.append(message)
	_log(message)

func select_commander(id: String) -> Dictionary:
	if not COMMANDERS.has(id):
		return {"ok": false, "reason": "unknown commander"}
	if wave_active or repair_interval_active:
		return {"ok": false, "reason": "commander cannot change during an invasion or repair interval"}
	commander_id = id
	materials = int(COMMANDERS[id].starting_materials)
	morale = int(COMMANDERS[id].starting_morale)
	command_points = 3
	return {"ok": true, "message": "%s takes command. %s Limitation: %s" % [COMMANDERS[id].name, COMMANDERS[id].passive, COMMANDERS[id].limitation], "ability_name": COMMANDERS[id].ability_name, "ability_text": COMMANDERS[id].ability_text}

func _variation_for_scenario(id: String) -> Dictionary:
	var options: Array = SCENARIO_VARIATIONS.get(id, [])
	if options.is_empty():
		return {"id": "standard_bell", "materials": 0, "morale": 0, "target_room": ""}
	var stable_id_value: int = 0
	for byte_value in id.to_utf8_buffer():
		stable_id_value += int(byte_value)
	var index: int = absi(seed + stable_id_value) % options.size()
	return options[index].duplicate(true)

func select_scenario(id: String) -> Dictionary:
	if not SCENARIOS.has(id):
		return {"ok": false, "reason": "unknown Greywatch scenario"}
	if wave_active or repair_interval_active:
		return {"ok": false, "reason": "scenario cannot change during an invasion or repair interval"}
	if not pieces.is_empty() or wave_index > 0:
		return {"ok": false, "reason": "start a new run before changing scenarios"}
	scenario_id = id
	scenario_active = true
	enemy_doctrine = String(SCENARIOS[id].get("starting_doctrine", "gate_assault"))
	var variation: Dictionary = _variation_for_scenario(id)
	scenario_variation_id = String(variation.get("id", "standard_bell"))
	variation_target_room = String(variation.get("target_room", ""))
	variation_materials = int(variation.get("materials", 0))
	variation_morale = int(variation.get("morale", 0))
	materials = int(COMMANDERS[commander_id].starting_materials) + variation_materials
	morale = clampi(int(COMMANDERS[commander_id].starting_morale) + variation_morale, 0, 10)
	_log("Scenario selected: %s / variation %s. %s" % [SCENARIOS[id].name, scenario_variation_id, SCENARIOS[id].lesson])
	return {"ok": true, "message": "%s selected: %s Variation: %s." % [SCENARIOS[id].name, SCENARIOS[id].objective, scenario_variation_id], "scenario": scenario_preview(id)}

func scenario_preview(id: String = "") -> Dictionary:
	var selected_id: String = scenario_id if id.is_empty() else id
	if not SCENARIOS.has(selected_id):
		return {"ok": false, "reason": "unknown Greywatch scenario"}
	var scenario: Dictionary = SCENARIOS[selected_id]
	return {"ok": true, "scenario_id": selected_id, "name": String(scenario.name), "objective": String(scenario.objective), "lesson": String(scenario.lesson), "starting_doctrine": String(scenario.starting_doctrine), "wave_count": scenario.wave_plans.size(), "variation_id": scenario_variation_id if selected_id == scenario_id else String(_variation_for_scenario(selected_id).get("id", "standard_bell"))}

func authored_wave_count() -> int:
	if scenario_active and SCENARIOS.has(scenario_id):
		return SCENARIOS[scenario_id].get("wave_plans", []).size()
	return 0

func has_next_wave() -> bool:
	if not scenario_active or last_outcome == "collapse":
		return false
	return authored_wave_count() > wave_index

func pack_preview(pack_id: String) -> Dictionary:
	if not PACKS.has(pack_id):
		return {"ok": false, "reason": "unknown pack"}
	var pack: Dictionary = PACKS[pack_id]
	var explanation: Dictionary = PACK_EXPLANATIONS.get(pack_id, {})
	var piece_previews: Array[Dictionary] = []
	for piece_id in pack.pieces:
		var piece: Dictionary = PIECES[String(piece_id)]
		piece_previews.append({"id": String(piece_id), "name": String(piece.name), "cost": int(piece.cost), "size": piece.size, "role": String(piece.role), "availability": String(piece.availability)})
	return {"ok": true, "pack_id": pack_id, "name": String(pack.name), "doctrine": String(pack.doctrine), "cost": int(pack.cost), "pieces": piece_previews, "solves": String(explanation.get("solves", "")), "asks": String(explanation.get("asks", "")), "preview": String(explanation.get("preview", "")), "owned": owned_packs.has(pack_id), "reserved": reserved_pack_id == pack_id, "openings_remaining": _preparation_pack_limit() - pack_openings_this_preparation, "materials": materials}

func reserve_pack(pack_id: String) -> Dictionary:
	if not PACKS.has(pack_id):
		return {"ok": false, "reason": "unknown pack"}
	if wave_active or repair_interval_active:
		return {"ok": false, "reason": "packs can only be reserved during Preparation"}
	if owned_packs.has(pack_id):
		return {"ok": false, "reason": "an owned pack cannot occupy the reserve slot"}
	if reserved_pack_id == pack_id:
		reserved_pack_id = ""
		return {"ok": true, "message": "Reserve cleared."}
	reserved_pack_id = pack_id
	return {"ok": true, "message": "Reserved %s for the next Preparation." % PACKS[pack_id].name, "reserved_pack_id": reserved_pack_id}

func open_pack(pack_id: String) -> Dictionary:
	if not PACKS.has(pack_id):
		return {"ok": false, "reason": "unknown pack"}
	if wave_active or repair_interval_active:
		return {"ok": false, "reason": "packs can only be opened during Preparation"}
	if owned_packs.has(pack_id):
		return {"ok": false, "reason": "pack already opened"}
	if pack_openings_this_preparation >= _preparation_pack_limit():
		return {"ok": false, "reason": "this Preparation has no pack openings remaining"}
	var pack_cost: int = int(PACKS[pack_id].get("cost", 0))
	if materials < pack_cost:
		return {"ok": false, "reason": "not enough materials to open this pack"}
	materials -= pack_cost
	owned_packs.append(pack_id)
	pack_openings_this_preparation += 1
	if reserved_pack_id == pack_id:
		reserved_pack_id = ""
	for piece_id in PACKS[pack_id].pieces:
		if not available_pieces.has(piece_id):
			available_pieces.append(piece_id)
	return {"ok": true, "message": "Opened %s for %d materials: %s. Available units updated." % [PACKS[pack_id].name, pack_cost, PACKS[pack_id].doctrine.replace("_", " ")], "available_pieces": available_pieces.duplicate(), "openings_remaining": _preparation_pack_limit() - pack_openings_this_preparation, "materials": materials}

func piece_fits(piece_id: String, origin: Vector2i, floor: String = "ground") -> bool:
	if not PIECES.has(piece_id) or not FLOORS.has(floor):
		return false
	var size: Vector2i = PIECES[piece_id].size
	if origin.x < 0 or origin.y < 0 or origin.x + size.x > GRID_SIZE.x or origin.y + size.y > GRID_SIZE.y:
		return false
	for existing in pieces.values():
		if String(existing.get("floor", "ground")) != floor:
			continue
		var existing_origin: Vector2i = existing.get("origin", Vector2i.ZERO)
		var existing_size: Vector2i = PIECES[String(existing.get("piece_id", ""))].size
		if Rect2i(origin, size).intersects(Rect2i(existing_origin, existing_size)):
			return false
	return true

func placement_zone(origin: Vector2i, floor: String = "ground", size: Vector2i = Vector2i.ONE) -> String:
	if floor == "upper":
		return "wall"
	if origin.x <= 1 or origin.y <= 1 or origin.x + size.x >= GRID_SIZE.x - 1 or origin.y + size.y >= GRID_SIZE.y - 1:
		return "wall"
	if origin.x >= 3 and origin.y >= 2 and origin.x + size.x <= 9 and origin.y + size.y <= 6:
		return "courtyard"
	return "keep"

func piece_preview(piece_id: String, origin: Vector2i, floor: String = "ground") -> Dictionary:
	if not PIECES.has(piece_id):
		return {"ok": false, "valid": false, "reason": "unknown defensive piece"}
	var piece: Dictionary = PIECES[piece_id]
	var reason: String = ""
	if wave_active or repair_interval_active:
		reason = "placement is only available during Preparation"
	elif not FLOORS.has(floor):
		reason = "unknown keep floor"
	elif not available_pieces.has(piece_id):
		reason = "%s is not available; open its pack during Preparation" % piece.name
	elif not piece_fits(piece_id, origin, floor):
		reason = "piece does not fit on this floor of the keep"
	elif materials < int(piece.cost):
		reason = "not enough materials"
	return {"ok": reason.is_empty(), "valid": reason.is_empty(), "reason": reason, "piece_id": piece_id, "name": String(piece.name), "origin": origin, "floor": floor, "placement_zone": placement_zone(origin, floor, piece.size), "size": piece.size, "cost": int(piece.cost), "role": String(piece.role), "remaining_materials": materials - int(piece.cost)}

func place_piece(piece_id: String, origin: Vector2i, floor: String = "ground") -> Dictionary:
	var preview: Dictionary = piece_preview(piece_id, origin, floor)
	if not bool(preview.get("valid", false)):
		return {"ok": false, "reason": String(preview.get("reason", "invalid placement"))}
	var cost: int = int(PIECES[piece_id].cost)
	materials -= cost
	var instance_id: String = "%s_%d" % [piece_id, pieces.size()]
	var max_health: int = int(PIECES[piece_id].get("max_health", 10))
	var max_ammo: int = int(PIECES[piece_id].get("max_ammo", 0))
	pieces[instance_id] = {"piece_id": piece_id, "origin": origin, "floor": floor, "max_health": max_health, "health": max_health, "condition": 1.0, "assignment": "", "attack_cooldown": 0, "attacks": 0, "damage_dealt": 0, "targets_stopped": 0, "disabled": false, "last_target": "", "max_ammo": max_ammo, "ammo": max_ammo}
	var zone: String = placement_zone(origin, floor, PIECES[piece_id].size)
	pieces[instance_id].placement_zone = zone
	return {"ok": true, "piece_instance": instance_id, "placement_zone": zone, "message": "Placed %s in the %s zone on the %s floor: %s." % [PIECES[piece_id].name, zone, floor, PIECES[piece_id].role]}

func _set_piece_health(instance_id: String, value: int) -> void:
	if not pieces.has(instance_id):
		return
	var instance: Dictionary = pieces[instance_id]
	var max_health: int = int(instance.get("max_health", PIECES[String(instance.get("piece_id", ""))].get("max_health", 10)))
	var was_disabled: bool = bool(instance.get("disabled", false))
	instance.health = clampi(value, 0, max_health)
	instance.condition = float(instance.health) / float(max_health)
	instance.disabled = int(instance.health) <= 0
	if instance.disabled and not was_disabled:
		combat_metrics["disabled_units"] = int(combat_metrics.get("disabled_units", 0)) + 1

func room_at_cell(floor: String, cell: Vector2i) -> String:
	for room_id in ROOMS.keys():
		var room: Dictionary = ROOMS[room_id]
		if String(room.get("floor", "ground")) == floor and Rect2i(room.origin, room.size).has_point(cell):
			return String(room_id)
	return ""

func piece_at_cell(floor: String, cell: Vector2i) -> String:
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		if String(instance.get("floor", "ground")) != floor:
			continue
		var piece_id: String = String(instance.get("piece_id", ""))
		if piece_id.is_empty() or not PIECES.has(piece_id):
			continue
		if Rect2i(instance.get("origin", Vector2i.ZERO), PIECES[piece_id].size).has_point(cell):
			return String(instance_id)
	return ""

func inspect_room(room_id: String) -> Dictionary:
	if not ROOMS.has(room_id):
		return {"ok": false, "reason": "unknown keep room"}
	var room: Dictionary = ROOMS[room_id]
	return {"ok": true, "kind": "room", "id": room_id, "name": String(room.name), "floor": String(room.floor), "role": String(room.role), "critical": bool(room.critical), "condition": room_condition(room_id), "state": room_state(room_id)}

func inspect_piece(instance_id: String) -> Dictionary:
	if not pieces.has(instance_id):
		return {"ok": false, "reason": "unknown defensive piece"}
	var instance: Dictionary = pieces[instance_id]
	var piece_id: String = String(instance.get("piece_id", ""))
	if not PIECES.has(piece_id):
		return {"ok": false, "reason": "piece definition is unavailable"}
	var piece: Dictionary = PIECES[piece_id]
	return {"ok": true, "kind": "piece", "id": instance_id, "piece_id": piece_id, "name": String(piece.name), "floor": String(instance.get("floor", "ground")), "origin": instance.get("origin", Vector2i.ZERO), "role": String(piece.role), "health": int(instance.get("health", 0)), "max_health": int(instance.get("max_health", piece.max_health)), "condition": float(instance.get("condition", 0.0)), "assignment": String(instance.get("assignment", "")), "placement_zone": String(instance.get("placement_zone", placement_zone(instance.get("origin", Vector2i.ZERO), String(instance.get("floor", "ground")), piece.get("size", Vector2i.ONE)))), "disabled": bool(instance.get("disabled", false)), "attack": int(piece.attack), "defense": int(piece.defense), "range": int(piece.range), "combat_style": String(piece.get("combat_style", "support")), "skill": String(piece.get("skill", "")), "ammo": int(instance.get("ammo", piece.get("max_ammo", 0))), "max_ammo": int(instance.get("max_ammo", piece.get("max_ammo", 0))), "availability": String(piece.availability)}

func inspect_enemy(index: int) -> Dictionary:
	if index < 0 or index >= enemies.size():
		return {"ok": false, "reason": "unknown enemy"}
	var enemy: Dictionary = enemies[index]
	var enemy_id: String = String(enemy.get("enemy_id", ""))
	if not ENEMIES.has(enemy_id):
		return {"ok": false, "reason": "enemy definition is unavailable"}
	var definition: Dictionary = ENEMIES[enemy_id]
	return {"ok": true, "kind": "enemy", "id": enemy_id, "index": index, "name": String(definition.name), "doctrine": String(definition.doctrine), "route": String(definition.route), "counter": String(definition.counter), "health": int(enemy.get("hp", 0)), "max_health": int(enemy.get("max_health", definition.health)), "damage": int(definition.damage), "arrival_step": int(definition.arrival_step), "target": String(enemy.get("target", "")), "defeated": bool(enemy.get("defeated", false))}

func remove_piece(instance_id: String) -> Dictionary:
	if wave_active or repair_interval_active:
		return {"ok": false, "reason": "piece removal is only available during Preparation"}
	if not pieces.has(instance_id):
		return {"ok": false, "reason": "unknown defensive piece"}
	var assignment: String = String(pieces[instance_id].get("assignment", ""))
	if not assignment.is_empty():
		assigned_rooms.erase(assignment)
	pieces.erase(instance_id)
	return {"ok": true, "message": "Removed defensive piece; materials are not refunded during an active run."}

func recovery_action_preview(action_id: String, instance_id: String = "", room_id: String = "") -> Dictionary:
	var preview: Dictionary = {
		"action_id": action_id,
		"ok": false,
		"reason": "unknown recovery action",
		"target_id": "",
		"target_name": "Select a target",
		"material_cost": 0,
		"action_cost": 1,
		"benefit": "",
		"tradeoff": "Consumes one of the two recovery actions."
	}
	if action_id == "repair_room":
		preview.material_cost = 8
		preview.target_id = room_id
		preview.target_name = String(ROOMS.get(room_id, {}).get("name", "Select a room"))
		preview.benefit = "Restore up to 30 condition to the selected keep function."
		preview.tradeoff = "Spend 8 materials and one recovery action instead of changing an assignment."
	elif action_id == "repair_piece":
		preview.material_cost = 6
		preview.target_id = instance_id
		var repair_piece_id: String = String(pieces.get(instance_id, {}).get("piece_id", ""))
		preview.target_name = String(PIECES.get(repair_piece_id, {}).get("name", "Select a placed piece"))
		preview.benefit = "Restore 30% of the selected defender's maximum health."
		preview.tradeoff = "Spend 6 materials and one recovery action instead of restoring a room."
	elif action_id == "assign_piece":
		preview.target_id = instance_id
		var assign_piece_id: String = String(pieces.get(instance_id, {}).get("piece_id", ""))
		var assign_piece_name: String = String(PIECES.get(assign_piece_id, {}).get("name", "Select a placed piece"))
		var assign_room_name: String = String(ROOMS.get(room_id, {}).get("name", "Select a room"))
		preview.target_name = "%s -> %s" % [assign_piece_name, assign_room_name]
		preview.benefit = String(ASSIGNMENT_RULES.get(assign_piece_id, {}).get("effect", "Activate the piece's specialist room behavior."))
		preview.tradeoff = "Spend one recovery action and commit this piece to one room."
	elif action_id == "clear_assignment":
		preview.target_id = instance_id
		var clear_piece_id: String = String(pieces.get(instance_id, {}).get("piece_id", ""))
		preview.target_name = String(PIECES.get(clear_piece_id, {}).get("name", "Select an assigned piece"))
		preview.benefit = "Free the selected piece for a different specialist assignment later."
		preview.tradeoff = "Spend one recovery action and lose the current room benefit."
	else:
		return preview
	if not repair_interval_active:
		preview.reason = "no recovery interval is open"
		return preview
	if repair_actions_remaining <= 0:
		preview.reason = "no recovery actions remain"
		return preview
	match action_id:
		"repair_room":
			if not rooms.has(room_id):
				preview.reason = "select a keep room"
			elif materials < 8:
				preview.reason = "not enough materials"
			elif room_condition(room_id) >= 100:
				preview.reason = "room is already stable"
			else:
				preview.ok = true
				preview.reason = ""
		"repair_piece":
			if not pieces.has(instance_id):
				preview.reason = "select a placed defensive piece"
			elif float(pieces[instance_id].get("condition", 0.0)) >= 1.0:
				preview.reason = "piece is already stable"
			elif materials < 6:
				preview.reason = "not enough materials"
			else:
				preview.ok = true
				preview.reason = ""
		"assign_piece":
			if not pieces.has(instance_id):
				preview.reason = "select a placed defensive piece"
			elif not rooms.has(room_id):
				preview.reason = "select a keep room"
			else:
				var piece_id: String = String(pieces[instance_id].get("piece_id", ""))
				if not ASSIGNMENT_RULES.has(piece_id):
					preview.reason = "%s has no room assignment behavior" % PIECES[piece_id].name
				else:
					var rule: Dictionary = ASSIGNMENT_RULES[piece_id]
					if String(rule.get("room", "")) != room_id:
						preview.reason = "%s can only be assigned to %s" % [PIECES[piece_id].name, ROOMS[String(rule.get("room", ""))].name]
					elif String(pieces[instance_id].get("floor", "ground")) != String(ROOMS[room_id].get("floor", "ground")):
						preview.reason = "piece and assigned room must share a floor"
					elif not _piece_is_adjacent_to_room(pieces[instance_id], room_id):
						preview.reason = "piece must be inside or adjacent to its assigned room"
					elif assigned_rooms.has(room_id) and String(assigned_rooms[room_id]) != instance_id:
						preview.reason = "%s already has an assigned piece" % ROOMS[room_id].name
					else:
						var existing_assignment: String = String(pieces[instance_id].get("assignment", ""))
						if not existing_assignment.is_empty():
							preview.reason = "piece is already assigned to %s; clear it during the interval first" % ROOMS[existing_assignment].name
						else:
							preview.ok = true
							preview.reason = ""
		"clear_assignment":
			if not pieces.has(instance_id):
				preview.reason = "select a placed defensive piece"
			else:
				var assignment: String = String(pieces[instance_id].get("assignment", ""))
				if assignment.is_empty():
					preview.reason = "piece has no room assignment"
				else:
					preview.target_name = "%s <- %s" % [String(PIECES[String(pieces[instance_id].get("piece_id", ""))].name), String(ROOMS[assignment].name)]
					preview.ok = true
					preview.reason = ""
	return preview

func assign_piece_to_room(instance_id: String, room_id: String) -> Dictionary:
	var preview: Dictionary = recovery_action_preview("assign_piece", instance_id, room_id)
	if not bool(preview.get("ok", false)):
		return {"ok": false, "reason": String(preview.get("reason", "assignment is unavailable")), "state_changes": []}
	var piece_id: String = String(pieces[instance_id].get("piece_id", ""))
	var rule: Dictionary = ASSIGNMENT_RULES[piece_id]
	assigned_rooms[room_id] = instance_id
	pieces[instance_id].assignment = room_id
	repair_actions_remaining -= 1
	_log("Assigned %s to %s: %s." % [PIECES[piece_id].name, ROOMS[room_id].name, rule.effect])
	return {"ok": true, "message": "Assigned %s to %s: %s." % [PIECES[piece_id].name, ROOMS[room_id].name, rule.effect], "actions_remaining": repair_actions_remaining, "state_changes": [{"op": "assign_piece", "piece": instance_id, "room": room_id}]}

func clear_piece_assignment(instance_id: String) -> Dictionary:
	var preview: Dictionary = recovery_action_preview("clear_assignment", instance_id)
	if not bool(preview.get("ok", false)):
		return {"ok": false, "reason": String(preview.get("reason", "assignment clearing is unavailable")), "state_changes": []}
	var assignment: String = String(pieces[instance_id].get("assignment", ""))
	assigned_rooms.erase(assignment)
	pieces[instance_id].assignment = ""
	repair_actions_remaining -= 1
	return {"ok": true, "message": "Cleared %s from %s." % [PIECES[String(pieces[instance_id].get("piece_id", ""))].name, ROOMS[assignment].name], "actions_remaining": repair_actions_remaining, "state_changes": [{"op": "clear_assignment", "piece": instance_id, "room": assignment}]}

func room_condition(room_id: String) -> int:
	if not rooms.has(room_id):
		return 0
	return int(rooms[room_id].condition)

func room_state(room_id: String) -> String:
	if not rooms.has(room_id):
		return "unknown"
	return String(rooms[room_id].state)

func _update_room_state(room_id: String) -> void:
	if not rooms.has(room_id):
		return
	var condition: int = int(rooms[room_id].condition)
	var state: String = "stable"
	if condition <= 0:
		state = "breached"
	elif condition <= 35:
		state = "damaged"
	elif condition <= 70:
		state = "strained"
	rooms[room_id].state = state

func _piece_is_adjacent_to_room(instance: Dictionary, room_id: String) -> bool:
	if not ROOMS.has(room_id) or String(instance.get("floor", "ground")) != String(ROOMS[room_id].floor):
		return false
	var piece_id: String = String(instance.get("piece_id", ""))
	var piece_rect: Rect2i = Rect2i(instance.get("origin", Vector2i.ZERO), PIECES[piece_id].size)
	var room_rect: Rect2i = Rect2i(ROOMS[room_id].origin, ROOMS[room_id].size)
	return piece_rect.grow(1).intersects(room_rect)

func _castellan_adjacent(instance: Dictionary, room_id: String) -> bool:
	if commander_id != "castellan":
		return false
	if _piece_is_adjacent_to_room(instance, room_id):
		return true
	for other in pieces.values():
		if String(other.get("piece_id", "")) == "brace" and String(other.get("floor", "ground")) == String(instance.get("floor", "ground")):
			var distance: Vector2i = other.get("origin", Vector2i.ZERO) - instance.get("origin", Vector2i.ZERO)
			if absi(distance.x) <= 2 and absi(distance.y) <= 2:
				return true
	return false

func _piece_has_open_lane(instance: Dictionary) -> bool:
	var floor_name: String = String(instance.get("floor", "ground"))
	var origin: Vector2i = instance.get("origin", Vector2i.ZERO)
	var piece_id: String = String(instance.get("piece_id", ""))
	if not PIECES.has(piece_id):
		return false
	var size: Vector2i = PIECES[piece_id].size
	var checks: Array[Vector2i] = [origin + Vector2i(-1, 0), origin + Vector2i(size.x, 0), origin + Vector2i(0, -1), origin + Vector2i(0, size.y)]
	for cell in checks:
		if cell.x >= 0 and cell.y >= 0 and cell.x < GRID_SIZE.x and cell.y < GRID_SIZE.y and piece_at_cell(floor_name, cell).is_empty():
			return true
	return false

func _warden_open_lane(instance: Dictionary) -> bool:
	return commander_id == "warden" and _piece_has_open_lane(instance)

func layout_summary() -> Dictionary:
	var counts: Dictionary = {"ground": 0, "upper": 0, "wall": 0, "courtyard": 0, "keep": 0}
	var role_counts: Dictionary = {}
	var open_lane_count: int = 0
	var room_edge_count: int = 0
	var support_piece_count: int = 0
	var signal_piece_count: int = 0
	var assigned_specialist_count: int = 0
	for instance in pieces.values():
		var piece_id: String = String(instance.get("piece_id", ""))
		if not PIECES.has(piece_id):
			continue
		var floor_name: String = String(instance.get("floor", "ground"))
		counts[floor_name] = int(counts.get(floor_name, 0)) + 1
		var zone: String = String(instance.get("placement_zone", placement_zone(instance.get("origin", Vector2i.ZERO), floor_name, PIECES[piece_id].size)))
		counts[zone] = int(counts.get(zone, 0)) + 1
		var role: String = String(PIECES[piece_id].get("combat_style", "support"))
		role_counts[role] = int(role_counts.get(role, 0)) + 1
		if role == "support":
			support_piece_count += 1
		if piece_id == "scout_post" or piece_id == "signal_beacon":
			signal_piece_count += 1
		if not String(instance.get("assignment", "")).is_empty():
			assigned_specialist_count += 1
		if _piece_has_open_lane(instance):
			open_lane_count += 1
		for room_id in ROOMS.keys():
			if _piece_is_adjacent_to_room(instance, String(room_id)):
				room_edge_count += 1
				break
	var warnings: Array[String] = []
	if int(counts.ground) == 0:
		warnings.append("No ground-floor defender covers the Gate or courtyard.")
	if int(counts.upper) == 0:
		warnings.append("No upper-floor piece covers climber or signal pressure.")
	if support_piece_count == 0:
		warnings.append("No support piece protects recovery or information.")
	if not pieces.is_empty() and open_lane_count == 0:
		warnings.append("No placed piece has an open adjacent response cell.")
	var role_ids: Array = role_counts.keys()
	role_ids.sort()
	for role_id in role_ids:
		var role_count: int = int(role_counts[role_id])
		if role_count > 1:
			warnings.append("%d %s pieces overlap in role; confirm they answer different routes." % [role_count, String(role_id)])
	if warnings.is_empty():
		warnings.append("No immediate coverage warning; the forecast still determines whether the layout fits.")
	var total: int = pieces.size()
	var castellan_summary: String = "%d/%d pieces reinforce a room edge; %d specialist assignment(s) are active." % [room_edge_count, total, assigned_specialist_count]
	var castellan_risk: String = "Disconnected pieces receive less value from compact defense."
	if total > 0 and room_edge_count == total:
		castellan_risk = "The layout is compact; verify that concentration does not abandon an upper route."
	var warden_summary: String = "%d/%d pieces retain an open response cell; %d signal piece(s) cover %d floor(s)." % [open_lane_count, total, signal_piece_count, (1 if int(counts.ground) > 0 else 0) + (1 if int(counts.upper) > 0 else 0)]
	var warden_risk: String = "Blocked lanes or single-floor coverage reduce mobile response."
	if total > 0 and open_lane_count == total and int(counts.ground) > 0 and int(counts.upper) > 0:
		warden_risk = "Movement is preserved; verify that the lighter formation can absorb direct pressure."
	return {
		"counts": counts,
		"open_lane_count": open_lane_count,
		"room_edge_count": room_edge_count,
		"support_piece_count": support_piece_count,
		"signal_piece_count": signal_piece_count,
		"assigned_specialist_count": assigned_specialist_count,
		"duplicate_role_warnings": warnings,
		"active_commander": commander_id,
		"commander_comparison": {
			"castellan": {"name": String(COMMANDERS.castellan.name), "summary": castellan_summary, "risk": castellan_risk},
			"warden": {"name": String(COMMANDERS.warden.name), "summary": warden_summary, "risk": warden_risk}
		}
	}

func _warden_signal_bonus() -> bool:
	return commander_id == "warden" and (_has_unit("scout_post") or _has_unit("signal_beacon"))

func _living_piece_count(piece_id: String, floor: String = "") -> int:
	var count: int = 0
	for instance in pieces.values():
		if String(instance.get("piece_id", "")) == piece_id and (floor.is_empty() or String(instance.get("floor", "")) == floor) and float(instance.get("condition", 0.0)) > 0.0:
			count += 1
	return count

func _has_unit(piece_id: String, floor: String = "") -> bool:
	return _living_piece_count(piece_id, floor) > 0

func _has_assignment(piece_id: String, room_id: String) -> bool:
	if not assigned_rooms.has(room_id):
		return false
	var instance_id: String = String(assigned_rooms[room_id])
	return pieces.has(instance_id) and String(pieces[instance_id].get("piece_id", "")) == piece_id and float(pieces[instance_id].get("condition", 0.0)) > 0.0

func _reload_ammunition() -> void:
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		var piece_id: String = String(instance.get("piece_id", ""))
		if not PIECES.has(piece_id):
			continue
		var max_ammo: int = int(instance.get("max_ammo", PIECES[piece_id].get("max_ammo", 0)))
		instance.max_ammo = max_ammo
		instance.ammo = max_ammo

func _defender_damage(enemy_id: String) -> int:
	var enemy: Dictionary = ENEMIES[enemy_id]
	var damage: int = 0
	_last_attackers.clear()
	_last_attack_damage.clear()
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		if float(instance.get("condition", 0.0)) <= 0.0 or bool(instance.get("disabled", false)):
			continue
		var piece_id: String = String(instance.get("piece_id", ""))
		var piece: Dictionary = PIECES[piece_id]
		var combat_style: String = String(piece.get("combat_style", "support"))
		var zone: String = String(instance.get("placement_zone", placement_zone(instance.get("origin", Vector2i.ZERO), String(instance.get("floor", "ground")), piece.get("size", Vector2i.ONE))))
		var ammo: int = int(instance.get("ammo", piece.get("max_ammo", 0)))
		if combat_style == "ranged" and ammo <= 0:
			continue
		var valid: bool = piece.targets.has("all") or piece.targets.has(enemy_id)
		if not valid:
			continue
		var cooldown: int = int(instance.get("attack_cooldown", 0))
		if cooldown > 0:
			instance.attack_cooldown = cooldown - 1
			continue
		var contribution: int = int(piece.attack)
		if piece_id == "pike_squad" and (String(enemy.route) != "gate_road" or String(instance.get("floor", "ground")) != "ground"):
			contribution = 0
		if piece_id == "fire_team" and enemy_id != "climber":
			contribution = 1
		if piece_id == "fire_team" and enemy_id == "climber" and String(instance.get("floor", "ground")) != "upper" and String(instance.get("assignment", "")) != "inner_yard":
			contribution = 1
		if piece_id == "fire_brazier" and String(instance.get("floor", "ground")) != "upper":
			contribution = 0
		if piece_id == "pike_squad" and zone == "keep":
			contribution = 1
		elif piece_id == "pike_squad" and zone == "courtyard":
			contribution += 1
		if piece_id == "fire_team" and zone == "keep":
			contribution = 0
		elif piece_id == "fire_team" and zone == "courtyard":
			contribution = mini(contribution, 2)
		if piece_id == "pike_squad" and String(instance.get("assignment", "")) == "gate" and enemy_id == "raider":
			contribution += 2
		if piece_id == "fire_team" and String(instance.get("assignment", "")) == "inner_yard" and enemy_id == "climber":
			contribution += 1
		if _castellan_adjacent(instance, String(enemy.target_rooms[0])):
			contribution += 1
		if _warden_open_lane(instance):
			contribution += 1
		if rally_pending and commander_id == "warden" and piece.attack > 0:
			contribution += 1
		if contribution > 0:
			_last_attackers.append(String(instance_id))
			_last_attack_damage[String(instance_id)] = contribution
			if combat_style == "ranged":
				instance.ammo = maxi(0, ammo - 1)
				combat_metrics["ammo_spent"] = int(combat_metrics.get("ammo_spent", 0)) + 1
			damage += contribution
	return damage

func _choose_target(enemy_id: String) -> String:
	var enemy: Dictionary = ENEMIES[enemy_id]
	var candidates: Array[String] = []
	var target_rooms: Array = enemy.target_rooms.duplicate()
	if enemy_id == "siege_beast" and not variation_target_room.is_empty() and target_rooms.has(variation_target_room):
		target_rooms.erase(variation_target_room)
		target_rooms.push_front(variation_target_room)
	for room_id in target_rooms:
		if rooms.has(room_id) and room_condition(room_id) > 0:
			candidates.append(String(room_id))
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		var piece_id: String = String(instance.get("piece_id", ""))
		if enemy_id == "sapper" and piece_id == "repair_station" and float(instance.get("condition", 0.0)) > 0.0:
			candidates.append(String(instance_id))
		elif enemy_id == "climber" and String(instance.get("floor", "ground")) == "upper" and float(instance.get("condition", 0.0)) > 0.0:
			candidates.append(String(instance_id))
	if candidates.is_empty():
		return ""
	var selected: String = candidates[0]
	var selected_condition: float = _target_condition(selected)
	for candidate in candidates:
		var candidate_condition: float = _target_condition(candidate)
		if candidate_condition < selected_condition or (is_equal_approx(candidate_condition, selected_condition) and candidate < selected):
			selected = candidate
			selected_condition = candidate_condition
	return selected

func _target_condition(target_id: String) -> float:
	if rooms.has(target_id):
		return float(room_condition(target_id)) / 100.0
	if pieces.has(target_id):
		return float(pieces[target_id].get("condition", 0.0))
	return 1.0

func _apply_enemy_damage(enemy_id: String, target_id: String) -> void:
	if target_id.is_empty():
		_battle_log("%s found no valid target; the keep’s empty response space mattered." % ENEMIES[enemy_id].name)
		return
	var damage: int = int(ENEMIES[enemy_id].damage)
	combat_metrics["enemy_attacks"] = int(combat_metrics.get("enemy_attacks", 0)) + 1
	var reduced: bool = lockdown_pending or rally_pending
	if reduced:
		damage = maxi(1, int(ceil(float(damage) * 0.5)))
	if enemy_id == "siege_beast":
		var area_targets: Array[String] = []
		for room_id in ENEMIES[enemy_id].target_rooms:
			if rooms.has(room_id) and room_condition(room_id) > 0:
				area_targets.append(String(room_id))
		if not area_targets.has(target_id):
			area_targets.push_front(target_id)
		for area_index in range(mini(3, area_targets.size())):
			var area_room: String = area_targets[area_index]
			var area_damage: int = maxi(1, damage - (1 if area_index > 0 else 0))
			_apply_room_damage(enemy_id, area_room, area_damage, reduced, true)
		_battle_log("Siege Beast impact spread across %d rooms; preserve the refuge or accept a scarred perimeter." % mini(3, area_targets.size()))
		return
	if rooms.has(target_id):
		_apply_room_damage(enemy_id, target_id, damage, reduced, false)
	elif pieces.has(target_id):
		combat_metrics["piece_damage"] = int(combat_metrics.get("piece_damage", 0)) + damage
		var instance: Dictionary = pieces[target_id]
		var piece_id: String = String(instance.get("piece_id", ""))
		var max_health: int = int(instance.get("max_health", PIECES[piece_id].get("max_health", 10)))
		var health_loss: int = maxi(1, int(ceil(float(max_health) * float(damage) * 0.25)))
		_set_piece_health(target_id, int(instance.get("health", max_health)) - health_loss)
		_battle_log("%s damaged %s by %d; health is %d/%d." % [ENEMIES[enemy_id].name, PIECES[piece_id].name, damage, int(instance.get("health", 0)), max_health])

func _apply_room_damage(enemy_id: String, room_id: String, damage: int, reduced: bool, area_impact: bool) -> void:
	if not rooms.has(room_id):
		return
	var brace_bonus: int = 0
	for instance in pieces.values():
		if String(instance.get("piece_id", "")) == "brace" and _piece_is_adjacent_to_room(instance, room_id) and float(instance.get("condition", 0.0)) > 0.0:
			brace_bonus += 1
	damage = maxi(0, damage - brace_bonus)
	var was_breached: bool = rooms[room_id].state == "breached"
	combat_metrics["room_damage"] = int(combat_metrics.get("room_damage", 0)) + damage * 15
	rooms[room_id].condition = maxi(0, int(rooms[room_id].condition) - damage * 15)
	_update_room_state(room_id)
	_battle_log("%s %s %s and dealt %d room damage%s; room is %s." % [ENEMIES[enemy_id].name, "impacted" if area_impact else "reached", ROOMS[room_id].name, damage, " under response mitigation" if reduced else "", rooms[room_id].state])
	if rooms[room_id].state == "breached" and not was_breached:
		breach_level += 1
		morale = maxi(0, morale - 1)
		_battle_log("%s breached. Morale falls because its named function is offline." % ROOMS[room_id].name)

func _repair_after_defenders() -> void:
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		if String(instance.get("piece_id", "")) != "repair_station" or float(instance.get("condition", 0.0)) <= 0.0:
			continue
		var best_room: String = ""
		var repair_amount: int = 8
		var assigned_room: String = String(instance.get("assignment", ""))
		if assigned_room == "workshop" and room_condition(assigned_room) > 0 and room_condition(assigned_room) < 100:
			best_room = assigned_room
			repair_amount = 12
		else:
			var lowest: int = 101
			for room_id in rooms.keys():
				if room_condition(room_id) > 0 and room_condition(room_id) < lowest:
					lowest = room_condition(room_id)
					best_room = String(room_id)
		if not best_room.is_empty() and room_condition(best_room) < 100:
			rooms[best_room].condition = mini(100, room_condition(best_room) + repair_amount)
			_update_room_state(best_room)
			combat_metrics["repairs"] = int(combat_metrics.get("repairs", 0)) + repair_amount
			_battle_log("Repair Station restored %s by %d; it is now %s." % [ROOMS[best_room].name, repair_amount, rooms[best_room].state])
			break

func _battle_step() -> Dictionary:
	battle_step += 1
	combat_metrics["battle_steps"] = int(combat_metrics.get("battle_steps", 0)) + 1
	var lockdown_contact: bool = false
	var rally_contact: bool = rally_pending
	_battle_log("Step %d: forecast says %s; the keep executes its prepared routine." % [battle_step, enemy_doctrine.replace("_", " ")])
	for enemy in enemies:
		if bool(enemy.get("defeated", false)):
			continue
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		var damage: int = _defender_damage(enemy_id)
		if damage > 0:
			enemy.hp = maxi(0, int(enemy.get("hp", 0)) - damage)
			combat_metrics["unit_attacks"] = int(combat_metrics.get("unit_attacks", 0)) + _last_attackers.size()
			combat_metrics["damage_dealt"] = int(combat_metrics.get("damage_dealt", 0)) + damage
			enemy.damage_taken = int(enemy.get("damage_taken", 0)) + damage
			for attacker_id in _last_attackers:
				var attacker_damage: int = int(_last_attack_damage.get(attacker_id, 0))
				pieces[attacker_id].attacks = int(pieces[attacker_id].get("attacks", 0)) + 1
				pieces[attacker_id].damage_dealt = int(pieces[attacker_id].get("damage_dealt", 0)) + attacker_damage
				pieces[attacker_id].last_target = enemy_id
			_battle_log("Defenders dealt %d to %s using %s counterplay." % [damage, ENEMIES[enemy_id].name, ENEMIES[enemy_id].counter])
		if int(enemy.get("hp", 0)) <= 0:
			enemy.defeated = true
			combat_metrics["defeated_enemies"] = int(combat_metrics.get("defeated_enemies", 0)) + 1
			for attacker_id in _last_attackers:
				pieces[attacker_id].targets_stopped = int(pieces[attacker_id].get("targets_stopped", 0)) + 1
			_battle_log("%s was stopped before its doctrine could complete." % ENEMIES[enemy_id].name)
			continue
		if battle_step >= int(ENEMIES[enemy_id].arrival_step):
			if String(enemy.get("target", "")).is_empty():
				enemy.target = _choose_target(enemy_id)
				var target_name: String = "none"
				if ROOMS.has(enemy.target):
					target_name = String(ROOMS[enemy.target].name)
				elif pieces.has(enemy.target):
					target_name = String(PIECES[String(pieces[enemy.target].piece_id)].name)
				_battle_log("%s arrived by %s; target forecast resolves to %s." % [ENEMIES[enemy_id].name, ENEMIES[enemy_id].route, target_name])
			if lockdown_pending:
				lockdown_contact = true
			if rally_pending:
				rally_contact = true
			if not String(enemy.get("target", "")).is_empty():
				enemy.attacks_received = int(enemy.get("attacks_received", 0)) + 1
			_apply_enemy_damage(enemy_id, String(enemy.get("target", "")))
	_repair_after_defenders()
	if lockdown_contact:
		for instance_id in pieces.keys():
			var instance: Dictionary = pieces[instance_id]
			var max_health: int = int(instance.get("max_health", PIECES[String(instance.get("piece_id", ""))].get("max_health", 10)))
			_set_piece_health(String(instance_id), int(instance.get("health", max_health)) + maxi(1, int(round(float(max_health) * 0.05))))
		_battle_log("Lockdown restored 5% condition across placed pieces, then released.")
		lockdown_pending = false
	if rally_contact:
		_battle_log("Rally coordinated the response across floors, then released.")
		rally_pending = false
	wave_progress = clamp(float(battle_step) / 6.0, 0.0, 1.0)
	if battle_step >= 6 or _all_enemies_defeated():
		return _finish_wave()
	return {"ok": true, "resolved": false, "step": battle_step, "timeline": battle_report.duplicate()}

func _all_enemies_defeated() -> bool:
	if enemies.is_empty():
		return false
	for enemy in enemies:
		if not bool(enemy.get("defeated", false)):
			return false
	return true

func _critical_breach_count() -> int:
	var count: int = 0
	for room_id in rooms.keys():
		if bool(ROOMS[room_id].critical) and room_state(String(room_id)) == "breached":
			count += 1
	return count

func _append_wave_history() -> void:
	wave_history.append({
		"wave": wave_index,
		"doctrine": enemy_doctrine,
		"principal_pressure": String(DOCTRINE_PRESSURES.get(enemy_doctrine, "Unknown pressure")),
		"outcome": last_outcome,
		"breach_level": breach_level,
		"morale_after": morale,
		"defeated_enemies": int(combat_metrics.get("defeated_enemies", 0)),
		"room_damage": int(combat_metrics.get("room_damage", 0)),
		"piece_damage": int(combat_metrics.get("piece_damage", 0)),
		"ammo_spent": int(combat_metrics.get("ammo_spent", 0)),
		"enemy_attacks": int(combat_metrics.get("enemy_attacks", 0)),
		"recovery_actions_used": 0
	})

func _open_repair_interval(outcome: String) -> void:
	repair_interval_active = true
	repair_actions_remaining = 2
	pack_openings_this_preparation = 0
	if outcome == "partial_breach":
		repair_interval_reason = "The breach is quiet for now. Stabilize one function, then choose who takes the next post."
	else:
		repair_interval_reason = "The bells stop. Assign the crew before the next warning."
	_log("Greywatch repair interval opened: %s" % repair_interval_reason)
	_append_wave_history()

func finish_repair_interval() -> Dictionary:
	if not repair_interval_active:
		return {"ok": false, "reason": "no Greywatch repair interval is open"}
	var unused: int = repair_actions_remaining
	if not wave_history.is_empty():
		wave_history[wave_history.size() - 1].recovery_actions_used = 2 - unused
	repair_interval_active = false
	repair_actions_remaining = 0
	repair_interval_reason = ""
	_reload_ammunition()
	_log("Repair interval closed with %d unused action(s). Surviving ranged defenders reload." % unused)
	if has_next_wave():
		var next_wave: Dictionary = start_wave(enemy_doctrine)
		if bool(next_wave.get("ok", false)):
			_log("Automatic scenario sequence advanced to wave %d/%d." % [wave_index, authored_wave_count()])
			return {"ok": true, "message": "Recovery closed. Wave %d/%d begins automatically." % [wave_index, authored_wave_count()], "unused_actions": unused, "next_wave_started": true, "next_wave": next_wave}
	return {"ok": true, "message": "Repair interval closed. Greywatch is ready for the next forecast.", "unused_actions": unused, "next_wave_started": false, "next_wave": {}}

func _finish_wave() -> Dictionary:
	wave_active = false
	var critical_breaches: int = _critical_breach_count()
	if critical_breaches >= 3 or morale <= 0:
		last_outcome = "collapse"
		repair_interval_active = false
		repair_actions_remaining = 0
		repair_interval_reason = ""
		_reload_ammunition()
		_battle_log("Outcome: collapse. Three critical functions or morale failed; the report identifies the chain; surviving ranged defenders reload for the next attempt.")
		_append_wave_history()
	elif breach_level > 0:
		last_outcome = "partial_breach"
		morale = maxi(0, morale - 1)
		materials += 5
		_battle_log("Outcome: partial breach. The keep remains playable and receives 5 recovery materials.")
		_open_repair_interval(last_outcome)
	else:
		last_outcome = "held"
		morale = mini(10, morale + 1)
		materials += 8
		_battle_log("Outcome: held. The defenders gain 8 materials and 1 morale.")
		_open_repair_interval(last_outcome)
	return {"ok": true, "resolved": true, "outcome": last_outcome, "timeline": battle_report.duplicate(), "breach_level": breach_level, "repair_interval_active": repair_interval_active, "repair_actions_remaining": repair_actions_remaining}

func start_wave(doctrine: String) -> Dictionary:
	if not WAVE_COMPOSITIONS.has(doctrine):
		return {"ok": false, "reason": "unknown invasion doctrine"}
	if repair_interval_active:
		return {"ok": false, "reason": "finish the Greywatch repair interval before starting the next wave"}
	if wave_active:
		return {"ok": false, "reason": "an invasion is already active"}
	if pieces.is_empty():
		return {"ok": false, "reason": "place at least one defensive piece first"}
	if scenario_active and last_outcome == "collapse":
		return {"ok": false, "reason": "this authored sequence ended in collapse; start a new run to replay it"}
	if scenario_active and SCENARIOS.has(scenario_id) and wave_index >= SCENARIOS[scenario_id].get("wave_plans", []).size():
		return {"ok": false, "reason": "this authored scenario has no further waves; start a new run to replay it"}
	wave_index += 1
	if scenario_active and SCENARIOS.has(scenario_id):
		var scenario_doctrines: Array = SCENARIOS[scenario_id].get("doctrines", [doctrine])
		doctrine = String(scenario_doctrines[mini(wave_index - 1, scenario_doctrines.size() - 1)])
		enemy_doctrine = doctrine
	wave_active = true
	battle_step = 0
	battle_clock = 0.0
	wave_progress = 0.0
	breach_level = 0
	lockdown_used = false
	lockdown_pending = false
	rally_used = false
	rally_pending = false
	last_outcome = ""
	enemies.clear()
	battle_report.clear()
	var composition: Array = WAVE_COMPOSITIONS[doctrine]
	if scenario_active and SCENARIOS.has(scenario_id):
		var wave_plan: Array = SCENARIOS[scenario_id].wave_plans[mini(wave_index - 1, SCENARIOS[scenario_id].wave_plans.size() - 1)]
		composition = wave_plan.duplicate()
	_reset_combat_metrics()
	for index in range(composition.size()):
		var enemy_id: String = String(composition[index])
		var enemy_health: int = int(ENEMIES[enemy_id].get("health", 1))
		enemies.append({"enemy_id": enemy_id, "max_health": enemy_health, "hp": enemy_health, "damage": int(ENEMIES[enemy_id].get("damage", 0)), "target": "", "defeated": false, "slot": index, "attacks_received": 0, "damage_taken": 0})
	_battle_log("Forecast: %s. Question: %s" % [doctrine.replace("_", " "), DOCTRINE_QUESTIONS[doctrine]])
	_battle_log("Likely pressure: %s. Scout Post can reveal the exact target before contact." % String(ENEMIES[String(composition[0])].route).replace("_", " "))
	return {"ok": true, "message": "Wave %d begins. Pause between steps and read the target before using Lockdown." % wave_index, "forecast": forecast(), "composition": composition.duplicate()}

func advance_wave(delta: float) -> Dictionary:
	if not wave_active:
		return {"ok": false, "reason": "no active invasion"}
	battle_clock += maxf(0.0, delta)
	var latest: Dictionary = {"ok": true, "resolved": false, "step": battle_step, "timeline": battle_report.duplicate()}
	while battle_clock >= 1.0 and wave_active:
		battle_clock -= 1.0
		latest = _battle_step()
	return latest

func use_commander_ability() -> Dictionary:
	if not wave_active:
		return {"ok": false, "reason": "commander abilities are only meaningful during an active invasion"}
	if command_points <= 0:
		return {"ok": false, "reason": "not enough command points"}
	if commander_id == "castellan":
		if lockdown_used:
			return {"ok": false, "reason": "Lockdown has already been used this wave"}
		command_points -= 1
		lockdown_used = true
		lockdown_pending = true
		_battle_log("The Castellan ordered Lockdown. The next contact will be contained, but the keep cannot reposition during it.")
		return {"ok": true, "message": "Lockdown is armed for the next battle step.", "command_points": command_points}
	if commander_id == "warden":
		if rally_used:
			return {"ok": false, "reason": "Rally has already been used this wave"}
		command_points -= 1
		rally_used = true
		rally_pending = true
		morale = mini(10, morale + 1)
		_battle_log("The Warden called Rally. Open lanes answer the bell; the next response will be coordinated.")
		return {"ok": true, "message": "Rally is armed for the next battle step and restored 1 morale.", "command_points": command_points}
	return {"ok": false, "reason": "unknown active commander"}

func repair_piece(instance_id: String) -> Dictionary:
	var preview: Dictionary = recovery_action_preview("repair_piece", instance_id)
	if not bool(preview.get("ok", false)):
		return {"ok": false, "reason": String(preview.get("reason", "piece repair is unavailable")), "state_changes": []}
	materials -= 6
	var max_health: int = int(pieces[instance_id].get("max_health", PIECES[String(pieces[instance_id].get("piece_id", ""))].get("max_health", 10)))
	_set_piece_health(instance_id, int(pieces[instance_id].get("health", max_health)) + maxi(1, int(round(float(max_health) * 0.30))))
	combat_metrics["repairs"] = int(combat_metrics.get("repairs", 0)) + 30
	repair_actions_remaining -= 1
	return {"ok": true, "health": pieces[instance_id].health, "max_health": max_health, "condition": pieces[instance_id].condition, "actions_remaining": repair_actions_remaining, "message": "Repair restored the named piece without erasing its battle history.", "state_changes": [{"op": "repair_piece", "piece": instance_id, "health": pieces[instance_id].health}]}

func repair_room(room_id: String) -> Dictionary:
	var preview: Dictionary = recovery_action_preview("repair_room", "", room_id)
	if not bool(preview.get("ok", false)):
		return {"ok": false, "reason": String(preview.get("reason", "room repair is unavailable")), "state_changes": []}
	materials -= 8
	rooms[room_id].condition = mini(100, room_condition(room_id) + 30)
	_update_room_state(room_id)
	combat_metrics["repairs"] = int(combat_metrics.get("repairs", 0)) + 30
	repair_actions_remaining -= 1
	return {"ok": true, "actions_remaining": repair_actions_remaining, "message": "Repaired %s to %s." % [ROOMS[room_id].name, rooms[room_id].state], "state_changes": [{"op": "repair_room", "room": room_id, "condition": room_condition(room_id), "state": room_state(room_id)}]}

func recovery_advice() -> Dictionary:
	if not repair_interval_active:
		return {"ok": false, "reason": "no recovery interval is open"}
	var next_doctrine: String = ""
	if has_next_wave() and SCENARIOS.has(scenario_id):
		var doctrines: Array = SCENARIOS[scenario_id].get("doctrines", [])
		next_doctrine = String(doctrines[mini(wave_index, doctrines.size() - 1)]) if not doctrines.is_empty() else enemy_doctrine
	var target: String = "the most damaged critical room"
	var action: String = "repair_room"
	if next_doctrine == "distributed_sabotage":
		target = "Workshop or Supply Room; preserve support coverage"
		action = "repair_room_or_assign_support"
	elif next_doctrine == "feint_and_flank":
		target = "North Tower or Old Chapel; preserve an upper response lane"
		action = "assign_upper_response_or_repair"
	elif next_doctrine == "area_pressure":
		target = "Inner Yard and adjacent support rooms"
		action = "brace_or_repair_area"
	return {"ok": true, "next_doctrine": next_doctrine, "target": target, "recommended_action": action, "actions_remaining": repair_actions_remaining, "tradeoff": "Each action repairs or reassigns one priority; unused actions do not silently reset damage."}

func scenario_scorecard() -> Dictionary:
	var outcomes: Array[String] = []
	var total_defeated: int = 0
	var total_room_damage: int = 0
	var total_piece_damage: int = 0
	var total_recovery_actions: int = 0
	for row in wave_history:
		outcomes.append(String(row.get("outcome", "")))
		total_defeated += int(row.get("defeated_enemies", 0))
		total_room_damage += int(row.get("room_damage", 0))
		total_piece_damage += int(row.get("piece_damage", 0))
		total_recovery_actions += int(row.get("recovery_actions_used", 0))
	return {"scenario_id": scenario_id, "scenario_name": String(SCENARIOS.get(scenario_id, {}).get("name", scenario_id)), "completed_waves": wave_history.size(), "wave_count": authored_wave_count(), "outcomes": outcomes, "total_defeated": total_defeated, "total_room_damage": total_room_damage, "total_piece_damage": total_piece_damage, "recovery_actions_used": total_recovery_actions, "final_outcome": last_outcome, "replay_key": "%s/%s/%d" % [scenario_id, commander_id, seed]}

func scenario_report() -> Dictionary:
	var scorecard: Dictionary = scenario_scorecard()
	var wave_rows: Array[Dictionary] = []
	var held_waves: int = 0
	var breached_waves: int = 0
	for history_row in wave_history:
		var doctrine: String = String(history_row.get("doctrine", ""))
		var outcome: String = String(history_row.get("outcome", ""))
		if outcome == "held":
			held_waves += 1
		elif outcome == "partial_breach" or outcome == "collapse":
			breached_waves += 1
		wave_rows.append({
			"wave": int(history_row.get("wave", wave_rows.size() + 1)),
			"doctrine": doctrine,
			"principal_pressure": String(history_row.get("principal_pressure", DOCTRINE_PRESSURES.get(doctrine, "Unknown pressure"))),
			"outcome": outcome,
			"defeated_enemies": int(history_row.get("defeated_enemies", 0)),
			"room_damage": int(history_row.get("room_damage", 0)),
			"piece_damage": int(history_row.get("piece_damage", 0)),
			"recovery_actions_used": int(history_row.get("recovery_actions_used", 0))
		})
	var surviving_pieces: int = 0
	var disabled_pieces: int = 0
	for piece in pieces.values():
		if bool(piece.get("disabled", false)) or int(piece.get("health", 0)) <= 0:
			disabled_pieces += 1
		else:
			surviving_pieces += 1
	var damaged_rooms: Array[Dictionary] = []
	for room_id in rooms.keys():
		var condition: int = room_condition(String(room_id))
		if condition < 100:
			damaged_rooms.append({"id": String(room_id), "condition": condition})
	for outer in range(damaged_rooms.size()):
		for inner in range(outer + 1, damaged_rooms.size()):
			var left: Dictionary = damaged_rooms[outer]
			var right: Dictionary = damaged_rooms[inner]
			if int(right.condition) < int(left.condition) or (int(right.condition) == int(left.condition) and String(right.id) < String(left.id)):
				damaged_rooms[outer] = right
				damaged_rooms[inner] = left
	var what_worked: Array[String] = []
	if held_waves > 0:
		what_worked.append("%d wave%s held without a room breach." % [held_waves, "" if held_waves == 1 else "s"])
	if int(scorecard.get("total_defeated", 0)) > 0:
		what_worked.append("Defenders stopped %d attacker%s." % [int(scorecard.total_defeated), "" if int(scorecard.total_defeated) == 1 else "s"])
	if int(scorecard.get("recovery_actions_used", 0)) > 0:
		what_worked.append("Recovery committed %d action%s to the next defense." % [int(scorecard.recovery_actions_used), "" if int(scorecard.recovery_actions_used) == 1 else "s"])
	if what_worked.is_empty():
		what_worked.append("The run produced a deterministic record that can be replayed with the same command sequence.")
	var what_failed: Array[String] = []
	if last_outcome == "collapse":
		what_failed.append("The final state collapsed because critical functions or morale reached the failure threshold.")
	elif breached_waves > 0:
		what_failed.append("%d wave%s breached at least one keep function." % [breached_waves, "" if breached_waves == 1 else "s"])
	if not damaged_rooms.is_empty():
		var weakest: Dictionary = damaged_rooms[0]
		what_failed.append("%s finished at %d%% condition." % [String(ROOMS[String(weakest.id)].name), int(weakest.condition)])
	if disabled_pieces > 0:
		what_failed.append("%d defensive piece%s finished disabled." % [disabled_pieces, "" if disabled_pieces == 1 else "s"])
	if what_failed.is_empty():
		what_failed.append("No structural failure was recorded in the resolved waves.")
	var suggested_experiment: String = "Replay with The Warden and preserve an open response lane."
	if last_outcome == "collapse":
		suggested_experiment = "Replay the same seed and preserve one recovery action for the weakest critical function."
	elif room_condition("gate") < 100:
		suggested_experiment = "Assign Pike Squad to Gate and compare the Gate Assault result."
	elif room_condition("workshop") < 100 or room_condition("supply_room") < 100:
		suggested_experiment = "Protect the support chain with Field Engineers or an assigned Repair Station."
	elif room_condition("north_tower") < 100 or room_condition("old_chapel") < 100:
		suggested_experiment = "Preserve an upper response lane and test Scout Post coverage."
	elif commander_id == "warden":
		suggested_experiment = "Replay with The Castellan and compare a compact adjacent layout."
	return {
		"scenario_id": scenario_id,
		"scenario_name": String(scorecard.get("scenario_name", scenario_id)),
		"commander_id": commander_id,
		"commander_name": String(COMMANDERS[commander_id].name),
		"status": "complete" if not has_next_wave() and not wave_active else "in_progress",
		"wave_rows": wave_rows,
		"final_state": {
			"morale": morale,
			"breach_level": breach_level,
			"materials": materials,
			"surviving_pieces": surviving_pieces,
			"disabled_pieces": disabled_pieces
		},
		"what_worked": what_worked,
		"what_failed": what_failed,
		"suggested_experiment": suggested_experiment,
		"replay_key": String(scorecard.get("replay_key", ""))
	}

func forecast() -> Dictionary:
	var likely_target: String = "gate"
	var uncertainty: String = "secondary timing"
	if enemy_doctrine == "distributed_sabotage":
		likely_target = "workshop or supply_room"
		uncertainty = "which support room receives the first mark"
	elif enemy_doctrine == "feint_and_flank":
		likely_target = "north_tower or old_chapel"
		uncertainty = "whether the climber lands high or deep"
	elif enemy_doctrine == "area_pressure":
		likely_target = "inner_yard or outer_wall"
		uncertainty = "which adjacent room shares the impact"
	var scout_bonus: bool = _has_unit("scout_post", "upper") or _warden_signal_bonus()
	if _has_assignment("scout_post", "north_tower"):
		uncertainty = "none: North Tower assignment reveals the landing room"
	return {"doctrine": enemy_doctrine, "question": DOCTRINE_QUESTIONS.get(enemy_doctrine, ""), "likely_target": likely_target, "uncertainty": uncertainty, "scout_bonus": scout_bonus, "exact_target_revealed": _has_assignment("scout_post", "north_tower")}

func summary() -> Dictionary:
	return {
		"commander": COMMANDERS[commander_id].name,
		"commander_id": commander_id,
		"commander_passive": String(COMMANDERS[commander_id].passive),
		"commander_ability_name": String(COMMANDERS[commander_id].ability_name),
		"commander_ability_text": String(COMMANDERS[commander_id].ability_text),
		"commander_limitation": String(COMMANDERS[commander_id].limitation),
		"scenario_id": scenario_id,
		"scenario_active": scenario_active,
		"scenario": scenario_preview(),
		"authored_wave_count": authored_wave_count(),
		"has_next_wave": has_next_wave(),
		"scenario_variation_id": scenario_variation_id,
		"variation_target_room": variation_target_room,
		"variation_materials": variation_materials,
		"variation_morale": variation_morale,
		"materials": materials,
		"command_points": command_points,
		"morale": morale,
		"wave_index": wave_index,
		"wave_active": wave_active,
		"wave_progress": wave_progress,
		"battle_step": battle_step,
		"enemy_doctrine": enemy_doctrine,
		"breach_level": breach_level,
		"last_outcome": last_outcome,
		"repair_interval_active": repair_interval_active,
		"repair_actions_remaining": repair_actions_remaining,
		"repair_interval_reason": repair_interval_reason,
		"assigned_rooms": assigned_rooms.duplicate(),
		"available_pieces": available_pieces.duplicate(),
		"pack_openings_this_preparation": pack_openings_this_preparation,
		"combat_metrics": combat_metrics.duplicate(),
		"forecast": forecast(),
		"rooms": rooms.duplicate(true),
		"pieces": pieces.duplicate(true),
		"enemies": enemies.duplicate(true),
		"wave_history": wave_history.duplicate(true),
		"recovery_advice": recovery_advice(),
		"scenario_scorecard": scenario_scorecard()
	}

func serialize() -> Dictionary:
	return {
		"seed": seed,
		"commander_id": commander_id,
		"materials": materials,
		"command_points": command_points,
		"morale": morale,
		"wave_index": wave_index,
		"wave_active": wave_active,
		"wave_progress": wave_progress,
		"battle_step": battle_step,
		"battle_clock": battle_clock,
		"breach_level": breach_level,
		"enemy_doctrine": enemy_doctrine,
		"pieces": pieces.duplicate(true),
		"owned_packs": owned_packs.duplicate(),
		"offered_packs": offered_packs.duplicate(),
		"enemies": enemies.duplicate(true),
		"rooms": rooms.duplicate(true),
		"log": log.duplicate(),
		"battle_report": battle_report.duplicate(),
		"lockdown_pending": lockdown_pending,
		"lockdown_used": lockdown_used,
		"rally_pending": rally_pending,
		"rally_used": rally_used,
		"scenario_id": scenario_id,
		"scenario_active": scenario_active,
		"scenario_variation_id": scenario_variation_id,
		"variation_target_room": variation_target_room,
		"variation_materials": variation_materials,
		"variation_morale": variation_morale,
		"last_outcome": last_outcome,
		"repair_interval_active": repair_interval_active,
		"repair_actions_remaining": repair_actions_remaining,
		"repair_interval_reason": repair_interval_reason,
		"assigned_rooms": assigned_rooms.duplicate(),
		"available_pieces": available_pieces.duplicate(),
		"pack_openings_this_preparation": pack_openings_this_preparation,
		"reserved_pack_id": reserved_pack_id,
		"combat_metrics": combat_metrics.duplicate(),
		"wave_history": wave_history.duplicate(true),
		"schema_version": SAVE_SCHEMA_VERSION,
		"game_id": GAME_ID
	}

func _decode_origin(value: Variant) -> Vector2i:
	if value is Vector2i:
		return value
	if value is Array and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	if value is String:
		var cleaned: String = String(value).replace("Vector2i(", "").replace(")", "")
		var parts: PackedStringArray = cleaned.split(",")
		if parts.size() >= 2:
			return Vector2i(int(parts[0].strip_edges()), int(parts[1].strip_edges()))
	return Vector2i.ZERO

func load_serialized(data: Dictionary) -> Dictionary:
	if data.is_empty():
		return {"ok": false, "reason": "save payload is empty"}
	var schema_version: int = int(data.get("schema_version", 1))
	if schema_version > SAVE_SCHEMA_VERSION:
		return {"ok": false, "reason": "save was created by a newer schema (%d)" % schema_version}
	var game_id: String = String(data.get("game_id", GAME_ID))
	if game_id != GAME_ID:
		return {"ok": false, "reason": "save belongs to another game"}
	if data.has("pieces") and not (data.get("pieces") is Dictionary):
		return {"ok": false, "reason": "save pieces collection is malformed"}
	if data.has("rooms") and not (data.get("rooms") is Dictionary):
		return {"ok": false, "reason": "save rooms collection is malformed"}
	if data.has("enemies") and not (data.get("enemies") is Array):
		return {"ok": false, "reason": "save enemies collection is malformed"}
	seed = int(data.get("seed", seed))
	commander_id = String(data.get("commander_id", ACTIVE_COMMANDER))
	if not COMMANDERS.has(commander_id):
		return {"ok": false, "reason": "save contains an unknown commander"}
	scenario_id = String(data.get("scenario_id", scenario_id))
	if not SCENARIOS.has(scenario_id):
		return {"ok": false, "reason": "save contains an unknown scenario"}
	scenario_active = bool(data.get("scenario_active", scenario_active))
	scenario_variation_id = String(data.get("scenario_variation_id", scenario_variation_id))
	variation_target_room = String(data.get("variation_target_room", variation_target_room))
	variation_materials = int(data.get("variation_materials", variation_materials))
	variation_morale = int(data.get("variation_morale", variation_morale))
	materials = int(data.get("materials", materials))
	command_points = int(data.get("command_points", command_points))
	morale = int(data.get("morale", morale))
	wave_index = int(data.get("wave_index", wave_index))
	wave_active = bool(data.get("wave_active", wave_active))
	wave_progress = float(data.get("wave_progress", wave_progress))
	battle_step = int(data.get("battle_step", battle_step))
	battle_clock = float(data.get("battle_clock", battle_clock))
	breach_level = int(data.get("breach_level", breach_level))
	enemy_doctrine = String(data.get("enemy_doctrine", enemy_doctrine))
	pieces = data.get("pieces", {}).duplicate(true)
	for instance_id in pieces.keys():
		pieces[instance_id].origin = _decode_origin(pieces[instance_id].get("origin", Vector2i.ZERO))
	owned_packs.clear()
	for pack_id in data.get("owned_packs", []):
		owned_packs.append(String(pack_id))
	offered_packs.clear()
	for pack_id in data.get("offered_packs", offered_packs):
		offered_packs.append(String(pack_id))
	available_pieces.clear()
	for piece_id in data.get("available_pieces", STARTER_PIECES):
		available_pieces.append(String(piece_id))
	if not data.has("available_pieces"):
		_rebuild_available_pieces()
	pack_openings_this_preparation = int(data.get("pack_openings_this_preparation", pack_openings_this_preparation))
	reserved_pack_id = String(data.get("reserved_pack_id", reserved_pack_id))
	if not reserved_pack_id.is_empty() and not PACKS.has(reserved_pack_id):
		reserved_pack_id = ""
	enemies.clear()
	for enemy_data in data.get("enemies", []):
		if enemy_data is Dictionary:
			enemies.append(enemy_data.duplicate(true))
	rooms = data.get("rooms", rooms).duplicate(true)
	log.clear()
	for log_entry in data.get("log", []):
		if log_entry is String:
			log.append(String(log_entry))
	battle_report.clear()
	for report_entry in data.get("battle_report", []):
		if report_entry is String:
			battle_report.append(String(report_entry))
	lockdown_pending = bool(data.get("lockdown_pending", lockdown_pending))
	lockdown_used = bool(data.get("lockdown_used", lockdown_used))
	rally_pending = bool(data.get("rally_pending", rally_pending))
	rally_used = bool(data.get("rally_used", rally_used))
	last_outcome = String(data.get("last_outcome", last_outcome))
	combat_metrics = data.get("combat_metrics", combat_metrics).duplicate()
	wave_history.clear()
	for history_entry in data.get("wave_history", []):
		if history_entry is Dictionary:
			wave_history.append(history_entry.duplicate(true))
	if combat_metrics.is_empty():
		_reset_combat_metrics()
	repair_interval_active = bool(data.get("repair_interval_active", repair_interval_active))
	repair_actions_remaining = int(data.get("repair_actions_remaining", repair_actions_remaining))
	repair_interval_reason = String(data.get("repair_interval_reason", repair_interval_reason))
	assigned_rooms = data.get("assigned_rooms", {}).duplicate()
	for instance_id in pieces.keys():
		var piece_id: String = String(pieces[instance_id].get("piece_id", ""))
		if not PIECES.has(piece_id):
			continue
		var max_health: int = int(PIECES[piece_id].get("max_health", 10))
		pieces[instance_id].max_health = int(pieces[instance_id].get("max_health", max_health))
		pieces[instance_id].health = int(pieces[instance_id].get("health", roundf(float(pieces[instance_id].get("condition", 1.0)) * float(pieces[instance_id].max_health))))
		pieces[instance_id].condition = float(pieces[instance_id].health) / float(pieces[instance_id].max_health)
		pieces[instance_id].disabled = bool(pieces[instance_id].get("disabled", pieces[instance_id].health <= 0))
		pieces[instance_id].placement_zone = String(pieces[instance_id].get("placement_zone", placement_zone(pieces[instance_id].get("origin", Vector2i.ZERO), String(pieces[instance_id].get("floor", "ground")), PIECES[piece_id].get("size", Vector2i.ONE))))
		var max_ammo: int = int(PIECES[piece_id].get("max_ammo", 0))
		pieces[instance_id].max_ammo = max_ammo
		pieces[instance_id].ammo = clampi(int(pieces[instance_id].get("ammo", max_ammo)), 0, max_ammo)
	if assigned_rooms.is_empty():
		for instance_id in pieces.keys():
			var assignment: String = String(pieces[instance_id].get("assignment", ""))
			if not assignment.is_empty():
				assigned_rooms[assignment] = instance_id
	return {"ok": true, "message": "Save loaded.", "schema_version": schema_version, "legacy": not data.has("schema_version")}
