class_name PackKeepState
extends RefCounted

## Presentation-agnostic state for the Pack the Keep vertical slice.
## Keep decisions and invasion outcomes are reproducible from a seed.

const GRID_SIZE := Vector2i(12, 8)
const COMMANDERS := {
	"castellan": {"name": "The Castellan", "passive": "Adjacent rooms reinforce one another.", "ability": "lockdown", "materials": 0, "morale": 0},
	"warden": {"name": "The Warden", "passive": "Defenders reposition more quickly.", "ability": "rally", "materials": -4, "morale": 2},
}
const PACKS := {
	"pike_line": {"name": "Pike Line", "pieces": ["pike_squad", "narrow_gate"], "doctrine": "compact_corridors", "cost": 4},
	"field_engineers": {"name": "Field Engineers", "pieces": ["repair_station", "brace"], "doctrine": "redundancy", "cost": 4},
	"firekeepers": {"name": "Firekeepers", "pieces": ["fire_team", "fire_brazier"], "doctrine": "denial_zones", "cost": 5},
	"scouts": {"name": "Scouts", "pieces": ["scout_post", "signal_beacon"], "doctrine": "early_warning", "cost": 3},
}
const PIECES := {
	"pike_squad": {"name": "Pike Squad", "size": Vector2i(2, 1), "cost": 8, "role": "holds corridors"},
	"narrow_gate": {"name": "Narrow Gate", "size": Vector2i(1, 2), "cost": 7, "role": "concentrates pressure"},
	"repair_station": {"name": "Repair Station", "size": Vector2i(2, 1), "cost": 10, "role": "restores nearby structures"},
	"brace": {"name": "Wall Brace", "size": Vector2i(1, 1), "cost": 5, "role": "reduces breach damage"},
	"fire_team": {"name": "Fire Team", "size": Vector2i(2, 1), "cost": 9, "role": "controls open space"},
	"fire_brazier": {"name": "Fire Brazier", "size": Vector2i(1, 1), "cost": 6, "role": "creates a denial zone"},
	"scout_post": {"name": "Scout Post", "size": Vector2i(1, 1), "cost": 6, "role": "reveals threats"},
	"signal_beacon": {"name": "Signal Beacon", "size": Vector2i(1, 1), "cost": 5, "role": "improves response time"},
}
const ENEMIES := {
	"raider": {"name": "Raider", "health": 8, "damage": 2, "speed": 1.0, "doctrine": "gate_assault"},
	"sapper": {"name": "Sapper", "health": 5, "damage": 4, "speed": 0.8, "doctrine": "distributed_sabotage"},
	"climber": {"name": "Climber", "health": 6, "damage": 2, "speed": 1.2, "doctrine": "feint_and_flank"},
	"siege_beast": {"name": "Siege Beast", "health": 18, "damage": 7, "speed": 0.45, "doctrine": "area_pressure"},
}

var seed: int = 3307
var commander_id: String = "castellan"
var materials: int = 60
var command_points: int = 8
var morale: int = 6
var wave_index: int = 0
var wave_active: bool = false
var wave_progress: float = 0.0
var breach_level: int = 0
var pieces: Dictionary = {}
var owned_packs: Array[String] = []
var offered_packs: Array[String] = ["pike_line", "field_engineers", "firekeepers"]
var enemy_doctrine: String = "gate_assault"
var log: Array[String] = []

func _init(keep_seed: int = 3307) -> void:
	seed = keep_seed
	log.append("The keep is quiet. Choose a commander and open a pack.")

func select_commander(id: String) -> Dictionary:
	if not COMMANDERS.has(id):
		return {"ok": false, "reason": "unknown commander"}
	if wave_active:
		return {"ok": false, "reason": "commander cannot change during an invasion"}
	commander_id = id
	materials = maxi(0, materials + int(COMMANDERS[id].materials))
	morale = maxi(0, morale + int(COMMANDERS[id].morale))
	return {"ok": true, "message": "%s takes command. %s" % [COMMANDERS[id].name, COMMANDERS[id].passive]}

func open_pack(pack_id: String) -> Dictionary:
	if not PACKS.has(pack_id):
		return {"ok": false, "reason": "unknown pack"}
	if owned_packs.has(pack_id):
		return {"ok": false, "reason": "pack already opened"}
	owned_packs.append(pack_id)
	return {"ok": true, "message": "Opened %s: %s." % [PACKS[pack_id].name, PACKS[pack_id].doctrine.replace("_", " ")]}

func piece_fits(piece_id: String, origin: Vector2i) -> bool:
	if not PIECES.has(piece_id):
		return false
	var size: Vector2i = PIECES[piece_id].size
	if origin.x < 0 or origin.y < 0 or origin.x + size.x > GRID_SIZE.x or origin.y + size.y > GRID_SIZE.y:
		return false
	for existing in pieces.values():
		var existing_origin: Vector2i = existing.origin
		var existing_size: Vector2i = PIECES[existing.piece_id].size
		if Rect2i(origin, size).intersects(Rect2i(existing_origin, existing_size)):
			return false
	return true

