class_name BoardVisualRegistry
extends RefCounted

const AUTHORED_ALLY_FORMATION := "res://assets/actors/defender_formation.svg"
const AUTHORED_ALLY_RANGED := "res://assets/actors/defender_ranged.svg"
const AUTHORED_ALLY_MOBILE := "res://assets/actors/defender_mobile.svg"
const AUTHORED_ALLY_SIGNAL := "res://assets/actors/defender_signal.svg"
const AUTHORED_ENEMY_RAIDER := "res://assets/actors/enemy_raider.svg"
const AUTHORED_ENEMY_SAPPER := "res://assets/actors/enemy_sapper.svg"
const AUTHORED_ENEMY_CLIMBER := "res://assets/actors/enemy_climber.svg"
const AUTHORED_ENEMY_SIEGE := "res://assets/actors/enemy_siege_beast.svg"
const AUTHORED_ENEMY_SHIELD_GUARD := "res://assets/actors/enemy_shield_guard.svg"
const AUTHORED_ENEMY_ASH_SLINGER := "res://assets/actors/enemy_ash_slinger.svg"
const AUTHORED_ENEMY_SHIELDBREAKER := "res://assets/actors/enemy_shieldbreaker.svg"
const AUTHORED_ENEMY_STANDARD_CUTTER := "res://assets/actors/enemy_standard_cutter.svg"
const AUTHORED_ENEMY_OUTRIDER := "res://assets/actors/enemy_outrider.svg"
const AUTHORED_ENEMY_GLOAM_KNIFE := "res://assets/actors/enemy_gloam_knife.svg"
const TEMP_DEFENDER_RANGED_EFFECT := "res://assets/temporary/kenney/particle-pack/spark_01.png"
const TEMP_DEFENDER_MELEE_EFFECT := "res://assets/temporary/kenney/particle-pack/slash_01.png"
const TEMP_HOSTILE_RANGED_EFFECT := "res://assets/temporary/kenney/particle-pack/spark_02.png"
const TEMP_HOSTILE_MELEE_EFFECT := "res://assets/temporary/kenney/particle-pack/slash_02.png"
const TEMP_DEMOLITION_EFFECT := "res://assets/temporary/kenney/particle-pack/scorch_01.png"
const TEMP_DAMAGED_ROOM_EFFECT := "res://assets/temporary/kenney/particle-pack/smoke_01.png"
const TEMP_BREACHED_ROOM_EFFECT := "res://assets/temporary/kenney/particle-pack/smoke_04.png"
const TEMP_REPAIR_EFFECT := "res://assets/temporary/kenney/particle-pack/spark_04.png"
const TEMP_ROOM_GATE := "res://assets/temporary/kenney/tiny-dungeon/Tiles/tile_0047.png"
const TEMP_ROOM_ARMORY := "res://assets/temporary/kenney/tiny-dungeon/Tiles/tile_0075.png"
const TEMP_ROOM_WORKSHOP := "res://assets/temporary/kenney/tiny-dungeon/Tiles/tile_0064.png"
const TEMP_ROOM_BARRACKS := "res://assets/temporary/kenney/tiny-dungeon/Tiles/tile_0072.png"
const TEMP_ROOM_SUPPLY := "res://assets/temporary/kenney/tiny-dungeon/Tiles/tile_0066.png"
const TEMP_ROOM_TOWER := "res://assets/temporary/kenney/tiny-dungeon/Tiles/tile_0029.png"
const TEMP_ROOM_CHAPEL := "res://assets/temporary/kenney/tiny-dungeon/Tiles/tile_0065.png"

const ACTOR_PIECES: Array[String] = [
	"pike_squad", "fire_team", "runner_pair", "rear_guard", "crossbow_patrol",
	"bellkeepers", "shield_wardens", "hook_guard", "dusk_bow"
]

const LAYER_ORDER: Array[String] = [
	"background_atmosphere",
	"structural_board",
	"room_surfaces",
	"placement_zones",
	"defender_actors",
	"enemy_routes_and_actors",
	"damage_and_status",
	"focus_and_selection",
	"tactical_labels"
]

