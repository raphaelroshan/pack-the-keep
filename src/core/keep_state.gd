extends RefCounted

## Presentation-independent simulation for the Pack the Keep first battle slice.
## The same seed, keep layout, doctrine, and commands produce the same report.

const GRID_SIZE := Vector2i(12, 8)
const FLOORS := ["ground", "upper"]
const ACTIVE_COMMANDER := "castellan"

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
		"starting_materials": 60,
		"starting_morale": 6
	}
}

const PACKS: Dictionary = {
	"pike_line": {"name": "Pike Line", "pieces": ["pike_squad", "narrow_gate"], "doctrine": "compact_corridors", "cost": 4},
	"field_engineers": {"name": "Field Engineers", "pieces": ["repair_station", "brace"], "doctrine": "redundancy", "cost": 4},
	"firekeepers": {"name": "Firekeepers", "pieces": ["fire_team", "fire_brazier"], "doctrine": "denial_zones", "cost": 5},
	"scouts": {"name": "Scouts", "pieces": ["scout_post", "signal_beacon"], "doctrine": "early_warning", "cost": 3}
}

const PIECES: Dictionary = {
	"pike_squad": {"name": "Pike Squad", "size": Vector2i(2, 1), "cost": 8, "role": "holds Gate Road", "attack": 4, "defense": 2, "targets": ["raider"]},
	"repair_station": {"name": "Repair Station", "size": Vector2i(2, 1), "cost": 10, "role": "restores nearby structures", "attack": 0, "defense": 1, "targets": ["sapper", "area_pressure"]},
	"fire_team": {"name": "Fire Team", "size": Vector2i(2, 1), "cost": 9, "role": "controls an approach zone", "attack": 3, "defense": 1, "targets": ["climber", "raider"]},
	"scout_post": {"name": "Scout Post", "size": Vector2i(1, 1), "cost": 6, "role": "reveals target and arrival", "attack": 0, "defense": 0, "targets": ["all"]},
	"narrow_gate": {"name": "Narrow Gate", "size": Vector2i(1, 2), "cost": 7, "role": "concentrates Gate pressure", "attack": 0, "defense": 3, "targets": ["raider"]},
	"brace": {"name": "Wall Brace", "size": Vector2i(1, 1), "cost": 5, "role": "reduces adjacent room damage", "attack": 0, "defense": 2, "targets": ["all"]},
	"fire_brazier": {"name": "Fire Brazier", "size": Vector2i(1, 1), "cost": 6, "role": "extends Fire Team denial", "attack": 1, "defense": 0, "targets": ["climber"]},
	"signal_beacon": {"name": "Signal Beacon", "size": Vector2i(1, 1), "cost": 5, "role": "improves warning time", "attack": 0, "defense": 0, "targets": ["all"]}
}

const ENEMIES: Dictionary = {
	"raider": {"name": "Raider", "health": 8, "damage": 2, "arrival_step": 2, "route": "gate_road", "target_rooms": ["gate"], "doctrine": "gate_assault", "counter": "pike_squad"},
	"sapper": {"name": "Sapper", "health": 5, "damage": 3, "arrival_step": 3, "route": "service_lane", "target_rooms": ["workshop", "supply_room", "armory"], "doctrine": "distributed_sabotage", "counter": "scout_post"},
	"climber": {"name": "Climber", "health": 6, "damage": 2, "arrival_step": 2, "route": "north_tower_line", "target_rooms": ["north_tower", "old_chapel"], "doctrine": "feint_and_flank", "counter": "fire_team"}
}

const WAVE_COMPOSITIONS: Dictionary = {
	"gate_assault": ["raider", "raider"],
	"distributed_sabotage": ["raider", "sapper"],
	"feint_and_flank": ["raider", "climber"]
}

const DOCTRINE_QUESTIONS: Dictionary = {
	"gate_assault": "Can the keep concentrate strength at the obvious entrance?",
	"distributed_sabotage": "Can support rooms survive while the front is under pressure?",
	"feint_and_flank": "Has the player left an upper response lane?"
}

var seed: int = 3307
var commander_id: String = ACTIVE_COMMANDER
var materials: int = 60
var command_points: int = 3
var morale: int = 6
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
var enemies: Array[Dictionary] = []
var rooms: Dictionary = {}
var log: Array[String] = []
var battle_report: Array[String] = []
var lockdown_pending: bool = false
var lockdown_used: bool = false
var last_outcome: String = ""

