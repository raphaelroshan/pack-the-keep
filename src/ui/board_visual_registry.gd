class_name BoardVisualRegistry
extends RefCounted

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

static func floor_profile(floor_name: String, terrain: String = "fort", high_contrast: bool = false) -> Dictionary:
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
	if piece_id in ["pike_squad", "rear_guard", "shield_wardens"]:
		family = "formation"
		accent = Color("#6fa1b8")
	elif piece_id in ["fire_team", "crossbow_patrol"]:
		family = "ranged"
		accent = Color("#c87b5d") if piece_id == "fire_team" else Color("#9a7bc3")
	elif piece_id in ["narrow_gate", "breakaway_barricade", "emergency_shutters"]:
		family = "fortification"
		accent = Color("#c69358")
	elif piece_id in ["scout_post", "watch_banner", "bellkeepers", "signal_beacon"]:
		family = "signal"
		accent = Color("#d2b95f")
	elif piece_id in ["runner_pair", "supply_cache"]:
		family = "mobile_support"
		accent = Color("#5fb4bb")
	elif combat_style == "melee":
		family = "formation"
		accent = Color("#6fa1b8")
	return {
		"family": family,
		"shape": {"formation": "shield", "ranged": "crosshair", "fortification": "barrier", "signal": "beacon", "mobile_support": "linked", "support": "cross"}.get(family, "cross"),
		"accent": accent,
		"card": Color("#202a31")
	}

static func enemy_profile(enemy_id: String, attack_style: String = "melee") -> Dictionary:
	var profiles: Dictionary = {
		"raider": {"shape": "chevron", "color": Color("#d26155"), "initial": "R", "scale": 1.0},
		"sapper": {"shape": "diamond", "color": Color("#d7a35b"), "initial": "S", "scale": 1.0},
		"climber": {"shape": "claw", "color": Color("#a77bd1"), "initial": "C", "scale": 1.0},
		"shield_guard": {"shape": "shield", "color": Color("#9e3f48"), "initial": "G", "scale": 1.12},
		"ash_slinger": {"shape": "ring", "color": Color("#77727b"), "initial": "A", "scale": 1.0},
		"shieldbreaker": {"shape": "axe", "color": Color("#78453c"), "initial": "X", "scale": 1.05},
		"standard_cutter": {"shape": "standard", "color": Color("#a84f67"), "initial": "T", "scale": 1.08},
		"siege_beast": {"shape": "hex", "color": Color("#b36c45"), "initial": "B", "scale": 1.5}
	}
	if profiles.has(enemy_id):
		return profiles[enemy_id].duplicate(true)
	return {
		"shape": "diamond" if attack_style == "demolition" else "ring" if attack_style == "ranged" else "chevron",
		"color": Color("#d26155"),
		"initial": "?",
		"scale": 1.0
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
			"standard_cutter": enemy_profile("standard_cutter").shape
		}
	}
