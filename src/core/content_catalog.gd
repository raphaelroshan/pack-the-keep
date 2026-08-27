extends RefCounted

const PACK_PATHS: Array[String] = [
	"res://data/packs/pike_line.json",
	"res://data/packs/field_engineers.json",
	"res://data/packs/firekeepers.json",
	"res://data/packs/scouts.json"
]

const COMMANDER_PATHS: Array[String] = [
	"res://data/commanders/castellan.json",
	"res://data/commanders/warden.json"
]

const PIECE_PATHS: Array[String] = [
	"res://data/pieces/pike_squad.json",
	"res://data/pieces/repair_station.json",
	"res://data/pieces/fire_team.json",
	"res://data/pieces/scout_post.json",
	"res://data/pieces/narrow_gate.json",
	"res://data/pieces/brace.json",
	"res://data/pieces/fire_brazier.json",
	"res://data/pieces/signal_beacon.json"
]

const ENEMY_PATHS: Array[String] = [
	"res://data/enemies/raider.json",
	"res://data/enemies/sapper.json",
	"res://data/enemies/climber.json",
	"res://data/enemies/siege_beast.json"
]

const DOCTRINE_PATHS: Array[String] = [
	"res://data/doctrines/gate_assault.json",
	"res://data/doctrines/distributed_sabotage.json",
	"res://data/doctrines/feint_and_flank.json",
	"res://data/doctrines/area_pressure.json"
]

const REQUIRED_PACK_FIELDS: Array[String] = [
	"id",
	"content_version",
	"status",
	"name",
	"short_role",
	"question",
	"family",
	"contents",
	"doctrine",
	"cost",
	"strength",
	"weakness",
	"choice",
	"commander_affinity",
	"spatial_demand"
]

const REQUIRED_COMMANDER_FIELDS: Array[String] = [
	"id",
	"content_version",
	"status",
	"name",
	"short_role",
	"question",
	"passive",
	"ability",
	"ability_name",
	"ability_text",
	"limitation",
	"starting_materials",
	"starting_morale",
	"preferred_pattern",
	"favored_pack_families"
]

const REQUIRED_PIECE_FIELDS: Array[String] = [
	"id",
	"content_version",
	"status",
	"name",
	"short_role",
	"role",
	"question",
	"kind",
	"category",
	"footprint",
	"allowed_floors",
	"allowed_zones",
	"cost",
	"max_health",
	"placement_question",
	"skill",
	"strength_tags",
	"weakness_tags",
	"attack_profile",
	"support_profile",
	"assignment_rule",
	"availability",
	"presentation"
]

const REQUIRED_ENEMY_FIELDS: Array[String] = [
	"id",
	"content_version",
	"status",
	"name",
	"short_role",
	"question",
	"health",
	"damage",
	"arrival_step",
	"route",
	"target_rooms",
	"doctrine",
	"counter",
	"telegraph",
	"counter_families",
	"failure_mode",
	"report_phrase",
	"presentation"
]

const REQUIRED_DOCTRINE_FIELDS: Array[String] = [
	"id",
	"content_version",
	"status",
	"name",
	"short_role",
	"question",
	"composition",
	"route_pattern",
	"target_priority",
	"principal_pressure",
	"likely_target",
	"uncertainty",
	"counter_families"
]

var _packs: Dictionary = {}
var _commanders: Dictionary = {}
var _pieces: Dictionary = {}
var _enemies: Dictionary = {}
var _doctrines: Dictionary = {}
var errors: Array[String] = []

func load_default(known_room_ids: Array = []) -> Dictionary:
	_packs.clear()
	_commanders.clear()
	_pieces.clear()
	_enemies.clear()
	_doctrines.clear()
	errors.clear()
	for path in DOCTRINE_PATHS:
		_load_doctrine(path)
	for path in PIECE_PATHS:
		_load_piece(path, known_room_ids, _known_piece_targets())
	for path in PACK_PATHS:
		_load_pack(path, piece_ids())
	for path in COMMANDER_PATHS:
		_load_commander(path)
	for path in ENEMY_PATHS:
		_load_enemy(path, known_room_ids, doctrine_ids())
	_validate_piece_availability()
	_validate_doctrine_enemy_references()
	return {"ok": errors.is_empty(), "commanders": _commanders.duplicate(true), "pieces": _pieces.duplicate(true), "packs": _packs.duplicate(true), "enemies": _enemies.duplicate(true), "doctrines": _doctrines.duplicate(true), "errors": errors.duplicate()}