func _init(keep_seed: int = 3307) -> void:
	seed = keep_seed
	_reset_rooms()
	_log("Greywatch Keep is quiet. The Castellan waits for a first doctrine.")

func _reset_rooms() -> void:
	rooms.clear()
	for room_id in ROOMS.keys():
		rooms[room_id] = {"condition": 100, "state": "stable"}

func _log(message: String) -> void:
	log.append(message)

func _battle_log(message: String) -> void:
	battle_report.append(message)
	_log(message)

func select_commander(id: String) -> Dictionary:
	if not COMMANDERS.has(id):
		return {"ok": false, "reason": "the first slice only supports The Castellan"}
	if wave_active:
		return {"ok": false, "reason": "commander cannot change during an invasion"}
	commander_id = id
	materials = int(COMMANDERS[id].starting_materials)
	morale = int(COMMANDERS[id].starting_morale)
	return {"ok": true, "message": "%s takes command. %s" % [COMMANDERS[id].name, COMMANDERS[id].passive]}

func open_pack(pack_id: String) -> Dictionary:
	if not PACKS.has(pack_id):
		return {"ok": false, "reason": "unknown pack"}
	if owned_packs.has(pack_id):
		return {"ok": false, "reason": "pack already opened"}
	owned_packs.append(pack_id)
	return {"ok": true, "message": "Opened %s: %s." % [PACKS[pack_id].name, PACKS[pack_id].doctrine.replace("_", " ")]}

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

func place_piece(piece_id: String, origin: Vector2i, floor: String = "ground") -> Dictionary:
	if not PIECES.has(piece_id):
		return {"ok": false, "reason": "unknown defensive piece"}
	if not piece_fits(piece_id, origin, floor):
		return {"ok": false, "reason": "piece does not fit on this floor of the keep"}
	var cost: int = int(PIECES[piece_id].cost)
	if materials < cost:
		return {"ok": false, "reason": "not enough materials"}
	materials -= cost
	var instance_id: String = "%s_%d" % [piece_id, pieces.size()]
	pieces[instance_id] = {"piece_id": piece_id, "origin": origin, "floor": floor, "condition": 1.0}
	return {"ok": true, "piece_instance": instance_id, "message": "Placed %s on the %s floor: %s." % [PIECES[piece_id].name, floor, PIECES[piece_id].role]}

func remove_piece(instance_id: String) -> Dictionary:
	if not pieces.has(instance_id):
		return {"ok": false, "reason": "unknown defensive piece"}
	pieces.erase(instance_id)
	return {"ok": true, "message": "Removed defensive piece; materials are not refunded during an active run."}

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

func _living_piece_count(piece_id: String, floor: String = "") -> int:
	var count: int = 0
	for instance in pieces.values():
		if String(instance.get("piece_id", "")) == piece_id and (floor.is_empty() or String(instance.get("floor", "")) == floor) and float(instance.get("condition", 0.0)) > 0.0:
			count += 1
	return count

func _has_unit(piece_id: String, floor: String = "") -> bool:
	return _living_piece_count(piece_id, floor) > 0

func _defender_damage(enemy_id: String) -> int:
	var enemy: Dictionary = ENEMIES[enemy_id]
	var damage: int = 0
	for instance in pieces.values():
		if float(instance.get("condition", 0.0)) <= 0.0:
			continue
		var piece_id: String = String(instance.get("piece_id", ""))
		var piece: Dictionary = PIECES[piece_id]
		var valid: bool = piece.targets.has("all") or piece.targets.has(enemy_id)
		if not valid:
			continue
		var contribution: int = int(piece.attack)
		if piece_id == "pike_squad" and String(enemy.route) != "gate_road":
			contribution = 0
		if piece_id == "fire_team" and enemy_id != "climber":
			contribution = 1
		if _castellan_adjacent(instance, String(enemy.target_rooms[0])):
			contribution += 1
		damage += contribution
	return damage

