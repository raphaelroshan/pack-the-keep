extends RefCounted

## Presentation-independent simulation for the Pack the Keep first battle slice.
## The same seed, keep layout, doctrine, and commands produce the same report.

const ContentCatalog = preload("res://src/core/content_catalog.gd")

const GRID_SIZE := Vector2i(12, 8)
const FLOORS := ["ground", "upper"]
const ACTIVE_COMMANDER := "castellan"
const STARTER_PIECES := ["pike_squad", "narrow_gate"]
const SAVE_SCHEMA_VERSION := 4
const GAME_ID := "pack-the-keep"

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

var seed: int = 3307
var commander_id: String = ACTIVE_COMMANDER
var materials: int = 60
var command_points: int = 3
var morale: int = 6
var keep_id: String = "greywatch_keep"
var scenario_id: String = "gatehouse_lock"
var scenario_active: bool = false
var scenario_variation_id: String = "standard_bell"
var variation_target_room: String = ""
var variation_materials: int = 0
var variation_morale: int = 0
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
var available_pieces: Array[String] = ["pike_squad", "narrow_gate"]
var pack_openings_this_preparation: int = 0
var reserved_pack_id: String = ""
var enemies: Array[Dictionary] = []
var rooms: Dictionary = {}
var log: Array[String] = []
var battle_report: Array[String] = []
var lockdown_pending: bool = false
var lockdown_used: bool = false
var rally_pending: bool = false
var rally_used: bool = false
var last_outcome: String = ""
var repair_interval_active: bool = false
var repair_actions_remaining: int = 0
var repair_interval_reason: String = ""
var assigned_rooms: Dictionary = {}
var combat_metrics: Dictionary = {}
var wave_history: Array[Dictionary] = []
var active_event_id: String = ""
var resolved_event_ids: Array[String] = []
var event_flags: Dictionary = {}
var event_history: Array[Dictionary] = []
var unlocked_modifier_ids: Array[String] = []
var equipped_modifier_id: String = ""
var regional_state: Dictionary = {}
var content_catalog: RefCounted
var _keep_definitions: Dictionary = {}
var _room_definitions: Dictionary = ROOMS.duplicate(true)
var _region_definitions: Dictionary = {}
var _commander_definitions: Dictionary = {}
var _piece_definitions: Dictionary = {}
var _pack_definitions: Dictionary = {}
var _enemy_definitions: Dictionary = {}
var _doctrine_definitions: Dictionary = {}
var _scenario_definitions: Dictionary = {}
var _event_definitions: Dictionary = {}
var _modifier_definitions: Dictionary = {}
var content_catalog_errors: Array[String] = []

func _init(keep_seed: int = 3307) -> void:
	content_catalog = ContentCatalog.new()
	var catalog_result: Dictionary = content_catalog.load_default(ROOMS.keys())
	_keep_definitions = catalog_result.get("keeps", {}).duplicate(true)
	_region_definitions = catalog_result.get("regions", {}).duplicate(true)
	_commander_definitions = catalog_result.get("commanders", {}).duplicate(true)
	_piece_definitions = catalog_result.get("pieces", {}).duplicate(true)
	_pack_definitions = catalog_result.get("packs", {}).duplicate(true)
	_enemy_definitions = catalog_result.get("enemies", {}).duplicate(true)
	_doctrine_definitions = catalog_result.get("doctrines", {}).duplicate(true)
	_scenario_definitions = catalog_result.get("scenarios", {}).duplicate(true)
	_event_definitions = catalog_result.get("events", {}).duplicate(true)
	_modifier_definitions = catalog_result.get("modifiers", {}).duplicate(true)
	for error in catalog_result.get("errors", []):
		content_catalog_errors.append(String(error))
	if not content_catalog_errors.is_empty():
		push_error("Runtime content catalog failed validation: %s" % "; ".join(content_catalog_errors))
	reset_run(keep_seed)

func _activate_keep(selected_keep_id: String) -> void:
	keep_id = selected_keep_id if _keep_definitions.has(selected_keep_id) else "greywatch_keep"
	_room_definitions = _keep_definitions.get(keep_id, {"rooms": ROOMS}).get("rooms", ROOMS).duplicate(true)

func _room_definitions_for_scenario(selected_scenario_id: String) -> Dictionary:
	var selected_keep_id: String = String(_scenario_definitions.get(selected_scenario_id, {}).get("keep_id", "greywatch_keep"))
	return _keep_definitions.get(selected_keep_id, {"rooms": ROOMS}).get("rooms", ROOMS)

func _reset_rooms() -> void:
	rooms.clear()
	for room_id in _room_definitions.keys():
		rooms[room_id] = {"condition": 100, "state": "stable"}

func _default_regional_state() -> Dictionary:
	return {
		"settlement_id": "low_mill",
		"settlement_name": String(_region_definitions.get("low_mill", {}).get("name", "Low Mill")),
		"settlement_status": "unproven",
		"route_id": String(_region_definitions.get("low_mill", {}).get("route", {}).get("id", "mill_road")),
		"route_name": String(_region_definitions.get("low_mill", {}).get("route", {}).get("name", "Miller's Road")),
		"route_status": "unknown",
		"consequence_id": "",
		"summary": "Low Mill is waiting to see whether the defended road can carry people and supplies.",
		"next_run_materials": 0,
		"pending_support": false,
		"applied_to_scenario_id": "",
		"source_scenario_id": "",
		"source_keep_id": "",
		"source_replay_key": ""
	}

func reset_run(new_seed: int = 3307) -> void:
	var preserved_unlocks: Array[String] = unlocked_modifier_ids.duplicate()
	var preserved_equipped: String = equipped_modifier_id
	var preserved_regional_state: Dictionary = regional_state.duplicate(true) if not regional_state.is_empty() else _default_regional_state()
	seed = new_seed
	commander_id = ACTIVE_COMMANDER
	materials = int(_commander_definitions[ACTIVE_COMMANDER].starting_materials)
	command_points = 3
	unlocked_modifier_ids = preserved_unlocks
	equipped_modifier_id = preserved_equipped if preserved_unlocks.has(preserved_equipped) and _modifier_definitions.has(preserved_equipped) else ""
	regional_state = preserved_regional_state
	morale = _starting_morale()
	scenario_id = "gatehouse_lock"
	_activate_keep(String(_scenario_definitions.get(scenario_id, {}).get("keep_id", "greywatch_keep")))
	scenario_active = false
	scenario_variation_id = "standard_bell"
	variation_target_room = ""
	variation_materials = 0
	variation_morale = 0
	wave_index = 0
	wave_active = false
	wave_progress = 0.0
	battle_step = 0
	battle_clock = 0.0
	breach_level = 0
	enemy_doctrine = "gate_assault"
	pieces.clear()
	owned_packs.clear()
	available_pieces.clear()
	for piece_id in STARTER_PIECES:
		available_pieces.append(String(piece_id))
	reserved_pack_id = ""
	enemies.clear()
	_reset_rooms()
	log.clear()
	battle_report.clear()
	lockdown_pending = false
	lockdown_used = false
	rally_pending = false
	rally_used = false
	last_outcome = ""
	repair_interval_active = false
	repair_actions_remaining = 0
	repair_interval_reason = ""
	assigned_rooms.clear()
	_reset_combat_metrics()
	wave_history.clear()
	active_event_id = ""
	resolved_event_ids.clear()
	event_flags.clear()
	event_history.clear()
	_log("%s is quiet. The Castellan waits for a first doctrine." % String(_keep_definitions.get(keep_id, {}).get("name", "The keep")))

func _reset_combat_metrics() -> void:
	combat_metrics = {
		"battle_steps": 0,
		"unit_attacks": 0,
		"damage_dealt": 0,
		"enemy_attacks": 0,
		"room_damage": 0,
		"piece_damage": 0,
		"repairs": 0,
		"disabled_units": 0,
		"defeated_enemies": 0,
		"ammo_spent": 0
	}

func _starting_morale() -> int:
	var base: int = int(_commander_definitions[commander_id].starting_morale)
	if not equipped_modifier_id.is_empty() and _modifier_definitions.has(equipped_modifier_id):
		base -= int(_modifier_definitions[equipped_modifier_id].get("starting_morale_cost", 0))
	return clampi(base, 0, 10)

func _active_enemy_health_bonus() -> int:
	if equipped_modifier_id.is_empty() or not _modifier_definitions.has(equipped_modifier_id):
		return 0
	var modifier: Dictionary = _modifier_definitions[equipped_modifier_id]
	if String(modifier.get("effect", "")) != "enemy_health_bonus":
		return 0
	return int(modifier.get("enemy_health_bonus", 0))

func _preparation_pack_limit() -> int:
	return 2 if wave_index == 0 else 1

func _rebuild_available_pieces() -> void:
	available_pieces.clear()
	for piece_id in STARTER_PIECES:
		available_pieces.append(String(piece_id))
	for pack_id in owned_packs:
		if not _pack_definitions.has(pack_id):
			continue
		for piece_id in _pack_definitions[pack_id].contents:
			if not available_pieces.has(String(piece_id)):
				available_pieces.append(String(piece_id))

func _log(message: String) -> void:
	log.append(message)

func _battle_log(message: String) -> void:
	battle_report.append(message)
	_log(message)

func select_commander(id: String) -> Dictionary:
	if not _commander_definitions.has(id):
		return {"ok": false, "reason": "unknown commander"}
	if wave_active or repair_interval_active:
		return {"ok": false, "reason": "commander cannot change during an invasion or repair interval"}
	if not event_history.is_empty():
		return {"ok": false, "reason": "commander cannot change after scenario events begin"}
	commander_id = id
	var applied_regional_materials: int = int(regional_state.get("next_run_materials", 0)) if scenario_active and String(regional_state.get("applied_to_scenario_id", "")) == scenario_id else 0
	materials = int(_commander_definitions[id].starting_materials) + (variation_materials if scenario_active else 0) + applied_regional_materials
	morale = clampi(_starting_morale() + (variation_morale if scenario_active else 0), 0, 10)
	command_points = 3
	return {"ok": true, "message": "%s takes command. %s Limitation: %s" % [_commander_definitions[id].name, _commander_definitions[id].passive, _commander_definitions[id].limitation], "ability_name": _commander_definitions[id].ability_name, "ability_text": _commander_definitions[id].ability_text}

func _variation_for_scenario(id: String) -> Dictionary:
	var options: Array = _scenario_definitions.get(id, {}).get("variations", [])
	if options.is_empty():
		return {"id": "standard_bell", "materials": 0, "morale": 0, "target_room": ""}
	var stable_id_value: int = 0
	for byte_value in id.to_utf8_buffer():
		stable_id_value += int(byte_value)
	var index: int = absi(seed + stable_id_value) % options.size()
	return options[index].duplicate(true)

func select_scenario(id: String) -> Dictionary:
	if not _scenario_definitions.has(id):
		return {"ok": false, "reason": "unknown defensive scenario"}
	if wave_active or repair_interval_active:
		return {"ok": false, "reason": "scenario cannot change during an invasion or repair interval"}
	if not pieces.is_empty() or wave_index > 0:
		return {"ok": false, "reason": "start a new run before changing scenarios"}
	active_event_id = ""
	resolved_event_ids.clear()
	event_flags.clear()
	event_history.clear()
	scenario_id = id
	_activate_keep(String(_scenario_definitions[id].get("keep_id", "greywatch_keep")))
	_reset_rooms()
	scenario_active = true
	enemy_doctrine = String(_scenario_definitions[id].get("starting_doctrine", "gate_assault"))
	var variation: Dictionary = _variation_for_scenario(id)
	scenario_variation_id = String(variation.get("id", "standard_bell"))
	variation_target_room = String(variation.get("target_room", ""))
	variation_materials = int(variation.get("materials", 0))
	variation_morale = int(variation.get("morale", 0))
	var regional_materials: int = 0
	if bool(regional_state.get("pending_support", false)):
		regional_materials = int(regional_state.get("next_run_materials", 0))
		regional_state.pending_support = false
		regional_state.applied_to_scenario_id = id
	materials = int(_commander_definitions[commander_id].starting_materials) + variation_materials + regional_materials
	morale = clampi(_starting_morale() + variation_morale, 0, 10)
	_log("Scenario selected: %s / variation %s. %s" % [_scenario_definitions[id].name, scenario_variation_id, _scenario_definitions[id].lesson])
	if regional_materials > 0:
		_log("%s support reached the keep by %s: +%d starting materials." % [String(regional_state.get("settlement_name", "Low Mill")), String(regional_state.get("route_name", "Miller's Road")), regional_materials])
	_refresh_active_event()
	return {"ok": true, "message": "%s selected: %s Variation: %s." % [_scenario_definitions[id].name, _scenario_definitions[id].objective, scenario_variation_id], "scenario": scenario_preview(id)}

func scenario_preview(id: String = "") -> Dictionary:
	var selected_id: String = scenario_id if id.is_empty() else id
	if not _scenario_definitions.has(selected_id):
		return {"ok": false, "reason": "unknown defensive scenario"}
	var scenario: Dictionary = _scenario_definitions[selected_id]
	var scenario_keep_id: String = String(scenario.get("keep_id", "greywatch_keep"))
	var peak_wave_size: int = 0
	var enemy_roster: Array[String] = []
	for wave_plan in scenario.get("wave_plans", []):
		if not wave_plan is Array:
			continue
		peak_wave_size = maxi(peak_wave_size, wave_plan.size())
		for enemy_id_value in wave_plan:
			var enemy_id: String = String(enemy_id_value)
			if _enemy_definitions.has(enemy_id):
				var enemy_name: String = String(_enemy_definitions[enemy_id].get("name", enemy_id))
				if not enemy_roster.has(enemy_name):
					enemy_roster.append(enemy_name)
	var doctrine_names: Array[String] = []
	for doctrine_id_value in scenario.get("doctrines", []):
		var doctrine_id: String = String(doctrine_id_value)
		if _doctrine_definitions.has(doctrine_id):
			doctrine_names.append(String(_doctrine_definitions[doctrine_id].get("name", doctrine_id)))
	var difficulty: String = String(scenario.get("difficulty", ""))
	if difficulty.is_empty():
		difficulty = "guided" if peak_wave_size <= 2 else "standard" if peak_wave_size <= 3 else "advanced"
	var ordered_ids: Array[String] = scenario_ids()
	var variation: Dictionary = scenario_variation_preview(selected_id)
	return {
		"ok": true,
		"scenario_id": selected_id,
		"catalog_index": ordered_ids.find(selected_id) + 1,
		"catalog_count": ordered_ids.size(),
		"name": String(scenario.name),
		"objective": String(scenario.objective),
		"lesson": String(scenario.lesson),
		"keep_id": scenario_keep_id,
		"keep_name": String(_keep_definitions.get(scenario_keep_id, {}).get("name", scenario_keep_id)),
		"recommended_packs": scenario.get("recommended_packs", []).duplicate(),
		"starting_doctrine": String(scenario.starting_doctrine),
		"doctrine_names": doctrine_names,
		"wave_count": scenario.wave_plans.size(),
		"peak_wave_size": peak_wave_size,
		"enemy_roster": enemy_roster,
		"difficulty": difficulty,
		"collapse_on_defender_wipe": bool(scenario.get("collapse_on_defender_wipe", false)),
		"variation_id": String(variation.get("id", "standard_bell")),
		"variation": variation,
	}

func scenario_variation_preview(id: String = "") -> Dictionary:
	var selected_id: String = scenario_id if id.is_empty() else id
	if not _scenario_definitions.has(selected_id):
		return {"ok": false, "reason": "unknown defensive scenario"}
	var variation: Dictionary = _variation_for_scenario(selected_id)
	if selected_id == scenario_id and scenario_active:
		variation = {
			"id": scenario_variation_id,
			"materials": variation_materials,
			"morale": variation_morale,
			"target_room": variation_target_room,
		}
	var variation_id: String = String(variation.get("id", "standard_bell"))
	var material_delta: int = int(variation.get("materials", 0))
	var morale_delta: int = int(variation.get("morale", 0))
	var target_room: String = String(variation.get("target_room", ""))
	var effects: Array[String] = []
	if material_delta != 0:
		effects.append("%+d starting materials" % material_delta)
	if morale_delta != 0:
		effects.append("%+d starting morale" % morale_delta)
	var target_applies: bool = false
	if not target_room.is_empty():
		for wave_plan in _scenario_definitions[selected_id].get("wave_plans", []):
			for enemy_id_value in wave_plan:
				var enemy: Dictionary = _enemy_definitions.get(String(enemy_id_value), {})
				if String(enemy.get("target_mode", "")) == "room_destroyer" and enemy.get("target_rooms", []).has(target_room):
					target_applies = true
					break
			if target_applies:
				break
	if target_applies:
		effects.append("room pressure favors %s" % String(_room_definitions_for_scenario(selected_id).get(target_room, {}).get("name", target_room.replace("_", " ").capitalize())))
	if effects.is_empty():
		effects.append("baseline stores and morale; target priorities remain adaptive")
	return {
		"ok": true,
		"id": variation_id,
		"label": variation_id.replace("_", " ").capitalize(),
		"materials": material_delta,
		"morale": morale_delta,
		"target_room": target_room,
		"target_applies": target_applies,
		"effects": effects,
		"summary": "%s — %s." % [variation_id.replace("_", " ").capitalize(), "; ".join(effects)],
	}

func current_event() -> Dictionary:
	if active_event_id.is_empty() or not _event_definitions.has(active_event_id):
		return {"ok": false, "reason": "no_active_event", "message": "No authored event is active."}
	var definition: Dictionary = _event_definitions[active_event_id]
	var commander_variant: Dictionary = definition.get("commander_variants", {}).get(commander_id, {})
	var choice_previews: Array[Dictionary] = []
	for choice in definition.get("choices", []):
		var choice_id: String = String(choice.get("id", ""))
		var preview: Dictionary = event_choice_preview(choice_id)
		choice_previews.append({
			"id": choice_id,
			"label": String(commander_variant.get("choice_labels", {}).get(choice_id, choice.get("label", choice_id))),
			"visible_result": String(choice.get("visible_result", "")),
			"available": bool(preview.get("ok", false)),
			"reason": String(preview.get("reason", ""))
		})
	return {"ok": true, "id": active_event_id, "title": String(definition.get("title", active_event_id)), "type": String(definition.get("type", "")), "setup": String(commander_variant.get("setup", definition.get("setup", ""))), "phase": _current_event_phase(), "choices": choice_previews}

func event_choice_preview(choice_id: String) -> Dictionary:
	if active_event_id.is_empty() or not _event_definitions.has(active_event_id):
		return {"ok": false, "reason": "no_active_event", "message": "No authored event is active.", "state_changes": []}
	var choice: Dictionary = _event_choice(_event_definitions[active_event_id], choice_id)
	if choice.is_empty():
		return {"ok": false, "reason": "unknown_event_choice", "message": "That event choice is unavailable.", "state_changes": []}
	var requirement_reason: String = _event_requirement_failure(choice.get("requirements", {}))
	if not requirement_reason.is_empty():
		return {"ok": false, "reason": requirement_reason, "message": "The event requirements are no longer satisfied.", "state_changes": []}
	var effect_reason: String = _event_effect_failure(choice.get("effects", []))
	if not effect_reason.is_empty():
		return {"ok": false, "reason": effect_reason, "message": "The event effect cannot be applied safely.", "state_changes": []}
	return {"ok": true, "reason": "", "message": String(choice.get("visible_result", "")), "state_changes": []}

