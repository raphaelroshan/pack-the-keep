extends SceneTree

const ContentCatalog = preload("res://src/core/content_catalog.gd")
const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var catalog: RefCounted = ContentCatalog.new()
	var loaded: Dictionary = catalog.load_default(PackKeepState.PIECES.keys())
	_check(bool(loaded.get("ok", false)), "active runtime catalog did not load cleanly: %s" % "; ".join(loaded.get("errors", [])))
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
	_check(catalog.pack_ids() == ["pike_line", "field_engineers", "firekeepers", "scouts"], "pack catalog order or active IDs changed")
	var expected: Dictionary = {
		"pike_line": {"cost": 4, "contents": ["pike_squad", "narrow_gate"], "doctrine": "compact_corridors"},
		"field_engineers": {"cost": 4, "contents": ["repair_station", "brace"], "doctrine": "redundancy"},
		"firekeepers": {"cost": 5, "contents": ["fire_team", "fire_brazier"], "doctrine": "denial_zones"},
		"scouts": {"cost": 3, "contents": ["scout_post", "signal_beacon"], "doctrine": "early_warning"}
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
	var validation_errors: Array[String] = catalog.validate_pack_definition(malformed, "wrong_filename", PackKeepState.PIECES.keys())
	_check(validation_errors.size() >= 3, "catalog validator did not reject missing fields, ID mismatch, and unknown piece references")

	var first: PackKeepState = PackKeepState.new(3307)
	var second: PackKeepState = PackKeepState.new(3307)
	_check(bool(first.content_catalog_status().get("ok", false)) and int(first.content_catalog_status().get("pack_count", 0)) == 4 and int(first.content_catalog_status().get("commander_count", 0)) == 2, "KeepState did not expose a valid four-pack, two-commander catalog")
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
