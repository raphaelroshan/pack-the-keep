class_name RecoveryPresentationSnapshot
extends RefCounted

static func build(keep: Object, selected_piece_id: String, selected_room_id: String) -> Dictionary:
	if keep == null:
		return {}
	var priorities: Array[Dictionary] = priority_rows(keep)
	return {
		"brief": _brief(keep, priorities),
		"priorities_text": _priorities_text(keep, priorities),
		"stage_text": "CHOICE %d OF 2 — exact costs and trade-offs are shown below." % (3 - keep.repair_actions_remaining) if keep.repair_actions_remaining > 0 else "ACTIONS COMPLETE — continue explicitly when the keep is ready.",
		"cards": {
			"room": _action_card("REPAIR ROOM", keep.recovery_action_preview("repair_room", "", selected_room_id)),
			"piece": _action_card("REPAIR PIECE", keep.recovery_action_preview("repair_piece", selected_piece_id)),
			"assign": _action_card("ASSIGN SPECIALIST", keep.recovery_action_preview("assign_piece", selected_piece_id, selected_room_id)),
			"clear": _action_card("CLEAR ASSIGNMENT", keep.recovery_action_preview("clear_assignment", selected_piece_id)),
		},
		"finish": {
			"disabled": not keep.active_event_id.is_empty(),
			"tooltip": "Resolve the active event before continuing." if not keep.active_event_id.is_empty() else "Close recovery explicitly; unused actions are recorded and never spent automatically.",
			"text": "END LULL — RELEASE PHASE %d/%d" % [keep.wave_index + 1, keep.authored_wave_count()] if keep.has_next_wave() else "FINISH RECOVERY",
		},
	}

static func priority_rows(keep: Object) -> Array[Dictionary]:
	var priorities: Array[Dictionary] = []
	for room_id in keep.rooms.keys():
		var id: String = String(room_id)
		var state: String = keep.room_state(id)
		var condition: int = keep.room_condition(id)
		var room_definition: Dictionary = keep.room_definition(id)
		var critical: bool = bool(room_definition.get("critical", false))
		var score: int = 0
		if state == "breached":
			score = 400 if critical else 300
		elif state == "damaged":
			score = 200 if critical else 100
		elif state == "strained":
			score = 50
		score += 100 - condition
		priorities.append({"id": id, "name": String(room_definition.get("name", id)), "state": state.to_upper(), "condition": condition, "score": score})
	priorities.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		if int(left.get("score", 0)) == int(right.get("score", 0)):
			return String(left.get("id", "")) < String(right.get("id", ""))
		return int(left.get("score", 0)) > int(right.get("score", 0))
	)
	return priorities

