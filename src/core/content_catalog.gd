extends RefCounted

const KEEP_PATHS: Array[String] = [
	"res://data/keeps/greywatch_keep.json",
	"res://data/keeps/ash_ford_redoubt.json",
	"res://data/keeps/twinwatch_bastion.json"
]

const REGION_PATHS: Array[String] = [
	"res://data/regions/low_mill.json"
]

const PACK_PATHS: Array[String] = [
	"res://data/packs/pike_line.json",
	"res://data/packs/field_engineers.json",
	"res://data/packs/firekeepers.json",
	"res://data/packs/scouts.json",
	"res://data/packs/runner_network.json",
	"res://data/packs/fallback_convoy.json",
	"res://data/packs/crossbow_watch.json",
	"res://data/packs/bell_guard.json",
	"res://data/packs/shieldwall.json",
	"res://data/packs/road_wardens.json",
	"res://data/packs/lantern_watch.json"
]

const COMMANDER_PATHS: Array[String] = [
	"res://data/commanders/castellan.json",
	"res://data/commanders/warden.json",
	"res://data/commanders/quartermaster.json"
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
	"res://data/pieces/breakaway_barricade.json",
	"res://data/pieces/crossbow_patrol.json",
	"res://data/pieces/watch_banner.json",
	"res://data/pieces/bellkeepers.json",
	"res://data/pieces/shield_wardens.json",
	"res://data/pieces/emergency_shutters.json",
	"res://data/pieces/hook_guard.json",
	"res://data/pieces/stake_line.json",
	"res://data/pieces/dusk_bow.json",
	"res://data/pieces/lantern_post.json"
]

const ENEMY_PATHS: Array[String] = [
	"res://data/enemies/raider.json",
	"res://data/enemies/sapper.json",
	"res://data/enemies/climber.json",
	"res://data/enemies/siege_beast.json",
	"res://data/enemies/shield_guard.json",
	"res://data/enemies/ash_slinger.json",
	"res://data/enemies/shieldbreaker.json",
	"res://data/enemies/standard_cutter.json",
	"res://data/enemies/outrider.json",
	"res://data/enemies/gloam_knife.json"
]

const DOCTRINE_PATHS: Array[String] = [
	"res://data/doctrines/gate_assault.json",
	"res://data/doctrines/distributed_sabotage.json",
	"res://data/doctrines/feint_and_flank.json",
	"res://data/doctrines/area_pressure.json",
	"res://data/doctrines/rolling_breach.json",
	"res://data/doctrines/shielded_advance.json",
	"res://data/doctrines/smoke_and_signal.json",
	"res://data/doctrines/break_the_line.json",
	"res://data/doctrines/cut_the_chain.json",
	"res://data/doctrines/rapid_breakthrough.json",
	"res://data/doctrines/veiled_entry.json"
]

const SCENARIO_PATHS: Array[String] = [
	"res://data/scenarios/gatehouse_lock.json",
	"res://data/scenarios/wrong_wall.json",
	"res://data/scenarios/open_yard_net.json",
	"res://data/scenarios/relief_road.json",
	"res://data/scenarios/red_banner_road.json",
	"res://data/scenarios/ash_at_the_bell.json",
	"res://data/scenarios/the_splintered_gate.json",
	"res://data/scenarios/three_bells_at_dusk.json",
	"res://data/scenarios/ash_ford_crossing.json",
	"res://data/scenarios/the_cut_standard.json",
	"res://data/scenarios/the_divided_bell.json",
	"res://data/scenarios/before_the_horn.json",
	"res://data/scenarios/the_unlit_stair.json",
	"res://data/scenarios/last_stand.json"
]

const EVENT_PATHS: Array[String] = [
	"res://data/events/relief_road_warning.json",
	"res://data/events/relief_road_recovery.json",
	"res://data/events/relief_road_report.json",
	"res://data/events/workshop_can_wait.json",
	"res://data/events/mara_second_door.json",
	"res://data/events/old_drain_opens.json",
	"res://data/events/the_bell_has_a_pattern.json",
	"res://data/events/the_gate_is_not_the_keep.json",
	"res://data/events/wrong_wall_report.json"
]