func choose_event_option(choice_id: String) -> Dictionary:
	var preview: Dictionary = event_choice_preview(choice_id)
	if not bool(preview.get("ok", false)):
		return preview
	var event_id: String = active_event_id
	var definition: Dictionary = _event_definitions[event_id]
	var choice: Dictionary = _event_choice(definition, choice_id)
	var state_changes: Array[Dictionary] = []
	for effect in choice.get("effects", []):
		state_changes.append(_apply_event_effect(effect))
	var choice_flag_ids: Array = choice.get("flags", {}).keys()
	choice_flag_ids.sort()
	for flag_id_value in choice_flag_ids:
		var flag_id: String = String(flag_id_value)
		event_flags[flag_id] = bool(choice.flags[flag_id_value])
		state_changes.append({"op": "set_flag", "flag": flag_id, "value": event_flags[flag_id]})
	var history_entry: Dictionary = {
		"event_id": event_id,
		"choice_id": choice_id,
		"wave": wave_index,
		"phase": _current_event_phase(),
		"visible_result": String(choice.get("visible_result", "")),
		"state_changes": state_changes.duplicate(true)
	}
	event_history.append(history_entry)
	if not resolved_event_ids.has(event_id):
		resolved_event_ids.append(event_id)
	active_event_id = ""
	_log("Event resolved — %s: %s" % [String(definition.get("title", event_id)), String(choice.get("visible_result", ""))])
	_refresh_active_event()
	return {"ok": true, "reason": "", "message": String(choice.get("visible_result", "")), "event_id": event_id, "choice_id": choice_id, "state_changes": state_changes}

func _event_choice(definition: Dictionary, choice_id: String) -> Dictionary:
	for choice in definition.get("choices", []):
		if String(choice.get("id", "")) == choice_id:
			return choice
	return {}

func _event_requirement_failure(requirements: Variant) -> String:
	if not requirements is Dictionary:
		return "malformed_event_requirements"
	var requirement_ids: Array = requirements.keys()
	requirement_ids.sort()
	for requirement_id in requirement_ids:
		if String(requirement_id) == "piece_available":
			var piece_id: String = String(requirements[requirement_id])
			if _event_piece_instance(piece_id).is_empty():
				return "event_requirement_piece_available"
			continue
		var current: int = command_points if String(requirement_id) == "command_points" else repair_actions_remaining if String(requirement_id) == "recovery_actions" else morale if String(requirement_id) == "morale" else materials if String(requirement_id) == "materials" else -1
		if current < 0:
			return "unsupported_event_requirement"
		var constraint: Dictionary = requirements[requirement_id]
		if constraint.has("gte") and current < int(constraint.gte):
			return "event_requirement_%s" % String(requirement_id)
		if constraint.has("lt") and current >= int(constraint.lt):
			return "event_requirement_%s" % String(requirement_id)
	return ""

func _event_effect_failure(effects: Variant) -> String:
	if not effects is Array:
		return "malformed_event_effects"
	var remaining_command: int = command_points
	var remaining_actions: int = repair_actions_remaining
	for effect in effects:
		var operation: String = String(effect.get("op", ""))
		var amount: int = int(effect.get("amount", 0))
		if operation == "spend_command_points":
			remaining_command -= amount
			if remaining_command < 0:
				return "event_requirement_command_points"
		elif operation == "spend_recovery_action":
			if not repair_interval_active:
				return "event_requires_recovery"
			remaining_actions -= amount
			if remaining_actions < 0:
				return "event_requirement_recovery_actions"
		elif operation == "repair_room":
			var repair_preview: Dictionary = recovery_action_preview("repair_room", "", String(effect.get("room", "")), true)
			if not bool(repair_preview.get("ok", false)):
				return String(repair_preview.get("reason", "event_effect_repair_room"))
		elif operation == "assign_piece":
			var instance_id: String = _event_piece_instance(String(effect.get("piece", "")), String(effect.get("room", "")))
			if instance_id.is_empty():
				return "event_effect_assign_piece"
		elif not ["add_materials", "add_morale", "set_flag", "record_outcome", "unlock_modifier"].has(operation):
			return "unsupported_event_effect"
		elif operation == "unlock_modifier" and not _modifier_definitions.has(String(effect.get("modifier", ""))):
			return "unknown_modifier"
	return ""

func _apply_event_effect(effect: Dictionary) -> Dictionary:
	var operation: String = String(effect.get("op", ""))
	var amount: int = int(effect.get("amount", 0))
	if operation == "spend_command_points":
		command_points -= amount
		return {"op": operation, "amount": amount, "remaining": command_points}
	if operation == "spend_recovery_action":
		repair_actions_remaining -= amount
		return {"op": operation, "amount": amount, "remaining": repair_actions_remaining}
	if operation == "add_materials":
		materials += amount
		return {"op": operation, "amount": amount, "total": materials}
	if operation == "add_morale":
		var before: int = morale
		morale = mini(10, morale + amount)
		return {"op": operation, "amount": morale - before, "total": morale}
	if operation == "set_flag":
		var flag_id: String = String(effect.get("flag", ""))
		event_flags[flag_id] = bool(effect.get("value", false))
		return {"op": operation, "flag": flag_id, "value": event_flags[flag_id]}
	if operation == "record_outcome":
		return {"op": operation, "tag": String(effect.get("tag", "")), "outcome": last_outcome, "materials": materials, "morale": morale, "breach_level": breach_level, "surviving_pieces": _surviving_piece_count()}
	if operation == "unlock_modifier":
		var result: Dictionary = unlock_modifier(String(effect.get("modifier", "")), active_event_id)
		return result.get("state_changes", [])[0] if not result.get("state_changes", []).is_empty() else {"op": operation, "modifier": String(effect.get("modifier", "")), "already_unlocked": true}
	if operation == "repair_room":
		var repair_result: Dictionary = _commit_room_repair(String(effect.get("room", "")))
		return repair_result.get("state_changes", [])[0] if not repair_result.get("state_changes", []).is_empty() else {"op": operation, "room": String(effect.get("room", ""))}
	if operation == "assign_piece":
		var instance_id: String = _event_piece_instance(String(effect.get("piece", "")), String(effect.get("room", "")))
		var assignment_result: Dictionary = _commit_piece_assignment(instance_id, String(effect.get("room", "")))
		return assignment_result.get("state_changes", [])[0] if not assignment_result.get("state_changes", []).is_empty() else {"op": operation, "piece": instance_id, "room": String(effect.get("room", ""))}
	return {"op": operation}

func _event_piece_instance(piece_id: String, room_id: String = "") -> String:
	var instance_ids: Array[String] = []
	for instance_id_value in pieces.keys():
		instance_ids.append(String(instance_id_value))
	instance_ids.sort()
	for instance_id in instance_ids:
		var instance: Dictionary = pieces[instance_id]
		if String(instance.get("piece_id", "")) != piece_id or bool(instance.get("disabled", false)):
			continue
		if room_id.is_empty() or bool(recovery_action_preview("assign_piece", instance_id, room_id, true).get("ok", false)):
			return instance_id
	return ""

func _current_event_phase() -> String:
	if not wave_active and last_outcome == "collapse":
		return "results"
	if repair_interval_active and not has_next_wave() and not last_outcome.is_empty():
		return "results"
	if repair_interval_active:
		return "recovery"
	if not wave_active and wave_index == 0:
		return "preparation"
	return "battle"

func _event_trigger_matches(definition: Dictionary) -> bool:
	var trigger: Dictionary = definition.get("trigger", {})
	var selection: Dictionary = definition.get("selection", {})
	return String(definition.get("scenario", "")) == scenario_id and String(trigger.get("phase", "")) == _current_event_phase() and _event_trigger_wave_matches(trigger.get("wave")) and _event_repeat_policy_allows(definition) and _event_eligibility_matches(definition.get("eligibility", {}), String(selection.get("stream", definition.get("id", ""))))

func _event_trigger_wave_matches(trigger_wave: Variant) -> bool:
	if trigger_wave is Array:
		for wave_value in trigger_wave:
			if int(wave_value) == wave_index:
				return true
		return false
	return int(trigger_wave) == wave_index

func _event_eligibility_matches(eligibility: Variant, event_id: String = "") -> bool:
	if not eligibility is Dictionary:
		return false
	for eligibility_id in eligibility.keys():
		if String(eligibility_id) == "room_condition":
			var condition: Dictionary = eligibility[eligibility_id]
			if room_condition(String(condition.get("room", ""))) > int(condition.get("lte", 100)):
				return false
		elif String(eligibility_id) == "next_doctrine":
			var doctrines: Array = eligibility[eligibility_id]
			var next_doctrine: String = ""
			if has_next_wave() and _scenario_definitions.has(scenario_id):
				var authored_doctrines: Array = _scenario_definitions[scenario_id].get("doctrines", [])
				if wave_index < authored_doctrines.size():
					next_doctrine = String(authored_doctrines[wave_index])
			if not doctrines.has(next_doctrine):
				return false
		elif String(eligibility_id) == "any_flag":
			var flag_ids: Array = eligibility[eligibility_id]
			var matched: bool = false
			for flag_id in flag_ids:
				if bool(event_flags.get(String(flag_id), false)):
					matched = true
					break
			if not matched:
				return false
		elif String(eligibility_id) == "seed_slot":
			var slot: Dictionary = eligibility[eligibility_id]
			var stream_value: int = seed
			for byte_value in ("%s|%s|%d" % [scenario_id, event_id, wave_index]).to_utf8_buffer():
				stream_value = posmod(stream_value * 31 + int(byte_value), 2147483647)
			var selected_slot: int = posmod(stream_value, int(slot.get("mod", 2)))
			var matched_slot: bool = false
			for slot_value in slot.get("slots", []):
				if int(slot_value) == selected_slot:
					matched_slot = true
					break
			if not matched_slot:
				return false
		else:
			return false
	return true

func _event_repeat_policy_allows(definition: Dictionary) -> bool:
	var event_id: String = String(definition.get("id", ""))
	var selection: Dictionary = definition.get("selection", {})
	var repeat_policy: String = String(selection.get("repeat_policy", "once_per_run"))
	var occurrence_count: int = 0
	var last_wave: int = -1
	var last_phase: String = ""
	for history_entry in event_history:
		if String(history_entry.get("event_id", "")) == event_id:
			occurrence_count += 1
			last_wave = int(history_entry.get("wave", -1))
			last_phase = String(history_entry.get("phase", ""))
	if occurrence_count >= int(selection.get("max_occurrences", 1)):
		return false
	if repeat_policy == "once_per_run":
		return not resolved_event_ids.has(event_id)
	if repeat_policy != "repeat_after_cooldown":
		return false
	if last_wave == wave_index and last_phase == _current_event_phase():
		return false
	return last_wave < 0 or wave_index - last_wave > int(selection.get("cooldown_waves", 0))

func _refresh_active_event() -> void:
	if not active_event_id.is_empty() or not scenario_active or not _scenario_definitions.has(scenario_id):
		return
	for event_id_value in _scenario_definitions[scenario_id].get("event_chain", []):
		var event_id: String = String(event_id_value)
		if not _event_definitions.has(event_id) or not _event_trigger_matches(_event_definitions[event_id]):
			continue
		active_event_id = event_id
		_log("Event opened — %s." % String(_event_definitions[event_id].get("title", event_id)))
		break

func _surviving_piece_count() -> int:
	var count: int = 0
	for piece in pieces.values():
		if not bool(piece.get("disabled", false)) and int(piece.get("health", 0)) > 0:
			count += 1
	return count

func _defender_wipe_is_terminal() -> bool:
	return not pieces.is_empty() and _surviving_piece_count() == 0 and scenario_active and bool(_scenario_definitions.get(scenario_id, {}).get("collapse_on_defender_wipe", false))

func authored_wave_count() -> int:
	if scenario_active and _scenario_definitions.has(scenario_id):
		return _scenario_definitions[scenario_id].get("wave_plans", []).size()
	return 0

func has_next_wave() -> bool:
	if not scenario_active or last_outcome == "collapse":
		return false
	return authored_wave_count() > wave_index

func pack_ids() -> Array[String]:
	return content_catalog.pack_ids()

func commander_ids() -> Array[String]:
	return content_catalog.commander_ids()

func commander_definition(id: String) -> Dictionary:
	if not _commander_definitions.has(id):
		return {}
	return _commander_definitions[id].duplicate(true)

func piece_ids() -> Array[String]:
	return content_catalog.piece_ids()

func piece_definition(id: String) -> Dictionary:
	if not _piece_definitions.has(id):
		return {}
	return _piece_definitions[id].duplicate(true)

func enemy_ids() -> Array[String]:
	return content_catalog.enemy_ids()

func enemy_definition(id: String) -> Dictionary:
	if not _enemy_definitions.has(id):
		return {}
	return _enemy_definitions[id].duplicate(true)

func doctrine_ids() -> Array[String]:
	return content_catalog.doctrine_ids()

func doctrine_definition(id: String) -> Dictionary:
	if not _doctrine_definitions.has(id):
		return {}
	return _doctrine_definitions[id].duplicate(true)

func scenario_ids() -> Array[String]:
	return content_catalog.scenario_ids()

func scenario_definition(id: String) -> Dictionary:
	if not _scenario_definitions.has(id):
		return {}
	return _scenario_definitions[id].duplicate(true)

func keep_ids() -> Array[String]:
	return content_catalog.keep_ids()

func keep_definition(id: String = "") -> Dictionary:
	var selected_id: String = keep_id if id.is_empty() else id
	if not _keep_definitions.has(selected_id):
		return {}
	return _keep_definitions[selected_id].duplicate(true)

func region_ids() -> Array[String]:
	return content_catalog.region_ids()

func region_definition(id: String) -> Dictionary:
	if not _region_definitions.has(id):
		return {}
	return _region_definitions[id].duplicate(true)

func regional_consequence() -> Dictionary:
	return regional_state.duplicate(true)

func current_regional_consequence() -> Dictionary:
	var terminal_run: bool = scenario_active and (last_outcome == "collapse" or (wave_index >= authored_wave_count() and not wave_active and not repair_interval_active))
	if not terminal_run or String(regional_state.get("source_scenario_id", "")) != scenario_id or String(regional_state.get("source_keep_id", "")) != keep_id:
		return {}
	return regional_consequence()

func room_definitions() -> Dictionary:
	return _room_definitions.duplicate(true)

func room_definition(id: String) -> Dictionary:
	return _room_definitions.get(id, {}).duplicate(true)

func event_ids() -> Array[String]:
	return content_catalog.event_ids()

func event_definition(id: String) -> Dictionary:
	if not _event_definitions.has(id):
		return {}
	return _event_definitions[id].duplicate(true)

func event_ledger_snapshot(limit: int = 5) -> Dictionary:
	var bounded_limit: int = clampi(limit, 0, 20)
	var entries: Array[Dictionary] = []
	var entry_count: int = mini(bounded_limit, event_history.size())
	for offset in range(entry_count):
		var source: Dictionary = event_history[event_history.size() - 1 - offset]
		var event_id: String = String(source.get("event_id", ""))
		var definition: Dictionary = _event_definitions.get(event_id, {})
		entries.append({
			"event_id": event_id,
			"title": String(definition.get("title", event_id.replace("_", " ").capitalize())),
			"choice_id": String(source.get("choice_id", "")),
			"wave": int(source.get("wave", 0)),
			"phase": String(source.get("phase", "")),
			"visible_result": String(source.get("visible_result", ""))
		})
	var flag_ids: Array[String] = []
	for flag_id_value in event_flags.keys():
		flag_ids.append(String(flag_id_value))
	flag_ids.sort()
	var flags: Array[Dictionary] = []
	for flag_id in flag_ids:
		flags.append({"id": flag_id, "value": bool(event_flags.get(flag_id, false))})
	return {
		"total": event_history.size(),
		"limit": bounded_limit,
		"truncated": event_history.size() > entry_count,
		"entries": entries,
		"flags": flags
	}

func modifier_ids() -> Array[String]:
	return content_catalog.modifier_ids()

func modifier_definition(id: String) -> Dictionary:
	if not _modifier_definitions.has(id):
		return {}
	return _modifier_definitions[id].duplicate(true)

func unlock_modifier(modifier_id: String, source_event_id: String = "") -> Dictionary:
	if not _modifier_definitions.has(modifier_id):
		return {"ok": false, "reason": "unknown_modifier", "message": "That run modifier does not exist.", "state_changes": []}
	var required_event: String = String(_modifier_definitions[modifier_id].get("unlock_event", ""))
	if source_event_id != required_event or (active_event_id != source_event_id and not resolved_event_ids.has(source_event_id)):
		return {"ok": false, "reason": "modifier_unlock_requirement", "message": "Complete the required scenario event before unlocking this modifier.", "state_changes": []}
	if unlocked_modifier_ids.has(modifier_id):
		return {"ok": true, "reason": "", "message": "%s is already unlocked." % String(_modifier_definitions[modifier_id].name), "state_changes": []}
	unlocked_modifier_ids.append(modifier_id)
	return {"ok": true, "reason": "", "message": "%s unlocked for future runs." % String(_modifier_definitions[modifier_id].name), "state_changes": [{"op": "unlock_modifier", "modifier": modifier_id}]}

func modifier_equip_preview(modifier_id: String) -> Dictionary:
	if not modifier_id.is_empty() and not _modifier_definitions.has(modifier_id):
		return {"ok": false, "reason": "unknown_modifier", "message": "That run modifier does not exist.", "state_changes": []}
	if not modifier_id.is_empty() and not unlocked_modifier_ids.has(modifier_id):
		return {"ok": false, "reason": "modifier_locked", "message": "Complete its unlock objective first.", "state_changes": []}
	var terminal_run: bool = scenario_active and authored_wave_count() > 0 and wave_index >= authored_wave_count() and not wave_active and not has_next_wave() and active_event_id.is_empty() and not last_outcome.is_empty()
	var fresh_run: bool = wave_index == 0 and not wave_active and not repair_interval_active and pieces.is_empty() and event_history.is_empty()
	if not terminal_run and not fresh_run:
		return {"ok": false, "reason": "modifier_change_requires_between_runs", "message": "Change run modifiers before setup or after a completed scenario.", "state_changes": []}
	if equipped_modifier_id == modifier_id:
		return {"ok": false, "reason": "modifier_already_equipped", "message": "That run modifier is already equipped.", "state_changes": []}
	return {"ok": true, "reason": "", "message": "Modifier selection is available.", "state_changes": []}

func equip_modifier(modifier_id: String) -> Dictionary:
	var preview: Dictionary = modifier_equip_preview(modifier_id)
	if not bool(preview.get("ok", false)):
		return preview
	var fresh_run: bool = wave_index == 0 and not wave_active and not repair_interval_active and pieces.is_empty() and event_history.is_empty()
	equipped_modifier_id = modifier_id
	if fresh_run:
		morale = clampi(_starting_morale() + (variation_morale if scenario_active else 0), 0, 10)
	var modifier_name: String = "No modifier" if modifier_id.is_empty() else String(_modifier_definitions[modifier_id].name)
	return {"ok": true, "reason": "", "message": "%s will apply to the next run." % modifier_name, "state_changes": [{"op": "equip_modifier", "modifier": modifier_id, "starting_morale": morale}]}

func pack_definition(pack_id: String) -> Dictionary:
	if not _pack_definitions.has(pack_id):
		return {}
	return _pack_definitions[pack_id].duplicate(true)

func content_catalog_status() -> Dictionary:
	return {"ok": content_catalog_errors.is_empty(), "keep_count": _keep_definitions.size(), "region_count": _region_definitions.size(), "commander_count": _commander_definitions.size(), "piece_count": _piece_definitions.size(), "pack_count": _pack_definitions.size(), "enemy_count": _enemy_definitions.size(), "doctrine_count": _doctrine_definitions.size(), "scenario_count": _scenario_definitions.size(), "event_count": _event_definitions.size(), "modifier_count": _modifier_definitions.size(), "errors": content_catalog_errors.duplicate()}