func _choose_target(enemy_id: String) -> String:
	var enemy: Dictionary = ENEMIES[enemy_id]
	var candidates: Array[String] = []
	for room_id in enemy.target_rooms:
		if rooms.has(room_id) and room_condition(room_id) > 0:
			candidates.append(room_id)
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
	var reduced: bool = lockdown_pending
	if reduced:
		damage = maxi(1, int(ceil(float(damage) * 0.5)))
	if rooms.has(target_id):
		var brace_bonus: int = 0
		for instance in pieces.values():
			if String(instance.get("piece_id", "")) == "brace" and _piece_is_adjacent_to_room(instance, target_id) and float(instance.get("condition", 0.0)) > 0.0:
				brace_bonus += 1
		damage = maxi(0, damage - brace_bonus)
		var was_breached: bool = rooms[target_id].state == "breached"
		rooms[target_id].condition = maxi(0, int(rooms[target_id].condition) - damage * 15)
		_update_room_state(target_id)
		_battle_log("%s reached %s and dealt %d room damage%s; room is %s." % [ENEMIES[enemy_id].name, ROOMS[target_id].name, damage, " under Lockdown" if reduced else "", rooms[target_id].state])
		if rooms[target_id].state == "breached" and not was_breached:
			breach_level += 1
			morale = maxi(0, morale - 1)
			_battle_log("%s breached. Morale falls because its named function is offline." % ROOMS[target_id].name)
	elif pieces.has(target_id):
		var instance: Dictionary = pieces[target_id]
		instance.condition = maxf(0.0, float(instance.condition) - float(damage) * 0.25)
		_battle_log("%s damaged %s by %d; condition is %.0f%%." % [ENEMIES[enemy_id].name, PIECES[String(instance.piece_id)].name, damage, float(instance.condition) * 100.0])

func _repair_after_defenders() -> void:
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		if String(instance.get("piece_id", "")) != "repair_station" or float(instance.get("condition", 0.0)) <= 0.0:
			continue
		var best_room: String = ""
		var lowest: int = 101
		for room_id in rooms.keys():
			if room_condition(room_id) > 0 and room_condition(room_id) < lowest:
				lowest = room_condition(room_id)
				best_room = String(room_id)
		if not best_room.is_empty() and lowest < 100:
			rooms[best_room].condition = mini(100, lowest + 8)
			_update_room_state(best_room)
			_battle_log("Repair Station restored %s by 8; it is now %s." % [ROOMS[best_room].name, rooms[best_room].state])
			break

func _battle_step() -> Dictionary:
	battle_step += 1
	var lockdown_contact: bool = false
	_battle_log("Step %d: forecast says %s; the keep executes its prepared routine." % [battle_step, enemy_doctrine.replace("_", " ")])
	for enemy in enemies:
		if bool(enemy.get("defeated", false)):
			continue
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		var damage: int = _defender_damage(enemy_id)
		if damage > 0:
			enemy.hp = maxi(0, int(enemy.hp) - damage)
			_battle_log("Defenders dealt %d to %s using %s counterplay." % [damage, ENEMIES[enemy_id].name, ENEMIES[enemy_id].counter])
		if int(enemy.hp) <= 0:
			enemy.defeated = true
			_battle_log("%s was stopped before its doctrine could complete." % ENEMIES[enemy_id].name)
			continue
		if battle_step >= int(ENEMIES[enemy_id].arrival_step):
			if String(enemy.target).is_empty():
				enemy.target = _choose_target(enemy_id)
				_battle_log("%s arrived by %s; target forecast resolves to %s." % [ENEMIES[enemy_id].name, ENEMIES[enemy_id].route, ROOMS[enemy.target].name if ROOMS.has(enemy.target) else PIECES[String(pieces[enemy.target].piece_id)].name if pieces.has(enemy.target) else "none"])
			if lockdown_pending:
				lockdown_contact = true
			_apply_enemy_damage(enemy_id, String(enemy.target))
	_repair_after_defenders()
	if lockdown_contact:
		for instance in pieces.values():
			instance.condition = minf(1.0, float(instance.get("condition", 0.0)) + 0.05)
		_battle_log("Lockdown restored 5% condition across placed pieces, then released.")
		lockdown_pending = false
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

func _finish_wave() -> Dictionary:
	wave_active = false
	var critical_breaches: int = _critical_breach_count()
	if critical_breaches >= 3 or morale <= 0:
		last_outcome = "collapse"
		_battle_log("Outcome: collapse. Three critical functions or morale failed; the report identifies the chain.")
	elif breach_level > 0:
		last_outcome = "partial_breach"
		morale = maxi(0, morale - 1)
		materials += 5
		_battle_log("Outcome: partial breach. The keep remains playable and receives 5 recovery materials.")
	else:
		last_outcome = "held"
		morale = mini(10, morale + 1)
		materials += 8
		_battle_log("Outcome: held. The defenders gain 8 materials and 1 morale.")
	return {"ok": true, "resolved": true, "outcome": last_outcome, "step": battle_step, "timeline": battle_report.duplicate(), "breach_level": breach_level}

