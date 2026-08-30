class_name ResultsPresentationSnapshot
extends RefCounted

static func build(keep: Object, tutorial_active: bool, tutorial_failure_active: bool, tutorial_expected_action: String) -> Dictionary:
	if keep == null:
		return {}
	var report: Dictionary = keep.scenario_report()
	var final_state: Dictionary = report.get("final_state", {})
	var damaged_rooms: Array[Dictionary] = []
	for room_id_value in keep.rooms.keys():
		var room_id: String = String(room_id_value)
		var condition: int = keep.room_condition(room_id)
		if condition < 100:
			damaged_rooms.append({"id": room_id, "name": String(keep.room_definition(room_id).get("name", room_id)), "condition": condition, "state": keep.room_state(room_id)})
	damaged_rooms.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		if int(left.get("condition", 0)) == int(right.get("condition", 0)):
			return String(left.get("id", "")) < String(right.get("id", ""))
		return int(left.get("condition", 0)) < int(right.get("condition", 0))
	)
	var damaged_pieces: Array[Dictionary] = []
	for instance_id_value in keep.pieces.keys():
		var instance_id: String = String(instance_id_value)
		var piece: Dictionary = keep.pieces[instance_id]
		var health: int = int(piece.get("health", 0))
		var max_health: int = int(piece.get("max_health", 0))
		if health < max_health or bool(piece.get("disabled", false)):
			damaged_pieces.append({"id": instance_id, "name": String(keep.piece_definition(String(piece.get("piece_id", ""))).get("name", instance_id)), "health": health, "max_health": max_health, "disabled": bool(piece.get("disabled", false))})
	var consequence_rows: Array[String] = []
	var event_snapshot: Dictionary = keep.event_ledger_snapshot(5)
	for event_entry in event_snapshot.get("entries", []):
		consequence_rows.append("%s — %s" % [_event_ledger_name(event_entry), String(event_entry.get("visible_result", ""))])
	var regional_text: String = _regional_report_text(keep).strip_edges()
	if not regional_text.is_empty():
		consequence_rows.append(regional_text)
	var outcome: String = String(report.get("final_outcome", keep.last_outcome))
	var outcome_title: String = "DEFENSE COMPLETE"
	if outcome in ["held", "hold"]:
		outcome_title = "%s HOLDS" % String(keep.keep_definition().get("name", "THE KEEP")).to_upper()
	elif outcome == "partial_breach":
		outcome_title = "THE KEEP ENDURES"
	elif outcome == "collapse":
		outcome_title = "THE FORTRESS FALLS"
	var primary_label: String = "REVIEW SETUP — PLAY AGAIN"
	var primary_tooltip: String = "Return to the War Council and change the next defense."
	if tutorial_active and tutorial_failure_active:
		primary_label = "RETRY PHASE"
		primary_tooltip = "Restore the exact checkpoint at the start of this tutorial phase."
	elif tutorial_active and tutorial_expected_action == "finish_tutorial":
		primary_label = "COMPLETE FIRST WATCH"
		primary_tooltip = "Record First Watch as complete and return to the War Council."
	var what_worked: Array = report.get("what_worked", []).duplicate()
	var what_failed: Array = report.get("what_failed", []).duplicate()
	var held_reason: String = String(what_worked[0]) if not what_worked.is_empty() else "No single defensive advantage dominated the result."
	var failure_reason: String = String(what_failed[0]) if not what_failed.is_empty() else "No decisive structural failure was recorded."
	var mastery: Dictionary = report.get("mastery", {})
	var variation: Dictionary = mastery.get("variation", {})
	var pack_names: Array = mastery.get("pack_names", [])
	var packs_text: String = ", ".join(pack_names) if not pack_names.is_empty() else "starter defense only"
	var uncovered_names: Array = mastery.get("uncovered_names", [])
	var gap_text: String = "all authored pressure covered" if uncovered_names.is_empty() else "uncovered: %s" % ", ".join(uncovered_names)
	var mastery_summary: String = "SEED PRESSURE — %s\nDOCTRINE FIT — %s (%s)\nRECOVERY COMMITMENT — %s\nPACK PLAN — %s" % [String(variation.get("summary", "Baseline pressure.")), String(mastery.get("coverage_text", "Coverage unavailable")), gap_text, String(mastery.get("recovery_text", "No recovery interval recorded")), packs_text]
	return {
		"eyebrow": "FINAL DEFENSE · %d PHASES RESOLVED" % int(report.get("wave_rows", []).size()),
		"outcome": outcome,
		"outcome_title": outcome_title,
		"scenario_name": String(report.get("scenario_name", keep.scenario_id)),
		"commander_name": String(report.get("commander_name", keep.commander_id)),
		"morale": int(final_state.get("morale", 0)),
		"materials": int(final_state.get("materials", 0)),
		"surviving_pieces": int(final_state.get("surviving_pieces", 0)),
		"disabled_pieces": int(final_state.get("disabled_pieces", 0)),
		"breach_level": int(final_state.get("breach_level", 0)),
		"waves": report.get("wave_rows", []).duplicate(true),
		"causal_summary": "DECISIVE PATTERN — %s\nREMAINING COST — %s" % [held_reason, failure_reason],
		"mastery_summary": mastery_summary,
		"what_worked": what_worked,
		"what_failed": what_failed,
		"damaged_rooms": damaged_rooms,
		"damaged_pieces": damaged_pieces,
		"consequence_text": "CONSEQUENCES\n%s" % "\n".join(consequence_rows) if not consequence_rows.is_empty() else "",
		"replay_experiment": String(report.get("suggested_experiment", "Replay one changed decision.")),
		"primary_label": primary_label,
		"primary_tooltip": primary_tooltip,
		"primary_enabled": true,
		"show_save": not tutorial_active,
		"show_menu": not tutorial_active,
	}

static func _event_ledger_name(entry: Dictionary) -> String:
	var stable_name: String = String(entry.get("event_id", "event")).replace("_", " ").capitalize()
	var authored_title: String = String(entry.get("title", stable_name))
	return stable_name if authored_title == stable_name else "%s — %s" % [stable_name, authored_title]

static func _regional_report_text(keep: Object) -> String:
	var consequence: Dictionary = keep.current_regional_consequence()
	if consequence.is_empty():
		return "\nREGIONAL REPORT — resolves when this defense reaches a terminal state."
	if String(consequence.get("consequence_id", "")).is_empty():
		return "\nREGIONAL REPORT — Low Mill is waiting for a proven route."
	var support_materials: int = int(consequence.get("next_run_materials", 0))
	var support_status: String = "No material support follows this route state."
	if support_materials > 0 and bool(consequence.get("pending_support", false)):
		support_status = "Next scenario: +%d starting materials pending." % support_materials
	elif support_materials > 0:
		support_status = "Support applied to %s: +%d starting materials." % [String(consequence.get("applied_to_scenario_id", "the next defense")).replace("_", " ").capitalize(), support_materials]
	return "\nREGIONAL REPORT — %s [%s]\n%s: %s\n%s\n%s" % [String(consequence.get("settlement_name", "Low Mill")), String(consequence.get("settlement_status", "unknown")).to_upper(), String(consequence.get("route_name", "Miller's Road")), String(consequence.get("route_status", "unknown")).to_upper(), String(consequence.get("summary", "")), support_status]