const ROOM_DISPLAY_LABELS := {
	"greywatch_keep": {
		"supply_room": "Supply",
		"north_tower": "Tower",
	},
	"ash_ford_redoubt": {
		"gate": "West Head",
		"inner_yard": "Causeway",
		"workshop": "Sluice",
		"barracks": "Ferry",
		"supply_room": "Grain",
		"north_tower": "Signal",
		"old_chapel": "Refuge",
	},
	"twinwatch_bastion": {
		"gate": "West Gate",
		"armory": "East Post",
		"workshop": "Forge",
		"barracks": "Quarters",
		"supply_room": "Magazine",
		"old_chapel": "Chapel",
	},
}

static func floor_profile(floor_name: String, terrain: String = "fort", high_contrast: bool = false) -> Dictionary:
	if terrain == "ridge" and floor_name == "ground":
		return {
			"surface": Color("#302d3f") if not high_contrast else Color("#24213d"),
			"frame": Color("#9ea9c7") if not high_contrast else Color("#d9e2ff"),
			"inset": Color("#4a475d"),
			"header": Color("#d8d5ed"),
			"pattern": "ridge_stone"
		}
	if terrain == "river" and floor_name == "ground":
		return {
			"surface": Color("#203b49") if not high_contrast else Color("#163f55"),
			"frame": Color("#78aeb4") if not high_contrast else Color("#b9f2ff"),
			"inset": Color("#2e5660"),
			"header": Color("#bcdbe0"),
			"pattern": "water"
		}
	if floor_name == "upper":
		return {
			"surface": Color("#263744") if not high_contrast else Color("#17384c"),
			"frame": Color("#8eb6bd") if not high_contrast else Color("#c8f4ff"),
			"inset": Color("#3f5b67"),
			"header": Color("#c8e0d1"),
			"pattern": "wall_walk"
		}
	return {
		"surface": Color("#2b222d") if not high_contrast else Color("#211927"),
		"frame": Color("#b58b67") if not high_contrast else Color("#f1c58d"),
		"inset": Color("#4e4047"),
		"header": Color("#e2bd84"),
		"pattern": "stone"
	}

static func room_profile(critical: bool, state: String, high_contrast: bool = false) -> Dictionary:
	var fill: Color
	match state:
		"breached": fill = Color("#9d3441") if high_contrast else Color("#733b45")
		"damaged": fill = Color("#a66b27") if high_contrast else Color("#8a684d")
		"strained": fill = Color("#81741b") if high_contrast else Color("#6f6544")
		_: fill = Color("#24526b") if high_contrast else Color("#3d4b55")
	return {
		"fill": fill,
		"edge": Color("#f3cf82") if critical else Color("#8fc6c8"),
		"symbol": "diamond" if critical else "notch"
	}


static func room_display_label(keep_id: String, room_id: String, fallback_name: String) -> String:
	var keep_labels: Dictionary = ROOM_DISPLAY_LABELS.get(keep_id, {})
	return String(keep_labels.get(room_id, fallback_name))

static func surface_finish_profile(keep_id: String, floor_name: String, high_contrast: bool = false) -> Dictionary:
	if keep_id != "greywatch_keep":
		return {
			"authored": false,
			"material": "terrain_fallback",
			"source_region": Rect2(),
			"texture_opacity": 0.0,
			"state_fill_opacity": 1.0,
			"selection_width": 3.0 if high_contrast else 2.0,
		}
	var upper: bool = floor_name == "upper"
	return {
		"authored": true,
		"material": "timber_wall_walk" if upper else "stone_work_yard",
		"source_region": Rect2(344, 38, 592, 278) if upper else Rect2(344, 296, 592, 326),
		"texture_opacity": 0.20 if high_contrast else 0.46,
		"state_fill_opacity": 0.88 if high_contrast else 0.72,
		"selection_width": 4.0 if high_contrast else 2.5,
		"surface_tint": Color("#26323a") if upper else Color("#332a2b"),
	}