const MODIFIER_PATHS: Array[String] = [
	"res://data/modifiers/roadside_intelligence.json",
	"res://data/modifiers/hardened_vanguard.json"
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
	"attack_interval",
	"attack_style",
	"target_mode",
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

const REQUIRED_KEEP_FIELDS: Array[String] = ["id", "content_version", "status", "name", "short_role", "question", "grid_size", "rooms", "connections", "spatial_rule", "recovery_profile", "visual"]
const REQUIRED_ROOM_FIELDS: Array[String] = ["name", "floor", "origin", "size", "critical", "role"]
const REQUIRED_REGION_FIELDS: Array[String] = ["id", "content_version", "status", "name", "need", "route", "consequences"]
const REQUIRED_REGION_CONSEQUENCE_FIELDS: Array[String] = ["id", "settlement_status", "route_status", "minimum_anchor_condition", "requires_non_collapse", "next_run_materials", "summary"]
const REQUIRED_SCENARIO_FIELDS: Array[String] = ["id", "content_version", "status", "name", "short_role", "question", "objective", "lesson", "keep_id", "recommended_packs", "starting_doctrine", "doctrines", "wave_plans", "variations"]
const REQUIRED_EVENT_FIELDS: Array[String] = ["id", "content_version", "status", "title", "short_role", "type", "scenario", "trigger", "selection", "setup", "choices", "follow_up"]
const REQUIRED_EVENT_CHOICE_FIELDS: Array[String] = ["id", "label", "requirements", "effects", "visible_result"]
const REQUIRED_EVENT_SELECTION_FIELDS: Array[String] = ["stream", "repeat_policy", "cooldown_waves", "max_occurrences"]
const SUPPORTED_EVENT_TYPES: Array[String] = ["forecast", "recovery", "scenario_conclusion"]
const SUPPORTED_EVENT_PHASES: Array[String] = ["preparation", "recovery", "results"]
const SUPPORTED_EVENT_REQUIREMENTS: Array[String] = ["command_points", "recovery_actions", "morale", "materials", "piece_available"]
const SUPPORTED_EVENT_REQUIREMENT_OPERATORS: Array[String] = ["gte", "lt"]
const SUPPORTED_EVENT_EFFECTS: Array[String] = ["spend_command_points", "spend_recovery_action", "add_materials", "add_morale", "set_flag", "record_outcome", "unlock_modifier", "repair_room", "assign_piece"]
const EVENT_EFFECT_FIELDS: Dictionary = {
	"spend_command_points": ["amount"],
	"spend_recovery_action": ["amount"],
	"add_materials": ["amount"],
	"add_morale": ["amount"],
	"set_flag": ["flag", "value"],
	"record_outcome": ["tag"],
	"unlock_modifier": ["modifier"],
	"repair_room": ["room"],
	"assign_piece": ["piece", "room"]
}
const SUPPORTED_EVENT_REPEAT_POLICIES: Array[String] = ["once_per_run", "repeat_after_cooldown"]
const MAX_EVENT_COOLDOWN_WAVES: int = 3
const MAX_EVENT_OCCURRENCES: int = 3
const REQUIRED_MODIFIER_FIELDS: Array[String] = ["id", "content_version", "status", "name", "short_role", "question", "unlock_event", "effect", "starting_morale_cost", "limitation"]
const SUPPORTED_MODIFIER_EFFECTS: Array[String] = ["reveal_wave_composition", "enemy_health_bonus"]

var _keeps: Dictionary = {}
var _regions: Dictionary = {}
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
	_keeps.clear()
	_regions.clear()
	_packs.clear()
	_commanders.clear()
	_pieces.clear()
	_enemies.clear()
	_doctrines.clear()
	_scenarios.clear()
	_events.clear()
	_modifiers.clear()
	errors.clear()
	for path in KEEP_PATHS:
		_load_keep(path)
	var runtime_room_ids: Array = room_ids()
	for room_id in known_room_ids:
		if not runtime_room_ids.has(String(room_id)):
			runtime_room_ids.append(String(room_id))
	for path in REGION_PATHS:
		_load_region(path, runtime_room_ids)
	for path in DOCTRINE_PATHS:
		_load_doctrine(path)
	for path in PIECE_PATHS:
		_load_piece(path, runtime_room_ids, _known_piece_targets())
	for path in PACK_PATHS:
		_load_pack(path, piece_ids())
	for path in COMMANDER_PATHS:
		_load_commander(path)
	for path in ENEMY_PATHS:
		_load_enemy(path, runtime_room_ids, doctrine_ids())
	for path in SCENARIO_PATHS:
		_load_scenario(path, runtime_room_ids)
	for path in MODIFIER_PATHS:
		_load_modifier(path)
	for path in EVENT_PATHS:
		_load_event(path, runtime_room_ids)
	_validate_piece_availability()
	_validate_doctrine_enemy_references()
	_validate_event_follow_ups()
	_validate_scenario_event_references()
	_validate_modifier_unlock_events()
	return {"ok": errors.is_empty(), "keeps": _keeps.duplicate(true), "regions": _regions.duplicate(true), "commanders": _commanders.duplicate(true), "pieces": _pieces.duplicate(true), "packs": _packs.duplicate(true), "enemies": _enemies.duplicate(true), "doctrines": _doctrines.duplicate(true), "scenarios": _scenarios.duplicate(true), "events": _events.duplicate(true), "modifiers": _modifiers.duplicate(true), "errors": errors.duplicate()}

func keep_ids() -> Array[String]:
	var result: Array[String] = []
	for path in KEEP_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _keeps.has(expected_id):
			result.append(expected_id)
	return result

func keep_definition(keep_id: String) -> Dictionary:
	return _keeps.get(keep_id, {}).duplicate(true)

func region_ids() -> Array[String]:
	var result: Array[String] = []
	for path in REGION_PATHS:
		var expected_id: String = path.get_file().get_basename()
		if _regions.has(expected_id):
			result.append(expected_id)
	return result

func region_definition(region_id: String) -> Dictionary:
	return _regions.get(region_id, {}).duplicate(true)

func room_ids() -> Array[String]:
	var result: Array[String] = []
	for keep in _keeps.values():
		for room_id in keep.get("rooms", {}).keys():
			if not result.has(String(room_id)):
				result.append(String(room_id))
	return result

func _room_ids_for_keep(keep_id: String) -> Array[String]:
	var result: Array[String] = []
	for room_id in _keeps.get(keep_id, {}).get("rooms", {}).keys():
		result.append(String(room_id))
	return result

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

func event_schema_contract() -> Dictionary:
	return {
		"required_event_fields": REQUIRED_EVENT_FIELDS.duplicate(),
		"required_choice_fields": REQUIRED_EVENT_CHOICE_FIELDS.duplicate(),
		"selection": {
			"required_fields": REQUIRED_EVENT_SELECTION_FIELDS.duplicate(),
			"repeat_policies": SUPPORTED_EVENT_REPEAT_POLICIES.duplicate(),
			"maximum_cooldown_waves": MAX_EVENT_COOLDOWN_WAVES,
			"maximum_occurrences": MAX_EVENT_OCCURRENCES
		},
		"requirements": SUPPORTED_EVENT_REQUIREMENTS.duplicate(),
		"requirement_operators": SUPPORTED_EVENT_REQUIREMENT_OPERATORS.duplicate(),
		"effects": EVENT_EFFECT_FIELDS.duplicate(true)
	}

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
			for reduction_field in ["room_damage_reduction", "piece_damage_reduction"]:
				if support_profile.has(reduction_field):
					_validate_integer_minimum(support_profile, reduction_field, piece_id, "piece support profile", 0, validation_errors)
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
	_validate_integer_minimum(enemy, "attack_interval", enemy_id, "enemy", 1, validation_errors)
	if not ["melee", "ranged", "demolition"].has(String(enemy.get("attack_style", ""))):
		validation_errors.append("enemy %s attack_style must be melee, ranged, or demolition" % enemy_id)
	if not ["unit_hunter", "room_destroyer"].has(String(enemy.get("target_mode", ""))):
		validation_errors.append("enemy %s target_mode must be unit_hunter or room_destroyer" % enemy_id)
	if enemy.has("armor"):
		_validate_integer_minimum(enemy, "armor", enemy_id, "enemy", 0, validation_errors)
		if int(enemy.get("armor", 0)) > 0 and (not enemy.get("armor_counter_tag") is String or String(enemy.get("armor_counter_tag", "")).strip_edges().is_empty()):
			validation_errors.append("enemy %s with armor must name a non-empty armor_counter_tag" % enemy_id)
	if enemy.has("disruption_profile"):
		var disruption: Variant = enemy.get("disruption_profile")
		if not disruption is Dictionary:
			validation_errors.append("enemy %s disruption_profile must be an object" % enemy_id)
		else:
			for field in ["kind", "counter_modifier", "relay_modifier", "forecast_target"]:
				if not disruption.get(field) is String or String(disruption.get(field, "")).strip_edges().is_empty():
					validation_errors.append("enemy %s disruption_profile %s must be non-empty text" % [enemy_id, field])
			var arrival_delta: Variant = disruption.get("arrival_step_delta")
			if not _is_integer_number(arrival_delta) or int(arrival_delta) < -2 or int(arrival_delta) > 0:
				validation_errors.append("enemy %s disruption_profile arrival_step_delta must be an integer from -2 to 0" % enemy_id)
			if String(disruption.get("kind", "")) != "signal_smoke":
				validation_errors.append("enemy %s has an unsupported disruption kind" % enemy_id)
			var support_modifiers: Array[String] = _known_support_modifiers()
			for modifier_field in ["counter_modifier", "relay_modifier"]:
				var modifier: String = String(disruption.get(modifier_field, ""))
				if not modifier.is_empty() and not support_modifiers.has(modifier):
					validation_errors.append("enemy %s references unknown support modifier: %s" % [enemy_id, modifier])
	if enemy.has("momentum_profile"):
		var momentum: Variant = enemy.get("momentum_profile")
		if not momentum is Dictionary:
			validation_errors.append("enemy %s momentum_profile must be an object" % enemy_id)
		else:
			for field in ["kind", "counter_modifier"]:
				if not momentum.get(field) is String or String(momentum.get(field, "")).strip_edges().is_empty():
					validation_errors.append("enemy %s momentum_profile %s must be non-empty text" % [enemy_id, field])
			if String(momentum.get("kind", "")) != "breakthrough_charge":
				validation_errors.append("enemy %s has an unsupported momentum kind" % enemy_id)
			var delay_steps: Variant = momentum.get("delay_steps")
			if not _is_integer_number(delay_steps) or int(delay_steps) < 1 or int(delay_steps) > 2:
				validation_errors.append("enemy %s momentum_profile delay_steps must be an integer from 1 to 2" % enemy_id)
			var counter_modifier: String = String(momentum.get("counter_modifier", ""))
			if not counter_modifier.is_empty() and not _known_support_modifiers().has(counter_modifier):
				validation_errors.append("enemy %s references unknown support modifier: %s" % [enemy_id, counter_modifier])
	if enemy.has("concealment_profile"):
		var concealment: Variant = enemy.get("concealment_profile")
		if not concealment is Dictionary:
			validation_errors.append("enemy %s concealment_profile must be an object" % enemy_id)
		else:
			for field in ["kind", "counter_modifier"]:
				if not concealment.get(field) is String or String(concealment.get(field, "")).strip_edges().is_empty():
					validation_errors.append("enemy %s concealment_profile %s must be non-empty text" % [enemy_id, field])
			if String(concealment.get("kind", "")) != "veiled_approach":
				validation_errors.append("enemy %s has an unsupported concealment kind" % enemy_id)
			var counter_modifier: String = String(concealment.get("counter_modifier", ""))
			if not counter_modifier.is_empty() and not _known_support_modifiers().has(counter_modifier):
				validation_errors.append("enemy %s references unknown support modifier: %s" % [enemy_id, counter_modifier])
			var blocked_styles: Variant = concealment.get("blocked_attack_styles", [])
			if not blocked_styles is Array or blocked_styles.is_empty():
				validation_errors.append("enemy %s concealment_profile blocked_attack_styles must be a non-empty array" % enemy_id)
			else:
				for style in blocked_styles:
					if not style is String or not ["melee", "ranged"].has(String(style)):
						validation_errors.append("enemy %s concealment_profile has unsupported blocked attack style: %s" % [enemy_id, String(style)])
	if enemy.has("target_piece_categories"):
		_validate_non_empty_string_array(enemy, "target_piece_categories", enemy_id, validation_errors)
	if enemy.has("target_piece_floors"):
		_validate_non_empty_string_array(enemy, "target_piece_floors", enemy_id, validation_errors)
		for floor in enemy.get("target_piece_floors", []):
			if not ["ground", "upper"].has(String(floor)):
				validation_errors.append("enemy %s target_piece_floors contains unsupported floor: %s" % [enemy_id, String(floor)])
	if enemy.has("target_piece_preference") and not ["lowest_condition", "highest_max_health"].has(String(enemy.get("target_piece_preference", ""))):
		validation_errors.append("enemy %s target_piece_preference must be lowest_condition or highest_max_health" % enemy_id)
	if enemy.has("targets_assigned_first") and not enemy.get("targets_assigned_first") is bool:
		validation_errors.append("enemy %s targets_assigned_first must be boolean" % enemy_id)
	if enemy.has("ignores_protection") and not enemy.get("ignores_protection") is bool:
		validation_errors.append("enemy %s ignores_protection must be boolean" % enemy_id)
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

func validate_keep_definition(keep: Dictionary, expected_id: String) -> Array[String]:
	var validation_errors: Array[String] = []
	for field in REQUIRED_KEEP_FIELDS:
		if not keep.has(field):
			validation_errors.append("%s is missing required field: %s" % [expected_id, field])
	var keep_id: String = String(keep.get("id", ""))
	if keep_id != expected_id:
		validation_errors.append("keep id %s does not match filename %s" % [keep_id, expected_id])
	if not _is_snake_case_id(keep_id):
		validation_errors.append("keep id %s must be snake_case" % keep_id)
	if String(keep.get("status", "")) != "active":
		validation_errors.append("keep %s must have active status" % keep_id)
	_validate_integer_minimum(keep, "content_version", keep_id, "keep", 1, validation_errors)
	for field in ["name", "short_role", "question"]:
		if not keep.get(field) is String or String(keep.get(field, "")).strip_edges().is_empty():
			validation_errors.append("keep %s must have non-empty text for %s" % [keep_id, field])
	var grid_size: Variant = keep.get("grid_size")
	if not grid_size is Array or grid_size.size() != 2 or not _is_integer_number(grid_size[0]) or not _is_integer_number(grid_size[1]) or int(grid_size[0]) != 12 or int(grid_size[1]) != 8:
		validation_errors.append("keep %s grid_size must be [12, 8] for the current board" % keep_id)
	var rooms: Variant = keep.get("rooms")
	var room_rects: Dictionary = {}
	if not rooms is Dictionary or rooms.is_empty():
		validation_errors.append("keep %s rooms must be a non-empty object" % keep_id)
	else:
		for room_id_value in rooms.keys():
			var room_id: String = String(room_id_value)
			var room: Variant = rooms[room_id_value]
			if not _is_snake_case_id(room_id) or not room is Dictionary:
				validation_errors.append("keep %s has malformed room: %s" % [keep_id, room_id])
				continue
			for field in REQUIRED_ROOM_FIELDS:
				if not room.has(field):
					validation_errors.append("keep %s room %s is missing required field: %s" % [keep_id, room_id, field])
			for field in ["name", "role"]:
				if not room.get(field) is String or String(room.get(field, "")).strip_edges().is_empty():
					validation_errors.append("keep %s room %s needs non-empty %s" % [keep_id, room_id, field])
			if not ["ground", "upper"].has(String(room.get("floor", ""))):
				validation_errors.append("keep %s room %s has unsupported floor" % [keep_id, room_id])
			if not room.get("critical") is bool:
				validation_errors.append("keep %s room %s critical must be boolean" % [keep_id, room_id])
			var origin: Variant = room.get("origin")
			var size: Variant = room.get("size")
			if not origin is Array or origin.size() != 2 or not _is_integer_number(origin[0]) or not _is_integer_number(origin[1]) or not size is Array or size.size() != 2 or not _is_integer_number(size[0]) or not _is_integer_number(size[1]) or int(size[0]) < 1 or int(size[1]) < 1 or int(origin[0]) < 0 or int(origin[1]) < 0 or int(origin[0]) + int(size[0]) > 12 or int(origin[1]) + int(size[1]) > 8:
				validation_errors.append("keep %s room %s must fit the 12x8 grid" % [keep_id, room_id])
			else:
				var rect: Rect2i = Rect2i(Vector2i(int(origin[0]), int(origin[1])), Vector2i(int(size[0]), int(size[1])))
				for other_id in room_rects.keys():
					if String(rooms[other_id].get("floor", "")) == String(room.get("floor", "")) and rect.intersects(room_rects[other_id]):
						validation_errors.append("keep %s rooms %s and %s overlap" % [keep_id, String(other_id), room_id])
				room_rects[room_id] = rect
	var connections: Variant = keep.get("connections")
	var connection_keys: Array[String] = []
	if not connections is Array or connections.is_empty():
		validation_errors.append("keep %s connections must be a non-empty array" % keep_id)
	else:
		for connection in connections:
			if not connection is Array or connection.size() != 2 or not rooms is Dictionary or not rooms.has(String(connection[0])) or not rooms.has(String(connection[1])) or String(connection[0]) == String(connection[1]):
				validation_errors.append("keep %s has an invalid room connection" % keep_id)
				continue
			var pair: Array[String] = [String(connection[0]), String(connection[1])]
			pair.sort()
			var key: String = "%s|%s" % pair
			if connection_keys.has(key):
				validation_errors.append("keep %s has duplicate room connection: %s" % [keep_id, key])
			else:
				connection_keys.append(key)
	var spatial_rule: Variant = keep.get("spatial_rule")
	if not spatial_rule is Dictionary or not ["compact_adjacency", "clear_causeway", "paired_bastions"].has(String(spatial_rule.get("id", ""))) or not spatial_rule.get("lane_cells") is Array or not _is_integer_number(spatial_rule.get("room_damage_reduction")) or int(spatial_rule.get("room_damage_reduction", -1)) < 0 or int(spatial_rule.get("room_damage_reduction", -1)) > 3 or not spatial_rule.get("label") is String or String(spatial_rule.get("label", "")).strip_edges().is_empty():
		validation_errors.append("keep %s has an invalid spatial_rule" % keep_id)
	elif String(spatial_rule.get("id", "")) == "clear_causeway":
		if spatial_rule.get("lane_cells", []).is_empty() or int(spatial_rule.get("room_damage_reduction", 0)) < 1:
			validation_errors.append("keep %s clear_causeway needs lane cells and positive room damage reduction" % keep_id)
		for cell in spatial_rule.get("lane_cells", []):
			if not cell is Array or cell.size() != 2 or not _is_integer_number(cell[0]) or not _is_integer_number(cell[1]) or int(cell[0]) < 0 or int(cell[0]) >= 12 or int(cell[1]) < 0 or int(cell[1]) >= 8:
				validation_errors.append("keep %s clear_causeway contains an invalid cell" % keep_id)
	elif String(spatial_rule.get("id", "")) == "paired_bastions":
		var anchors: Variant = spatial_rule.get("anchor_rooms")
		if not anchors is Array or anchors.size() != 2 or String(anchors[0]) == String(anchors[1]) or not rooms.has(String(anchors[0])) or not rooms.has(String(anchors[1])) or int(spatial_rule.get("room_damage_reduction", 0)) < 1:
			validation_errors.append("keep %s paired_bastions needs two distinct known anchor rooms and positive room damage reduction" % keep_id)
	var recovery: Variant = keep.get("recovery_profile")
	if not recovery is Dictionary or not _is_integer_number(recovery.get("room_repair_materials")) or int(recovery.get("room_repair_materials", 0)) < 1 or not _is_integer_number(recovery.get("room_repair_condition")) or int(recovery.get("room_repair_condition", 0)) < 1 or int(recovery.get("room_repair_condition", 0)) > 100 or not recovery.get("question") is String or String(recovery.get("question", "")).strip_edges().is_empty():
		validation_errors.append("keep %s has an invalid recovery_profile" % keep_id)
	var visual: Variant = keep.get("visual")
	if not visual is Dictionary or not ["fort", "river", "ridge"].has(String(visual.get("terrain", ""))):
		validation_errors.append("keep %s has an invalid visual profile" % keep_id)
	else:
		for field in ["ground_label", "upper_label", "board_label"]:
			if not visual.get(field) is String or String(visual.get(field, "")).strip_edges().is_empty():
				validation_errors.append("keep %s visual %s must be non-empty text" % [keep_id, field])
	return validation_errors

func validate_region_definition(region: Dictionary, expected_id: String, known_room_ids: Array) -> Array[String]:
	var validation_errors: Array[String] = []
	for field in REQUIRED_REGION_FIELDS:
		if not region.has(field):
			validation_errors.append("%s is missing required field: %s" % [expected_id, field])
	var region_id: String = String(region.get("id", ""))
	if region_id != expected_id:
		validation_errors.append("region id %s does not match filename %s" % [region_id, expected_id])
	if not _is_snake_case_id(region_id):
		validation_errors.append("region id %s must be snake_case" % region_id)
	if String(region.get("status", "")) != "active":
		validation_errors.append("region %s must have active status" % region_id)
	_validate_integer_minimum(region, "content_version", region_id, "region", 1, validation_errors)
	for field in ["name", "need"]:
		if not region.get(field) is String or String(region.get(field, "")).strip_edges().is_empty():
			validation_errors.append("region %s must have non-empty text for %s" % [region_id, field])
	var route: Variant = region.get("route")
	if not route is Dictionary or not _is_snake_case_id(String(route.get("id", ""))) or not route.get("name") is String or String(route.get("name", "")).strip_edges().is_empty() or not route.get("anchor_rooms") is Array or route.get("anchor_rooms", []).size() != 2:
		validation_errors.append("region %s has an invalid route" % region_id)
	else:
		var seen_anchors: Array[String] = []
		for room_id_value in route.get("anchor_rooms", []):
			var room_id: String = String(room_id_value)
			if not room_id_value is String or not known_room_ids.has(room_id) or seen_anchors.has(room_id):
				validation_errors.append("region %s route has an invalid anchor room" % region_id)
			else:
				seen_anchors.append(room_id)
	var consequences: Variant = region.get("consequences")
	var consequence_ids: Array[String] = []
	var previous_threshold: int = 101
	if not consequences is Array or consequences.is_empty() or consequences.size() > 3:
		validation_errors.append("region %s consequences must contain one to three entries" % region_id)
	else:
		for consequence in consequences:
			if not consequence is Dictionary:
				validation_errors.append("region %s consequence must be an object" % region_id)
				continue
			for field in REQUIRED_REGION_CONSEQUENCE_FIELDS:
				if not consequence.has(field):
					validation_errors.append("region %s consequence is missing required field: %s" % [region_id, field])
			var consequence_id: String = String(consequence.get("id", ""))
			if not _is_snake_case_id(consequence_id) or consequence_ids.has(consequence_id):
				validation_errors.append("region %s has an invalid or duplicate consequence id" % region_id)
			else:
				consequence_ids.append(consequence_id)
			for field in ["settlement_status", "route_status", "summary"]:
				if not consequence.get(field) is String or String(consequence.get(field, "")).strip_edges().is_empty():
					validation_errors.append("region %s consequence %s needs non-empty %s" % [region_id, consequence_id, field])
			var threshold: Variant = consequence.get("minimum_anchor_condition")
			if not _is_integer_number(threshold) or int(threshold) < 0 or int(threshold) > 100:
				validation_errors.append("region %s consequence %s has an invalid anchor threshold" % [region_id, consequence_id])
			elif int(threshold) >= previous_threshold:
				validation_errors.append("region %s consequences must use descending anchor thresholds" % region_id)
			else:
				previous_threshold = int(threshold)
			if not consequence.get("requires_non_collapse") is bool:
				validation_errors.append("region %s consequence %s requires_non_collapse must be boolean" % [region_id, consequence_id])
			var next_materials: Variant = consequence.get("next_run_materials")
			if not _is_integer_number(next_materials) or int(next_materials) < 0 or int(next_materials) > 5:
				validation_errors.append("region %s consequence %s next_run_materials must be from 0 to 5" % [region_id, consequence_id])
		var fallback: Variant = consequences[consequences.size() - 1]
		if fallback is Dictionary and (int(fallback.get("minimum_anchor_condition", -1)) != 0 or bool(fallback.get("requires_non_collapse", true))):
			validation_errors.append("region %s final consequence must be an unconditional zero-threshold fallback" % region_id)
	return validation_errors

func validate_scenario_definition(scenario: Dictionary, expected_id: String, known_room_ids: Array, known_keep_ids: Array = [], known_pack_ids: Array = []) -> Array[String]:
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
	if not known_keep_ids.is_empty() and not known_keep_ids.has(String(scenario.get("keep_id", ""))):
		validation_errors.append("scenario %s references an unknown keep" % scenario_id)
	var recommended_packs: Variant = scenario.get("recommended_packs")
	if not recommended_packs is Array or recommended_packs.is_empty() or recommended_packs.size() > 2:
		validation_errors.append("scenario %s recommended_packs must contain one or two pack IDs" % scenario_id)
	else:
		var seen_recommended: Array[String] = []
		for pack_id_value in recommended_packs:
			var pack_id: String = String(pack_id_value)
			if not pack_id_value is String or (not known_pack_ids.is_empty() and not known_pack_ids.has(pack_id)):
				validation_errors.append("scenario %s references unknown recommended pack: %s" % [scenario_id, pack_id])
			elif seen_recommended.has(pack_id):
				validation_errors.append("scenario %s recommended_packs contains duplicates" % scenario_id)
			else:
				seen_recommended.append(pack_id)
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
	if scenario.has("difficulty") and (not scenario.difficulty is String or not ["guided", "standard", "advanced", "overwhelming"].has(String(scenario.difficulty))):
		validation_errors.append("scenario %s difficulty must be guided, standard, advanced, or overwhelming" % scenario_id)
	if scenario.has("collapse_on_defender_wipe") and not scenario.collapse_on_defender_wipe is bool:
		validation_errors.append("scenario %s collapse_on_defender_wipe must be boolean" % scenario_id)
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

func validate_event_definition(event: Dictionary, expected_id: String, known_room_ids: Array = []) -> Array[String]:
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
		var trigger_wave: Variant = trigger.get("wave")
		if trigger_wave is Array:
			var seen_waves: Array[int] = []
			if trigger_wave.is_empty():
				validation_errors.append("event %s trigger wave array must not be empty" % event_id)
			for wave_value in trigger_wave:
				if not _is_integer_number(wave_value) or int(wave_value) < 0 or int(wave_value) > 3:
					validation_errors.append("event %s trigger waves must be integers from 0 to 3" % event_id)
				elif seen_waves.has(int(wave_value)):
					validation_errors.append("event %s trigger wave array contains a duplicate" % event_id)
				else:
					seen_waves.append(int(wave_value))
		elif not _is_integer_number(trigger_wave) or int(trigger_wave) < 0 or int(trigger_wave) > 3:
			validation_errors.append("event %s trigger wave must be an integer or array from 0 to 3" % event_id)
	_validate_event_selection(event_id, event.get("selection"), validation_errors)
	var eligibility: Variant = event.get("eligibility", {})
	if not eligibility is Dictionary:
		validation_errors.append("event %s eligibility must be an object" % event_id)
	else:
		for eligibility_id in eligibility.keys():
			if String(eligibility_id) == "room_condition":
				var condition: Variant = eligibility[eligibility_id]
				if not condition is Dictionary or not condition.get("room") is String or (not known_room_ids.is_empty() and not known_room_ids.has(String(condition.get("room", "")))) or not _is_integer_number(condition.get("lte")) or int(condition.get("lte", -1)) < 0 or int(condition.get("lte", -1)) > 100:
					validation_errors.append("event %s room_condition eligibility needs a known room and lte from 0 to 100" % event_id)
			elif String(eligibility_id) == "next_doctrine":
				var doctrines: Variant = eligibility[eligibility_id]
				if not doctrines is Array or doctrines.is_empty():
					validation_errors.append("event %s next_doctrine eligibility must be a non-empty array" % event_id)
				else:
					for doctrine_id in doctrines:
						if not doctrine_id is String or not doctrine_ids().has(String(doctrine_id)):
							validation_errors.append("event %s next_doctrine eligibility references an unknown doctrine" % event_id)
			elif String(eligibility_id) == "any_flag":
				var flag_ids: Variant = eligibility[eligibility_id]
				if not flag_ids is Array or flag_ids.is_empty():
					validation_errors.append("event %s any_flag eligibility must be a non-empty array" % event_id)
				else:
					for flag_id in flag_ids:
						if not flag_id is String or not _is_snake_case_id(String(flag_id)):
							validation_errors.append("event %s any_flag eligibility contains an invalid flag" % event_id)
			elif String(eligibility_id) == "seed_slot":
				var slot: Variant = eligibility[eligibility_id]
				if not slot is Dictionary or not _is_integer_number(slot.get("mod")) or int(slot.get("mod", 0)) < 2 or int(slot.get("mod", 0)) > 32 or not slot.get("slots") is Array or slot.get("slots", []).is_empty():
					validation_errors.append("event %s seed_slot eligibility needs mod 2 to 32 and non-empty slots" % event_id)
				else:
					for slot_value in slot.get("slots", []):
						if not _is_integer_number(slot_value) or int(slot_value) < 0 or int(slot_value) >= int(slot.get("mod", 0)):
							validation_errors.append("event %s seed_slot eligibility contains an out-of-range slot" % event_id)
			else:
				validation_errors.append("event %s has unsupported eligibility: %s" % [event_id, String(eligibility_id)])
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
			for required_field in REQUIRED_EVENT_CHOICE_FIELDS:
				if not choice.has(required_field):
					validation_errors.append("event %s choice %s is missing required field: %s" % [event_id, choice_id, required_field])
			for field in ["label", "visible_result"]:
				if not choice.get(field) is String or String(choice.get(field, "")).strip_edges().is_empty():
					validation_errors.append("event %s choice %s must have non-empty %s" % [event_id, choice_id, field])
			_validate_event_requirements(event_id, choice_id, choice.get("requirements", {}), validation_errors)
			_validate_event_effects(event_id, choice_id, choice.get("effects", []), known_room_ids, validation_errors)
			_validate_event_choice_flags(event_id, choice_id, choice.get("flags", {}), validation_errors)
	var commander_variants: Variant = event.get("commander_variants", {})
	if not commander_variants is Dictionary:
		validation_errors.append("event %s commander_variants must be an object" % event_id)
	else:
		for commander_id_value in commander_variants.keys():
			var commander_id: String = String(commander_id_value)
			var variant: Variant = commander_variants[commander_id_value]
			if not commander_ids().has(commander_id) or not variant is Dictionary or not variant.get("setup") is String or String(variant.get("setup", "")).strip_edges().is_empty() or not variant.get("choice_labels", {}) is Dictionary:
				validation_errors.append("event %s commander variant %s is malformed" % [event_id, commander_id])
				continue
			for variant_choice_id in variant.get("choice_labels", {}).keys():
				if not choice_ids.has(String(variant_choice_id)) or not variant.choice_labels[variant_choice_id] is String or String(variant.choice_labels[variant_choice_id]).strip_edges().is_empty():
					validation_errors.append("event %s commander variant %s references an invalid choice label" % [event_id, commander_id])
	var follow_up: Variant = event.get("follow_up", "")
	if not follow_up is String or (not String(follow_up).is_empty() and not _is_snake_case_id(String(follow_up))):
		validation_errors.append("event %s follow_up must be empty or snake_case" % event_id)
	if String(follow_up) == event_id:
		validation_errors.append("event %s cannot follow itself" % event_id)
	return validation_errors

func _validate_event_selection(event_id: String, selection: Variant, validation_errors: Array[String]) -> void:
	if not selection is Dictionary:
		validation_errors.append("event %s selection must be an object" % event_id)
		return
	for field in REQUIRED_EVENT_SELECTION_FIELDS:
		if not selection.has(field):
			validation_errors.append("event %s selection is missing required field: %s" % [event_id, field])
	for field_value in selection.keys():
		var field: String = String(field_value)
		if not REQUIRED_EVENT_SELECTION_FIELDS.has(field):
			validation_errors.append("event %s selection has unsupported field: %s" % [event_id, field])
	var stream: String = String(selection.get("stream", ""))
	if not selection.get("stream") is String or not _is_snake_case_id(stream):
		validation_errors.append("event %s selection stream must be snake_case" % event_id)
	var repeat_policy: String = String(selection.get("repeat_policy", ""))
	if not SUPPORTED_EVENT_REPEAT_POLICIES.has(repeat_policy):
		validation_errors.append("event %s selection repeat_policy is unsupported" % event_id)
	var cooldown_waves: Variant = selection.get("cooldown_waves")
	if not _is_integer_number(cooldown_waves) or int(cooldown_waves) < 0 or int(cooldown_waves) > MAX_EVENT_COOLDOWN_WAVES:
		validation_errors.append("event %s selection cooldown_waves must be an integer from 0 to %d" % [event_id, MAX_EVENT_COOLDOWN_WAVES])
	var max_occurrences: Variant = selection.get("max_occurrences")
	if not _is_integer_number(max_occurrences) or int(max_occurrences) < 1 or int(max_occurrences) > MAX_EVENT_OCCURRENCES:
		validation_errors.append("event %s selection max_occurrences must be an integer from 1 to %d" % [event_id, MAX_EVENT_OCCURRENCES])
	if repeat_policy == "once_per_run" and (cooldown_waves != 0 or max_occurrences != 1):
		validation_errors.append("event %s selection once_per_run requires cooldown_waves 0 and max_occurrences 1" % event_id)
	if repeat_policy == "repeat_after_cooldown" and (not _is_integer_number(cooldown_waves) or int(cooldown_waves) < 1):
		validation_errors.append("event %s selection repeat_after_cooldown requires at least one cooldown wave" % event_id)
	if repeat_policy == "repeat_after_cooldown" and (not _is_integer_number(max_occurrences) or int(max_occurrences) < 2):
		validation_errors.append("event %s selection repeat_after_cooldown requires max_occurrences of at least 2" % event_id)

func _validate_event_requirements(event_id: String, choice_id: String, requirements: Variant, validation_errors: Array[String]) -> void:
	if not requirements is Dictionary:
		validation_errors.append("event %s choice %s requirements must be an object" % [event_id, choice_id])
		return
	for requirement_id in requirements.keys():
		if not SUPPORTED_EVENT_REQUIREMENTS.has(String(requirement_id)):
			validation_errors.append("event %s choice %s has unsupported requirement: %s" % [event_id, choice_id, String(requirement_id)])
			continue
		if String(requirement_id) == "piece_available":
			if not requirements[requirement_id] is String or not piece_ids().has(String(requirements[requirement_id])):
				validation_errors.append("event %s choice %s piece_available must reference a known piece" % [event_id, choice_id])
			continue
		var constraint: Variant = requirements[requirement_id]
		if not constraint is Dictionary or constraint.size() != 1:
			validation_errors.append("event %s choice %s requirement %s must contain one constraint" % [event_id, choice_id, String(requirement_id)])
			continue
		var operator_id: String = String(constraint.keys()[0])
		if not SUPPORTED_EVENT_REQUIREMENT_OPERATORS.has(operator_id) or not _is_integer_number(constraint[operator_id]):
			validation_errors.append("event %s choice %s requirement %s has invalid constraint" % [event_id, choice_id, String(requirement_id)])
		elif int(constraint[operator_id]) < 0:
			validation_errors.append("event %s choice %s requirement %s must use a non-negative integer" % [event_id, choice_id, String(requirement_id)])

func _validate_event_choice_flags(event_id: String, choice_id: String, flags: Variant, validation_errors: Array[String]) -> void:
	if not flags is Dictionary:
		validation_errors.append("event %s choice %s flags must be an object" % [event_id, choice_id])
		return
	for flag_id in flags.keys():
		if not _is_snake_case_id(String(flag_id)) or not flags[flag_id] is bool:
			validation_errors.append("event %s choice %s flag %s must be a stable boolean" % [event_id, choice_id, String(flag_id)])

func _validate_event_effects(event_id: String, choice_id: String, effects: Variant, known_room_ids: Array, validation_errors: Array[String]) -> void:
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
		var expected_fields: Array = EVENT_EFFECT_FIELDS.get(operation, [])
		for required_field in expected_fields:
			if not effect.has(required_field):
				validation_errors.append("event %s choice %s effect %s is missing required field: %s" % [event_id, choice_id, operation, String(required_field)])
		for field_value in effect.keys():
			var field: String = String(field_value)
			if field != "op" and not expected_fields.has(field):
				validation_errors.append("event %s choice %s effect %s has unsupported field: %s" % [event_id, choice_id, operation, field])
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
		elif operation == "repair_room":
			if not effect.get("room") is String or not known_room_ids.has(String(effect.get("room", ""))):
				validation_errors.append("event %s choice %s repair_room references unknown room" % [event_id, choice_id])
		elif operation == "assign_piece":
			if not effect.get("piece") is String or not piece_ids().has(String(effect.get("piece", ""))):
				validation_errors.append("event %s choice %s assign_piece references unknown piece" % [event_id, choice_id])
			if not effect.get("room") is String or not known_room_ids.has(String(effect.get("room", ""))):
				validation_errors.append("event %s choice %s assign_piece references unknown room" % [event_id, choice_id])
	if effects is Array and effects.size() > 1:
		for effect in effects:
			if effect is Dictionary and ["repair_room", "assign_piece"].has(String(effect.get("op", ""))):
				validation_errors.append("event %s choice %s authoritative recovery effects must be the only effect" % [event_id, choice_id])
				break

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
	var effect: String = String(modifier.get("effect", ""))
	if effect == "enemy_health_bonus":
		_validate_integer_minimum(modifier, "enemy_health_bonus", modifier_id, "modifier", 1, validation_errors)
		if _is_integer_number(modifier.get("enemy_health_bonus")) and int(modifier.get("enemy_health_bonus", 0)) > 8:
			validation_errors.append("modifier %s enemy_health_bonus must be at most 8" % modifier_id)
	elif modifier.has("enemy_health_bonus"):
		validation_errors.append("modifier %s cannot define enemy_health_bonus for effect %s" % [modifier_id, effect])
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
	if commander.has("passive_profile"):
		var passive_profile: Variant = commander.get("passive_profile")
		if not passive_profile is Dictionary or String(passive_profile.get("kind", "")) != "reserve_economy":
			validation_errors.append("commander %s has an unsupported passive profile" % commander_id)
		else:
			for field in ["first_pack_discount", "supply_cache_recovery_bonus"]:
				if not _is_integer_number(passive_profile.get(field)) or int(passive_profile.get(field, 0)) < 0:
					validation_errors.append("commander %s passive profile needs a non-negative integer %s" % [commander_id, field])
	if commander.has("ability_profile"):
		var ability_profile: Variant = commander.get("ability_profile")
		if not ability_profile is Dictionary or String(ability_profile.get("kind", "")) != String(commander.get("ability", "")):
			validation_errors.append("commander %s ability profile must match its ability" % commander_id)
		else:
			for field in ["health_restore", "ammo_restore"]:
				if not _is_integer_number(ability_profile.get(field)) or int(ability_profile.get(field, 0)) < 0:
					validation_errors.append("commander %s ability profile needs a non-negative integer %s" % [commander_id, field])
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

func _load_keep(path: String) -> void:
	if not FileAccess.file_exists(path):
		errors.append("missing keep file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("could not open keep file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("keep file must contain one JSON object: %s" % path)
		return
	var authored: Dictionary = parsed
	var keep_id: String = String(authored.get("id", ""))
	var validation_errors: Array[String] = validate_keep_definition(authored, path.get_file().get_basename())
	if _keeps.has(keep_id):
		validation_errors.append("duplicate keep id: %s" % keep_id)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if validation_errors.is_empty():
		_keeps[keep_id] = _normalize_keep(authored)

func _load_region(path: String, known_room_ids: Array) -> void:
	if not FileAccess.file_exists(path):
		errors.append("missing region file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("could not open region file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("region file must contain one JSON object: %s" % path)
		return
	var region: Dictionary = parsed
	var region_id: String = String(region.get("id", ""))
	var validation_errors: Array[String] = validate_region_definition(region, path.get_file().get_basename(), known_room_ids)
	if _regions.has(region_id):
		validation_errors.append("duplicate region id: %s" % region_id)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if validation_errors.is_empty():
		_regions[region_id] = region.duplicate(true)

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
	var scenario_room_ids: Array[String] = _room_ids_for_keep(String(scenario.get("keep_id", "")))
	if scenario_room_ids.is_empty():
		scenario_room_ids.assign(known_room_ids)
	var validation_errors: Array[String] = validate_scenario_definition(scenario, path.get_file().get_basename(), scenario_room_ids, keep_ids(), pack_ids())
	if _scenarios.has(scenario_id):
		validation_errors.append("duplicate scenario id: %s" % scenario_id)
	for validation_error in validation_errors:
		errors.append("%s: %s" % [path, validation_error])
	if validation_errors.is_empty():
		_scenarios[scenario_id] = scenario.duplicate(true)

func _load_event(path: String, known_room_ids: Array) -> void:
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
	var event_scenario_id: String = String(event.get("scenario", ""))
	var event_keep_id: String = String(_scenarios.get(event_scenario_id, {}).get("keep_id", ""))
	var event_room_ids: Array[String] = _room_ids_for_keep(event_keep_id)
	if event_room_ids.is_empty():
		event_room_ids.assign(known_room_ids)
	var validation_errors: Array[String] = validate_event_definition(event, path.get_file().get_basename(), event_room_ids)
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
		elif not follow_up.is_empty() and String(_events[follow_up].get("scenario", "")) != String(_events[event_id].get("scenario", "")):
			errors.append("event %s follow_up crosses scenarios: %s" % [event_id, follow_up])
		var visited: Array[String] = []
		var current_id: String = event_id
		while not current_id.is_empty() and _events.has(current_id):
			if visited.has(current_id):
				errors.append("event follow_up cycle includes: %s" % current_id)
				break
			visited.append(current_id)
			current_id = String(_events[current_id].get("follow_up", ""))

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

func _normalize_keep(authored: Dictionary) -> Dictionary:
	var runtime: Dictionary = authored.duplicate(true)
	var normalized_rooms: Dictionary = {}
	for room_id_value in authored.get("rooms", {}).keys():
		var room: Dictionary = authored.rooms[room_id_value].duplicate(true)
		var origin: Array = room.get("origin", [0, 0])
		var size: Array = room.get("size", [1, 1])
		room.origin = Vector2i(int(origin[0]), int(origin[1]))
		room.size = Vector2i(int(size[0]), int(size[1]))
		normalized_rooms[String(room_id_value)] = room
	runtime.rooms = normalized_rooms
	var spatial_rule: Dictionary = authored.get("spatial_rule", {}).duplicate(true)
	var lane_cells: Array[Vector2i] = []
	for cell in spatial_rule.get("lane_cells", []):
		lane_cells.append(Vector2i(int(cell[0]), int(cell[1])))
	spatial_rule.lane_cells = lane_cells
	runtime.spatial_rule = spatial_rule
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

func _known_support_modifiers() -> Array[String]:
	var result: Array[String] = []
	for piece in _pieces.values():
		var support_profile: Variant = piece.get("support_profile")
		if support_profile is Dictionary:
			var modifier: String = String(support_profile.get("response_modifier", ""))
			if not modifier.is_empty() and not result.has(modifier):
				result.append(modifier)
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