func commander_ids() -> Array[String]:
	var result: Array[String] = []
	for path in COMMANDER_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _commanders.has(expected_id):
			result.append(expected_id)
	return result

func commander_definition(commander_id: String) -> Dictionary:
	return _commanders.get(commander_id, {}).duplicate(true)

func piece_ids() -> Array[String]:
	var result: Array[String] = []
	for path in PIECE_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _pieces.has(expected_id):
			result.append(expected_id)
	return result

func piece_definition(piece_id: String) -> Dictionary:
	return _pieces.get(piece_id, {}).duplicate(true)

func enemy_ids() -> Array[String]:
	var result: Array[String] = []
	for path in ENEMY_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _enemies.has(expected_id):
			result.append(expected_id)
	return result

func enemy_definition(enemy_id: String) -> Dictionary:
	return _enemies.get(enemy_id, {}).duplicate(true)

func doctrine_ids() -> Array[String]:
	var result: Array[String] = []
	for path in DOCTRINE_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _doctrines.has(expected_id):
			result.append(expected_id)
	return result

func doctrine_definition(doctrine_id: String) -> Dictionary:
	return _doctrines.get(doctrine_id, {}).duplicate(true)

func pack_ids() -> Array[String]:
	var result: Array[String] = []
	for path in PACK_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _packs.has(expected_id):
			result.append(expected_id)
	return result

func pack_definition(pack_id: String) -> Dictionary:
	if not _packs.has(pack_id):
		return {}
	return _packs[pack_id].duplicate(true)