static func piece_profile(piece_id: String, combat_style: String = "support") -> Dictionary:
	var family: String = "support"
	var accent: Color = Color("#83a47d")
	if piece_id in ["pike_squad", "rear_guard", "shield_wardens", "hook_guard"]:
		family = "formation"
		accent = Color("#7cb0a0") if piece_id == "hook_guard" else Color("#6fa1b8")
	elif piece_id in ["fire_team", "crossbow_patrol", "dusk_bow"]:
		family = "ranged"
		accent = Color("#c87b5d") if piece_id == "fire_team" else Color("#d9b65f") if piece_id == "dusk_bow" else Color("#9a7bc3")
	elif piece_id in ["narrow_gate", "breakaway_barricade", "emergency_shutters", "stake_line"]:
		family = "fortification"
		accent = Color("#9eb36b") if piece_id == "stake_line" else Color("#c69358")
	elif piece_id in ["scout_post", "watch_banner", "bellkeepers", "signal_beacon", "lantern_post"]:
		family = "signal"
		accent = Color("#efc968") if piece_id == "lantern_post" else Color("#d2b95f")
	elif piece_id in ["runner_pair", "supply_cache"]:
		family = "mobile_support"
		accent = Color("#5fb4bb")
	elif combat_style == "melee":
		family = "formation"
		accent = Color("#6fa1b8")
	var profile: Dictionary = {
		"family": family,
		"shape": {"formation": "shield", "ranged": "crosshair", "fortification": "barrier", "signal": "beacon", "mobile_support": "linked", "support": "cross"}.get(family, "cross"),
		"accent": accent,
		"card": Color("#202a31")
	}
	if piece_id in ACTOR_PIECES:
		profile["sprite_path"] = _defender_actor_path(family)
		profile["asset_status"] = "authored_original"
		profile["source"] = "Pack the Keep 32px vector silhouettes"
	return profile

static func _defender_actor_path(family: String) -> String:
	match family:
		"ranged": return AUTHORED_ALLY_RANGED
		"mobile_support": return AUTHORED_ALLY_MOBILE
		"signal": return AUTHORED_ALLY_SIGNAL
		_: return AUTHORED_ALLY_FORMATION

static func enemy_profile(enemy_id: String, attack_style: String = "melee") -> Dictionary:
	var profiles: Dictionary = {
		"raider": {"shape": "chevron", "color": Color("#d26155"), "initial": "R", "scale": 1.0},
		"sapper": {"shape": "diamond", "color": Color("#d7a35b"), "initial": "S", "scale": 1.0},
		"climber": {"shape": "claw", "color": Color("#a77bd1"), "initial": "C", "scale": 1.0},
		"shield_guard": {"shape": "shield", "color": Color("#9e3f48"), "initial": "G", "scale": 1.12},
		"ash_slinger": {"shape": "ring", "color": Color("#77727b"), "initial": "A", "scale": 1.0},
		"shieldbreaker": {"shape": "axe", "color": Color("#78453c"), "initial": "X", "scale": 1.05},
		"standard_cutter": {"shape": "standard", "color": Color("#a84f67"), "initial": "T", "scale": 1.08},
		"outrider": {"shape": "chevron", "color": Color("#d9904f"), "initial": "O", "scale": 0.96},
		"gloam_knife": {"shape": "claw", "color": Color("#75649b"), "initial": "K", "scale": 0.92},
		"siege_beast": {"shape": "hex", "color": Color("#b36c45"), "initial": "B", "scale": 1.5}
	}
	var profile: Dictionary
	if profiles.has(enemy_id):
		profile = profiles[enemy_id].duplicate(true)
	else:
		profile = {
		"shape": "diamond" if attack_style == "demolition" else "ring" if attack_style == "ranged" else "chevron",
		"color": Color("#d26155"),
		"initial": "?",
		"scale": 1.0
		}
	var actor: Dictionary = _enemy_actor_profile(enemy_id, attack_style)
	profile.merge(actor)
	return profile

static func _enemy_actor_profile(enemy_id: String, _attack_style: String) -> Dictionary:
	var authored_paths: Dictionary = {
		"raider": AUTHORED_ENEMY_RAIDER,
		"sapper": AUTHORED_ENEMY_SAPPER,
		"climber": AUTHORED_ENEMY_CLIMBER,
		"siege_beast": AUTHORED_ENEMY_SIEGE,
		"shield_guard": AUTHORED_ENEMY_SHIELD_GUARD,
		"ash_slinger": AUTHORED_ENEMY_ASH_SLINGER,
		"shieldbreaker": AUTHORED_ENEMY_SHIELDBREAKER,
		"standard_cutter": AUTHORED_ENEMY_STANDARD_CUTTER,
		"outrider": AUTHORED_ENEMY_OUTRIDER,
		"gloam_knife": AUTHORED_ENEMY_GLOAM_KNIFE,
	}
	if authored_paths.has(enemy_id):
		return {
			"sprite_path": authored_paths[enemy_id],
			"asset_status": "authored_original",
			"source": "Pack the Keep 32px vector silhouettes",
		}
	return {
		"sprite_path": "",
		"asset_status": "procedural_fallback",
		"source": "BoardVisualRegistry procedural silhouette",
	}

