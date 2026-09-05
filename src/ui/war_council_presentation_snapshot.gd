class_name WarCouncilPresentationSnapshot
extends RefCounted

static func build(keep: Object, commander_id: String, scenario_id: String, tutorial_active: bool, guided_setup: bool) -> Dictionary:
	if keep == null:
		return {}
	var commander_definition: Dictionary = keep.commander_definition(commander_id)
	var commander_ids: Array[String] = keep.commander_ids()
	var scenario_definition: Dictionary = keep.scenario_definition(scenario_id)
	var scenario_preview: Dictionary = keep.scenario_preview(scenario_id)
	var keep_definition: Dictionary = keep.keep_definition(String(scenario_definition.get("keep_id", "")))
	var geometry_fit: Dictionary = _geometry_fit(keep_definition, commander_id)
	var variation: Dictionary = scenario_preview.get("variation", {})
	var modifier_name: String = "None"
	if not keep.equipped_modifier_id.is_empty():
		modifier_name = String(keep.modifier_definition(keep.equipped_modifier_id).get("name", keep.equipped_modifier_id))
	var collapse_rule: bool = bool(scenario_preview.get("collapse_on_defender_wipe", false))
	var end_state_summary: String = "a routed garrison ends the defense" if collapse_rule else "a routed garrison can regroup"
	var setup_mode: String = "FIRST WATCH" if tutorial_active else "GUIDED DEFENSE" if guided_setup else "SKIRMISH"
	var modifier_summary: String = "" if modifier_name == "None" else " · %s" % modifier_name
	var preparation_focus: String = _concise_focus(String(variation.get("preparation_focus", "Read the first forecast before placing the defense.")))
	var recommended_pack_name: String = String(keep.pack_definition(String(geometry_fit.get("recommended_pack_id", ""))).get("name", "Any coherent pack"))
	return {
		"run_frame": "%s%s · %s · %s" % [setup_mode, modifier_summary, String(scenario_preview.get("difficulty", "standard")).to_upper(), end_state_summary],
		"pairing": "%s leads %s at %s." % [String(commander_definition.get("name", commander_id)), String(scenario_preview.get("name", scenario_id)), String(scenario_preview.get("keep_name", "the keep"))],
		"seed_pressure": _seed_pressure(keep, variation),
		"preparation_focus": preparation_focus,
		"locked": tutorial_active,
		"commander": {
			"index": commander_ids.find(commander_id) + 1,
			"count": commander_ids.size(),
			"name": String(commander_definition.get("name", commander_id)),
			"identity": String(commander_definition.get("short_role", "Choose a strategic lens.")),
			"strength": String(commander_definition.get("passive", "")),
			"ability_name": String(commander_definition.get("ability_name", "Ability")),
			"ability": String(commander_definition.get("ability_text", "")),
			"limitation": String(commander_definition.get("limitation", "")),
			"question": String(commander_definition.get("question", "")),
		},
		"scenario": {
			"index": int(scenario_preview.get("catalog_index", 0)),
			"count": int(scenario_preview.get("catalog_count", 0)),
			"difficulty": String(scenario_preview.get("difficulty", "standard")),
			"name": String(scenario_preview.get("name", scenario_id)),
			"keep": String(scenario_preview.get("keep_name", "Keep")),
			"identity": String(scenario_definition.get("short_role", "Known pressure")),
			"question": String(scenario_definition.get("question", "What must this defense preserve?")),
			"geometry_rule": String(keep_definition.get("spatial_rule", {}).get("label", "Read the keep geometry.")),
			"geometry_fit": String(geometry_fit.get("fit", "Choose a doctrine that answers it.")),
			"opening": String(geometry_fit.get("opening", "Build one legible answer.")),
			"recommended_pack": recommended_pack_name,
			"accepted_risk": String(geometry_fit.get("risk", "Another route remains exposed.")),
			"geometry": "%s %s" % [String(keep_definition.get("spatial_rule", {}).get("label", "Read the keep geometry.")), String(geometry_fit.get("fit", "Choose a doctrine that answers it."))],
			"geometry_opening": "%s Recommended pack: %s. Accepted risk: %s" % [String(geometry_fit.get("opening", "Build one legible answer.")), recommended_pack_name, String(geometry_fit.get("risk", "Another route remains exposed."))],
			"objective": String(scenario_preview.get("objective", "")),
			"arc": " → ".join(scenario_preview.get("doctrine_names", [])),
			"peak_pressure": int(scenario_preview.get("peak_wave_size", 0)),
			"wave_count": int(scenario_preview.get("wave_count", 0)),
			"collapse_rule": collapse_rule,
			"risk": "%s; peak pressure %d; %s." % [String(scenario_preview.get("difficulty", "standard")).capitalize(), int(scenario_preview.get("peak_wave_size", 0)), end_state_summary],
			"fixed": "%s, %d assault phases; this opening pressure will not change mid-run." % [String(scenario_preview.get("keep_name", "Keep")), int(scenario_preview.get("wave_count", 0))],
		},
	}

static func _geometry_fit(keep_definition: Dictionary, commander_id: String) -> Dictionary:
	for row_value in keep_definition.get("doctrine_geometry", []):
		var row: Dictionary = row_value
		if String(row.get("commander_id", "")) == commander_id:
			return row
	return {}

static func _seed_pressure(keep: Object, variation: Dictionary) -> String:
	var parts: Array[String] = []
	var material_delta: int = int(variation.get("materials", 0))
	var morale_delta: int = int(variation.get("morale", 0))
	if material_delta != 0:
		parts.append("%+d materials" % material_delta)
	if morale_delta != 0:
		parts.append("%+d morale" % morale_delta)
	var counts: Dictionary = {}
	var order: Array[String] = []
	for enemy_id_value in variation.get("final_wave_plan", []):
		var enemy_id: String = String(enemy_id_value)
		if not counts.has(enemy_id):
			counts[enemy_id] = 0
			order.append(enemy_id)
		counts[enemy_id] = int(counts[enemy_id]) + 1
	if not order.is_empty():
		var composition: Array[String] = []
		for enemy_id in order:
			composition.append("%d %s" % [int(counts[enemy_id]), String(keep.enemy_definition(enemy_id).get("name", enemy_id))])
		parts.append("final pressure %s" % " + ".join(composition))
	if parts.is_empty():
		parts.append("usual stores and familiar pressure")
	return "%s: %s." % [String(variation.get("label", variation.get("id", "standard_bell").replace("_", " ").capitalize())), "; ".join(parts)]

static func _concise_focus(value: String) -> String:
	var focus: String = value.strip_edges()
	var detail_separator: int = focus.find(";")
	if detail_separator > 0:
		focus = focus.left(detail_separator)
	if focus.is_empty():
		return "Read the first forecast before placing the defense."
	return focus if focus.ends_with(".") else "%s." % focus