func pack_preview(pack_id: String) -> Dictionary:
	if not _pack_definitions.has(pack_id):
		return {"ok": false, "reason": "unknown pack"}
	var pack: Dictionary = _pack_definitions[pack_id]
	var piece_previews: Array[Dictionary] = []
	for piece_id in pack.contents:
		var piece: Dictionary = _piece_definitions[String(piece_id)]
		piece_previews.append({"id": String(piece_id), "name": String(piece.name), "cost": int(piece.cost), "size": piece.size, "role": String(piece.role), "availability": String(piece.availability)})
	return {"ok": true, "pack_id": pack_id, "name": String(pack.name), "doctrine": String(pack.doctrine), "cost": int(pack.cost), "pieces": piece_previews, "solves": String(pack.get("strength", "")), "asks": String(pack.get("weakness", "")), "preview": String(pack.get("choice", "")), "question": String(pack.get("question", "")), "owned": owned_packs.has(pack_id), "reserved": reserved_pack_id == pack_id, "openings_remaining": _preparation_pack_limit() - pack_openings_this_preparation, "materials": materials}

func reserve_pack(pack_id: String) -> Dictionary:
	if not _pack_definitions.has(pack_id):
		return {"ok": false, "reason": "unknown pack"}
	if wave_active or repair_interval_active:
		return {"ok": false, "reason": "packs can only be reserved during Preparation"}
	if owned_packs.has(pack_id):
		return {"ok": false, "reason": "an owned pack cannot occupy the reserve slot"}
	if reserved_pack_id == pack_id:
		reserved_pack_id = ""
		return {"ok": true, "message": "Reserve cleared."}
	reserved_pack_id = pack_id
	return {"ok": true, "message": "Reserved %s for the next Preparation." % _pack_definitions[pack_id].name, "reserved_pack_id": reserved_pack_id}

func open_pack(pack_id: String) -> Dictionary:
	if not _pack_definitions.has(pack_id):
		return {"ok": false, "reason": "unknown pack"}
	if wave_active or repair_interval_active:
		return {"ok": false, "reason": "packs can only be opened during Preparation"}
	if owned_packs.has(pack_id):
		return {"ok": false, "reason": "pack already opened"}
	if pack_openings_this_preparation >= _preparation_pack_limit():
		return {"ok": false, "reason": "this Preparation has no pack openings remaining"}
	var pack_cost: int = int(_pack_definitions[pack_id].get("cost", 0))
	if materials < pack_cost:
		return {"ok": false, "reason": "not enough materials to open this pack"}
	materials -= pack_cost
	owned_packs.append(pack_id)
	pack_openings_this_preparation += 1
	if reserved_pack_id == pack_id:
		reserved_pack_id = ""
	for piece_id in _pack_definitions[pack_id].contents:
		if not available_pieces.has(piece_id):
			available_pieces.append(piece_id)
	return {"ok": true, "message": "Opened %s for %d materials: %s. Available units updated." % [_pack_definitions[pack_id].name, pack_cost, _pack_definitions[pack_id].doctrine.replace("_", " ")], "available_pieces": available_pieces.duplicate(), "openings_remaining": _preparation_pack_limit() - pack_openings_this_preparation, "materials": materials}

func piece_fits(piece_id: String, origin: Vector2i, floor: String = "ground") -> bool:
	if not _piece_definitions.has(piece_id) or not FLOORS.has(floor):
		return false
	var size: Vector2i = _piece_definitions[piece_id].size
	if origin.x < 0 or origin.y < 0 or origin.x + size.x > GRID_SIZE.x or origin.y + size.y > GRID_SIZE.y:
		return false
	for existing in pieces.values():
		if String(existing.get("floor", "ground")) != floor:
			continue
		var existing_origin: Vector2i = existing.get("origin", Vector2i.ZERO)
		var existing_size: Vector2i = _piece_definitions[String(existing.get("piece_id", ""))].size
		if Rect2i(origin, size).intersects(Rect2i(existing_origin, existing_size)):
			return false
	return true

func placement_zone(origin: Vector2i, floor: String = "ground", size: Vector2i = Vector2i.ONE) -> String:
	if floor == "upper":
		return "wall"
	if origin.x <= 1 or origin.y <= 1 or origin.x + size.x >= GRID_SIZE.x - 1 or origin.y + size.y >= GRID_SIZE.y - 1:
		return "wall"
	if origin.x >= 3 and origin.y >= 2 and origin.x + size.x <= 9 and origin.y + size.y <= 6:
		return "courtyard"
	return "keep"

func piece_preview(piece_id: String, origin: Vector2i, floor: String = "ground") -> Dictionary:
	if not _piece_definitions.has(piece_id):
		return {"ok": false, "valid": false, "reason": "unknown defensive piece"}
	var piece: Dictionary = _piece_definitions[piece_id]
	var reason: String = ""
	if wave_active or repair_interval_active:
		reason = "placement is only available during Preparation"
	elif not FLOORS.has(floor):
		reason = "unknown keep floor"
	elif not piece.get("allowed_floors", FLOORS).has(floor):
		reason = "%s cannot be placed on the %s floor" % [piece.name, floor]
	elif not available_pieces.has(piece_id):
		reason = "%s is not available; open its pack during Preparation" % piece.name
	elif not piece_fits(piece_id, origin, floor):
		reason = "piece does not fit on this floor of the keep"
	elif not piece.get("allowed_zones", ["wall", "courtyard", "keep"]).has(placement_zone(origin, floor, piece.size)):
		reason = "%s cannot be placed in the %s zone" % [piece.name, placement_zone(origin, floor, piece.size)]
	elif materials < int(piece.cost):
		reason = "not enough materials"
	return {"ok": reason.is_empty(), "valid": reason.is_empty(), "reason": reason, "piece_id": piece_id, "name": String(piece.name), "origin": origin, "floor": floor, "placement_zone": placement_zone(origin, floor, piece.size), "size": piece.size, "cost": int(piece.cost), "role": String(piece.role), "remaining_materials": materials - int(piece.cost)}

func place_piece(piece_id: String, origin: Vector2i, floor: String = "ground") -> Dictionary:
	var preview: Dictionary = piece_preview(piece_id, origin, floor)
	if not bool(preview.get("valid", false)):
		return {"ok": false, "reason": String(preview.get("reason", "invalid placement"))}
	var cost: int = int(_piece_definitions[piece_id].cost)
	materials -= cost
	var instance_id: String = "%s_%d" % [piece_id, pieces.size()]
	var max_health: int = int(_piece_definitions[piece_id].get("max_health", 10))
	var max_ammo: int = int(_piece_definitions[piece_id].get("max_ammo", 0))
	pieces[instance_id] = {"piece_id": piece_id, "origin": origin, "floor": floor, "max_health": max_health, "health": max_health, "condition": 1.0, "assignment": "", "attack_cooldown": 0, "attacks": 0, "damage_dealt": 0, "targets_stopped": 0, "disabled": false, "last_target": "", "max_ammo": max_ammo, "ammo": max_ammo, "supply_spent": false}
	var zone: String = placement_zone(origin, floor, _piece_definitions[piece_id].size)
	pieces[instance_id].placement_zone = zone
	return {"ok": true, "piece_instance": instance_id, "placement_zone": zone, "message": "Placed %s in the %s zone on the %s floor: %s." % [_piece_definitions[piece_id].name, zone, floor, _piece_definitions[piece_id].role]}

func _set_piece_health(instance_id: String, value: int) -> void:
	if not pieces.has(instance_id):
		return
	var instance: Dictionary = pieces[instance_id]
	var max_health: int = int(instance.get("max_health", _piece_definitions[String(instance.get("piece_id", ""))].get("max_health", 10)))
	var was_disabled: bool = bool(instance.get("disabled", false))
	instance.health = clampi(value, 0, max_health)
	instance.condition = float(instance.health) / float(max_health)
	instance.disabled = int(instance.health) <= 0
	if instance.disabled and not was_disabled:
		combat_metrics["disabled_units"] = int(combat_metrics.get("disabled_units", 0)) + 1

func room_at_cell(floor: String, cell: Vector2i) -> String:
	for room_id in _room_definitions.keys():
		var room: Dictionary = _room_definitions[room_id]
		if String(room.get("floor", "ground")) == floor and Rect2i(room.origin, room.size).has_point(cell):
			return String(room_id)
	return ""

func piece_at_cell(floor: String, cell: Vector2i) -> String:
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		if String(instance.get("floor", "ground")) != floor:
			continue
		var piece_id: String = String(instance.get("piece_id", ""))
		if piece_id.is_empty() or not _piece_definitions.has(piece_id):
			continue
		if Rect2i(instance.get("origin", Vector2i.ZERO), _piece_definitions[piece_id].size).has_point(cell):
			return String(instance_id)
	return ""

func inspect_room(room_id: String) -> Dictionary:
	if not _room_definitions.has(room_id):
		return {"ok": false, "reason": "unknown keep room"}
	var room: Dictionary = _room_definitions[room_id]
	return {"ok": true, "kind": "room", "id": room_id, "name": String(room.name), "floor": String(room.floor), "role": String(room.role), "critical": bool(room.critical), "condition": room_condition(room_id), "state": room_state(room_id)}

func inspect_piece(instance_id: String) -> Dictionary:
	if not pieces.has(instance_id):
		return {"ok": false, "reason": "unknown defensive piece"}
	var instance: Dictionary = pieces[instance_id]
	var piece_id: String = String(instance.get("piece_id", ""))
	if not _piece_definitions.has(piece_id):
		return {"ok": false, "reason": "piece definition is unavailable"}
	var piece: Dictionary = _piece_definitions[piece_id]
	return {"ok": true, "kind": "piece", "id": instance_id, "piece_id": piece_id, "name": String(piece.name), "floor": String(instance.get("floor", "ground")), "origin": instance.get("origin", Vector2i.ZERO), "role": String(piece.role), "health": int(instance.get("health", 0)), "max_health": int(instance.get("max_health", piece.max_health)), "condition": float(instance.get("condition", 0.0)), "assignment": String(instance.get("assignment", "")), "placement_zone": String(instance.get("placement_zone", placement_zone(instance.get("origin", Vector2i.ZERO), String(instance.get("floor", "ground")), piece.get("size", Vector2i.ONE)))), "disabled": bool(instance.get("disabled", false)), "attack": int(piece.attack), "defense": int(piece.defense), "range": int(piece.range), "combat_style": String(piece.get("combat_style", "support")), "skill": String(piece.get("skill", "")), "ammo": int(instance.get("ammo", piece.get("max_ammo", 0))), "max_ammo": int(instance.get("max_ammo", piece.get("max_ammo", 0))), "supply_spent": bool(instance.get("supply_spent", false)), "fallback_active": piece_id == "rear_guard" and _fallback_is_active(), "availability": String(piece.availability)}

func fallback_active() -> bool:
	return _fallback_is_active()

func inspect_enemy(index: int) -> Dictionary:
	if index < 0 or index >= enemies.size():
		return {"ok": false, "reason": "unknown enemy"}
	var enemy: Dictionary = enemies[index]
	var enemy_id: String = String(enemy.get("enemy_id", ""))
	if not _enemy_definitions.has(enemy_id):
		return {"ok": false, "reason": "enemy definition is unavailable"}
	var definition: Dictionary = _enemy_definitions[enemy_id]
	return {"ok": true, "kind": "enemy", "id": enemy_id, "index": index, "name": String(definition.name), "doctrine": String(definition.doctrine), "route": String(definition.route), "counter": String(definition.counter), "target_mode": String(definition.get("target_mode", "room_destroyer")), "attack_style": String(definition.get("attack_style", "melee")), "health": int(enemy.get("hp", 0)), "max_health": int(enemy.get("max_health", definition.health)), "damage": int(definition.damage), "attack_interval": int(definition.get("attack_interval", 1)), "armor": int(definition.get("armor", 0)), "armor_counter_tag": String(definition.get("armor_counter_tag", "")), "arrival_step": int(enemy.get("arrival_step", definition.arrival_step)), "base_arrival_step": int(definition.arrival_step), "has_signal_disruption": definition.get("disruption_profile") is Dictionary, "signal_disrupted": bool(enemy.get("signal_disrupted", false)), "ignores_protection": bool(definition.get("ignores_protection", false)), "targets_assigned_first": bool(definition.get("targets_assigned_first", false)), "target_piece_categories": definition.get("target_piece_categories", []).duplicate(), "target": String(enemy.get("target", "")), "defeated": bool(enemy.get("defeated", false))}

func enemy_attack_timing(index: int) -> Dictionary:
	if index < 0 or index >= enemies.size():
		return {"ok": false, "reason": "unknown enemy"}
	var enemy: Dictionary = enemies[index]
	var enemy_id: String = String(enemy.get("enemy_id", ""))
	if not _enemy_definitions.has(enemy_id):
		return {"ok": false, "reason": "enemy definition is unavailable"}
	var definition: Dictionary = _enemy_definitions[enemy_id]
	var arrival_step: int = int(enemy.get("arrival_step", definition.get("arrival_step", 1)))
	var attack_interval: int = maxi(1, int(definition.get("attack_interval", 1)))
	var current_time: float = float(battle_step) + battle_clock
	var in_contact: bool = current_time >= float(arrival_step)
	var next_attack_step: int = arrival_step
	var cadence_progress: float = 0.0
	if in_contact:
		var completed_intervals: int = int(floor((current_time - float(arrival_step)) / float(attack_interval)))
		var last_attack_step: int = arrival_step + completed_intervals * attack_interval
		next_attack_step = last_attack_step + attack_interval
		cadence_progress = clampf((current_time - float(last_attack_step)) / float(attack_interval), 0.0, 1.0)
	return {
		"ok": true,
		"active": wave_active and not bool(enemy.get("defeated", false)),
		"in_contact": in_contact,
		"attack_interval": attack_interval,
		"next_attack_step": next_attack_step,
		"ticks_until_attack": maxf(0.0, float(next_attack_step) - current_time),
		"cadence_progress": cadence_progress,
		"within_wave": next_attack_step <= 6,
		"has_target": _target_is_active(String(enemy.get("target", "")))
	}

func enemy_target_readout(index: int) -> Dictionary:
	if index < 0 or index >= enemies.size():
		return {"ok": false, "reason": "unknown enemy"}
	var enemy: Dictionary = enemies[index]
	var target_id: String = String(enemy.get("target", ""))
	if target_id.is_empty():
		var timing: Dictionary = enemy_attack_timing(index)
		var summary: String = "No valid target" if bool(timing.get("in_contact", false)) else "Approaching"
		return {"ok": true, "kind": "none", "id": "", "name": summary, "summary": summary, "active": false}
	if pieces.has(target_id):
		var instance: Dictionary = pieces[target_id]
		var piece_id: String = String(instance.get("piece_id", ""))
		var piece: Dictionary = _piece_definitions.get(piece_id, {})
		var current_health: int = int(instance.get("health", 0))
		var maximum_health: int = int(instance.get("max_health", piece.get("max_health", 0)))
		var disabled: bool = bool(instance.get("disabled", false)) or current_health <= 0
		return {
			"ok": true, "kind": "piece", "id": target_id,
			"name": String(piece.get("name", piece_id.replace("_", " ").capitalize())),
			"summary": "%s · %d/%d HP%s" % [String(piece.get("name", piece_id.replace("_", " ").capitalize())), current_health, maximum_health, " · DISABLED" if disabled else ""],
			"health": current_health, "max_health": maximum_health,
			"floor": String(instance.get("floor", "ground")), "active": not disabled
		}
	if rooms.has(target_id):
		var room: Dictionary = _room_definitions.get(target_id, {})
		var condition: int = room_condition(target_id)
		var state: String = room_state(target_id)
		return {
			"ok": true, "kind": "room", "id": target_id,
			"name": String(room.get("name", target_id.replace("_", " ").capitalize())),
			"summary": "%s · %d%% · %s" % [String(room.get("name", target_id.replace("_", " ").capitalize())), condition, state.capitalize()],
			"condition": condition, "state": state, "critical": bool(room.get("critical", false)),
			"floor": String(room.get("floor", "ground")), "active": condition > 0
		}
	return {"ok": false, "reason": "enemy target is unavailable", "id": target_id}

func remove_piece(instance_id: String) -> Dictionary:
	if wave_active or repair_interval_active:
		return {"ok": false, "reason": "piece removal is only available during Preparation"}
	if not pieces.has(instance_id):
		return {"ok": false, "reason": "unknown defensive piece"}
	var assignment: String = String(pieces[instance_id].get("assignment", ""))
	if not assignment.is_empty():
		assigned_rooms.erase(assignment)
	pieces.erase(instance_id)
	return {"ok": true, "message": "Removed defensive piece; materials are not refunded during an active run."}

func recovery_profile() -> Dictionary:
	return _keep_definitions.get(keep_id, {}).get("recovery_profile", {"room_repair_materials": 8, "room_repair_condition": 30, "question": "Which damaged function is worth a deep repair?"}).duplicate(true)

func spatial_rule_state() -> Dictionary:
	var rule: Dictionary = _keep_definitions.get(keep_id, {}).get("spatial_rule", {}).duplicate(true)
	var active: bool = String(rule.get("id", "")) == "clear_causeway" and _is_causeway_clear(rule.get("lane_cells", []))
	rule.active = active
	return rule

func _is_causeway_clear(lane_cells: Array) -> bool:
	for instance in pieces.values():
		if String(instance.get("floor", "ground")) != "ground":
			continue
		var piece_id: String = String(instance.get("piece_id", ""))
		if not _piece_definitions.has(piece_id):
			continue
		var footprint: Rect2i = Rect2i(instance.get("origin", Vector2i.ZERO), _piece_definitions[piece_id].size)
		for lane_cell in lane_cells:
			if footprint.has_point(lane_cell):
				return false
	return true