func validate_piece_definition(piece: Dictionary, expected_id: String, known_room_ids: Array, known_enemy_ids: Array) -> Array[String]:
	var validation_errors: Array[String] = []
	for field in REQUIRED_PIECE_FIELDS:
		if not piece.has(field):
			validation_errors.append("%s is missing required field: %s" % [expected_id, field])
	var piece_id: String = String(piece.get("id", ""))
	if piece_id != expected_id:
		validation_errors.append("piece id %s does not match filename %s" % [piece_id, expected_id])
	if not _is_snake_case_id(piece_id):
		validation_errors.append("piece id %s must be snake_case" % piece_id)
	if String(piece.get("status", "")) != "active":
		validation_errors.append("piece %s must have active status" % piece_id)
	_validate_integer_minimum(piece, "content_version", piece_id, "piece", 1, validation_errors)
	_validate_integer_minimum(piece, "cost", piece_id, "piece", 0, validation_errors)
	_validate_integer_minimum(piece, "max_health", piece_id, "piece", 1, validation_errors)
	for field in ["name", "short_role", "role", "question", "category", "placement_question", "skill", "availability"]:
		if not piece.get(field) is String or String(piece.get(field, "")).strip_edges().is_empty():
			validation_errors.append("piece %s must have non-empty text for %s" % [piece_id, field])
	if not ["unit", "equipment"].has(String(piece.get("kind", ""))):
		validation_errors.append("piece %s kind must be unit or equipment" % piece_id)
	var footprint: Variant = piece.get("footprint", [])
	if not footprint is Array or footprint.size() != 2 or not _is_integer_number(footprint[0]) or not _is_integer_number(footprint[1]) or int(footprint[0]) < 1 or int(footprint[1]) < 1 or int(footprint[0]) > 12 or int(footprint[1]) > 8:
		validation_errors.append("piece %s footprint must contain two positive integers" % piece_id)
	_validate_supported_string_array(piece, "allowed_floors", ["ground", "upper"], piece_id, validation_errors)
	_validate_supported_string_array(piece, "allowed_zones", ["wall", "courtyard", "keep"], piece_id, validation_errors)
	_validate_non_empty_string_array(piece, "strength_tags", piece_id, validation_errors)
	_validate_non_empty_string_array(piece, "weakness_tags", piece_id, validation_errors)
	var attack_profile: Variant = piece.get("attack_profile", {})
	if not attack_profile is Dictionary:
		validation_errors.append("piece %s attack_profile must be an object" % piece_id)
	else:
		if not ["melee", "ranged", "support", "fortification"].has(String(attack_profile.get("style", ""))):
			validation_errors.append("piece %s has an unsupported attack style" % piece_id)
		for field in ["range", "cooldown_steps", "damage", "defense", "ammo_capacity"]:
			_validate_integer_minimum(attack_profile, field, piece_id, "piece attack profile", 0, validation_errors)
		var targets: Variant = attack_profile.get("targets", [])
		if not targets is Array or targets.is_empty():
			validation_errors.append("piece %s attack targets must be a non-empty array" % piece_id)
		else:
			for target in targets:
				if not target is String or (String(target) != "all" and not known_enemy_ids.has(String(target))):
					validation_errors.append("piece %s references unknown attack target: %s" % [piece_id, String(target)])
	var support_profile: Variant = piece.get("support_profile")
	if support_profile != null:
		if not support_profile is Dictionary:
			validation_errors.append("piece %s support_profile must be null or an object" % piece_id)
		else:
			if String(support_profile.get("kind", "")).strip_edges().is_empty():
				validation_errors.append("piece %s support profile must have a kind" % piece_id)
			if String(support_profile.get("response_modifier", "")).strip_edges().is_empty():
				validation_errors.append("piece %s support profile must have a response modifier" % piece_id)
			_validate_integer_minimum(support_profile, "condition_restore", piece_id, "piece support profile", 0, validation_errors)
			var target_rooms: Variant = support_profile.get("target_rooms", [])
			if not target_rooms is Array:
				validation_errors.append("piece %s support target_rooms must be an array" % piece_id)
			else:
				for room_id in target_rooms:
					if not room_id is String or not known_room_ids.has(String(room_id)):
						validation_errors.append("piece %s references unknown support room: %s" % [piece_id, String(room_id)])
	var assignment_rule: Variant = piece.get("assignment_rule")
	if assignment_rule != null:
		if not assignment_rule is Dictionary:
			validation_errors.append("piece %s assignment_rule must be null or an object" % piece_id)
		else:
			var room_id: String = String(assignment_rule.get("room", ""))
			if not known_room_ids.has(room_id):
				validation_errors.append("piece %s references unknown assignment room: %s" % [piece_id, room_id])
			if String(assignment_rule.get("effect", "")).strip_edges().is_empty():
				validation_errors.append("piece %s assignment rule must describe its effect" % piece_id)
	var availability: String = String(piece.get("availability", ""))
	var known_availability: Array[String] = ["starter"]
	for path in PACK_PATHS:
		known_availability.append(path.get_file().get_basename())
	if not known_availability.has(availability):
		validation_errors.append("piece %s references unknown availability source: %s" % [piece_id, availability])
	var presentation: Variant = piece.get("presentation")
	if not presentation is Dictionary:
		validation_errors.append("piece %s presentation must be an object" % piece_id)
	else:
		if not presentation.get("icon") is String:
			validation_errors.append("piece %s presentation icon must be text" % piece_id)
		if not presentation.get("marker_color_role") is String or String(presentation.get("marker_color_role", "")).strip_edges().is_empty():
			validation_errors.append("piece %s presentation marker color role must be non-empty text" % piece_id)
	return validation_errors

