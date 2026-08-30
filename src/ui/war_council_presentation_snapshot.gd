class_name WarCouncilPresentationSnapshot
extends RefCounted

static func build(keep: Object, commander_id: String, scenario_id: String, tutorial_active: bool, guided_setup: bool) -> Dictionary:
	if keep == null:
		return {}
	var commander_definition: Dictionary = keep.commander_definition(commander_id)
	var commander_ids: Array[String] = keep.commander_ids()
	var scenario_definition: Dictionary = keep.scenario_definition(scenario_id)
	var scenario_preview: Dictionary = keep.scenario_preview(scenario_id)
	var modifier_name: String = "None"
	if not keep.equipped_modifier_id.is_empty():
		modifier_name = String(keep.modifier_definition(keep.equipped_modifier_id).get("name", keep.equipped_modifier_id))
	var collapse_rule: bool = bool(scenario_preview.get("collapse_on_defender_wipe", false))
	var end_state_summary: String = "defender wipe ends the run" if collapse_rule else "defender wipe is recoverable"
	var setup_mode: String = "FIRST WATCH" if tutorial_active else "GUIDED DEFENSE" if guided_setup else "SKIRMISH"
	return {
		"mode": setup_mode,
		"modifier": modifier_name,
		"risk_summary": "RISK — %s · %s" % [String(scenario_preview.get("difficulty", "standard")).to_upper(), end_state_summary],
		"commitment": "Entering fixes commander, keep, seeded variation, and the authored pressure order for this run.",
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
			"identity": String(scenario_definition.get("short_role", "Authored pressure")),
			"question": String(scenario_definition.get("question", "What must this defense preserve?")),
			"objective": String(scenario_preview.get("objective", "")),
			"arc": " → ".join(scenario_preview.get("doctrine_names", [])),
			"risk": "%s; peak pressure %d; %s." % [String(scenario_preview.get("difficulty", "standard")).capitalize(), int(scenario_preview.get("peak_wave_size", 0)), end_state_summary],
			"fixed": "%s, %d authored phases, variation %s." % [String(scenario_preview.get("keep_name", "Keep")), int(scenario_preview.get("wave_count", 0)), String(scenario_preview.get("variation_id", "standard_bell")).replace("_", " ")],
		},
	}