func recovery_action_preview(action_id: String, instance_id: String = "", room_id: String = "", allow_active_event: bool = false) -> Dictionary:
	var preview: Dictionary = {
		"action_id": action_id,
		"ok": false,
		"reason": "unknown recovery action",
		"target_id": "",
		"target_name": "Select a target",
		"material_cost": 0,
		"action_cost": 1,
		"benefit": "",
		"tradeoff": "Consumes one of the two recovery actions."
	}
	if action_id == "repair_room":
		var keep_recovery: Dictionary = recovery_profile()
		var room_repair_cost: int = int(keep_recovery.get("room_repair_materials", 8))
		var room_repair_amount: int = int(keep_recovery.get("room_repair_condition", 30))
		preview.material_cost = room_repair_cost
		preview.target_id = room_id
		preview.target_name = String(_room_definitions.get(room_id, {}).get("name", "Select a room"))
		preview.benefit = "Restore up to %d condition to the selected keep function." % room_repair_amount
		preview.tradeoff = "Spend %d materials and one recovery action instead of changing an assignment." % room_repair_cost
	elif action_id == "repair_piece":
		preview.material_cost = 6
		preview.target_id = instance_id
		var repair_piece_id: String = String(pieces.get(instance_id, {}).get("piece_id", ""))
		preview.target_name = String(_piece_definitions.get(repair_piece_id, {}).get("name", "Select a placed piece"))
		preview.benefit = "Restore 30% of the selected defender's maximum health."
		preview.tradeoff = "Spend 6 materials and one recovery action instead of restoring a room."
	elif action_id == "assign_piece":
		preview.target_id = instance_id
		var assign_piece_id: String = String(pieces.get(instance_id, {}).get("piece_id", ""))
		var assign_piece_name: String = String(_piece_definitions.get(assign_piece_id, {}).get("name", "Select a placed piece"))
		var assign_room_name: String = String(_room_definitions.get(room_id, {}).get("name", "Select a room"))
		preview.target_name = "%s -> %s" % [assign_piece_name, assign_room_name]
		preview.benefit = String(_piece_assignment_rule(assign_piece_id).get("effect", "Activate the piece's specialist room behavior."))
		preview.tradeoff = "Spend one recovery action and commit this piece to one room."
	elif action_id == "clear_assignment":
		preview.target_id = instance_id
		var clear_piece_id: String = String(pieces.get(instance_id, {}).get("piece_id", ""))
		preview.target_name = String(_piece_definitions.get(clear_piece_id, {}).get("name", "Select an assigned piece"))
		preview.benefit = "Free the selected piece for a different specialist assignment later."
		preview.tradeoff = "Spend one recovery action and lose the current room benefit."
	else:
		return preview
	if not repair_interval_active:
		preview.reason = "no recovery interval is open"
		return preview
	if not active_event_id.is_empty() and not allow_active_event:
		preview.reason = "resolve the active event first"
		return preview
	if repair_actions_remaining <= 0:
		preview.reason = "no recovery actions remain"
		return preview
	match action_id:
		"repair_room":
			var room_repair_cost: int = int(recovery_profile().get("room_repair_materials", 8))
			if not rooms.has(room_id):
				preview.reason = "select a keep room"
			elif materials < room_repair_cost:
				preview.reason = "not enough materials"
			elif room_condition(room_id) >= 100:
				preview.reason = "room is already stable"
			else:
				preview.ok = true
				preview.reason = ""
		"repair_piece":
			if not pieces.has(instance_id):
				preview.reason = "select a placed defensive piece"
			elif float(pieces[instance_id].get("condition", 0.0)) >= 1.0:
				preview.reason = "piece is already stable"
			elif materials < 6:
				preview.reason = "not enough materials"
			else:
				preview.ok = true
				preview.reason = ""
		"assign_piece":
			if not pieces.has(instance_id):
				preview.reason = "select a placed defensive piece"
			elif not rooms.has(room_id):
				preview.reason = "select a keep room"
			else:
				var piece_id: String = String(pieces[instance_id].get("piece_id", ""))
				var rule: Dictionary = _piece_assignment_rule(piece_id)
				if rule.is_empty():
					preview.reason = "%s has no room assignment behavior" % _piece_definitions[piece_id].name
				else:
					if String(rule.get("room", "")) != room_id:
						preview.reason = "%s can only be assigned to %s" % [_piece_definitions[piece_id].name, _room_definitions[String(rule.get("room", ""))].name]
					elif String(pieces[instance_id].get("floor", "ground")) != String(_room_definitions[room_id].get("floor", "ground")):
						preview.reason = "piece and assigned room must share a floor"
					elif not _piece_is_adjacent_to_room(pieces[instance_id], room_id):
						preview.reason = "piece must be inside or adjacent to its assigned room"
					elif assigned_rooms.has(room_id) and String(assigned_rooms[room_id]) != instance_id:
						preview.reason = "%s already has an assigned piece" % _room_definitions[room_id].name
					else:
						var existing_assignment: String = String(pieces[instance_id].get("assignment", ""))
						if not existing_assignment.is_empty():
							preview.reason = "piece is already assigned to %s; clear it during the interval first" % _room_definitions[existing_assignment].name
						else:
							preview.ok = true
							preview.reason = ""
		"clear_assignment":
			if not pieces.has(instance_id):
				preview.reason = "select a placed defensive piece"
			else:
				var assignment: String = String(pieces[instance_id].get("assignment", ""))
				if assignment.is_empty():
					preview.reason = "piece has no room assignment"
				else:
					preview.target_name = "%s <- %s" % [String(_piece_definitions[String(pieces[instance_id].get("piece_id", ""))].name), String(_room_definitions[assignment].name)]
					preview.ok = true
					preview.reason = ""
	return preview

func assign_piece_to_room(instance_id: String, room_id: String) -> Dictionary:
	var preview: Dictionary = recovery_action_preview("assign_piece", instance_id, room_id)
	if not bool(preview.get("ok", false)):
		return {"ok": false, "reason": String(preview.get("reason", "assignment is unavailable")), "state_changes": []}
	return _commit_piece_assignment(instance_id, room_id)

func _commit_piece_assignment(instance_id: String, room_id: String) -> Dictionary:
	var piece_id: String = String(pieces[instance_id].get("piece_id", ""))
	var rule: Dictionary = _piece_assignment_rule(piece_id)
	assigned_rooms[room_id] = instance_id
	pieces[instance_id].assignment = room_id
	repair_actions_remaining -= 1
	_log("Assigned %s to %s: %s." % [_piece_definitions[piece_id].name, _room_definitions[room_id].name, rule.effect])
	return {"ok": true, "message": "Assigned %s to %s: %s." % [_piece_definitions[piece_id].name, _room_definitions[room_id].name, rule.effect], "actions_remaining": repair_actions_remaining, "state_changes": [{"op": "assign_piece", "piece": instance_id, "room": room_id}]}

func clear_piece_assignment(instance_id: String) -> Dictionary:
	var preview: Dictionary = recovery_action_preview("clear_assignment", instance_id)
	if not bool(preview.get("ok", false)):
		return {"ok": false, "reason": String(preview.get("reason", "assignment clearing is unavailable")), "state_changes": []}
	var assignment: String = String(pieces[instance_id].get("assignment", ""))
	assigned_rooms.erase(assignment)
	pieces[instance_id].assignment = ""
	repair_actions_remaining -= 1
	return {"ok": true, "message": "Cleared %s from %s." % [_piece_definitions[String(pieces[instance_id].get("piece_id", ""))].name, _room_definitions[assignment].name], "actions_remaining": repair_actions_remaining, "state_changes": [{"op": "clear_assignment", "piece": instance_id, "room": assignment}]}

func _piece_assignment_rule(piece_id: String) -> Dictionary:
	if not _piece_definitions.has(piece_id):
		return {}
	var rule: Variant = _piece_definitions[piece_id].get("assignment_rule")
	return rule.duplicate(true) if rule is Dictionary else {}

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
	if not _room_definitions.has(room_id) or String(instance.get("floor", "ground")) != String(_room_definitions[room_id].floor):
		return false
	var piece_id: String = String(instance.get("piece_id", ""))
	var piece_rect: Rect2i = Rect2i(instance.get("origin", Vector2i.ZERO), _piece_definitions[piece_id].size)
	var room_rect: Rect2i = Rect2i(_room_definitions[room_id].origin, _room_definitions[room_id].size)
	return piece_rect.grow(1).intersects(room_rect)

func _pieces_are_adjacent(first: Dictionary, second: Dictionary) -> bool:
	if String(first.get("floor", "ground")) != String(second.get("floor", "ground")):
		return false
	var first_id: String = String(first.get("piece_id", ""))
	var second_id: String = String(second.get("piece_id", ""))
	if not _piece_definitions.has(first_id) or not _piece_definitions.has(second_id):
		return false
	var first_rect := Rect2i(first.get("origin", Vector2i.ZERO), _piece_definitions[first_id].size)
	var second_rect := Rect2i(second.get("origin", Vector2i.ZERO), _piece_definitions[second_id].size)
	return first_rect.grow(1).intersects(second_rect)

func _room_protection(room_id: String) -> int:
	var reduction: int = 0
	for instance in pieces.values():
		if bool(instance.get("disabled", false)) or float(instance.get("condition", 0.0)) <= 0.0 or not _piece_is_adjacent_to_room(instance, room_id):
			continue
		var profile: Variant = _piece_definitions[String(instance.get("piece_id", ""))].get("support_profile")
		if profile is Dictionary:
			reduction += int(profile.get("room_damage_reduction", 0))
	return reduction

func _piece_protection(target_id: String) -> int:
	if not pieces.has(target_id):
		return 0
	var reduction: int = 0
	for instance_id in pieces.keys():
		if String(instance_id) == target_id:
			continue
		var instance: Dictionary = pieces[instance_id]
		if bool(instance.get("disabled", false)) or float(instance.get("condition", 0.0)) <= 0.0 or not _pieces_are_adjacent(instance, pieces[target_id]):
			continue
		var profile: Variant = _piece_definitions[String(instance.get("piece_id", ""))].get("support_profile")
		if profile is Dictionary:
			reduction = maxi(reduction, int(profile.get("piece_damage_reduction", 0)))
	return reduction

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

func _piece_has_open_lane(instance: Dictionary) -> bool:
	var floor_name: String = String(instance.get("floor", "ground"))
	var origin: Vector2i = instance.get("origin", Vector2i.ZERO)
	var piece_id: String = String(instance.get("piece_id", ""))
	if not _piece_definitions.has(piece_id):
		return false
	var size: Vector2i = _piece_definitions[piece_id].size
	var checks: Array[Vector2i] = [origin + Vector2i(-1, 0), origin + Vector2i(size.x, 0), origin + Vector2i(0, -1), origin + Vector2i(0, size.y)]
	for cell in checks:
		if cell.x >= 0 and cell.y >= 0 and cell.x < GRID_SIZE.x and cell.y < GRID_SIZE.y and piece_at_cell(floor_name, cell).is_empty():
			return true
	return false

func _warden_open_lane(instance: Dictionary) -> bool:
	return commander_id == "warden" and _piece_has_open_lane(instance)

func layout_summary() -> Dictionary:
	var counts: Dictionary = {"ground": 0, "upper": 0, "wall": 0, "courtyard": 0, "keep": 0}
	var role_counts: Dictionary = {}
	var open_lane_count: int = 0
	var room_edge_count: int = 0
	var support_piece_count: int = 0
	var signal_piece_count: int = 0
	var assigned_specialist_count: int = 0
	var active_spatial_rule: Dictionary = spatial_rule_state()
	for instance in pieces.values():
		var piece_id: String = String(instance.get("piece_id", ""))
		if not _piece_definitions.has(piece_id):
			continue
		var floor_name: String = String(instance.get("floor", "ground"))
		counts[floor_name] = int(counts.get(floor_name, 0)) + 1
		var zone: String = String(instance.get("placement_zone", placement_zone(instance.get("origin", Vector2i.ZERO), floor_name, _piece_definitions[piece_id].size)))
		counts[zone] = int(counts.get(zone, 0)) + 1
		var role: String = String(_piece_definitions[piece_id].get("combat_style", "support"))
		role_counts[role] = int(role_counts.get(role, 0)) + 1
		if role == "support":
			support_piece_count += 1
		if piece_id == "scout_post" or piece_id == "signal_beacon":
			signal_piece_count += 1
		if not String(instance.get("assignment", "")).is_empty():
			assigned_specialist_count += 1
		if _piece_has_open_lane(instance):
			open_lane_count += 1
		for room_id in _room_definitions.keys():
			if _piece_is_adjacent_to_room(instance, String(room_id)):
				room_edge_count += 1
				break
	var warnings: Array[String] = []
	if int(counts.ground) == 0:
		warnings.append("No ground-floor defender covers the Gate or courtyard.")
	if int(counts.upper) == 0:
		warnings.append("No upper-floor piece covers climber or signal pressure.")
	if support_piece_count == 0:
		warnings.append("No support piece protects recovery or information.")
	if not pieces.is_empty() and open_lane_count == 0:
		warnings.append("No placed piece has an open adjacent response cell.")
	if String(active_spatial_rule.get("id", "")) == "clear_causeway" and not bool(active_spatial_rule.get("active", false)):
		warnings.append("A placed piece blocks the causeway, so its room-damage reduction is inactive.")
	var role_ids: Array = role_counts.keys()
	role_ids.sort()
	for role_id in role_ids:
		var role_count: int = int(role_counts[role_id])
		if role_count > 1:
			warnings.append("%d %s pieces overlap in role; confirm they answer different routes." % [role_count, String(role_id)])
	if warnings.is_empty():
		warnings.append("No immediate coverage warning; the forecast still determines whether the layout fits.")
	var total: int = pieces.size()
	var castellan_summary: String = "%d/%d pieces reinforce a room edge; %d specialist assignment(s) are active." % [room_edge_count, total, assigned_specialist_count]
	var castellan_risk: String = "Disconnected pieces receive less value from compact defense."
	if total > 0 and room_edge_count == total:
		castellan_risk = "The layout is compact; verify that concentration does not abandon an upper route."
	var warden_summary: String = "%d/%d pieces retain an open response cell; %d signal piece(s) cover %d floor(s)." % [open_lane_count, total, signal_piece_count, (1 if int(counts.ground) > 0 else 0) + (1 if int(counts.upper) > 0 else 0)]
	var warden_risk: String = "Blocked lanes or single-floor coverage reduce mobile response."
	if total > 0 and open_lane_count == total and int(counts.ground) > 0 and int(counts.upper) > 0:
		warden_risk = "Movement is preserved; verify that the lighter formation can absorb direct pressure."
	return {
		"keep_id": keep_id,
		"keep_name": String(_keep_definitions.get(keep_id, {}).get("name", keep_id)),
		"spatial_rule": active_spatial_rule,
		"counts": counts,
		"open_lane_count": open_lane_count,
		"room_edge_count": room_edge_count,
		"support_piece_count": support_piece_count,
		"signal_piece_count": signal_piece_count,
		"assigned_specialist_count": assigned_specialist_count,
		"duplicate_role_warnings": warnings,
		"active_commander": commander_id,
		"commander_comparison": {
			"castellan": {"name": String(_commander_definitions.castellan.name), "summary": castellan_summary, "risk": castellan_risk},
			"warden": {"name": String(_commander_definitions.warden.name), "summary": warden_summary, "risk": warden_risk}
		}
	}

func _warden_signal_bonus() -> bool:
	return commander_id == "warden" and (_has_unit("scout_post") or _has_unit("signal_beacon"))

func _living_piece_count(piece_id: String, floor: String = "") -> int:
	var count: int = 0
	for instance in pieces.values():
		if String(instance.get("piece_id", "")) == piece_id and (floor.is_empty() or String(instance.get("floor", "")) == floor) and float(instance.get("condition", 0.0)) > 0.0:
			count += 1
	return count

func _has_unit(piece_id: String, floor: String = "") -> bool:
	return _living_piece_count(piece_id, floor) > 0

func _has_nearby_ranged_support(instance: Dictionary) -> bool:
	var floor_name: String = String(instance.get("floor", "ground"))
	var origin: Vector2i = instance.get("origin", Vector2i.ZERO)
	for support in pieces.values():
		if bool(support.get("disabled", false)) or float(support.get("condition", 0.0)) <= 0.0 or String(support.get("floor", "ground")) != floor_name:
			continue
		var support_id: String = String(support.get("piece_id", ""))
		if not _piece_definitions.has(support_id):
			continue
		var support_profile: Variant = _piece_definitions[support_id].get("support_profile")
		if not support_profile is Dictionary or String(support_profile.get("response_modifier", "")) != "nearby_ranged_plus_one":
			continue
		var support_origin: Vector2i = support.get("origin", Vector2i.ZERO)
		var support_range: int = int(_piece_definitions[support_id].get("range", 0))
		if absi(support_origin.x - origin.x) + absi(support_origin.y - origin.y) <= support_range:
			return true
	return false

func _has_linked_support(counter_modifier: String, relay_modifier: String) -> bool:
	for counter_instance in pieces.values():
		if bool(counter_instance.get("disabled", false)) or float(counter_instance.get("condition", 0.0)) <= 0.0:
			continue
		var counter_piece_id: String = String(counter_instance.get("piece_id", ""))
		var counter_piece: Dictionary = _piece_definitions.get(counter_piece_id, {})
		var counter_profile: Variant = counter_piece.get("support_profile")
		if not counter_profile is Dictionary or String(counter_profile.get("response_modifier", "")) != counter_modifier:
			continue
		var counter_floor: String = String(counter_instance.get("floor", "ground"))
		var counter_origin: Vector2i = counter_instance.get("origin", Vector2i.ZERO)
		var counter_range: int = int(counter_piece.get("range", 0))
		for relay_instance in pieces.values():
			if bool(relay_instance.get("disabled", false)) or float(relay_instance.get("condition", 0.0)) <= 0.0 or String(relay_instance.get("floor", "ground")) != counter_floor:
				continue
			var relay_piece: Dictionary = _piece_definitions.get(String(relay_instance.get("piece_id", "")), {})
			var relay_profile: Variant = relay_piece.get("support_profile")
			if not relay_profile is Dictionary or String(relay_profile.get("response_modifier", "")) != relay_modifier:
				continue
			var relay_origin: Vector2i = relay_instance.get("origin", Vector2i.ZERO)
			if absi(relay_origin.x - counter_origin.x) + absi(relay_origin.y - counter_origin.y) <= counter_range:
				return true
	return false

func _enemy_disruption_countered(enemy_id: String) -> bool:
	var disruption: Variant = _enemy_definitions.get(enemy_id, {}).get("disruption_profile")
	if not disruption is Dictionary:
		return true
	return _has_linked_support(String(disruption.get("counter_modifier", "")), String(disruption.get("relay_modifier", "")))

func _enemy_arrival_state(enemy_id: String) -> Dictionary:
	var definition: Dictionary = _enemy_definitions.get(enemy_id, {})
	var base_arrival: int = int(definition.get("arrival_step", 1))
	var disruption: Variant = definition.get("disruption_profile")
	var disrupted: bool = disruption is Dictionary and not _enemy_disruption_countered(enemy_id)
	var delta: int = int(disruption.get("arrival_step_delta", 0)) if disrupted else 0
	return {"arrival_step": maxi(1, base_arrival + delta), "base_arrival_step": base_arrival, "signal_disrupted": disrupted}

func _has_assignment(piece_id: String, room_id: String) -> bool:
	if not assigned_rooms.has(room_id):
		return false
	var instance_id: String = String(assigned_rooms[room_id])
	return pieces.has(instance_id) and String(pieces[instance_id].get("piece_id", "")) == piece_id and float(pieces[instance_id].get("condition", 0.0)) > 0.0

func _reload_ammunition() -> void:
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		var piece_id: String = String(instance.get("piece_id", ""))
		if not _piece_definitions.has(piece_id):
			continue
		var max_ammo: int = int(instance.get("max_ammo", _piece_definitions[piece_id].get("max_ammo", 0)))
		instance.max_ammo = max_ammo
		instance.ammo = max_ammo

func _defender_attack_projection(instance_id: String, enemy_id: String) -> Dictionary:
	if not pieces.has(instance_id) or not _enemy_definitions.has(enemy_id):
		return {"damage": 0, "armor_blocked": 0}
	var instance: Dictionary = pieces[instance_id]
	if float(instance.get("condition", 0.0)) <= 0.0 or bool(instance.get("disabled", false)):
		return {"damage": 0, "armor_blocked": 0}
	var piece_id: String = String(instance.get("piece_id", ""))
	if not _piece_definitions.has(piece_id):
		return {"damage": 0, "armor_blocked": 0}
	var piece: Dictionary = _piece_definitions[piece_id]
	var combat_style: String = String(piece.get("combat_style", "support"))
	if not ["melee", "ranged"].has(combat_style) or int(piece.get("attack", 0)) <= 0:
		return {"damage": 0, "armor_blocked": 0}
	var ammo: int = int(instance.get("ammo", piece.get("max_ammo", 0)))
	if combat_style == "ranged" and ammo <= 0:
		return {"damage": 0, "armor_blocked": 0}
	if not piece.targets.has("all") and not piece.targets.has(enemy_id):
		return {"damage": 0, "armor_blocked": 0}
	var enemy: Dictionary = _enemy_definitions[enemy_id]
	var zone: String = String(instance.get("placement_zone", placement_zone(instance.get("origin", Vector2i.ZERO), String(instance.get("floor", "ground")), piece.get("size", Vector2i.ONE))))
	var contribution: int = int(piece.attack)
	if piece_id == "pike_squad" and (String(enemy.route) != "gate_road" or String(instance.get("floor", "ground")) != "ground"):
		contribution = 0
	if piece_id == "fire_team" and enemy_id != "climber":
		contribution = 1
	if piece_id == "fire_team" and enemy_id == "climber" and String(instance.get("floor", "ground")) != "upper" and String(instance.get("assignment", "")) != "inner_yard":
		contribution = 1
	if piece_id == "fire_brazier" and String(instance.get("floor", "ground")) != "upper":
		contribution = 0
	if piece_id == "runner_pair":
		contribution = 4 if _piece_has_open_lane(instance) and ["sapper", "climber"].has(enemy_id) else 0
	if piece_id == "rear_guard" and _fallback_is_active():
		contribution += 2
		if String(instance.get("assignment", "")) == "barracks":
			contribution += 1
	if piece_id == "pike_squad" and zone == "keep":
		contribution = 1
	elif piece_id == "pike_squad" and zone == "courtyard":
		contribution += 1
	if piece_id == "fire_team" and zone == "keep":
		contribution = 0
	elif piece_id == "fire_team" and zone == "courtyard":
		contribution = mini(contribution, 2)
	if piece_id == "pike_squad" and String(instance.get("assignment", "")) == "gate" and enemy_id == "raider":
		contribution += 2
	if piece_id == "fire_team" and String(instance.get("assignment", "")) == "inner_yard" and enemy_id == "climber":
		contribution += 1
	if _castellan_adjacent(instance, String(enemy.target_rooms[0])):
		contribution += 1
	if _warden_open_lane(instance):
		contribution += 1
	if rally_pending and commander_id == "warden" and int(piece.attack) > 0:
		contribution += 1
	if combat_style == "ranged" and _has_nearby_ranged_support(instance):
		contribution += 1
	var armor_blocked: int = 0
	var armor: int = int(enemy.get("armor", 0))
	var armor_counter_tag: String = String(enemy.get("armor_counter_tag", ""))
	if armor > 0 and (armor_counter_tag.is_empty() or not piece.get("strength_tags", []).has(armor_counter_tag)):
		var unarmored_contribution: int = contribution
		contribution = maxi(0, contribution - armor)
		armor_blocked = unarmored_contribution - contribution
	return {"damage": contribution, "armor_blocked": armor_blocked}