static func _brief(keep: Object, priorities: Array[Dictionary]) -> Dictionary:
	var latest: Dictionary = keep.wave_history.back() if not keep.wave_history.is_empty() else {}
	var outcome: String = String(latest.get("outcome", keep.last_outcome)).replace("_", " ").to_upper()
	var changed: String = "Phase %d %s · %d enemies defeated · %d room / %d defender damage." % [int(latest.get("wave", keep.wave_index)), outcome, int(latest.get("defeated_enemies", 0)), int(latest.get("room_damage", 0)), int(latest.get("piece_damage", 0))]
	var first_priority: Dictionary = priorities[0] if not priorities.is_empty() else {}
	var damaged_piece: Dictionary = {}
	var largest_piece_loss: int = 0
	for instance_id_value in keep.pieces.keys():
		var instance_id: String = String(instance_id_value)
		var instance: Dictionary = keep.pieces[instance_id]
		var maximum: int = int(instance.get("max_health", 0))
		var health: int = int(instance.get("health", maximum))
		var loss: int = maximum - health
		if loss > largest_piece_loss:
			largest_piece_loss = loss
			damaged_piece = {"name": String(keep.piece_definition(String(instance.get("piece_id", ""))).get("name", instance_id)), "health": health, "maximum": maximum, "disabled": bool(instance.get("disabled", false))}
	var matters: String
	var room_needs_attention: bool = not first_priority.is_empty() and int(first_priority.get("score", 0)) > 0
	if not damaged_piece.is_empty() and not room_needs_attention:
		matters = "%s is %s at %d/%d health." % [String(damaged_piece.get("name", "A defender")), "DISABLED" if bool(damaged_piece.get("disabled", false)) else "DAMAGED", int(damaged_piece.get("health", 0)), int(damaged_piece.get("maximum", 0))]
	elif first_priority.is_empty():
		matters = "No damaged room is currently ranked; preserve flexibility before the next pressure."
	else:
		matters = "%s is %s at %d%% condition." % [String(first_priority.get("name", "The keep")), String(first_priority.get("state", "STABLE")), int(first_priority.get("condition", 100))]
	var advice: Dictionary = keep.recovery_advice()
	var next_pressure: String = "%s · %s" % [String(advice.get("next_doctrine", "next doctrine")).replace("_", " ").capitalize(), String(advice.get("target", "Preserve the most important function."))] if bool(advice.get("ok", false)) else "No further pressure is forecast."
	var priority_name: String = String(damaged_piece.get("name", "")) if not damaged_piece.is_empty() and not room_needs_attention else String(first_priority.get("name", advice.get("target", "Preserve the most important function.")))
	var alternative_name: String = "flexibility before the next pressure"
	for priority_index in range(priorities.size()):
		var candidate: Dictionary = priorities[priority_index]
		if int(candidate.get("score", 0)) > 0 and String(candidate.get("name", "")) != priority_name:
			alternative_name = String(candidate.get("name", alternative_name))
			break
	if not damaged_piece.is_empty() and String(damaged_piece.get("name", "")) != priority_name:
		alternative_name = String(damaged_piece.get("name", alternative_name))
	var remaining_after_choice: int = maxi(0, keep.repair_actions_remaining - 1)
	var sacrifice: String = "No recovery actions remain; unresolved damage carries forward."
	if keep.repair_actions_remaining > 0:
		sacrifice = "Commit one action to %s; only %d action%s %s for %s." % [priority_name, remaining_after_choice, "" if remaining_after_choice == 1 else "s", "remains" if remaining_after_choice == 1 else "remain", alternative_name]
	return {
		"actions_remaining": keep.repair_actions_remaining,
		"materials": keep.materials,
		"changed": changed,
		"matters": matters,
		"next": next_pressure,
		"priority": priority_name,
		"sacrifice": sacrifice,
		"tradeoff": String(advice.get("tradeoff", "Every recovery action leaves another need unanswered.")),
	}

static func _priorities_text(keep: Object, priorities: Array[Dictionary]) -> String:
	if not keep.repair_interval_active and keep.last_outcome.is_empty():
		return "RECOVERY PRIORITIES — Appear after a Hold or Partial Breach. The ranking is advisory; repair commands remain authoritative."
	var rows: Array[String] = []
	for index in range(mini(3, priorities.size())):
		var row: Dictionary = priorities[index]
		rows.append("%s — %s %d%%" % [String(row.get("name", "room")), String(row.get("state", "STABLE")), int(row.get("condition", 0))])
	var advice: Dictionary = keep.recovery_advice()
	if bool(advice.get("ok", false)):
		return "RECOVERY PRIORITIES — advisory order\n%s\nNEXT: %s | %s\nTRADE-OFF: %s" % [" | ".join(rows), String(advice.get("next_doctrine", "next doctrine")).replace("_", " "), String(advice.get("target", "preserve the most important function")), String(advice.get("tradeoff", "choose deliberately"))]
	return "RECOVERY PRIORITIES — advisory order\n%s" % " | ".join(rows)

static func _action_card(action_name: String, preview: Dictionary) -> Dictionary:
	var target_name: String = String(preview.get("target_name", "Select a target"))
	var material_cost: int = int(preview.get("material_cost", 0))
	var cost_text: String = "%d material%s + 1 action" % [material_cost, "" if material_cost == 1 else "s"] if material_cost > 0 else "1 recovery action"
	var ready: bool = bool(preview.get("ok", false))
	return {
		"title": "%s — %s" % [action_name, target_name],
		"detail": "COST — %s\nBENEFIT — %s\nTRADE-OFF — %s\n%s" % [cost_text, String(preview.get("benefit", "")), String(preview.get("tradeoff", "")), "READY" if ready else "BLOCKED — %s" % String(preview.get("reason", "unavailable"))],
		"ready": ready,
		"tooltip": String(preview.get("benefit", "")) if ready else String(preview.get("reason", "unavailable")),
	}