func validate_enemy_definition(enemy: Dictionary, expected_id: String, known_room_ids: Array, known_doctrine_ids: Array) -> Array[String]:
	var validation_errors: Array[String] = []
	for field in REQUIRED_ENEMY_FIELDS:
		if not enemy.has(field):
			validation_errors.append("%s is missing required field: %s" % [expected_id, field])
	var enemy_id: String = String(enemy.get("id", ""))
	if enemy_id != expected_id:
		validation_errors.append("enemy id %s does not match filename %s" % [enemy_id, expected_id])
	if not _is_snake_case_id(enemy_id):
		validation_errors.append("enemy id %s must be snake_case" % enemy_id)
	if String(enemy.get("status", "")) != "active":
		validation_errors.append("enemy %s must have active status" % enemy_id)
	_validate_integer_minimum(enemy, "content_version", enemy_id, "enemy", 1, validation_errors)
	_validate_integer_minimum(enemy, "health", enemy_id, "enemy", 1, validation_errors)
	_validate_integer_minimum(enemy, "damage", enemy_id, "enemy", 0, validation_errors)
	_validate_integer_minimum(enemy, "arrival_step", enemy_id, "enemy", 1, validation_errors)
	for field in ["name", "short_role", "question", "route", "doctrine", "counter", "telegraph", "failure_mode", "report_phrase"]:
		if not enemy.get(field) is String or String(enemy.get(field, "")).strip_edges().is_empty():
			validation_errors.append("enemy %s must have non-empty text for %s" % [enemy_id, field])
	var target_rooms: Variant = enemy.get("target_rooms", [])
	if not target_rooms is Array or target_rooms.is_empty():
		validation_errors.append("enemy %s target_rooms must be a non-empty array" % enemy_id)
	else:
		for room_id in target_rooms:
			if not room_id is String or not known_room_ids.has(String(room_id)):
				validation_errors.append("enemy %s references unknown target room: %s" % [enemy_id, String(room_id)])
	if not known_doctrine_ids.has(String(enemy.get("doctrine", ""))):
		validation_errors.append("enemy %s references unknown doctrine: %s" % [enemy_id, String(enemy.get("doctrine", ""))])
	if not piece_ids().has(String(enemy.get("counter", ""))):
		validation_errors.append("enemy %s references unknown counter piece: %s" % [enemy_id, String(enemy.get("counter", ""))])
	var counter_families: Variant = enemy.get("counter_families", [])
	if not counter_families is Array or counter_families.size() < 3:
		validation_errors.append("enemy %s must expose at least three counter families" % enemy_id)
	else:
		for family in counter_families:
			if not family is String or String(family).strip_edges().is_empty():
				validation_errors.append("enemy %s counter families must be non-empty strings" % enemy_id)
	var presentation: Variant = enemy.get("presentation")
	if not presentation is Dictionary:
		validation_errors.append("enemy %s presentation must be an object" % enemy_id)
	else:
		if not presentation.get("icon") is String:
			validation_errors.append("enemy %s presentation icon must be text" % enemy_id)
		if String(presentation.get("marker_color_role", "")).strip_edges().is_empty():
			validation_errors.append("enemy %s marker color role must be non-empty text" % enemy_id)
		var radius_scale: Variant = presentation.get("radius_scale")
		if (typeof(radius_scale) != TYPE_INT and typeof(radius_scale) != TYPE_FLOAT) or float(radius_scale) <= 0.0:
			validation_errors.append("enemy %s radius scale must be positive" % enemy_id)
	return validation_errors