func _defender_target_is_better(candidate_index: int, selected_index: int, candidate_damage: int, selected_damage: int, resolution_step: int, projected_health: Dictionary) -> bool:
	if selected_index < 0:
		return true
	var candidate: Dictionary = enemies[candidate_index]
	var selected: Dictionary = enemies[selected_index]
	var candidate_arrival: int = int(candidate.get("arrival_step", 1))
	var selected_arrival: int = int(selected.get("arrival_step", 1))
	var candidate_contact: bool = resolution_step >= candidate_arrival
	var selected_contact: bool = resolution_step >= selected_arrival
	if candidate_contact != selected_contact:
		return candidate_contact
	if candidate_arrival != selected_arrival:
		return candidate_arrival < selected_arrival
	if candidate_damage != selected_damage:
		return candidate_damage > selected_damage
	var candidate_pressure: int = int(_enemy_definitions[String(candidate.get("enemy_id", ""))].get("damage", 0))
	var selected_pressure: int = int(_enemy_definitions[String(selected.get("enemy_id", ""))].get("damage", 0))
	if candidate_pressure != selected_pressure:
		return candidate_pressure > selected_pressure
	var candidate_health: int = int(projected_health.get(candidate_index, candidate.get("hp", 0)))
	var selected_health: int = int(projected_health.get(selected_index, selected.get("hp", 0)))
	if candidate_health != selected_health:
		return candidate_health < selected_health
	return int(candidate.get("slot", candidate_index)) < int(selected.get("slot", selected_index))

func _planned_defender_engagements(resolution_step: int) -> Array[Dictionary]:
	var engagements: Array[Dictionary] = []
	var projected_health: Dictionary = {}
	for enemy_index in range(enemies.size()):
		projected_health[enemy_index] = int(enemies[enemy_index].get("hp", 0))
	var instance_ids: Array = pieces.keys()
	instance_ids.sort()
	for instance_id_value in instance_ids:
		var instance_id: String = String(instance_id_value)
		var instance: Dictionary = pieces[instance_id]
		if float(instance.get("condition", 0.0)) <= 0.0 or bool(instance.get("disabled", false)) or int(instance.get("attack_cooldown", 0)) > 0:
			continue
		var selected_index: int = -1
		var selected_projection: Dictionary = {"damage": 0, "armor_blocked": 0}
		for enemy_index in range(enemies.size()):
			var enemy: Dictionary = enemies[enemy_index]
			if bool(enemy.get("defeated", false)) or int(projected_health.get(enemy_index, 0)) <= 0:
				continue
			var projection: Dictionary = _defender_attack_projection(instance_id, String(enemy.get("enemy_id", "")))
			var projected_damage: int = int(projection.get("damage", 0))
			if projected_damage <= 0:
				continue
			if _defender_target_is_better(enemy_index, selected_index, projected_damage, int(selected_projection.get("damage", 0)), resolution_step, projected_health):
				selected_index = enemy_index
				selected_projection = projection
		if selected_index < 0:
			continue
		var selected_enemy: Dictionary = enemies[selected_index]
		var damage: int = int(selected_projection.get("damage", 0))
		projected_health[selected_index] = maxi(0, int(projected_health[selected_index]) - damage)
		engagements.append({
			"attacker_id": instance_id,
			"enemy_index": selected_index,
			"enemy_id": String(selected_enemy.get("enemy_id", "")),
			"damage": damage,
			"armor_blocked": int(selected_projection.get("armor_blocked", 0))
		})
	return engagements

func defender_response_preview(enemy_index: int) -> Dictionary:
	if not wave_active:
		return {"ok": false, "reason": "no active invasion"}
	if enemy_index < 0 or enemy_index >= enemies.size():
		return {"ok": false, "reason": "unknown enemy"}
	if bool(enemies[enemy_index].get("defeated", false)):
		return {"ok": false, "reason": "enemy already defeated"}
	var next_step: int = mini(6, battle_step + 1)
	var attackers: Array[Dictionary] = []
	var expected_damage: int = 0
	for engagement in _planned_defender_engagements(next_step):
		if int(engagement.get("enemy_index", -1)) != enemy_index:
			continue
		var attacker_id: String = String(engagement.get("attacker_id", ""))
		var piece_id: String = String(pieces.get(attacker_id, {}).get("piece_id", ""))
		var damage: int = int(engagement.get("damage", 0))
		expected_damage += damage
		attackers.append({"id": attacker_id, "piece_id": piece_id, "name": String(_piece_definitions.get(piece_id, {}).get("name", piece_id)), "damage": damage})
	var enemy: Dictionary = enemies[enemy_index]
	var remaining_health: int = maxi(0, int(enemy.get("hp", 0)) - expected_damage)
	var contact_step: int = int(enemy.get("arrival_step", 1))
	return {
		"ok": true,
		"step": next_step,
		"enemy_index": enemy_index,
		"attackers": attackers,
		"expected_damage": expected_damage,
		"projected_health": remaining_health,
		"stopped_before_contact": remaining_health <= 0 and next_step < contact_step,
		"contact_state": "CONTACT" if next_step >= contact_step else "APPROACH",
		"priority_rule": "contact, arrival, effective counter damage, pressure, remaining health, wave slot"
	}

func _living_piece_targets(enemy: Dictionary, apply_preferences: bool) -> Array[String]:
	var candidates: Array[String] = []
	var assigned_candidates: Array[String] = []
	var target_categories: Array = enemy.get("target_piece_categories", [])
	var target_floors: Array = enemy.get("target_piece_floors", [])
	var assigned_first: bool = bool(enemy.get("targets_assigned_first", false))
	var instance_ids: Array = pieces.keys()
	instance_ids.sort()
	for instance_id_value in instance_ids:
		var instance_id: String = String(instance_id_value)
		var instance: Dictionary = pieces[instance_id]
		if bool(instance.get("disabled", false)) or float(instance.get("condition", 0.0)) <= 0.0:
			continue
		if apply_preferences:
			var piece: Dictionary = _piece_definitions[String(instance.get("piece_id", ""))]
			if assigned_first and not String(instance.get("assignment", "")).is_empty():
				assigned_candidates.append(instance_id)
				continue
			if not target_categories.is_empty() and not target_categories.has(String(piece.get("category", ""))):
				continue
			if not target_floors.is_empty() and not target_floors.has(String(instance.get("floor", "ground"))):
				continue
		candidates.append(instance_id)
	if apply_preferences and assigned_first and not assigned_candidates.is_empty():
		return assigned_candidates
	return candidates

func _choose_piece_target(enemy: Dictionary) -> String:
	var candidates: Array[String] = _living_piece_targets(enemy, true)
	if candidates.is_empty():
		candidates = _living_piece_targets(enemy, false)
	if candidates.is_empty():
		return ""
	var preference: String = String(enemy.get("target_piece_preference", "lowest_condition"))
	var selected: String = candidates[0]
	for candidate in candidates:
		if preference == "highest_max_health":
			var candidate_max: int = int(pieces[candidate].get("max_health", 0))
			var selected_max: int = int(pieces[selected].get("max_health", 0))
			if candidate_max > selected_max or (candidate_max == selected_max and candidate < selected):
				selected = candidate
		else:
			var candidate_condition: float = _target_condition(candidate)
			var selected_condition: float = _target_condition(selected)
			if candidate_condition < selected_condition or (is_equal_approx(candidate_condition, selected_condition) and candidate < selected):
				selected = candidate
	return selected

func _target_is_active(target_id: String) -> bool:
	if rooms.has(target_id):
		return room_condition(target_id) > 0
	if pieces.has(target_id):
		return not bool(pieces[target_id].get("disabled", false)) and float(pieces[target_id].get("condition", 0.0)) > 0.0
	return false

func _choose_target(enemy_id: String) -> String:
	var enemy: Dictionary = _enemy_definitions[enemy_id]
	if String(enemy.get("target_mode", "room_destroyer")) == "unit_hunter":
		return _choose_piece_target(enemy)
	var candidates: Array[String] = []
	var preferred_piece_candidates: Array[String] = []
	var target_rooms: Array = enemy.target_rooms.duplicate()
	if enemy_id == "siege_beast" and not variation_target_room.is_empty() and target_rooms.has(variation_target_room):
		target_rooms.erase(variation_target_room)
		target_rooms.push_front(variation_target_room)
	for room_id in target_rooms:
		if rooms.has(room_id) and room_condition(room_id) > 0:
			candidates.append(String(room_id))
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		var piece_id: String = String(instance.get("piece_id", ""))
		if enemy_id == "sapper" and ["repair_station", "supply_cache"].has(piece_id) and float(instance.get("condition", 0.0)) > 0.0:
			preferred_piece_candidates.append(String(instance_id))
	if not preferred_piece_candidates.is_empty():
		candidates = preferred_piece_candidates
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
		_battle_log("%s found no valid target; the keep’s empty response space mattered." % _enemy_definitions[enemy_id].name)
		return
	var damage: int = int(_enemy_definitions[enemy_id].damage)
	var ignores_protection: bool = bool(_enemy_definitions[enemy_id].get("ignores_protection", false))
	combat_metrics["enemy_attacks"] = int(combat_metrics.get("enemy_attacks", 0)) + 1
	var reduced: bool = lockdown_pending or rally_pending
	if reduced:
		damage = maxi(1, int(ceil(float(damage) * 0.5)))
	if enemy_id == "sapper" and bool(event_flags.get("support_lane_marked", false)):
		damage = maxi(0, damage - 1)
		event_flags.support_lane_marked = false
		_battle_log("The marked support lane reduced the first Sapper contact by 1 damage and is now spent.")
	if enemy_id == "siege_beast":
		var area_targets: Array[String] = []
		for room_id in _enemy_definitions[enemy_id].target_rooms:
			if rooms.has(room_id) and room_condition(room_id) > 0:
				area_targets.append(String(room_id))
		if not area_targets.has(target_id):
			area_targets.push_front(target_id)
		for area_index in range(mini(3, area_targets.size())):
			var area_room: String = area_targets[area_index]
			var area_damage: int = maxi(1, damage - (1 if area_index > 0 else 0))
			_apply_room_damage(enemy_id, area_room, area_damage, reduced, true)
		_battle_log("Siege Beast impact spread across %d rooms; preserve the refuge or accept a scarred perimeter." % mini(3, area_targets.size()))
		return
	if rooms.has(target_id):
		_apply_room_damage(enemy_id, target_id, damage, reduced, false)
	elif pieces.has(target_id):
		var piece_protection: int = _piece_protection(target_id)
		if piece_protection > 0:
			if ignores_protection:
				_battle_log("%s ignored %d adjacent guard protecting %s." % [_enemy_definitions[enemy_id].name, piece_protection, _piece_definitions[String(pieces[target_id].piece_id)].name])
			else:
				damage = maxi(0, damage - piece_protection)
		combat_metrics["piece_damage"] = int(combat_metrics.get("piece_damage", 0)) + damage
		var instance: Dictionary = pieces[target_id]
		var piece_id: String = String(instance.get("piece_id", ""))
		var max_health: int = int(instance.get("max_health", _piece_definitions[piece_id].get("max_health", 10)))
		var health_loss: int = damage
		_set_piece_health(target_id, int(instance.get("health", max_health)) - health_loss)
		_battle_log("%s damaged %s by %d; health is %d/%d." % [_enemy_definitions[enemy_id].name, _piece_definitions[piece_id].name, damage, int(instance.get("health", 0)), max_health])

func _apply_room_damage(enemy_id: String, room_id: String, damage: int, reduced: bool, area_impact: bool) -> void:
	if not rooms.has(room_id):
		return
	var spatial_rule: Dictionary = spatial_rule_state()
	if bool(spatial_rule.get("active", false)):
		var causeway_reduction: int = int(spatial_rule.get("room_damage_reduction", 0))
		if causeway_reduction > 0:
			damage = maxi(0, damage - causeway_reduction)
			_battle_log("The clear causeway dispersed the response and reduced room damage by %d." % causeway_reduction)
	var ignores_protection: bool = bool(_enemy_definitions[enemy_id].get("ignores_protection", false))
	var room_protection: int = _room_protection(room_id)
	if room_protection > 0:
		if ignores_protection:
			_battle_log("%s ignored %d static protection at %s." % [_enemy_definitions[enemy_id].name, room_protection, _room_definitions[room_id].name])
		else:
			damage = maxi(0, damage - room_protection)
	if not ignores_protection:
		for instance_id in pieces.keys():
			var instance: Dictionary = pieces[instance_id]
			if String(instance.get("piece_id", "")) == "breakaway_barricade" and not bool(instance.get("disabled", false)) and _piece_is_adjacent_to_room(instance, room_id):
				damage = maxi(0, damage - 2)
				_set_piece_health(String(instance_id), 0)
				_battle_log("Breakaway Barricade absorbed 2 contact damage for %s and broke as planned." % _room_definitions[room_id].name)
				break
	var was_breached: bool = rooms[room_id].state == "breached"
	combat_metrics["room_damage"] = int(combat_metrics.get("room_damage", 0)) + damage * 15
	rooms[room_id].condition = maxi(0, int(rooms[room_id].condition) - damage * 15)
	_update_room_state(room_id)
	_battle_log("%s %s %s and dealt %d room damage%s; room is %s." % [_enemy_definitions[enemy_id].name, "impacted" if area_impact else "reached", _room_definitions[room_id].name, damage, " under response mitigation" if reduced else "", rooms[room_id].state])
	if rooms[room_id].state == "breached" and not was_breached:
		breach_level += 1
		morale = maxi(0, morale - 1)
		_battle_log("%s breached. Morale falls because its named function is offline." % _room_definitions[room_id].name)

func _repair_after_defenders() -> void:
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		if String(instance.get("piece_id", "")) != "repair_station" or float(instance.get("condition", 0.0)) <= 0.0:
			continue
		var best_room: String = ""
		var repair_amount: int = 8
		var assigned_room: String = String(instance.get("assignment", ""))
		if assigned_room == "workshop" and room_condition(assigned_room) > 0 and room_condition(assigned_room) < 100:
			best_room = assigned_room
			repair_amount = 12
		else:
			var lowest: int = 101
			for room_id in rooms.keys():
				if room_condition(room_id) > 0 and room_condition(room_id) < lowest:
					lowest = room_condition(room_id)
					best_room = String(room_id)
		if not best_room.is_empty() and room_condition(best_room) < 100:
			rooms[best_room].condition = mini(100, room_condition(best_room) + repair_amount)
			_update_room_state(best_room)
			combat_metrics["repairs"] = int(combat_metrics.get("repairs", 0)) + repair_amount
			_battle_log("Repair Station restored %s by %d; it is now %s." % [_room_definitions[best_room].name, repair_amount, rooms[best_room].state])
			break

func _battle_step() -> Dictionary:
	battle_step += 1
	combat_metrics["battle_steps"] = int(combat_metrics.get("battle_steps", 0)) + 1
	var lockdown_contact: bool = false
	var rally_contact: bool = rally_pending
	_battle_log("Step %d: forecast says %s; the keep executes its prepared routine." % [battle_step, enemy_doctrine.replace("_", " ")])
	var engagements: Array[Dictionary] = _planned_defender_engagements(battle_step)
	var instance_ids: Array = pieces.keys()
	instance_ids.sort()
	for instance_id_value in instance_ids:
		var instance_id: String = String(instance_id_value)
		var cooldown: int = int(pieces[instance_id].get("attack_cooldown", 0))
		if cooldown > 0:
			pieces[instance_id].attack_cooldown = cooldown - 1
	var attackers_by_enemy: Dictionary = {}
	var damage_by_enemy: Dictionary = {}
	var armor_blocked_by_enemy: Dictionary = {}
	for engagement in engagements:
		var attacker_id: String = String(engagement.get("attacker_id", ""))
		var enemy_index: int = int(engagement.get("enemy_index", -1))
		if not pieces.has(attacker_id) or enemy_index < 0 or enemy_index >= enemies.size() or bool(enemies[enemy_index].get("defeated", false)):
			continue
		var damage: int = int(engagement.get("damage", 0))
		if damage <= 0:
			continue
		var instance: Dictionary = pieces[attacker_id]
		var piece_id: String = String(instance.get("piece_id", ""))
		var piece: Dictionary = _piece_definitions[piece_id]
		var enemy: Dictionary = enemies[enemy_index]
		enemy.hp = maxi(0, int(enemy.get("hp", 0)) - damage)
		enemy.damage_taken = int(enemy.get("damage_taken", 0)) + damage
		instance.attacks = int(instance.get("attacks", 0)) + 1
		instance.damage_dealt = int(instance.get("damage_dealt", 0)) + damage
		instance.last_target = String(enemy.get("enemy_id", ""))
		instance.attack_cooldown = maxi(0, int(piece.get("attack_interval", 1)) - 1)
		if String(piece.get("combat_style", "support")) == "ranged":
			instance.ammo = maxi(0, int(instance.get("ammo", piece.get("max_ammo", 0))) - 1)
			combat_metrics["ammo_spent"] = int(combat_metrics.get("ammo_spent", 0)) + 1
		combat_metrics["unit_attacks"] = int(combat_metrics.get("unit_attacks", 0)) + 1
		combat_metrics["damage_dealt"] = int(combat_metrics.get("damage_dealt", 0)) + damage
		if not attackers_by_enemy.has(enemy_index):
			attackers_by_enemy[enemy_index] = []
			damage_by_enemy[enemy_index] = 0
			armor_blocked_by_enemy[enemy_index] = 0
		attackers_by_enemy[enemy_index].append(String(piece.get("name", piece_id)))
		damage_by_enemy[enemy_index] = int(damage_by_enemy.get(enemy_index, 0)) + damage
		armor_blocked_by_enemy[enemy_index] = int(armor_blocked_by_enemy.get(enemy_index, 0)) + int(engagement.get("armor_blocked", 0))
	var engaged_enemy_indices: Array = attackers_by_enemy.keys()
	engaged_enemy_indices.sort()
	for enemy_index_value in engaged_enemy_indices:
		var enemy_index: int = int(enemy_index_value)
		var enemy: Dictionary = enemies[enemy_index]
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		var attacker_names: Array[String] = []
		for attacker_name in attackers_by_enemy[enemy_index]:
			attacker_names.append(String(attacker_name))
		if int(armor_blocked_by_enemy.get(enemy_index, 0)) > 0:
			_battle_log("%s armor absorbed %d damage from non-piercing defenders." % [_enemy_definitions[enemy_id].name, int(armor_blocked_by_enemy[enemy_index])])
		_battle_log("%s committed to %s for %d damage using %s counterplay." % [", ".join(attacker_names), _enemy_definitions[enemy_id].name, int(damage_by_enemy.get(enemy_index, 0)), _enemy_definitions[enemy_id].counter])
		if int(enemy.get("hp", 0)) <= 0 and not bool(enemy.get("defeated", false)):
			enemy.defeated = true
			combat_metrics["defeated_enemies"] = int(combat_metrics.get("defeated_enemies", 0)) + 1
			for engagement in engagements:
				if int(engagement.get("enemy_index", -1)) == enemy_index:
					var attacker_id: String = String(engagement.get("attacker_id", ""))
					pieces[attacker_id].targets_stopped = int(pieces[attacker_id].get("targets_stopped", 0)) + 1
			_battle_log("%s was stopped before its doctrine could complete." % _enemy_definitions[enemy_id].name)
	for enemy in enemies:
		if bool(enemy.get("defeated", false)):
			continue
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		if battle_step >= int(enemy.get("arrival_step", _enemy_definitions[enemy_id].arrival_step)):
			if not _target_is_active(String(enemy.get("target", ""))):
				enemy.target = _choose_target(enemy_id)
				var target_name: String = "none"
				if _room_definitions.has(enemy.target):
					target_name = String(_room_definitions[enemy.target].name)
				elif pieces.has(enemy.target):
					target_name = String(_piece_definitions[String(pieces[enemy.target].piece_id)].name)
				_battle_log("%s arrived by %s; target forecast resolves to %s." % [_enemy_definitions[enemy_id].name, _enemy_definitions[enemy_id].route, target_name])
			if lockdown_pending:
				lockdown_contact = true
			if rally_pending:
				rally_contact = true
			var arrival_step: int = int(enemy.get("arrival_step", _enemy_definitions[enemy_id].arrival_step))
			var attack_interval: int = maxi(1, int(_enemy_definitions[enemy_id].get("attack_interval", 1)))
			if (battle_step - arrival_step) % attack_interval == 0:
				if not String(enemy.get("target", "")).is_empty():
					enemy.attacks_received = int(enemy.get("attacks_received", 0)) + 1
				_apply_enemy_damage(enemy_id, String(enemy.get("target", "")))
	_repair_after_defenders()
	if lockdown_contact:
		for instance_id in pieces.keys():
			var instance: Dictionary = pieces[instance_id]
			var max_health: int = int(instance.get("max_health", _piece_definitions[String(instance.get("piece_id", ""))].get("max_health", 10)))
			_set_piece_health(String(instance_id), int(instance.get("health", max_health)) + maxi(1, int(round(float(max_health) * 0.05))))
		_battle_log("Lockdown restored 5% condition across placed pieces, then released.")
		lockdown_pending = false
	if rally_contact:
		_battle_log("Rally coordinated the response across floors, then released.")
		rally_pending = false
	wave_progress = clamp(float(battle_step) / 6.0, 0.0, 1.0)
	if _defender_wipe_is_terminal():
		return _finish_wave()
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
		if bool(_room_definitions[room_id].critical) and room_state(String(room_id)) == "breached":
			count += 1
	return count