static func combat_effect_profile(source_side: String, attack_style: String) -> Dictionary:
	var defender: bool = source_side == "defender"
	var effect_path: String
	var size: float
	if attack_style == "ranged":
		effect_path = TEMP_DEFENDER_RANGED_EFFECT if defender else TEMP_HOSTILE_RANGED_EFFECT
		size = 34.0
	elif attack_style == "demolition":
		effect_path = TEMP_DEMOLITION_EFFECT
		size = 48.0
	else:
		effect_path = TEMP_DEFENDER_MELEE_EFFECT if defender else TEMP_HOSTILE_MELEE_EFFECT
		size = 40.0
	return {
		"source_side": source_side,
		"attack_style": attack_style,
		"texture_path": effect_path,
		"size": size,
		"asset_status": "temporary_cc0",
		"source": "Kenney Particle Pack · CC0",
	}

static func room_damage_effect_profile(state: String) -> Dictionary:
	if state not in ["damaged", "breached"]:
		return {"active": false, "state": state, "texture_path": ""}
	return {
		"active": true,
		"state": state,
		"texture_path": TEMP_BREACHED_ROOM_EFFECT if state == "breached" else TEMP_DAMAGED_ROOM_EFFECT,
		"size": 38.0 if state == "breached" else 28.0,
		"opacity": 0.24 if state == "breached" else 0.16,
		"asset_status": "temporary_cc0",
		"source": "Kenney Particle Pack · CC0",
	}


static func room_function_accent_profile(keep_id: String, room_id: String) -> Dictionary:
	var paths: Dictionary = {
		"gate": TEMP_ROOM_GATE,
		"armory": TEMP_ROOM_ARMORY,
		"workshop": TEMP_ROOM_WORKSHOP,
		"barracks": TEMP_ROOM_BARRACKS,
		"supply_room": TEMP_ROOM_SUPPLY,
		"north_tower": TEMP_ROOM_TOWER,
		"old_chapel": TEMP_ROOM_CHAPEL,
	}
	if keep_id != "greywatch_keep" or not paths.has(room_id):
		return {"active": false, "keep_id": keep_id, "room_id": room_id, "texture_path": ""}
	return {
		"active": true,
		"keep_id": keep_id,
		"room_id": room_id,
		"texture_path": String(paths[room_id]),
		"size": 18.0,
		"opacity": 0.30,
		"asset_status": "temporary_cc0",
		"source": "Kenney Tiny Dungeon · CC0",
	}


static func repair_effect_profile() -> Dictionary:
	return {
		"texture_path": TEMP_REPAIR_EFFECT,
		"size": 42.0,
		"asset_status": "temporary_cc0",
		"source": "Kenney Particle Pack · CC0",
	}

static func presentation_snapshot() -> Dictionary:
	return {
		"layers": LAYER_ORDER.duplicate(),
		"ground": floor_profile("ground"),
		"upper": floor_profile("upper"),
		"greywatch_finish": {
			"ground": surface_finish_profile("greywatch_keep", "ground"),
			"upper": surface_finish_profile("greywatch_keep", "upper"),
		},
		"enemy_shapes": {
			"raider": enemy_profile("raider").shape,
			"sapper": enemy_profile("sapper", "demolition").shape,
			"climber": enemy_profile("climber").shape,
			"siege_beast": enemy_profile("siege_beast", "demolition").shape,
			"standard_cutter": enemy_profile("standard_cutter").shape,
			"outrider": enemy_profile("outrider").shape,
			"gloam_knife": enemy_profile("gloam_knife").shape
		},
		"authored_actor_assets": true,
		"authored_actor_source": "Pack the Keep original 32px vector silhouettes",
		"authored_enemy_count": 10,
		"temporary_actor_assets": false,
		"temporary_combat_effects": true,
		"temporary_combat_effect_source": "Kenney Particle Pack · CC0",
		"temporary_room_state_effects": true,
		"temporary_room_accents": true,
		"temporary_room_accent_source": "Kenney Tiny Dungeon · CC0",
	}