func place_piece(piece_id: String, origin: Vector2i) -> Dictionary:
	if not PIECES.has(piece_id):
		return {"ok": false, "reason": "unknown piece"}
	if not piece_fits(piece_id, origin):
		return {"ok": false, "reason": "piece does not fit on the keep grid"}
	var cost := int(PIECES[piece_id].cost)
	if materials < cost:
		return {"ok": false, "reason": "not enough materials"}
	materials -= cost
	var id := "%s_%d" % [piece_id, pieces.size()]
	pieces[id] = {"piece_id": piece_id, "origin": origin, "condition": 1.0}
	return {"ok": true, "piece_instance": id, "message": "Placed %s: %s." % [PIECES[piece_id].name, PIECES[piece_id].role]}

func start_wave(doctrine: String) -> Dictionary:
	if not ["gate_assault", "distributed_sabotage", "feint_and_flank"].has(doctrine):
		return {"ok": false, "reason": "unknown invasion doctrine"}
	if wave_active:
		return {"ok": false, "reason": "an invasion is already active"}
	if pieces.is_empty():
		return {"ok": false, "reason": "place at least one defensive piece first"}
	enemy_doctrine = doctrine
	wave_active = true
	wave_progress = 0.0
	wave_index += 1
	log.append("Wave %d begins: %s." % [wave_index, doctrine.replace("_", " ")])
	return {"ok": true, "message": "The invasion begins. Pause and read the pressure before intervening."}

func advance_wave(delta: float) -> Dictionary:
	if not wave_active:
		return {"ok": false, "reason": "no active invasion"}
	var speed := 0.18
	if enemy_doctrine == "distributed_sabotage":
		speed = 0.22
	elif enemy_doctrine == "feint_and_flank":
		speed = 0.20
	wave_progress = clamp(wave_progress + delta * speed, 0.0, 1.0)
	if wave_progress >= 1.0:
		wave_active = false
		if breach_level == 0:
			morale = mini(10, morale + 1)
			materials += 8
			log.append("The keep held. The defenders recover materials and morale.")
			return {"ok": true, "resolved": true, "outcome": "held"}
		breach_level += 1
		morale = maxi(0, morale - 2)
		log.append("The keep suffered a breach. The next defense must adapt.")
		return {"ok": true, "resolved": true, "outcome": "partial_breach"}
	return {"ok": true, "resolved": false, "progress": wave_progress}

func use_commander_ability() -> Dictionary:
	if command_points <= 0:
		return {"ok": false, "reason": "not enough command points"}
	command_points -= 1
	if commander_id == "castellan":
		for item in pieces.values():
			item.condition = min(1.0, float(item.condition) + 0.15)
		return {"ok": true, "message": "Lockdown reinforces every placed piece."}
	morale = mini(10, morale + 2)
	return {"ok": true, "message": "The Warden rallies the defenders and restores morale."}

func repair_piece(instance_id: String) -> Dictionary:
	if not pieces.has(instance_id):
		return {"ok": false, "reason": "unknown defensive piece"}
	if materials < 6:
		return {"ok": false, "reason": "not enough materials"}
	materials -= 6
	pieces[instance_id].condition = min(1.0, float(pieces[instance_id].condition) + 0.30)
	return {"ok": true, "condition": pieces[instance_id].condition}

func serialize() -> Dictionary:
	return {"seed": seed, "commander_id": commander_id, "materials": materials, "command_points": command_points, "morale": morale, "wave_index": wave_index, "wave_active": wave_active, "wave_progress": wave_progress, "breach_level": breach_level, "pieces": pieces.duplicate(true), "owned_packs": owned_packs.duplicate(), "offered_packs": offered_packs.duplicate(), "enemy_doctrine": enemy_doctrine, "log": log.duplicate()}

func load_serialized(data: Dictionary) -> void:
	seed = int(data.get("seed", seed))
	commander_id = String(data.get("commander_id", commander_id))
	materials = int(data.get("materials", materials))
	command_points = int(data.get("command_points", command_points))
	morale = int(data.get("morale", morale))
	wave_index = int(data.get("wave_index", wave_index))
	wave_active = bool(data.get("wave_active", wave_active))
	wave_progress = float(data.get("wave_progress", wave_progress))
	breach_level = int(data.get("breach_level", breach_level))
	pieces = data.get("pieces", {}).duplicate(true)
	owned_packs = data.get("owned_packs", []).duplicate()
	offered_packs = data.get("offered_packs", offered_packs).duplicate()
	enemy_doctrine = String(data.get("enemy_doctrine", enemy_doctrine))
	log = data.get("log", []).duplicate()