func _append_wave_history() -> void:
	wave_history.append({
		"wave": wave_index,
		"doctrine": enemy_doctrine,
		"principal_pressure": String(_doctrine_definitions.get(enemy_doctrine, {}).get("principal_pressure", "Unknown pressure")),
		"outcome": last_outcome,
		"breach_level": breach_level,
		"morale_after": morale,
		"defeated_enemies": int(combat_metrics.get("defeated_enemies", 0)),
		"room_damage": int(combat_metrics.get("room_damage", 0)),
		"piece_damage": int(combat_metrics.get("piece_damage", 0)),
		"ammo_spent": int(combat_metrics.get("ammo_spent", 0)),
		"enemy_attacks": int(combat_metrics.get("enemy_attacks", 0)),
		"recovery_actions_used": 0
	})

func _open_repair_interval(outcome: String) -> void:
	repair_interval_active = true
	repair_actions_remaining = 2
	pack_openings_this_preparation = 0
	if outcome == "partial_breach":
		repair_interval_reason = "The breach is quiet for now. Stabilize one function, then choose who takes the next post."
	else:
		repair_interval_reason = "The bells stop. Assign the crew before the next warning."
	_log("%s repair interval opened: %s" % [String(_keep_definitions.get(keep_id, {}).get("name", "Keep")), repair_interval_reason])
	for instance_id in pieces.keys():
		var instance: Dictionary = pieces[instance_id]
		if String(instance.get("piece_id", "")) == "supply_cache" and not bool(instance.get("disabled", false)) and not bool(instance.get("supply_spent", false)):
			instance.supply_spent = true
			materials += 5
			_log("Supply Cache released its field reserve: +5 materials. The cache is now spent.")
			break
	_append_wave_history()

func _fallback_is_active() -> bool:
	if breach_level > 0:
		return true
	for room_id in rooms.keys():
		if room_condition(String(room_id)) <= 70:
			return true
	return false

func finish_repair_interval() -> Dictionary:
	if not repair_interval_active:
		return {"ok": false, "reason": "no keep repair interval is open"}
	if not active_event_id.is_empty():
		return {"ok": false, "reason": "active_event_unresolved", "message": "Resolve the active event before closing recovery.", "state_changes": []}
	var unused: int = repair_actions_remaining
	if not wave_history.is_empty():
		wave_history[wave_history.size() - 1].recovery_actions_used = 2 - unused
	repair_interval_active = false
	repair_actions_remaining = 0
	repair_interval_reason = ""
	_reload_ammunition()
	_log("Repair interval closed with %d unused action(s). Surviving ranged defenders reload." % unused)
	if has_next_wave():
		var next_wave: Dictionary = start_wave(enemy_doctrine)
		if bool(next_wave.get("ok", false)):
			_log("Automatic scenario sequence advanced to wave %d/%d." % [wave_index, authored_wave_count()])
			return {"ok": true, "message": "Recovery closed. Wave %d/%d begins automatically." % [wave_index, authored_wave_count()], "unused_actions": unused, "next_wave_started": true, "next_wave": next_wave}
	_record_regional_consequence()
	return {"ok": true, "message": "Repair interval closed. The keep is ready for the next forecast.", "unused_actions": unused, "next_wave_started": false, "next_wave": {}}

func _record_regional_consequence() -> void:
	if not scenario_active or not _region_definitions.has("low_mill"):
		return
	var region: Dictionary = _region_definitions.low_mill
	var route: Dictionary = region.get("route", {})
	var anchor_condition: int = 100
	for room_id_value in route.get("anchor_rooms", []):
		var room_id: String = String(room_id_value)
		anchor_condition = mini(anchor_condition, room_condition(room_id)) if rooms.has(room_id) else 0
	var selected: Dictionary = {}
	for consequence in region.get("consequences", []):
		if bool(consequence.get("requires_non_collapse", false)) and last_outcome == "collapse":
			continue
		if anchor_condition >= int(consequence.get("minimum_anchor_condition", 0)):
			selected = consequence
			break
	if selected.is_empty():
		return
	var support_materials: int = int(selected.get("next_run_materials", 0))
	regional_state = {
		"settlement_id": String(region.get("id", "low_mill")),
		"settlement_name": String(region.get("name", "Low Mill")),
		"settlement_status": String(selected.get("settlement_status", "unproven")),
		"route_id": String(route.get("id", "mill_road")),
		"route_name": String(route.get("name", "Miller's Road")),
		"route_status": String(selected.get("route_status", "unknown")),
		"consequence_id": String(selected.get("id", "")),
		"summary": String(selected.get("summary", "")),
		"next_run_materials": support_materials,
		"pending_support": support_materials > 0,
		"applied_to_scenario_id": "",
		"source_scenario_id": scenario_id,
		"source_keep_id": keep_id,
		"source_replay_key": "%s/%s/%d" % [scenario_id, commander_id, seed]
	}
	_log("Regional report — %s / %s: %s" % [String(region.get("name", "Low Mill")), String(route.get("name", "Miller's Road")), String(selected.get("summary", ""))])

func _finish_wave() -> Dictionary:
	wave_active = false
	var critical_breaches: int = _critical_breach_count()
	var defense_line_broken: bool = not pieces.is_empty() and _surviving_piece_count() == 0
	var defender_wipe_is_terminal: bool = _defender_wipe_is_terminal()
	if critical_breaches >= 3 or morale <= 0 or defender_wipe_is_terminal:
		last_outcome = "collapse"
		repair_interval_active = false
		repair_actions_remaining = 0
		repair_interval_reason = ""
		_reload_ammunition()
		if defender_wipe_is_terminal:
			_battle_log("Outcome: collapse. Every defender was disabled under overwhelming pressure; this last stand has no recovery interval.")
		else:
			_battle_log("Outcome: collapse. Three critical functions or morale failed; the report identifies the chain; surviving ranged defenders reload for the next attempt.")
		_append_wave_history()
		_record_regional_consequence()
	elif breach_level > 0 or defense_line_broken:
		last_outcome = "partial_breach"
		morale = maxi(0, morale - 1)
		materials += 5
		if defense_line_broken and breach_level == 0:
			_battle_log("Outcome: partial breach. Every defensive piece was disabled, but the keep remains recoverable and receives 5 materials.")
		else:
			_battle_log("Outcome: partial breach. The keep remains playable and receives 5 recovery materials.")
		_open_repair_interval(last_outcome)
	else:
		last_outcome = "held"
		morale = mini(10, morale + 1)
		materials += 8
		_battle_log("Outcome: held. The defenders gain 8 materials and 1 morale.")
		_open_repair_interval(last_outcome)
	_refresh_active_event()
	return {"ok": true, "resolved": true, "outcome": last_outcome, "timeline": battle_report.duplicate(), "breach_level": breach_level, "repair_interval_active": repair_interval_active, "repair_actions_remaining": repair_actions_remaining}

func start_wave(doctrine: String) -> Dictionary:
	if not _doctrine_definitions.has(doctrine):
		return {"ok": false, "reason": "unknown invasion doctrine"}
	if repair_interval_active:
		return {"ok": false, "reason": "finish the keep repair interval before starting the next wave"}
	if wave_active:
		return {"ok": false, "reason": "an invasion is already active"}
	if not active_event_id.is_empty():
		return {"ok": false, "reason": "active_event_unresolved", "message": "Resolve the active event before starting the wave.", "state_changes": []}
	if pieces.is_empty():
		return {"ok": false, "reason": "place at least one defensive piece first"}
	if scenario_active and last_outcome == "collapse":
		return {"ok": false, "reason": "this authored sequence ended in collapse; start a new run to replay it"}
	if scenario_active and _scenario_definitions.has(scenario_id) and wave_index >= _scenario_definitions[scenario_id].get("wave_plans", []).size():
		return {"ok": false, "reason": "this authored scenario has no further waves; start a new run to replay it"}
	wave_index += 1
	if scenario_active and _scenario_definitions.has(scenario_id):
		var scenario_doctrines: Array = _scenario_definitions[scenario_id].get("doctrines", [doctrine])
		doctrine = String(scenario_doctrines[mini(wave_index - 1, scenario_doctrines.size() - 1)])
		enemy_doctrine = doctrine
	wave_active = true
	battle_step = 0
	battle_clock = 0.0
	wave_progress = 0.0
	breach_level = 0
	lockdown_used = false
	lockdown_pending = false
	rally_used = false
	rally_pending = false
	last_outcome = ""
	enemies.clear()
	battle_report.clear()
	var composition: Array = _doctrine_definitions[doctrine].get("composition", []).duplicate()
	if scenario_active and _scenario_definitions.has(scenario_id):
		var wave_plan: Array = _scenario_definitions[scenario_id].wave_plans[mini(wave_index - 1, _scenario_definitions[scenario_id].wave_plans.size() - 1)]
		composition = wave_plan.duplicate()
	_reset_combat_metrics()
	var enemy_health_bonus: int = _active_enemy_health_bonus()
	for index in range(composition.size()):
		var enemy_id: String = String(composition[index])
		var enemy_health: int = int(_enemy_definitions[enemy_id].get("health", 1)) + enemy_health_bonus
		var arrival_state: Dictionary = _enemy_arrival_state(enemy_id)
		enemies.append({"enemy_id": enemy_id, "max_health": enemy_health, "hp": enemy_health, "damage": int(_enemy_definitions[enemy_id].get("damage", 0)), "arrival_step": int(arrival_state.arrival_step), "signal_disrupted": bool(arrival_state.signal_disrupted), "target": "", "defeated": false, "slot": index, "attacks_received": 0, "damage_taken": 0})
	_battle_log("Forecast: %s. Question: %s" % [doctrine.replace("_", " "), _doctrine_definitions[doctrine].question])
	if enemy_health_bonus > 0:
		_battle_log("%s hardens the vanguard; every enemy begins with +%d health." % [String(_modifier_definitions[equipped_modifier_id].name), enemy_health_bonus])
	_battle_log("Likely pressure: %s. Scout Post can reveal the exact target before contact." % String(_enemy_definitions[String(composition[0])].route).replace("_", " "))
	var logged_disruptions: Array[String] = []
	for enemy in enemies:
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		if logged_disruptions.has(enemy_id) or not _enemy_definitions[enemy_id].get("disruption_profile") is Dictionary:
			continue
		logged_disruptions.append(enemy_id)
		if bool(enemy.get("signal_disrupted", false)):
			_battle_log("%s smoke broke the warning chain; contact advances from step %d to step %d." % [_enemy_definitions[enemy_id].name, int(_enemy_definitions[enemy_id].arrival_step), int(enemy.get("arrival_step", 1))])
		else:
			_battle_log("Bell Guard relayed through %s smoke; forecast detail and contact timing hold." % _enemy_definitions[enemy_id].name)
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
	if not wave_active:
		return {"ok": false, "reason": "commander abilities are only meaningful during an active invasion"}
	if command_points <= 0:
		return {"ok": false, "reason": "not enough command points"}
	if commander_id == "castellan":
		if lockdown_used:
			return {"ok": false, "reason": "Lockdown has already been used this wave"}
		command_points -= 1
		lockdown_used = true
		lockdown_pending = true
		_battle_log("The Castellan ordered Lockdown. The next contact will be contained, but the keep cannot reposition during it.")
		return {"ok": true, "message": "Lockdown is armed for the next battle step.", "command_points": command_points}
	if commander_id == "warden":
		if rally_used:
			return {"ok": false, "reason": "Rally has already been used this wave"}
		command_points -= 1
		rally_used = true
		rally_pending = true
		morale = mini(10, morale + 1)
		_battle_log("The Warden called Rally. Open lanes answer the bell; the next response will be coordinated.")
		return {"ok": true, "message": "Rally is armed for the next battle step and restored 1 morale.", "command_points": command_points}
	return {"ok": false, "reason": "unknown active commander"}

func repair_piece(instance_id: String) -> Dictionary:
	var preview: Dictionary = recovery_action_preview("repair_piece", instance_id)
	if not bool(preview.get("ok", false)):
		return {"ok": false, "reason": String(preview.get("reason", "piece repair is unavailable")), "state_changes": []}
	materials -= 6
	var max_health: int = int(pieces[instance_id].get("max_health", _piece_definitions[String(pieces[instance_id].get("piece_id", ""))].get("max_health", 10)))
	_set_piece_health(instance_id, int(pieces[instance_id].get("health", max_health)) + maxi(1, int(round(float(max_health) * 0.30))))
	combat_metrics["repairs"] = int(combat_metrics.get("repairs", 0)) + 30
	repair_actions_remaining -= 1
	return {"ok": true, "health": pieces[instance_id].health, "max_health": max_health, "condition": pieces[instance_id].condition, "actions_remaining": repair_actions_remaining, "message": "Repair restored the named piece without erasing its battle history.", "state_changes": [{"op": "repair_piece", "piece": instance_id, "health": pieces[instance_id].health}]}

func repair_room(room_id: String) -> Dictionary:
	var preview: Dictionary = recovery_action_preview("repair_room", "", room_id)
	if not bool(preview.get("ok", false)):
		return {"ok": false, "reason": String(preview.get("reason", "room repair is unavailable")), "state_changes": []}
	return _commit_room_repair(room_id)

func _commit_room_repair(room_id: String) -> Dictionary:
	var keep_recovery: Dictionary = recovery_profile()
	var room_repair_cost: int = int(keep_recovery.get("room_repair_materials", 8))
	var room_repair_amount: int = int(keep_recovery.get("room_repair_condition", 30))
	materials -= room_repair_cost
	rooms[room_id].condition = mini(100, room_condition(room_id) + room_repair_amount)
	_update_room_state(room_id)
	combat_metrics["repairs"] = int(combat_metrics.get("repairs", 0)) + room_repair_amount
	repair_actions_remaining -= 1
	return {"ok": true, "actions_remaining": repair_actions_remaining, "message": "Repaired %s to %s." % [_room_definitions[room_id].name, rooms[room_id].state], "state_changes": [{"op": "repair_room", "room": room_id, "condition": room_condition(room_id), "state": room_state(room_id)}]}

func recovery_advice() -> Dictionary:
	if not repair_interval_active:
		return {"ok": false, "reason": "no recovery interval is open"}
	var next_doctrine: String = ""
	if has_next_wave() and _scenario_definitions.has(scenario_id):
		var doctrines: Array = _scenario_definitions[scenario_id].get("doctrines", [])
		next_doctrine = String(doctrines[mini(wave_index, doctrines.size() - 1)]) if not doctrines.is_empty() else enemy_doctrine
	var target: String = "the most damaged critical room"
	var action: String = "repair_room"
	if next_doctrine == "distributed_sabotage":
		target = "Workshop or Supply Room; preserve support coverage"
		action = "repair_room_or_assign_support"
	elif next_doctrine == "feint_and_flank":
		target = "North Tower or Old Chapel; preserve an upper response lane"
		action = "assign_upper_response_or_repair"
	elif next_doctrine == "area_pressure":
		target = "Inner Yard and adjacent support rooms"
		action = "brace_or_repair_area"
	elif next_doctrine == "rolling_breach":
		target = "Gate, the support chain, and one preserved fallback position"
		action = "repair_weakest_function_or_preserve_fallback"
	return {"ok": true, "next_doctrine": next_doctrine, "target": target, "recommended_action": action, "actions_remaining": repair_actions_remaining, "tradeoff": "Each action repairs or reassigns one priority; unused actions do not silently reset damage."}

func scenario_scorecard() -> Dictionary:
	var outcomes: Array[String] = []
	var total_defeated: int = 0
	var total_room_damage: int = 0
	var total_piece_damage: int = 0
	var total_recovery_actions: int = 0
	for row in wave_history:
		outcomes.append(String(row.get("outcome", "")))
		total_defeated += int(row.get("defeated_enemies", 0))
		total_room_damage += int(row.get("room_damage", 0))
		total_piece_damage += int(row.get("piece_damage", 0))
		total_recovery_actions += int(row.get("recovery_actions_used", 0))
	return {"keep_id": keep_id, "keep_name": String(_keep_definitions.get(keep_id, {}).get("name", keep_id)), "scenario_id": scenario_id, "scenario_name": String(_scenario_definitions.get(scenario_id, {}).get("name", scenario_id)), "completed_waves": wave_history.size(), "wave_count": authored_wave_count(), "outcomes": outcomes, "total_defeated": total_defeated, "total_room_damage": total_room_damage, "total_piece_damage": total_piece_damage, "recovery_actions_used": total_recovery_actions, "final_outcome": last_outcome, "replay_key": "%s/%s/%d" % [scenario_id, commander_id, seed]}

