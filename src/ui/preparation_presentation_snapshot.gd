class_name PreparationPresentationSnapshot
extends RefCounted

static func build(keep: Object, pack_id: String, pack_index: int, pack_count: int, tutorial_active: bool, tutorial_expected_action: String) -> Dictionary:
	if keep == null:
		return {}
	return {
		"pack_offer": _pack_offer(keep, pack_id, pack_index, pack_count, tutorial_active, tutorial_expected_action),
		"brief": _brief(keep),
		"layout_lens_text": _layout_lens_text(keep),
	}

static func _pack_offer(keep: Object, pack_id: String, pack_index: int, pack_count: int, tutorial_active: bool, tutorial_expected_action: String) -> Dictionary:
	var preview: Dictionary = keep.pack_preview(pack_id)
	if not bool(preview.get("ok", false)):
		return {"ok": false, "error_text": "PACK PREVIEW — %s" % String(preview.get("reason", "unavailable")), "selection_locked": tutorial_active}
	var pieces: Array[String] = []
	for piece in preview.get("pieces", []):
		pieces.append("%s (%d)" % [String(piece.get("name", "")), int(piece.get("cost", 0))])
	var definition: Dictionary = keep.pack_definition(pack_id)
	var demand: Dictionary = definition.get("spatial_demand", {})
	var floors: Array[String] = []
	for floor_id in demand.get("preferred_floors", []):
		floors.append(String(floor_id).capitalize())
	var zones: Array[String] = []
	for zone_id in demand.get("preferred_zones", []):
		zones.append(String(zone_id).capitalize())
	var space: String = "%s floor; %s" % ["/".join(floors), "/".join(zones)]
	space += "; open lane" if bool(demand.get("needs_open_lane", false)) else "; compact footprint"
	space += "; adjacency" if bool(demand.get("needs_adjacency", false)) else ""
	var owned: bool = bool(preview.get("owned", false))
	var reserved: bool = bool(preview.get("reserved", false))
	var openings: int = int(preview.get("openings_remaining", 0))
	var enough_materials: bool = int(preview.get("materials", 0)) >= int(preview.get("cost", 0))
	var tutorial_open: bool = not tutorial_active or (tutorial_expected_action in ["open_pack", "open_pack:pike_line"] and pack_id == "pike_line")
	var can_open: bool = not owned and openings > 0 and enough_materials and not keep.wave_active and not keep.repair_interval_active and tutorial_open
	var state: String = "OPENED" if owned else "RESERVED" if reserved else "NO OPENINGS" if openings <= 0 else "NEEDS MATERIALS" if not enough_materials else "AVAILABLE"
	var open_reason: String = "Open this doctrine and grant its pieces."
	if owned:
		open_reason = "This pack is already part of the keep."
	elif openings <= 0:
		open_reason = "This Preparation has no pack openings remaining."
	elif not enough_materials:
		open_reason = "Not enough materials to open this pack."
	elif not tutorial_open:
		open_reason = "First Watch opens Pike Line only when the lesson reaches that step."
	return {
		"ok": true,
		"index": pack_index + 1,
		"count": pack_count,
		"openings": openings,
		"materials": int(preview.get("materials", 0)),
		"state": state,
		"name": String(preview.get("name", pack_id)),
		"role": String(definition.get("short_role", "")),
		"question": String(preview.get("question", "")),
		"doctrine": String(preview.get("doctrine", "")).replace("_", " ").capitalize(),
		"cost": int(preview.get("cost", 0)),
		"pieces": ", ".join(pieces),
		"strength": String(preview.get("solves", "")),
		"weakness": String(preview.get("asks", "")),
		"space": space,
		"choice": String(preview.get("preview", "")),
		"owned": owned,
		"reserved": reserved,
		"selection_locked": tutorial_active,
		"can_open": can_open,
		"can_reserve": not tutorial_active and not owned and not keep.wave_active and not keep.repair_interval_active,
		"open_reason": open_reason,
		"reserve_reason": "Clear this reserve." if reserved else "Hold this offer for the next Preparation without granting its pieces.",
	}