func start_wave(doctrine: String) -> Dictionary:
	if not WAVE_COMPOSITIONS.has(doctrine):
		return {"ok": false, "reason": "unknown invasion doctrine"}
	if wave_active:
		return {"ok": false, "reason": "an invasion is already active"}
	if pieces.is_empty():
		return {"ok": false, "reason": "place at least one defensive piece first"}
	enemy_doctrine = doctrine
	wave_active = true
	wave_index += 1
	battle_step = 0
	battle_clock = 0.0
	wave_progress = 0.0
	breach_level = 0
	lockdown_used = false
	lockdown_pending = false
	last_outcome = ""
	enemies.clear()
	battle_report.clear()
	var composition: Array = WAVE_COMPOSITIONS[doctrine]
	for index in range(composition.size()):
		var enemy_id: String = String(composition[index])
		enemies.append({"enemy_id": enemy_id, "hp": int(ENEMIES[enemy_id].health), "target": "", "defeated": false, "slot": index})
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
	if commander_id != "castellan":
		return {"ok": false, "reason": "unknown active commander"}
	if not wave_active:
		return {"ok": false, "reason": "Lockdown is only meaningful during an active invasion"}
	if lockdown_used:
		return {"ok": false, "reason": "Lockdown has already been used this wave"}
	if command_points <= 0:
		return {"ok": false, "reason": "not enough command points"}
	command_points -= 1
	lockdown_used = true
	lockdown_pending = true
	_battle_log("The Castellan ordered Lockdown. The next contact will be contained, but the keep cannot reposition during it.")
	return {"ok": true, "message": "Lockdown is armed for the next battle step.", "command_points": command_points}

func repair_piece(instance_id: String) -> Dictionary:
	if not pieces.has(instance_id):
		return {"ok": false, "reason": "unknown defensive piece"}
	if materials < 6:
		return {"ok": false, "reason": "not enough materials"}
	materials -= 6
	pieces[instance_id].condition = minf(1.0, float(pieces[instance_id].condition) + 0.30)
	return {"ok": true, "condition": pieces[instance_id].condition, "message": "Repair restored the named piece without erasing its battle history."}

func repair_room(room_id: String) -> Dictionary:
	if not rooms.has(room_id):
		return {"ok": false, "reason": "unknown keep room"}
	if materials < 8:
		return {"ok": false, "reason": "not enough materials"}
	if room_condition(room_id) >= 100:
		return {"ok": false, "reason": "room is already stable"}
	materials -= 8
	rooms[room_id].condition = mini(100, room_condition(room_id) + 30)
	_update_room_state(room_id)
	return {"ok": true, "message": "Repaired %s to %s." % [ROOMS[room_id].name, rooms[room_id].state]}

func forecast() -> Dictionary:
	var likely_target: String = "gate"
	var uncertainty: String = "secondary timing"
	if enemy_doctrine == "distributed_sabotage":
		likely_target = "workshop or supply_room"
		uncertainty = "which support room receives the first mark"
	elif enemy_doctrine == "feint_and_flank":
		likely_target = "north_tower or old_chapel"
		uncertainty = "whether the climber lands high or deep"
	return {"doctrine": enemy_doctrine, "question": DOCTRINE_QUESTIONS.get(enemy_doctrine, ""), "likely_target": likely_target, "uncertainty": uncertainty, "scout_bonus": _has_unit("scout_post", "upper")}

func summary() -> Dictionary:
	return {
		"commander": COMMANDERS[commander_id].name,
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
		"forecast": forecast(),
		"rooms": rooms.duplicate(true),
		"pieces": pieces.duplicate(true),
		"enemies": enemies.duplicate(true)
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
		"last_outcome": last_outcome
	}

func load_serialized(data: Dictionary) -> void:
	seed = int(data.get("seed", seed))
	commander_id = String(data.get("commander_id", ACTIVE_COMMANDER))
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
	owned_packs = data.get("owned_packs", []).duplicate()
	offered_packs = data.get("offered_packs", offered_packs).duplicate()
	enemies = data.get("enemies", []).duplicate(true)
	rooms = data.get("rooms", rooms).duplicate(true)
	log = data.get("log", []).duplicate()
	battle_report = data.get("battle_report", []).duplicate()
	lockdown_pending = bool(data.get("lockdown_pending", lockdown_pending))
	lockdown_used = bool(data.get("lockdown_used", lockdown_used))
	last_outcome = String(data.get("last_outcome", last_outcome))