func replay_mastery_summary() -> Dictionary:
	var pack_families: Array[String] = []
	var pack_names: Array[String] = []
	for pack_id_value in owned_packs:
		var pack_id: String = String(pack_id_value)
		var pack: Dictionary = _pack_definitions.get(pack_id, {})
		var family: String = String(pack.get("family", ""))
		if not family.is_empty() and not pack_families.has(family):
			pack_families.append(family)
		pack_names.append(String(pack.get("name", pack_id.replace("_", " ").capitalize())))
	pack_families.sort()
	pack_names.sort()
	var answer_families: Array[String] = pack_families.duplicate()
	for instance in pieces.values():
		var piece: Dictionary = _piece_definitions.get(String(instance.get("piece_id", "")), {})
		var category: String = String(piece.get("category", ""))
		if not category.is_empty() and not answer_families.has(category):
			answer_families.append(category)
	answer_families.sort()
	var doctrines: Array[String] = []
	if not wave_history.is_empty():
		for history_row in wave_history:
			doctrines.append(String(history_row.get("doctrine", "")))
	elif _scenario_definitions.has(scenario_id):
		for doctrine_id_value in _scenario_definitions[scenario_id].get("doctrines", []):
			doctrines.append(String(doctrine_id_value))
	var covered_phases: int = 0
	var phase_rows: Array[Dictionary] = []
	var uncovered_doctrines: Array[String] = []
	for doctrine_id in doctrines:
		var doctrine: Dictionary = _doctrine_definitions.get(doctrine_id, {})
		var matching_families: Array[String] = []
		for family in answer_families:
			if doctrine.get("counter_families", []).has(family):
				matching_families.append(family)
		var covered: bool = not matching_families.is_empty()
		if covered:
			covered_phases += 1
		elif not uncovered_doctrines.has(doctrine_id):
			uncovered_doctrines.append(doctrine_id)
		phase_rows.append({"doctrine": doctrine_id, "covered": covered, "matching_families": matching_families})
	var recovery_capacity: int = mini(wave_history.size(), maxi(0, authored_wave_count() - 1)) * 2
	var recovery_used: int = int(scenario_scorecard().get("recovery_actions_used", 0))
	var coverage_text: String = "%d/%d pressure phases matched by placed or opened defense families" % [covered_phases, doctrines.size()]
	var uncovered_names: Array[String] = []
	for doctrine_id in uncovered_doctrines:
		uncovered_names.append(String(_doctrine_definitions.get(doctrine_id, {}).get("name", doctrine_id.replace("_", " ").capitalize())))
	return {
		"variation": scenario_variation_preview(),
		"pack_names": pack_names,
		"pack_families": pack_families,
		"answer_families": answer_families,
		"phase_rows": phase_rows,
		"covered_phases": covered_phases,
		"phase_count": doctrines.size(),
		"coverage_text": coverage_text,
		"uncovered_doctrines": uncovered_doctrines,
		"uncovered_names": uncovered_names,
		"recovery_actions_used": recovery_used,
		"recovery_capacity": recovery_capacity,
		"recovery_text": "%d/%d available recovery actions committed" % [recovery_used, recovery_capacity],
	}

func scenario_report() -> Dictionary:
	var scorecard: Dictionary = scenario_scorecard()
	var wave_rows: Array[Dictionary] = []
	var held_waves: int = 0
	var breached_waves: int = 0
	for history_row in wave_history:
		var doctrine: String = String(history_row.get("doctrine", ""))
		var outcome: String = String(history_row.get("outcome", ""))
		if outcome == "held":
			held_waves += 1
		elif outcome == "partial_breach" or outcome == "collapse":
			breached_waves += 1
		wave_rows.append({
			"wave": int(history_row.get("wave", wave_rows.size() + 1)),
			"doctrine": doctrine,
			"principal_pressure": String(history_row.get("principal_pressure", _doctrine_definitions.get(doctrine, {}).get("principal_pressure", "Unknown pressure"))),
			"outcome": outcome,
			"defeated_enemies": int(history_row.get("defeated_enemies", 0)),
			"room_damage": int(history_row.get("room_damage", 0)),
			"piece_damage": int(history_row.get("piece_damage", 0)),
			"recovery_actions_used": int(history_row.get("recovery_actions_used", 0))
		})
	var surviving_pieces: int = 0
	var disabled_pieces: int = 0
	for piece in pieces.values():
		if bool(piece.get("disabled", false)) or int(piece.get("health", 0)) <= 0:
			disabled_pieces += 1
		else:
			surviving_pieces += 1
	var damaged_rooms: Array[Dictionary] = []
	for room_id in rooms.keys():
		var condition: int = room_condition(String(room_id))
		if condition < 100:
			damaged_rooms.append({"id": String(room_id), "condition": condition})
	for outer in range(damaged_rooms.size()):
		for inner in range(outer + 1, damaged_rooms.size()):
			var left: Dictionary = damaged_rooms[outer]
			var right: Dictionary = damaged_rooms[inner]
			if int(right.condition) < int(left.condition) or (int(right.condition) == int(left.condition) and String(right.id) < String(left.id)):
				damaged_rooms[outer] = right
				damaged_rooms[inner] = left
	var what_worked: Array[String] = []
	if held_waves > 0:
		what_worked.append("%d wave%s held without a room breach." % [held_waves, "" if held_waves == 1 else "s"])
	if int(scorecard.get("total_defeated", 0)) > 0:
		what_worked.append("Defenders stopped %d attacker%s." % [int(scorecard.total_defeated), "" if int(scorecard.total_defeated) == 1 else "s"])
	if int(scorecard.get("recovery_actions_used", 0)) > 0:
		what_worked.append("Recovery committed %d action%s to the next defense." % [int(scorecard.recovery_actions_used), "" if int(scorecard.recovery_actions_used) == 1 else "s"])
	if what_worked.is_empty():
		what_worked.append("The run produced a deterministic record that can be replayed with the same command sequence.")
	var what_failed: Array[String] = []
	if last_outcome == "collapse":
		if surviving_pieces == 0 and bool(_scenario_definitions.get(scenario_id, {}).get("collapse_on_defender_wipe", false)):
			what_failed.append("Every defender was disabled; this last stand ended immediately without a recovery interval.")
		else:
			what_failed.append("The final state collapsed because critical functions or morale reached the failure threshold.")
	elif breached_waves > 0:
		what_failed.append("%d wave%s broke the defensive line or breached a keep function." % [breached_waves, "" if breached_waves == 1 else "s"])
	if not damaged_rooms.is_empty():
		var weakest: Dictionary = damaged_rooms[0]
		what_failed.append("%s finished at %d%% condition." % [String(_room_definitions[String(weakest.id)].name), int(weakest.condition)])
	if disabled_pieces > 0:
		what_failed.append("%d defensive piece%s finished disabled." % [disabled_pieces, "" if disabled_pieces == 1 else "s"])
	if what_failed.is_empty():
		what_failed.append("No structural failure was recorded in the resolved waves.")
	var mastery: Dictionary = replay_mastery_summary()
	var suggested_experiment: String = "Replay with The Warden and preserve an open response lane."
	if last_outcome == "collapse":
		var terminal_defender_wipe: bool = surviving_pieces == 0 and bool(_scenario_definitions.get(scenario_id, {}).get("collapse_on_defender_wipe", false))
		suggested_experiment = "Replay with an additional independent fighting line so one focus target cannot erase the whole defense." if terminal_defender_wipe else "Replay the same seed and preserve one recovery action for the weakest critical function."
	elif room_condition("gate") < 100:
		suggested_experiment = "Assign Pike Squad to Gate and compare the Gate Assault result."
	elif room_condition("workshop") < 100 or room_condition("supply_room") < 100:
		suggested_experiment = "Protect the support chain with Field Engineers or an assigned Repair Station."
	elif room_condition("north_tower") < 100 or room_condition("old_chapel") < 100:
		suggested_experiment = "Preserve an upper response lane and test Scout Post coverage."
	elif commander_id == "warden":
		suggested_experiment = "Replay with The Castellan and compare a compact adjacent layout."
	if last_outcome == "held" and not mastery.get("uncovered_doctrines", []).is_empty():
		var uncovered_id: String = String(mastery.uncovered_doctrines[0])
		var uncovered: Dictionary = _doctrine_definitions.get(uncovered_id, {})
		var suggested_family: String = "another"
		for family_value in uncovered.get("counter_families", []):
			var family: String = String(family_value)
			if family != "commander_intervention" and not mastery.get("answer_families", []).has(family):
				suggested_family = family.replace("_", " ")
				break
		suggested_experiment = "Replay the same %s variation with a %s defense answer for %s." % [scenario_variation_id.replace("_", " "), suggested_family, String(uncovered.get("name", uncovered_id.replace("_", " ").capitalize()))]
	return {
		"scenario_id": scenario_id,
		"scenario_name": String(scorecard.get("scenario_name", scenario_id)),
		"commander_id": commander_id,
		"commander_name": String(_commander_definitions[commander_id].name),
		"status": "complete" if not has_next_wave() and not wave_active and active_event_id.is_empty() else "in_progress",
		"wave_rows": wave_rows,
		"final_state": {
			"morale": morale,
			"breach_level": breach_level,
			"materials": materials,
			"surviving_pieces": surviving_pieces,
			"disabled_pieces": disabled_pieces
		},
		"what_worked": what_worked,
		"what_failed": what_failed,
		"mastery": mastery,
		"suggested_experiment": suggested_experiment,
		"replay_key": String(scorecard.get("replay_key", "")),
		"event_history": event_history.duplicate(true),
		"regional_consequence": current_regional_consequence()
	}

func forecast() -> Dictionary:
	var doctrine: Dictionary = _doctrine_definitions.get(enemy_doctrine, {})
	var likely_target: String = String(doctrine.get("likely_target", "gate"))
	var uncertainty: String = String(doctrine.get("uncertainty", "secondary timing"))
	var scout_bonus: bool = _has_unit("scout_post", "upper") or _warden_signal_bonus()
	var forecast_enemy_ids: Array[String] = []
	if wave_active:
		for enemy in enemies:
			forecast_enemy_ids.append(String(enemy.get("enemy_id", "")))
	elif scenario_active and _scenario_definitions.has(scenario_id):
		var scenario_plans: Array = _scenario_definitions[scenario_id].get("wave_plans", [])
		if wave_index < scenario_plans.size():
			for enemy_id in scenario_plans[wave_index]:
				forecast_enemy_ids.append(String(enemy_id))
	else:
		for enemy_id in doctrine.get("composition", []):
			forecast_enemy_ids.append(String(enemy_id))
	var signal_disrupted: bool = false
	var signal_network_active: bool = false
	if wave_active:
		for enemy in enemies:
			var enemy_id: String = String(enemy.get("enemy_id", ""))
			var disruption: Variant = _enemy_definitions.get(enemy_id, {}).get("disruption_profile")
			if not disruption is Dictionary:
				continue
			if bool(enemy.get("signal_disrupted", false)):
				signal_disrupted = true
				likely_target = String(disruption.get("forecast_target", "obscured"))
				uncertainty = "signal smoke hides the target and advances contact by one step"
				break
			signal_network_active = true
	else:
		for enemy_id in forecast_enemy_ids:
			var disruption: Variant = _enemy_definitions.get(enemy_id, {}).get("disruption_profile")
			if not disruption is Dictionary:
				continue
			if _enemy_disruption_countered(enemy_id):
				signal_network_active = true
			else:
				signal_disrupted = true
				likely_target = String(disruption.get("forecast_target", "obscured"))
				uncertainty = "signal smoke hides the target and advances contact by one step"
				break
	if signal_disrupted:
		scout_bonus = false
	elif _has_assignment("scout_post", "north_tower"):
		uncertainty = "none: North Tower assignment reveals the landing room"
	var composition_revealed: bool = not equipped_modifier_id.is_empty() and String(_modifier_definitions.get(equipped_modifier_id, {}).get("effect", "")) == "reveal_wave_composition"
	var composition: Array[String] = []
	if composition_revealed:
		composition = forecast_enemy_ids.duplicate()
		if not signal_disrupted:
			uncertainty = "composition revealed by Roadside Intelligence; targets still respond to keep condition"
	return {"doctrine": enemy_doctrine, "question": doctrine.get("question", ""), "likely_target": likely_target, "uncertainty": uncertainty, "scout_bonus": scout_bonus, "exact_target_revealed": not signal_disrupted and _has_assignment("scout_post", "north_tower"), "signal_disrupted": signal_disrupted, "signal_network_active": signal_network_active, "composition_revealed": composition_revealed, "composition": composition}

func summary() -> Dictionary:
	return {
		"keep_id": keep_id,
		"keep": keep_definition(),
		"commander": _commander_definitions[commander_id].name,
		"commander_id": commander_id,
		"commander_passive": String(_commander_definitions[commander_id].passive),
		"commander_ability_name": String(_commander_definitions[commander_id].ability_name),
		"commander_ability_text": String(_commander_definitions[commander_id].ability_text),
		"commander_limitation": String(_commander_definitions[commander_id].limitation),
		"scenario_id": scenario_id,
		"scenario_active": scenario_active,
		"scenario": scenario_preview(),
		"authored_wave_count": authored_wave_count(),
		"has_next_wave": has_next_wave(),
		"scenario_variation_id": scenario_variation_id,
		"variation_target_room": variation_target_room,
		"variation_materials": variation_materials,
		"variation_morale": variation_morale,
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
		"repair_interval_active": repair_interval_active,
		"repair_actions_remaining": repair_actions_remaining,
		"repair_interval_reason": repair_interval_reason,
		"assigned_rooms": assigned_rooms.duplicate(),
		"available_pieces": available_pieces.duplicate(),
		"pack_openings_this_preparation": pack_openings_this_preparation,
		"combat_metrics": combat_metrics.duplicate(),
		"forecast": forecast(),
		"rooms": rooms.duplicate(true),
		"pieces": pieces.duplicate(true),
		"enemies": enemies.duplicate(true),
		"wave_history": wave_history.duplicate(true),
		"active_event": current_event(),
		"resolved_event_ids": resolved_event_ids.duplicate(),
		"event_history": event_history.duplicate(true),
		"unlocked_modifier_ids": unlocked_modifier_ids.duplicate(),
		"equipped_modifier_id": equipped_modifier_id,
		"regional_consequence": regional_consequence(),
		"recovery_advice": recovery_advice(),
		"scenario_scorecard": scenario_scorecard()
	}

func serialize() -> Dictionary:
	return {
		"seed": seed,
		"keep_id": keep_id,
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
		"rally_pending": rally_pending,
		"rally_used": rally_used,
		"scenario_id": scenario_id,
		"scenario_active": scenario_active,
		"scenario_variation_id": scenario_variation_id,
		"variation_target_room": variation_target_room,
		"variation_materials": variation_materials,
		"variation_morale": variation_morale,
		"last_outcome": last_outcome,
		"repair_interval_active": repair_interval_active,
		"repair_actions_remaining": repair_actions_remaining,
		"repair_interval_reason": repair_interval_reason,
		"assigned_rooms": assigned_rooms.duplicate(),
		"available_pieces": available_pieces.duplicate(),
		"pack_openings_this_preparation": pack_openings_this_preparation,
		"reserved_pack_id": reserved_pack_id,
		"combat_metrics": combat_metrics.duplicate(),
		"wave_history": wave_history.duplicate(true),
		"active_event_id": active_event_id,
		"resolved_event_ids": resolved_event_ids.duplicate(),
		"event_flags": event_flags.duplicate(true),
		"event_history": event_history.duplicate(true),
		"unlocked_modifier_ids": unlocked_modifier_ids.duplicate(),
		"equipped_modifier_id": equipped_modifier_id,
		"regional_state": regional_state.duplicate(true),
		"schema_version": SAVE_SCHEMA_VERSION,
		"game_id": GAME_ID
	}

func _decode_origin(value: Variant) -> Vector2i:
	if value is Vector2i:
		return value
	if value is Array and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	if value is String:
		var cleaned: String = String(value).replace("Vector2i(", "").replace(")", "")
		var parts: PackedStringArray = cleaned.split(",")
		if parts.size() >= 2:
			return Vector2i(int(parts[0].strip_edges()), int(parts[1].strip_edges()))
	return Vector2i.ZERO

func _is_saved_number(value: Variant) -> bool:
	return value is int or value is float

func _is_valid_saved_origin(value: Variant) -> bool:
	if value is Vector2i:
		return true
	if value is Array:
		return value.size() >= 2 and _is_saved_number(value[0]) and _is_saved_number(value[1])
	if value is String:
		var cleaned: String = String(value).replace("Vector2i(", "").replace("(", "").replace(")", "")
		var parts: PackedStringArray = cleaned.split(",")
		return parts.size() == 2 and parts[0].strip_edges().is_valid_int() and parts[1].strip_edges().is_valid_int()
	return false

func _validate_saved_id_array(data: Dictionary, field_name: String, definitions: Dictionary) -> String:
	if not data.has(field_name):
		return ""
	if not data.get(field_name) is Array:
		return "save %s collection is malformed" % field_name.replace("_", " ")
	var seen: Array[String] = []
	for value in data.get(field_name, []):
		if not value is String or not definitions.has(String(value)):
			return "save %s contains an unknown ID" % field_name.replace("_", " ")
		if seen.has(String(value)):
			return "save %s contains duplicates" % field_name.replace("_", " ")
		seen.append(String(value))
	return ""

func _validate_saved_string_array(data: Dictionary, field_name: String) -> String:
	if not data.has(field_name):
		return ""
	if not data.get(field_name) is Array:
		return "save %s collection is malformed" % field_name.replace("_", " ")
	for value in data.get(field_name, []):
		if not value is String:
			return "save %s entry is malformed" % field_name.replace("_", " ")
	return ""

func _validate_saved_regional_state(value: Variant) -> String:
	if not value is Dictionary:
		return "save regional state is malformed"
	var state: Dictionary = value
	for field_name in ["settlement_id", "settlement_name", "settlement_status", "route_id", "route_name", "route_status", "consequence_id", "summary", "applied_to_scenario_id", "source_scenario_id", "source_keep_id", "source_replay_key"]:
		if not state.get(field_name) is String:
			return "save regional state %s is malformed" % String(field_name).replace("_", " ")
	if not state.get("pending_support") is bool or not _is_saved_number(state.get("next_run_materials")):
		return "save regional support state is malformed"
	var next_run_materials: int = int(state.get("next_run_materials", -1))
	if next_run_materials < 0 or next_run_materials > 5:
		return "save regional support materials are out of range"
	var region_id: String = String(state.get("settlement_id", ""))
	if not _region_definitions.has(region_id):
		return "save regional state references an unknown settlement"
	var region: Dictionary = _region_definitions[region_id]
	var route: Dictionary = region.get("route", {})
	if String(state.get("route_id", "")) != String(route.get("id", "")):
		return "save regional state references an unknown route"
	var consequence_id: String = String(state.get("consequence_id", ""))
	if consequence_id.is_empty():
		if next_run_materials != 0 or bool(state.get("pending_support", false)) or not String(state.get("applied_to_scenario_id", "")).is_empty():
			return "save empty regional consequence cannot carry support"
	else:
		var authored: Dictionary = {}
		for consequence in region.get("consequences", []):
			if String(consequence.get("id", "")) == consequence_id:
				authored = consequence
				break
		if authored.is_empty():
			return "save regional state references an unknown consequence"
		if String(state.get("settlement_status", "")) != String(authored.get("settlement_status", "")) or String(state.get("route_status", "")) != String(authored.get("route_status", "")) or int(state.get("next_run_materials", -1)) != int(authored.get("next_run_materials", -2)):
			return "save regional consequence does not match authored content"
	var source_scenario_id: String = String(state.get("source_scenario_id", ""))
	if not source_scenario_id.is_empty() and not _scenario_definitions.has(source_scenario_id):
		return "save regional state references an unknown source scenario"
	var source_keep_id: String = String(state.get("source_keep_id", ""))
	if not source_keep_id.is_empty() and not _keep_definitions.has(source_keep_id):
		return "save regional state references an unknown source keep"
	var applied_scenario_id: String = String(state.get("applied_to_scenario_id", ""))
	if not applied_scenario_id.is_empty() and not _scenario_definitions.has(applied_scenario_id):
		return "save regional state references an unknown applied scenario"
	if bool(state.get("pending_support", false)) and next_run_materials <= 0:
		return "save regional support cannot be pending without materials"
	if bool(state.get("pending_support", false)) and not applied_scenario_id.is_empty():
		return "save regional support cannot be pending and already applied"
	if next_run_materials > 0 and not bool(state.get("pending_support", false)) and applied_scenario_id.is_empty():
		return "save regional support must be pending or applied"
	return ""