func validate_doctrine_definition(doctrine: Dictionary, expected_id: String, known_enemy_ids: Array) -> Array[String]:
	var validation_errors: Array[String] = []
	for field in REQUIRED_DOCTRINE_FIELDS:
		if not doctrine.has(field):
			validation_errors.append("%s is missing required field: %s" % [expected_id, field])
	var doctrine_id: String = String(doctrine.get("id", ""))
	if doctrine_id != expected_id:
		validation_errors.append("doctrine id %s does not match filename %s" % [doctrine_id, expected_id])
	if not _is_snake_case_id(doctrine_id):
		validation_errors.append("doctrine id %s must be snake_case" % doctrine_id)
	if String(doctrine.get("status", "")) != "active":
		validation_errors.append("doctrine %s must have active status" % doctrine_id)
	_validate_integer_minimum(doctrine, "content_version", doctrine_id, "doctrine", 1, validation_errors)
	for field in ["name", "short_role", "question", "route_pattern", "target_priority", "principal_pressure", "likely_target", "uncertainty"]:
		if not doctrine.get(field) is String or String(doctrine.get(field, "")).strip_edges().is_empty():
			validation_errors.append("doctrine %s must have non-empty text for %s" % [doctrine_id, field])
	var composition: Variant = doctrine.get("composition", [])
	if not composition is Array or composition.is_empty():
		validation_errors.append("doctrine %s composition must contain at least one enemy" % doctrine_id)
	else:
		for enemy_id in composition:
			if not enemy_id is String or not known_enemy_ids.has(String(enemy_id)):
				validation_errors.append("doctrine %s references unknown enemy: %s" % [doctrine_id, String(enemy_id)])
	var counter_families: Variant = doctrine.get("counter_families", [])
	if not counter_families is Array or counter_families.size() < 3:
		validation_errors.append("doctrine %s must expose at least three counter families" % doctrine_id)
	else:
		for family in counter_families:
			if not family is String or String(family).strip_edges().is_empty():
				validation_errors.append("doctrine %s counter families must be non-empty strings" % doctrine_id)
	return validation_errors

func validate_commander_definition(commander: Dictionary, expected_id: String) -> Array[String]:
	var validation_errors: Array[String] = []
	for field in REQUIRED_COMMANDER_FIELDS:
		if not commander.has(field):
			validation_errors.append("%s is missing required field: %s" % [expected_id, field])
	var commander_id: String = String(commander.get("id", ""))
	if commander_id.is_empty():
		validation_errors.append("%s has an empty id" % expected_id)
	elif commander_id != expected_id:
		validation_errors.append("commander id %s does not match filename %s" % [commander_id, expected_id])
	if not _is_snake_case_id(commander_id):
		validation_errors.append("commander id %s must be snake_case" % commander_id)
	if String(commander.get("status", "")) != "active":
		validation_errors.append("commander %s must have active status" % commander_id)
	_validate_positive_integer(commander, "content_version", commander_id, validation_errors)
	_validate_non_negative_integer(commander, "starting_materials", commander_id, validation_errors)
	var morale: Variant = commander.get("starting_morale")
	if not _is_integer_number(morale) or int(morale) < 0 or int(morale) > 10:
		validation_errors.append("commander %s must have starting morale from 0 to 10" % commander_id)
	for field in ["name", "short_role", "question", "passive", "ability", "ability_name", "ability_text", "limitation", "preferred_pattern"]:
		if not commander.get(field) is String or String(commander.get(field, "")).strip_edges().is_empty():
			validation_errors.append("commander %s must have non-empty text for %s" % [commander_id, field])
	var families: Variant = commander.get("favored_pack_families", [])
	if not families is Array or families.is_empty():
		validation_errors.append("commander %s must favor at least one pack family" % commander_id)
	else:
		for family in families:
			if not family is String or not _known_pack_families().has(String(family)):
				validation_errors.append("commander %s references unknown pack family: %s" % [commander_id, String(family)])
	return validation_errors

func validate_pack_definition(pack: Dictionary, expected_id: String, known_piece_ids: Array) -> Array[String]:
	var validation_errors: Array[String] = []
	for field in REQUIRED_PACK_FIELDS:
		if not pack.has(field):
			validation_errors.append("%s is missing required field: %s" % [expected_id, field])
	var pack_id: String = String(pack.get("id", ""))
	if pack_id.is_empty():
		validation_errors.append("%s has an empty id" % expected_id)
	elif pack_id != expected_id:
		validation_errors.append("pack id %s does not match filename %s" % [pack_id, expected_id])
	if int(pack.get("cost", -1)) < 0:
		validation_errors.append("pack %s has an invalid material cost" % pack_id)
	var contents: Variant = pack.get("contents", [])
	if not (contents is Array) or contents.is_empty():
		validation_errors.append("pack %s must contain at least one piece" % pack_id)
	else:
		for piece_id in contents:
			if not known_piece_ids.has(String(piece_id)):
				validation_errors.append("pack %s references unknown piece: %s" % [pack_id, String(piece_id)])
	return validation_errors