static func _brief(keep: Object) -> Dictionary:
	var forecast: Dictionary = keep.forecast()
	var scenario: Dictionary = keep.scenario_preview()
	var summary: Dictionary = keep.layout_summary()
	var counts: Dictionary = summary.get("counts", {})
	var doctrine_name: String = String(forecast.get("doctrine", "next pressure")).replace("_", " ").capitalize()
	var question: String = "%s threatens %s. %s" % [doctrine_name, String(forecast.get("likely_target", "the keep")), String(scenario.get("lesson", "Read the route before committing the defense."))]
	var answer: String
	if keep.pieces.is_empty():
		answer = "No defenders placed. Choose a pack and establish the first response line."
	else:
		var coverage: Array[String] = []
		if int(counts.get("ground", 0)) > 0:
			coverage.append("%d ground" % int(counts.get("ground", 0)))
		if int(counts.get("upper", 0)) > 0:
			coverage.append("%d upper" % int(counts.get("upper", 0)))
		if int(summary.get("support_piece_count", 0)) > 0:
			coverage.append("%d support" % int(summary.get("support_piece_count", 0)))
		if int(summary.get("assigned_specialist_count", 0)) > 0:
			coverage.append("%d assigned" % int(summary.get("assigned_specialist_count", 0)))
		var commander_answer: String = "%d room-edge connection(s)" % int(summary.get("room_edge_count", 0)) if keep.commander_id == "castellan" else "%d open response lane(s)" % int(summary.get("open_lane_count", 0))
		answer = "%s; %s. This is visible coverage, not a guaranteed hold." % [", ".join(coverage), commander_answer]
	var warnings: Array = summary.get("duplicate_role_warnings", [])
	var weakness: String = String(warnings[0]) if not warnings.is_empty() else "No immediate coverage warning; compare the layout against the forecast."
	return {"question": question, "answer": answer, "weakness": weakness}

static func _layout_lens_text(keep: Object) -> String:
	var summary: Dictionary = keep.layout_summary()
	var counts: Dictionary = summary.get("counts", {})
	var comparison: Dictionary = summary.get("commander_comparison", {})
	var castellan: Dictionary = comparison.get("castellan", {})
	var warden: Dictionary = comparison.get("warden", {})
	var warnings: Array[String] = []
	for warning in summary.get("duplicate_role_warnings", []):
		warnings.append(String(warning))
	var castellan_marker: String = "CURRENT" if keep.commander_id == "castellan" else "COMPARE"
	var warden_marker: String = "CURRENT" if keep.commander_id == "warden" else "COMPARE"
	var spatial_rule: Dictionary = summary.get("spatial_rule", {})
	var spatial_state: String = "ACTIVE" if bool(spatial_rule.get("active", false)) else "INACTIVE" if String(spatial_rule.get("id", "")) == "clear_causeway" else "BASELINE"
	return "LAYOUT SUMMARY — %s | Ground %d | Upper %d | Wall %d | Courtyard %d | Keep %d\nSpatial rule [%s] — %s\nCoverage — room edge %d | open lane %d | support %d | assigned %d\nCASTELLAN [%s] — %s Risk: %s\nWARDEN [%s] — %s Risk: %s\nWARNINGS — %s" % [String(summary.get("keep_name", keep.keep_id)), int(counts.get("ground", 0)), int(counts.get("upper", 0)), int(counts.get("wall", 0)), int(counts.get("courtyard", 0)), int(counts.get("keep", 0)), spatial_state, String(spatial_rule.get("label", "No special spatial rule.")), int(summary.get("room_edge_count", 0)), int(summary.get("open_lane_count", 0)), int(summary.get("support_piece_count", 0)), int(summary.get("assigned_specialist_count", 0)), castellan_marker, String(castellan.get("summary", "")), String(castellan.get("risk", "")), warden_marker, String(warden.get("summary", "")), String(warden.get("risk", "")), " | ".join(warnings)]