func _validate_serialized_payload(data: Dictionary) -> String:
	for field_name in ["seed", "materials", "command_points", "morale", "variation_materials", "variation_morale", "wave_index", "wave_progress", "battle_step", "battle_clock", "breach_level", "pack_openings_this_preparation", "repair_actions_remaining"]:
		if data.has(field_name) and not _is_saved_number(data.get(field_name)):
			return "save %s value is malformed" % String(field_name).replace("_", " ")
	for field_name in ["scenario_active", "wave_active", "lockdown_pending", "lockdown_used", "rally_pending", "rally_used", "repair_interval_active"]:
		if data.has(field_name) and not data.get(field_name) is bool:
			return "save %s value is malformed" % String(field_name).replace("_", " ")
	for field_name in ["commander_id", "keep_id", "scenario_id", "scenario_variation_id", "variation_target_room", "enemy_doctrine", "last_outcome", "repair_interval_reason", "reserved_pack_id"]:
		if data.has(field_name) and not data.get(field_name) is String:
			return "save %s value is malformed" % String(field_name).replace("_", " ")
	var saved_commander_id: String = String(data.get("commander_id", ACTIVE_COMMANDER))
	if not _commander_definitions.has(saved_commander_id):
		return "save contains an unknown commander"
	var saved_scenario_id: String = String(data.get("scenario_id", scenario_id))
	if not _scenario_definitions.has(saved_scenario_id):
		return "save contains an unknown scenario"
	var expected_keep_id: String = String(_scenario_definitions[saved_scenario_id].get("keep_id", "greywatch_keep"))
	var saved_keep_id: String = String(data.get("keep_id", expected_keep_id))
	if not _keep_definitions.has(saved_keep_id) or saved_keep_id != expected_keep_id:
		return "save keep does not match its scenario"
	var saved_room_definitions: Dictionary = _room_definitions_for_scenario(saved_scenario_id)
	var saved_doctrine_id: String = String(data.get("enemy_doctrine", enemy_doctrine))
	if not _doctrine_definitions.has(saved_doctrine_id):
		return "save contains an unknown invasion doctrine"
	var saved_outcome: String = String(data.get("last_outcome", ""))
	if not saved_outcome.is_empty() and not ["held", "partial_breach", "collapse"].has(saved_outcome):
		return "save contains an unknown outcome"
	var saved_variation_target: String = String(data.get("variation_target_room", ""))
	if not saved_variation_target.is_empty() and not saved_room_definitions.has(saved_variation_target):
		return "save variation target room is unknown"
	var saved_reserved_pack: String = String(data.get("reserved_pack_id", ""))
	if not saved_reserved_pack.is_empty() and not _pack_definitions.has(saved_reserved_pack):
		return "save reserved pack is unknown"
	for validation in [
		_validate_saved_id_array(data, "owned_packs", _pack_definitions),
		_validate_saved_id_array(data, "offered_packs", _pack_definitions),
		_validate_saved_id_array(data, "available_pieces", _piece_definitions),
		_validate_saved_string_array(data, "log"),
		_validate_saved_string_array(data, "battle_report"),
	]:
		if not String(validation).is_empty():
			return String(validation)
	if data.has("regional_state"):
		var regional_error: String = _validate_saved_regional_state(data.get("regional_state"))
		if not regional_error.is_empty():
			return regional_error
	if data.has("pieces") and not data.get("pieces") is Dictionary:
		return "save pieces collection is malformed"
	var saved_pieces: Dictionary = data.get("pieces", {})
	for instance_id_value in saved_pieces.keys():
		if not instance_id_value is String or String(instance_id_value).is_empty():
			return "save piece instance ID is malformed"
		var instance_value: Variant = saved_pieces[instance_id_value]
		if not instance_value is Dictionary:
			return "save piece entry is malformed"
		var instance: Dictionary = instance_value
		var piece_id_value: Variant = instance.get("piece_id", "")
		if not piece_id_value is String or not _piece_definitions.has(String(piece_id_value)):
			return "save contains an unknown piece"
		if instance.has("origin") and not _is_valid_saved_origin(instance.get("origin")):
			return "save piece origin is malformed"
		if instance.has("floor") and (not instance.get("floor") is String or not FLOORS.has(String(instance.get("floor")))):
			return "save piece floor is malformed"
		if instance.has("assignment"):
			if not instance.get("assignment") is String:
				return "save piece assignment is malformed"
			var assignment: String = String(instance.get("assignment"))
			if not assignment.is_empty() and not saved_room_definitions.has(assignment):
				return "save piece assignment room is unknown"
		for field_name in ["max_health", "health", "condition", "attack_cooldown", "attacks", "damage_dealt", "targets_stopped", "max_ammo", "ammo"]:
			if instance.has(field_name) and not _is_saved_number(instance.get(field_name)):
				return "save piece %s is malformed" % String(field_name).replace("_", " ")
		for field_name in ["disabled", "supply_spent"]:
			if instance.has(field_name) and not instance.get(field_name) is bool:
				return "save piece %s is malformed" % String(field_name).replace("_", " ")
		for field_name in ["last_target", "placement_zone"]:
			if instance.has(field_name) and not instance.get(field_name) is String:
				return "save piece %s is malformed" % String(field_name).replace("_", " ")
	if data.has("rooms"):
		if not data.get("rooms") is Dictionary:
			return "save rooms collection is malformed"
		var saved_rooms: Dictionary = data.get("rooms", {})
		for room_id in saved_room_definitions.keys():
			if not saved_rooms.has(room_id):
				return "save rooms collection is incomplete"
		for room_id_value in saved_rooms.keys():
			if not room_id_value is String or not saved_room_definitions.has(String(room_id_value)):
				return "save contains an unknown room"
			var room_value: Variant = saved_rooms[room_id_value]
			if not room_value is Dictionary:
				return "save room entry is malformed"
			if room_value.has("condition") and not _is_saved_number(room_value.get("condition")):
				return "save room condition is malformed"
			if room_value.has("state") and not room_value.get("state") is String:
				return "save room state is malformed"
	if data.has("enemies"):
		if not data.get("enemies") is Array:
			return "save enemies collection is malformed"
		for enemy_value in data.get("enemies", []):
			if not enemy_value is Dictionary:
				return "save enemy entry is malformed"
			var enemy: Dictionary = enemy_value
			var enemy_id_value: Variant = enemy.get("enemy_id", "")
			if not enemy_id_value is String or not _enemy_definitions.has(String(enemy_id_value)):
				return "save contains an unknown enemy"
			for field_name in ["max_health", "hp", "damage", "arrival_step", "slot", "attacks_received", "damage_taken"]:
				if enemy.has(field_name) and not _is_saved_number(enemy.get(field_name)):
					return "save enemy %s is malformed" % String(field_name).replace("_", " ")
			for field_name in ["signal_disrupted", "defeated"]:
				if enemy.has(field_name) and not enemy.get(field_name) is bool:
					return "save enemy %s is malformed" % String(field_name).replace("_", " ")
			if enemy.has("target"):
				if not enemy.get("target") is String:
					return "save enemy target is malformed"
				var target: String = String(enemy.get("target"))
				if not target.is_empty() and not saved_room_definitions.has(target) and not saved_pieces.has(target):
					return "save enemy target is unknown"
	if data.has("assigned_rooms"):
		if not data.get("assigned_rooms") is Dictionary:
			return "save assigned rooms collection is malformed"
		var saved_assignments: Dictionary = data.get("assigned_rooms", {})
		var assigned_instances: Array[String] = []
		for room_id_value in saved_assignments.keys():
			if not room_id_value is String or not saved_room_definitions.has(String(room_id_value)):
				return "save assignment room is unknown"
			var instance_id_value: Variant = saved_assignments[room_id_value]
			if not instance_id_value is String or not saved_pieces.has(String(instance_id_value)):
				return "save assignment piece is unknown"
			if assigned_instances.has(String(instance_id_value)):
				return "save assignment piece is duplicated"
			assigned_instances.append(String(instance_id_value))
			if String(saved_pieces[String(instance_id_value)].get("assignment", "")) != String(room_id_value):
				return "save assignment mapping is inconsistent"
	if data.has("combat_metrics"):
		if not data.get("combat_metrics") is Dictionary:
			return "save combat metrics collection is malformed"
		for metric_value in data.get("combat_metrics", {}).values():
			if not _is_saved_number(metric_value):
				return "save combat metric is malformed"
	if data.has("wave_history"):
		if not data.get("wave_history") is Array:
			return "save wave history collection is malformed"
		for history_value in data.get("wave_history", []):
			if not history_value is Dictionary:
				return "save wave history entry is malformed"
			var history: Dictionary = history_value
			if history.has("doctrine") and (not history.get("doctrine") is String or not _doctrine_definitions.has(String(history.get("doctrine")))):
				return "save wave history doctrine is unknown"
			if history.has("outcome") and (not history.get("outcome") is String or not ["held", "partial_breach", "collapse"].has(String(history.get("outcome")))):
				return "save wave history outcome is malformed"
			for field_name in ["wave", "breach_level", "morale_after", "defeated_enemies", "room_damage", "piece_damage", "ammo_spent", "enemy_attacks", "recovery_actions_used"]:
				if history.has(field_name) and not _is_saved_number(history.get(field_name)):
					return "save wave history %s is malformed" % String(field_name).replace("_", " ")
	return ""

func load_serialized(data: Dictionary) -> Dictionary:
	if data.is_empty():
		return {"ok": false, "reason": "save payload is empty"}
	var schema_version: int = int(data.get("schema_version", 1))
	if schema_version > SAVE_SCHEMA_VERSION:
		return {"ok": false, "reason": "save was created by a newer schema (%d)" % schema_version}
	var game_id: String = String(data.get("game_id", GAME_ID))
	if game_id != GAME_ID:
		return {"ok": false, "reason": "save belongs to another game"}
	var validation_error: String = _validate_serialized_payload(data)
	if not validation_error.is_empty():
		return {"ok": false, "reason": validation_error}
	if data.has("pieces") and not (data.get("pieces") is Dictionary):
		return {"ok": false, "reason": "save pieces collection is malformed"}
	if data.has("rooms") and not (data.get("rooms") is Dictionary):
		return {"ok": false, "reason": "save rooms collection is malformed"}
	if data.has("enemies") and not (data.get("enemies") is Array):
		return {"ok": false, "reason": "save enemies collection is malformed"}
	if data.has("active_event_id") and not data.get("active_event_id") is String:
		return {"ok": false, "reason": "save active event id is malformed"}
	var saved_active_event: String = String(data.get("active_event_id", ""))
	if not saved_active_event.is_empty() and not _event_definitions.has(saved_active_event):
		return {"ok": false, "reason": "save contains an unknown active event"}
	var saved_scenario_id: String = String(data.get("scenario_id", scenario_id))
	if not saved_active_event.is_empty() and String(_event_definitions[saved_active_event].get("scenario", "")) != saved_scenario_id:
		return {"ok": false, "reason": "save active event does not belong to its scenario"}
	if data.has("resolved_event_ids") and not data.get("resolved_event_ids") is Array:
		return {"ok": false, "reason": "save resolved event list is malformed"}
	var saved_resolved_events: Array[String] = []
	for event_id_value in data.get("resolved_event_ids", []):
		if not event_id_value is String or not _event_definitions.has(String(event_id_value)):
			return {"ok": false, "reason": "save contains an unknown resolved event"}
		if saved_resolved_events.has(String(event_id_value)):
			return {"ok": false, "reason": "save resolved event list contains duplicates"}
		saved_resolved_events.append(String(event_id_value))
	if data.has("event_flags") and not data.get("event_flags") is Dictionary:
		return {"ok": false, "reason": "save event flags are malformed"}
	for flag_value in data.get("event_flags", {}).values():
		if not flag_value is bool:
			return {"ok": false, "reason": "save event flag value is malformed"}
	if data.has("event_history") and not data.get("event_history") is Array:
		return {"ok": false, "reason": "save event history is malformed"}
	for history_value in data.get("event_history", []):
		if not history_value is Dictionary:
			return {"ok": false, "reason": "save event history entry is malformed"}
		var history_event_id: String = String(history_value.get("event_id", ""))
		var history_choice_id: String = String(history_value.get("choice_id", ""))
		if not _event_definitions.has(history_event_id) or _event_choice(_event_definitions[history_event_id], history_choice_id).is_empty():
			return {"ok": false, "reason": "save event history reference is malformed"}
	if not saved_active_event.is_empty() and saved_resolved_events.has(saved_active_event):
		return {"ok": false, "reason": "save event cannot be active and resolved"}
	if data.has("unlocked_modifier_ids") and not data.get("unlocked_modifier_ids") is Array:
		return {"ok": false, "reason": "save unlocked modifier list is malformed"}
	var saved_unlocked_modifiers: Array[String] = []
	for modifier_id_value in data.get("unlocked_modifier_ids", []):
		if not modifier_id_value is String or not _modifier_definitions.has(String(modifier_id_value)):
			return {"ok": false, "reason": "save contains an unknown unlocked modifier"}
		if saved_unlocked_modifiers.has(String(modifier_id_value)):
			return {"ok": false, "reason": "save unlocked modifier list contains duplicates"}
		saved_unlocked_modifiers.append(String(modifier_id_value))
	if data.has("equipped_modifier_id") and not data.get("equipped_modifier_id") is String:
		return {"ok": false, "reason": "save equipped modifier id is malformed"}
	var saved_equipped_modifier: String = String(data.get("equipped_modifier_id", ""))
	if not saved_equipped_modifier.is_empty() and (not _modifier_definitions.has(saved_equipped_modifier) or not saved_unlocked_modifiers.has(saved_equipped_modifier)):
		return {"ok": false, "reason": "save equipped modifier is not unlocked"}
	seed = int(data.get("seed", seed))
	commander_id = String(data.get("commander_id", ACTIVE_COMMANDER))
	if not _commander_definitions.has(commander_id):
		return {"ok": false, "reason": "save contains an unknown commander"}
	scenario_id = String(data.get("scenario_id", scenario_id))
	if not _scenario_definitions.has(scenario_id):
		return {"ok": false, "reason": "save contains an unknown scenario"}
	_activate_keep(String(_scenario_definitions[scenario_id].get("keep_id", "greywatch_keep")))
	scenario_active = bool(data.get("scenario_active", scenario_active))
	scenario_variation_id = String(data.get("scenario_variation_id", scenario_variation_id))
	variation_target_room = String(data.get("variation_target_room", variation_target_room))
	variation_materials = int(data.get("variation_materials", variation_materials))
	variation_morale = int(data.get("variation_morale", variation_morale))
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
	for instance_id in pieces.keys():
		pieces[instance_id].origin = _decode_origin(pieces[instance_id].get("origin", Vector2i.ZERO))
	owned_packs.clear()
	for pack_id in data.get("owned_packs", []):
		owned_packs.append(String(pack_id))
	offered_packs.clear()
	for pack_id in data.get("offered_packs", offered_packs):
		offered_packs.append(String(pack_id))
	available_pieces.clear()
	for piece_id in data.get("available_pieces", STARTER_PIECES):
		available_pieces.append(String(piece_id))
	if not data.has("available_pieces"):
		_rebuild_available_pieces()
	pack_openings_this_preparation = int(data.get("pack_openings_this_preparation", pack_openings_this_preparation))
	reserved_pack_id = String(data.get("reserved_pack_id", reserved_pack_id))
	if not reserved_pack_id.is_empty() and not _pack_definitions.has(reserved_pack_id):
		reserved_pack_id = ""
	enemies.clear()
	for enemy_data in data.get("enemies", []):
		if enemy_data is Dictionary:
			enemies.append(enemy_data.duplicate(true))
	rooms = data.get("rooms", rooms).duplicate(true)
	log.clear()
	for log_entry in data.get("log", []):
		if log_entry is String:
			log.append(String(log_entry))
	battle_report.clear()
	for report_entry in data.get("battle_report", []):
		if report_entry is String:
			battle_report.append(String(report_entry))
	lockdown_pending = bool(data.get("lockdown_pending", lockdown_pending))
	lockdown_used = bool(data.get("lockdown_used", lockdown_used))
	rally_pending = bool(data.get("rally_pending", rally_pending))
	rally_used = bool(data.get("rally_used", rally_used))
	last_outcome = String(data.get("last_outcome", last_outcome))
	combat_metrics = data.get("combat_metrics", combat_metrics).duplicate()
	wave_history.clear()
	for history_entry in data.get("wave_history", []):
		if history_entry is Dictionary:
			wave_history.append(history_entry.duplicate(true))
	active_event_id = saved_active_event
	resolved_event_ids.clear()
	for event_id_value in data.get("resolved_event_ids", []):
		resolved_event_ids.append(String(event_id_value))
	event_flags = data.get("event_flags", {}).duplicate(true)
	event_history.clear()
	for history_entry in data.get("event_history", []):
		if history_entry is Dictionary:
			event_history.append(history_entry.duplicate(true))
	unlocked_modifier_ids = saved_unlocked_modifiers
	equipped_modifier_id = saved_equipped_modifier
	regional_state = data.get("regional_state", _default_regional_state()).duplicate(true)
	if combat_metrics.is_empty():
		_reset_combat_metrics()
	repair_interval_active = bool(data.get("repair_interval_active", repair_interval_active))
	repair_actions_remaining = int(data.get("repair_actions_remaining", repair_actions_remaining))
	repair_interval_reason = String(data.get("repair_interval_reason", repair_interval_reason))
	assigned_rooms = data.get("assigned_rooms", {}).duplicate()
	for instance_id in pieces.keys():
		var piece_id: String = String(pieces[instance_id].get("piece_id", ""))
		if not _piece_definitions.has(piece_id):
			continue
		var max_health: int = int(_piece_definitions[piece_id].get("max_health", 10))
		pieces[instance_id].max_health = int(pieces[instance_id].get("max_health", max_health))
		pieces[instance_id].health = int(pieces[instance_id].get("health", roundf(float(pieces[instance_id].get("condition", 1.0)) * float(pieces[instance_id].max_health))))
		pieces[instance_id].condition = float(pieces[instance_id].health) / float(pieces[instance_id].max_health)
		pieces[instance_id].disabled = bool(pieces[instance_id].get("disabled", pieces[instance_id].health <= 0))
		pieces[instance_id].placement_zone = String(pieces[instance_id].get("placement_zone", placement_zone(pieces[instance_id].get("origin", Vector2i.ZERO), String(pieces[instance_id].get("floor", "ground")), _piece_definitions[piece_id].get("size", Vector2i.ONE))))
		var max_ammo: int = int(_piece_definitions[piece_id].get("max_ammo", 0))
		pieces[instance_id].max_ammo = max_ammo
		pieces[instance_id].ammo = clampi(int(pieces[instance_id].get("ammo", max_ammo)), 0, max_ammo)
	if assigned_rooms.is_empty():
		for instance_id in pieces.keys():
			var assignment: String = String(pieces[instance_id].get("assignment", ""))
			if not assignment.is_empty():
				assigned_rooms[assignment] = instance_id
	if schema_version < 3:
		_migrate_legacy_event_state()
	if schema_version < 4:
		unlocked_modifier_ids.clear()
		equipped_modifier_id = ""
	_refresh_active_event()
	return {"ok": true, "message": "Save loaded.", "schema_version": schema_version, "legacy": not data.has("schema_version"), "migrated": schema_version < SAVE_SCHEMA_VERSION}

func _migrate_legacy_event_state() -> void:
	active_event_id = ""
	resolved_event_ids.clear()
	event_flags.clear()
	event_history.clear()
	if not scenario_active or not _scenario_definitions.has(scenario_id):
		return
	for event_id_value in _scenario_definitions[scenario_id].get("event_chain", []):
		var event_id: String = String(event_id_value)
		if not _event_definitions.has(event_id):
			continue
		var trigger_wave: int = int(_event_definitions[event_id].get("trigger", {}).get("wave", 0))
		if trigger_wave < wave_index:
			resolved_event_ids.append(event_id)
