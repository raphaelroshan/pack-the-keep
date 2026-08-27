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

var _packs: Dictionary = {}
var _commanders: Dictionary = {}
var errors: Array[String] = []

func load_default(known_piece_ids: Array) -> Dictionary:
	_packs.clear()
	_commanders.clear()
	errors.clear()
	for path in PACK_PATHS:
		_load_pack(path, known_piece_ids)
	for path in COMMANDER_PATHS:
		_load_commander(path)
	return {"ok": errors.is_empty(), "commanders": _commanders.duplicate(true), "packs": _packs.duplicate(true), "errors": errors.duplicate()}

func commander_ids() -> Array[String]:
	var result: Array[String] = []
	for path in COMMANDER_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _commanders.has(expected_id):
			result.append(expected_id)
	return result

func commander_definition(commander_id: String) -> Dictionary:
	return _commanders.get(commander_id, {}).duplicate(true)

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

func _validate_positive_integer(definition: Dictionary, field: String, definition_id: String, validation_errors: Array[String]) -> void:
	var value: Variant = definition.get(field)
	if not _is_integer_number(value) or int(value) < 1:
		validation_errors.append("commander %s must have a positive integer %s" % [definition_id, field])

func _validate_non_negative_integer(definition: Dictionary, field: String, definition_id: String, validation_errors: Array[String]) -> void:
	var value: Variant = definition.get(field)
	if not _is_integer_number(value) or int(value) < 0:
		validation_errors.append("commander %s must have a non-negative integer %s" % [definition_id, field])

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

func _is_snake_case_id(value: String) -> bool:
	var pattern := RegEx.new()
	pattern.compile("^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
	return pattern.search(value) != null
