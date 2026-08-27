extends RefCounted

const PACK_PATHS: Array[String] = [
	"res://data/packs/pike_line.json",
	"res://data/packs/field_engineers.json",
	"res://data/packs/firekeepers.json",
	"res://data/packs/scouts.json",
	"res://data/packs/runner_network.json",
	"res://data/packs/fallback_convoy.json"
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
	"res://data/pieces/signal_beacon.json",
	"res://data/pieces/runner_pair.json",
	"res://data/pieces/supply_cache.json",
	"res://data/pieces/rear_guard.json",
	"res://data/pieces/breakaway_barricade.json"
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
	"res://data/doctrines/area_pressure.json",
	"res://data/doctrines/rolling_breach.json"
]

const SCENARIO_PATHS: Array[String] = [
	"res://data/scenarios/gatehouse_lock.json",
	"res://data/scenarios/wrong_wall.json",
	"res://data/scenarios/open_yard_net.json",
	"res://data/scenarios/relief_road.json"
]

const EVENT_PATHS: Array[String] = [
	"res://data/events/relief_road_warning.json",
	"res://data/events/relief_road_recovery.json",
	"res://data/events/relief_road_report.json"
]

const MODIFIER_PATHS: Array[String] = [
	"res://data/modifiers/roadside_intelligence.json"
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

const REQUIRED_SCENARIO_FIELDS: Array[String] = ["id", "content_version", "status", "name", "short_role", "question", "objective", "lesson", "starting_doctrine", "doctrines", "wave_plans", "variations"]
const REQUIRED_EVENT_FIELDS: Array[String] = ["id", "content_version", "status", "title", "short_role", "type", "scenario", "trigger", "setup", "choices", "follow_up"]
const SUPPORTED_EVENT_TYPES: Array[String] = ["forecast", "recovery", "scenario_conclusion"]
const SUPPORTED_EVENT_PHASES: Array[String] = ["preparation", "recovery", "results"]
const SUPPORTED_EVENT_REQUIREMENTS: Array[String] = ["command_points", "recovery_actions", "morale"]
const SUPPORTED_EVENT_EFFECTS: Array[String] = ["spend_command_points", "spend_recovery_action", "add_materials", "add_morale", "set_flag", "record_outcome", "unlock_modifier"]
const REQUIRED_MODIFIER_FIELDS: Array[String] = ["id", "content_version", "status", "name", "short_role", "question", "unlock_event", "effect", "starting_morale_cost", "limitation"]
const SUPPORTED_MODIFIER_EFFECTS: Array[String] = ["reveal_wave_composition"]

var _packs: Dictionary = {}
var _commanders: Dictionary = {}
var _pieces: Dictionary = {}
var _enemies: Dictionary = {}
var _doctrines: Dictionary = {}
var _scenarios: Dictionary = {}
var _events: Dictionary = {}
var _modifiers: Dictionary = {}
var errors: Array[String] = []

func load_default(known_room_ids: Array = []) -> Dictionary:
	_packs.clear()
	_commanders.clear()
	_pieces.clear()
	_enemies.clear()
	_doctrines.clear()
	_scenarios.clear()
	_events.clear()
	_modifiers.clear()
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
	for path in SCENARIO_PATHS:
		_load_scenario(path, known_room_ids)
	for path in MODIFIER_PATHS:
		_load_modifier(path)
	for path in EVENT_PATHS:
		_load_event(path)
	_validate_piece_availability()
	_validate_doctrine_enemy_references()
	_validate_event_follow_ups()
	_validate_scenario_event_references()
	_validate_modifier_unlock_events()
	return {"ok": errors.is_empty(), "commanders": _commanders.duplicate(true), "pieces": _pieces.duplicate(true), "packs": _packs.duplicate(true), "enemies": _enemies.duplicate(true), "doctrines": _doctrines.duplicate(true), "scenarios": _scenarios.duplicate(true), "events": _events.duplicate(true), "modifiers": _modifiers.duplicate(true), "errors": errors.duplicate()}

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

func scenario_ids() -> Array[String]:
	var result: Array[String] = []
	for path in SCENARIO_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _scenarios.has(expected_id):
			result.append(expected_id)
	return result

func scenario_definition(scenario_id: String) -> Dictionary:
	return _scenarios.get(scenario_id, {}).duplicate(true)

func event_ids() -> Array[String]:
	var result: Array[String] = []
	for path in EVENT_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _events.has(expected_id):
			result.append(expected_id)
	return result

func event_definition(event_id: String) -> Dictionary:
	return _events.get(event_id, {}).duplicate(true)

func modifier_ids() -> Array[String]:
	var result: Array[String] = []
	for path in MODIFIER_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _modifiers.has(expected_id):
			result.append(expected_id)
	return result

func modifier_definition(modifier_id: String) -> Dictionary:
	return _modifiers.get(modifier_id, {}).duplicate(true)

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

func validate_scenario_definition(scenario: Dictionary, expected_id: String, known_room_ids: Array) -> Array[String]:
	var validation_errors: Array[String] = []
	for field in REQUIRED_SCENARIO_FIELDS:
		if not scenario.has(field):
			validation_errors.append("%s is missing required field: %s" % [expected_id, field])
	var scenario_id: String = String(scenario.get("id", ""))
	if scenario_id != expected_id:
		validation_errors.append("scenario id %s does not match filename %s" % [scenario_id, expected_id])
	if not _is_snake_case_id(scenario_id):
		validation_errors.append("scenario id %s must be snake_case" % scenario_id)
	if String(scenario.get("status", "")) != "active":
		validation_errors.append("scenario %s must have active status" % scenario_id)
	_validate_integer_minimum(scenario, "content_version", scenario_id, "scenario", 1, validation_errors)
	for field in ["name", "short_role", "question", "objective", "lesson", "starting_doctrine"]:
		if not scenario.get(field) is String or String(scenario.get(field, "")).strip_edges().is_empty():
			validation_errors.append("scenario %s must have non-empty text for %s" % [scenario_id, field])
	var doctrines: Variant = scenario.get("doctrines", [])
	var wave_plans: Variant = scenario.get("wave_plans", [])
	if not doctrines is Array or doctrines.size() != 3 or not wave_plans is Array or wave_plans.size() != 3:
		validation_errors.append("scenario %s must define exactly three doctrines and wave plans" % scenario_id)
	else:
		for doctrine_id in doctrines:
			if not doctrine_ids().has(String(doctrine_id)):
				validation_errors.append("scenario %s references unknown doctrine: %s" % [scenario_id, String(doctrine_id)])
		for wave_plan in wave_plans:
			if not wave_plan is Array or wave_plan.is_empty():
				validation_errors.append("scenario %s wave plans must contain enemies" % scenario_id)
			else:
				for enemy_id in wave_plan:
					if not enemy_ids().has(String(enemy_id)):
						validation_errors.append("scenario %s references unknown enemy: %s" % [scenario_id, String(enemy_id)])
	if not doctrine_ids().has(String(scenario.get("starting_doctrine", ""))):
		validation_errors.append("scenario %s starting doctrine is unknown" % scenario_id)
	var variations: Variant = scenario.get("variations", [])
	var has_standard: bool = false
	if not variations is Array or variations.is_empty():
		validation_errors.append("scenario %s must define bounded variations" % scenario_id)
	else:
		for variation in variations:
			if not variation is Dictionary:
				validation_errors.append("scenario %s variation must be an object" % scenario_id)
				continue
			var variation_id: String = String(variation.get("id", ""))
			has_standard = has_standard or variation_id == "standard_bell"
			if not _is_snake_case_id(variation_id):
				validation_errors.append("scenario %s has invalid variation id: %s" % [scenario_id, variation_id])
			for field in ["materials", "morale"]:
				if not _is_integer_number(variation.get(field)):
					validation_errors.append("scenario %s variation %s must have integer %s" % [scenario_id, variation_id, field])
			var target_room: String = String(variation.get("target_room", ""))
			if not target_room.is_empty() and not known_room_ids.has(target_room):
				validation_errors.append("scenario %s variation %s references unknown room: %s" % [scenario_id, variation_id, target_room])
	if not has_standard:
		validation_errors.append("scenario %s must include standard_bell variation" % scenario_id)
	return validation_errors

func validate_event_definition(event: Dictionary, expected_id: String) -> Array[String]:
	var validation_errors: Array[String] = []
	for field in REQUIRED_EVENT_FIELDS:
		if not event.has(field):
			validation_errors.append("%s is missing required field: %s" % [expected_id, field])
	var event_id: String = String(event.get("id", ""))
	if event_id != expected_id:
		validation_errors.append("event id %s does not match filename %s" % [event_id, expected_id])
	if not _is_snake_case_id(event_id):
		validation_errors.append("event id %s must be snake_case" % event_id)
	if String(event.get("status", "")) != "active":
		validation_errors.append("event %s must have active status" % event_id)
	_validate_integer_minimum(event, "content_version", event_id, "event", 1, validation_errors)
	for field in ["title", "short_role", "setup"]:
		if not event.get(field) is String or String(event.get(field, "")).strip_edges().is_empty():
			validation_errors.append("event %s must have non-empty text for %s" % [event_id, field])
	if not SUPPORTED_EVENT_TYPES.has(String(event.get("type", ""))):
		validation_errors.append("event %s has unsupported type" % event_id)
	if not _known_scenario_ids().has(String(event.get("scenario", ""))):
		validation_errors.append("event %s references unknown scenario" % event_id)
	var trigger: Variant = event.get("trigger", {})
	if not trigger is Dictionary:
		validation_errors.append("event %s trigger must be an object" % event_id)
	else:
		if not SUPPORTED_EVENT_PHASES.has(String(trigger.get("phase", ""))):
			validation_errors.append("event %s trigger phase is unsupported" % event_id)
		if not _is_integer_number(trigger.get("wave")) or int(trigger.get("wave", -1)) < 0 or int(trigger.get("wave", -1)) > 3:
			validation_errors.append("event %s trigger wave must be an integer from 0 to 3" % event_id)
	var choices: Variant = event.get("choices", [])
	var choice_ids: Array[String] = []
	if not choices is Array or choices.is_empty():
		validation_errors.append("event %s must define at least one choice" % event_id)
	else:
		for choice in choices:
			if not choice is Dictionary:
				validation_errors.append("event %s choice must be an object" % event_id)
				continue
			var choice_id: String = String(choice.get("id", ""))
			if not _is_snake_case_id(choice_id):
				validation_errors.append("event %s has invalid choice id: %s" % [event_id, choice_id])
			elif choice_ids.has(choice_id):
				validation_errors.append("event %s has duplicate choice id: %s" % [event_id, choice_id])
			else:
				choice_ids.append(choice_id)
			for field in ["label", "visible_result"]:
				if not choice.get(field) is String or String(choice.get(field, "")).strip_edges().is_empty():
					validation_errors.append("event %s choice %s must have non-empty %s" % [event_id, choice_id, field])
			_validate_event_requirements(event_id, choice_id, choice.get("requirements", {}), validation_errors)
			_validate_event_effects(event_id, choice_id, choice.get("effects", []), validation_errors)
	var follow_up: Variant = event.get("follow_up", "")
	if not follow_up is String or (not String(follow_up).is_empty() and not _is_snake_case_id(String(follow_up))):
		validation_errors.append("event %s follow_up must be empty or snake_case" % event_id)
	if String(follow_up) == event_id:
		validation_errors.append("event %s cannot follow itself" % event_id)
	return validation_errors

func _validate_event_requirements(event_id: String, choice_id: String, requirements: Variant, validation_errors: Array[String]) -> void:
	if not requirements is Dictionary:
		validation_errors.append("event %s choice %s requirements must be an object" % [event_id, choice_id])
		return
	for requirement_id in requirements.keys():
		if not SUPPORTED_EVENT_REQUIREMENTS.has(String(requirement_id)):
			validation_errors.append("event %s choice %s has unsupported requirement: %s" % [event_id, choice_id, String(requirement_id)])
			continue
		var constraint: Variant = requirements[requirement_id]
		if not constraint is Dictionary or constraint.size() != 1:
			validation_errors.append("event %s choice %s requirement %s must contain one constraint" % [event_id, choice_id, String(requirement_id)])
			continue
		var operator_id: String = String(constraint.keys()[0])
		if not ["gte", "lt"].has(operator_id) or not _is_integer_number(constraint[operator_id]):
			validation_errors.append("event %s choice %s requirement %s has invalid constraint" % [event_id, choice_id, String(requirement_id)])

func _validate_event_effects(event_id: String, choice_id: String, effects: Variant, validation_errors: Array[String]) -> void:
	if not effects is Array or effects.is_empty():
		validation_errors.append("event %s choice %s must define typed effects" % [event_id, choice_id])
		return
	for effect in effects:
		if not effect is Dictionary:
			validation_errors.append("event %s choice %s effect must be an object" % [event_id, choice_id])
			continue
		var operation: String = String(effect.get("op", ""))
		if not SUPPORTED_EVENT_EFFECTS.has(operation):
			validation_errors.append("event %s choice %s has unsupported effect: %s" % [event_id, choice_id, operation])
			continue
		if ["spend_command_points", "spend_recovery_action", "add_materials", "add_morale"].has(operation):
			if not _is_integer_number(effect.get("amount")) or int(effect.get("amount", 0)) <= 0:
				validation_errors.append("event %s choice %s effect %s needs a positive integer amount" % [event_id, choice_id, operation])
		elif operation == "set_flag":
			if not _is_snake_case_id(String(effect.get("flag", ""))) or not effect.get("value") is bool:
				validation_errors.append("event %s choice %s set_flag needs a snake_case flag and boolean value" % [event_id, choice_id])
		elif operation == "record_outcome" and not _is_snake_case_id(String(effect.get("tag", ""))):
			validation_errors.append("event %s choice %s record_outcome needs a snake_case tag" % [event_id, choice_id])
		elif operation == "unlock_modifier" and not _known_modifier_ids().has(String(effect.get("modifier", ""))):
			validation_errors.append("event %s choice %s references unknown modifier" % [event_id, choice_id])

func validate_modifier_definition(modifier: Dictionary, expected_id: String) -> Array[String]:
	var validation_errors: Array[String] = []
	for field in REQUIRED_MODIFIER_FIELDS:
		if not modifier.has(field):
			validation_errors.append("%s is missing required field: %s" % [expected_id, field])
	var modifier_id: String = String(modifier.get("id", ""))
	if modifier_id != expected_id:
		validation_errors.append("modifier id %s does not match filename %s" % [modifier_id, expected_id])
	if not _is_snake_case_id(modifier_id):
		validation_errors.append("modifier id %s must be snake_case" % modifier_id)
	if String(modifier.get("status", "")) != "active":
		validation_errors.append("modifier %s must have active status" % modifier_id)
	_validate_integer_minimum(modifier, "content_version", modifier_id, "modifier", 1, validation_errors)
	_validate_integer_minimum(modifier, "starting_morale_cost", modifier_id, "modifier", 0, validation_errors)
	for field in ["name", "short_role", "question", "unlock_event", "effect", "limitation"]:
		if not modifier.get(field) is String or String(modifier.get(field, "")).strip_edges().is_empty():
			validation_errors.append("modifier %s must have non-empty text for %s" % [modifier_id, field])
	if not _known_event_ids().has(String(modifier.get("unlock_event", ""))):
		validation_errors.append("modifier %s references unknown unlock event" % modifier_id)
	if not SUPPORTED_MODIFIER_EFFECTS.has(String(modifier.get("effect", ""))):
		validation_errors.append("modifier %s has unsupported effect" % modifier_id)
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

func _load_scenario(path: String, known_room_ids: Array) -> void:
	if not FileAccess.file_exists(path):
		errors.append("missing scenario file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("could not open scenario file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("scenario file must contain one JSON object: %s" % path)
		return
	var scenario: Dictionary = parsed
	var scenario_id: String = String(scenario.get("id", ""))
	var validation_errors: Array[String] = validate_scenario_definition(scenario, path.get_file().get_basename(), known_room_ids)
	if _scenarios.has(scenario_id):
		validation_errors.append("duplicate scenario id: %s" % scenario_id)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if validation_errors.is_empty():
		_scenarios[scenario_id] = scenario.duplicate(true)

func _load_event(path: String) -> void:
	if not FileAccess.file_exists(path):
		errors.append("missing event file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("could not open event file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("event file must contain one JSON object: %s" % path)
		return
	var event: Dictionary = parsed
	var event_id: String = String(event.get("id", ""))
	var validation_errors: Array[String] = validate_event_definition(event, path.get_file().get_basename())
	if _events.has(event_id):
		validation_errors.append("duplicate event id: %s" % event_id)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if validation_errors.is_empty():
		_events[event_id] = event.duplicate(true)

func _load_modifier(path: String) -> void:
	if not FileAccess.file_exists(path):
		errors.append("missing modifier file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("could not open modifier file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("modifier file must contain one JSON object: %s" % path)
		return
	var modifier: Dictionary = parsed
	var modifier_id: String = String(modifier.get("id", ""))
	var validation_errors: Array[String] = validate_modifier_definition(modifier, path.get_file().get_basename())
	if _modifiers.has(modifier_id):
		validation_errors.append("duplicate modifier id: %s" % modifier_id)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if validation_errors.is_empty():
		_modifiers[modifier_id] = modifier.duplicate(true)

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

func _validate_event_follow_ups() -> void:
	for event_id in event_ids():
		var follow_up: String = String(_events[event_id].get("follow_up", ""))
		if not follow_up.is_empty() and not _events.has(follow_up):
			errors.append("event %s references unavailable follow_up: %s" % [event_id, follow_up])

func _validate_scenario_event_references() -> void:
	for scenario_id in scenario_ids():
		var chain: Variant = _scenarios[scenario_id].get("event_chain", [])
		if not chain is Array:
			errors.append("scenario %s event_chain must be an array" % scenario_id)
			continue
		var seen: Array[String] = []
		for index in range(chain.size()):
			var event_id: String = String(chain[index])
			if seen.has(event_id):
				errors.append("scenario %s event_chain contains duplicate event: %s" % [scenario_id, event_id])
			else:
				seen.append(event_id)
			if not _events.has(String(event_id)):
				errors.append("scenario %s references unavailable event: %s" % [scenario_id, String(event_id)])
			elif String(_events[String(event_id)].get("scenario", "")) != scenario_id:
				errors.append("scenario %s event %s belongs to another scenario" % [scenario_id, String(event_id)])
			else:
				var expected_follow_up: String = String(chain[index + 1]) if index + 1 < chain.size() else ""
				if String(_events[event_id].get("follow_up", "")) != expected_follow_up:
					errors.append("scenario %s event %s follow_up does not match chain order" % [scenario_id, event_id])

func _validate_modifier_unlock_events() -> void:
	for modifier_id in modifier_ids():
		var unlock_event: String = String(_modifiers[modifier_id].get("unlock_event", ""))
		if not _events.has(unlock_event):
			errors.append("modifier %s references unavailable unlock event: %s" % [modifier_id, unlock_event])

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

func _known_scenario_ids() -> Array[String]:
	var result: Array[String] = []
	for path in SCENARIO_PATHS:
		result.append(path.get_file().get_basename())
	return result

func _known_event_ids() -> Array[String]:
	var result: Array[String] = []
	for path in EVENT_PATHS:
		result.append(path.get_file().get_basename())
	return result

func _known_modifier_ids() -> Array[String]:
	var result: Array[String] = []
	for path in MODIFIER_PATHS:
		result.append(path.get_file().get_basename())
	return result

func _is_snake_case_id(value: String) -> bool:
	var pattern := RegEx.new()
	pattern.compile("^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
	return pattern.search(value) != null
