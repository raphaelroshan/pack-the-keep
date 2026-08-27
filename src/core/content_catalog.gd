extends RefCounted

const PACK_PATHS: Array[String] = [
	"res://data/packs/pike_line.json",
	"res://data/packs/field_engineers.json",
	"res://data/packs/firekeepers.json",
	"res://data/packs/scouts.json"
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

var _packs: Dictionary = {}
var errors: Array[String] = []

func load_default(known_piece_ids: Array) -> Dictionary:
	_packs.clear()
	errors.clear()
	for path in PACK_PATHS:
		_load_pack(path, known_piece_ids)
	return {"ok": errors.is_empty(), "packs": _packs.duplicate(true), "errors": errors.duplicate()}

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