func _load_commander(path: String) -> void:
	if not FileAccess.file_exists(path):
		errors.append("missing commander file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("could not open commander file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		errors.append("commander file must contain one JSON object: %s" % path)
		return
	var commander: Dictionary = parsed
	var commander_id: String = String(commander.get("id", ""))
	var validation_errors: Array[String] = validate_commander_definition(commander, path.get_file().get_basename())
	if _commanders.has(commander_id):
		validation_errors.append("duplicate commander id: %s" % commander_id)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if validation_errors.is_empty():
		_commanders[commander_id] = commander.duplicate(true)

func _load_piece(path: String, known_room_ids: Array, known_enemy_ids: Array) -> void:
	if not FileAccess.file_exists(path):
		errors.append("missing piece file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("could not open piece file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("piece file must contain one JSON object: %s" % path)
		return
	var authored: Dictionary = parsed
	var piece_id: String = String(authored.get("id", ""))
	var validation_errors: Array[String] = validate_piece_definition(authored, path.get_file().get_basename(), known_room_ids, known_enemy_ids)
	if _pieces.has(piece_id):
		validation_errors.append("duplicate piece id: %s" % piece_id)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if validation_errors.is_empty():
		_pieces[piece_id] = _normalize_piece(authored)

func _load_enemy(path: String, known_room_ids: Array, known_doctrine_ids: Array) -> void:
	if not FileAccess.file_exists(path):
		errors.append("missing enemy file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("could not open enemy file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("enemy file must contain one JSON object: %s" % path)
		return
	var enemy: Dictionary = parsed
	var enemy_id: String = String(enemy.get("id", ""))
	var validation_errors: Array[String] = validate_enemy_definition(enemy, path.get_file().get_basename(), known_room_ids, known_doctrine_ids)
	if _enemies.has(enemy_id):
		validation_errors.append("duplicate enemy id: %s" % enemy_id)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if validation_errors.is_empty():
		_enemies[enemy_id] = enemy.duplicate(true)

func _load_doctrine(path: String) -> void:
	if not FileAccess.file_exists(path):
		errors.append("missing doctrine file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("could not open doctrine file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("doctrine file must contain one JSON object: %s" % path)
		return
	var doctrine: Dictionary = parsed
	var doctrine_id: String = String(doctrine.get("id", ""))
	var validation_errors: Array[String] = validate_doctrine_definition(doctrine, path.get_file().get_basename(), _known_enemy_ids())
	if _doctrines.has(doctrine_id):
		validation_errors.append("duplicate doctrine id: %s" % doctrine_id)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if validation_errors.is_empty():
		_doctrines[doctrine_id] = doctrine.duplicate(true)

func _load_pack(path: String, known_piece_ids: Array) -> void:
	if not FileAccess.file_exists(path):
		errors.append("missing pack file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("could not open pack file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		errors.append("pack file must contain one JSON object: %s" % path)
		return
	var pack: Dictionary = parsed
	var pack_id: String = String(pack.get("id", ""))
	var validation_errors: Array[String] = validate_pack_definition(pack, path.get_file().get_basename(), known_piece_ids)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if not validation_errors.is_empty():
		return
	if _packs.has(pack_id):
		errors.append("duplicate pack id: %s" % pack_id)
		return
	_packs[pack_id] = pack.duplicate(true)

func _validate_piece_availability() -> void:
	for piece_id in piece_ids():
		var availability: String = String(_pieces[piece_id].get("availability", ""))
		if availability == "starter":
			continue
		if not _packs.has(availability) or not _packs[availability].get("contents", []).has(piece_id):
			errors.append("piece %s availability pack %s does not contain that piece" % [piece_id, availability])

func _validate_doctrine_enemy_references() -> void:
	for doctrine_id in doctrine_ids():
		for enemy_id in _doctrines[doctrine_id].get("composition", []):
			if not _enemies.has(String(enemy_id)):
				errors.append("doctrine %s composition references unavailable enemy: %s" % [doctrine_id, String(enemy_id)])

func _validate_positive_integer(definition: Dictionary, field: String, definition_id: String, validation_errors: Array[String]) -> void:
	var value: Variant = definition.get(field)
	if not _is_integer_number(value) or int(value) < 1:
		validation_errors.append("commander %s must have a positive integer %s" % [definition_id, field])

func _validate_non_negative_integer(definition: Dictionary, field: String, definition_id: String, validation_errors: Array[String]) -> void:
	var value: Variant = definition.get(field)
	if not _is_integer_number(value) or int(value) < 0:
		validation_errors.append("commander %s must have a non-negative integer %s" % [definition_id, field])

func _validate_integer_minimum(definition: Dictionary, field: String, definition_id: String, content_type: String, minimum: int, validation_errors: Array[String]) -> void:
	var value: Variant = definition.get(field)
	if not _is_integer_number(value) or int(value) < minimum:
		validation_errors.append("%s %s must have %s >= %d" % [content_type, definition_id, field, minimum])

func _validate_non_empty_string_array(definition: Dictionary, field: String, definition_id: String, validation_errors: Array[String]) -> void:
	var values: Variant = definition.get(field, [])
	if not values is Array or values.is_empty():
		validation_errors.append("piece %s %s must be a non-empty array" % [definition_id, field])
		return
	for value in values:
		if not value is String or String(value).strip_edges().is_empty():
			validation_errors.append("piece %s %s must contain non-empty strings" % [definition_id, field])

func _validate_supported_string_array(definition: Dictionary, field: String, supported: Array, definition_id: String, validation_errors: Array[String]) -> void:
	var values: Variant = definition.get(field, [])
	if not values is Array or values.is_empty():
		validation_errors.append("piece %s %s must be a non-empty array" % [definition_id, field])
		return
	for value in values:
		if not value is String or not supported.has(String(value)):
			validation_errors.append("piece %s %s contains unsupported value: %s" % [definition_id, field, String(value)])

func _normalize_piece(authored: Dictionary) -> Dictionary:
	var runtime: Dictionary = authored.duplicate(true)
	var footprint: Array = authored.get("footprint", [1, 1])
	var attack_profile: Dictionary = authored.get("attack_profile", {})
	runtime.size = Vector2i(int(footprint[0]), int(footprint[1]))
	runtime.role = String(authored.get("role", ""))
	runtime.combat_style = String(attack_profile.get("style", "support"))
	runtime.range = int(attack_profile.get("range", 0))
	runtime.attack_interval = int(attack_profile.get("cooldown_steps", 0))
	runtime.attack = int(attack_profile.get("damage", 0))
	runtime.defense = int(attack_profile.get("defense", 0))
	runtime.max_ammo = int(attack_profile.get("ammo_capacity", 0))
	runtime.targets = attack_profile.get("targets", []).duplicate()
	return runtime

func _is_integer_number(value: Variant) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false
	return float(value) == floor(float(value))

func _known_pack_families() -> Array[String]:
	var result: Array[String] = []
	for pack_id in pack_ids():
		var family: String = String(_packs[pack_id].get("family", ""))
		if not family.is_empty() and not result.has(family):
			result.append(family)
	return result

func _known_piece_targets() -> Array:
	var result: Array = doctrine_ids()
	for path in ENEMY_PATHS:
		var enemy_id: String = path.get_file().get_basename()
		if not result.has(enemy_id):
			result.append(enemy_id)
	return result

func _known_enemy_ids() -> Array[String]:
	var result: Array[String] = []
	for path in ENEMY_PATHS:
		result.append(path.get_file().get_basename())
	return result

func _is_snake_case_id(value: String) -> bool:
	var pattern := RegEx.new()
	pattern.compile("^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
	return pattern.search(value) != null
