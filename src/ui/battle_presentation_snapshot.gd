class_name BattlePresentationSnapshot
extends RefCounted

const BattleBeatPresentationView = preload("res://src/ui/battle_beat_presentation.gd")

static func build(keep: Object, battle_paused: bool, assault_ready_reason: String, focused_enemy_index: int, battle_speed: float) -> Dictionary:
	if keep == null:
		return {}
	var phase_text: String = "PHASE %d/%d  •  TICK %d" % [keep.wave_index, maxi(1, keep.authored_wave_count()), keep.battle_step]
	var state_text: String
	if not keep.wave_active:
		state_text = "BATTLE STATE — NO ACTIVE ASSAULT\nPrepare the defense or review the resolved outcome."
	elif not assault_ready_reason.is_empty():
		state_text = "BATTLE STATE — %s  •  PAUSED\nRead first contact, then sound the bell when the defense is understood." % phase_text
	elif battle_paused:
		state_text = "BATTLE STATE — %s  •  PAUSED\nInspect targets and timing before resuming the real-time assault." % phase_text
	else:
		state_text = "BATTLE STATE — %s  •  LIVE %.1fx\nWatch health, projectiles, and target lines; pause whenever the answer is unclear." % [phase_text, battle_speed]

	var commander: Dictionary = keep.commander_definition(keep.commander_id)
	var ability_spent: bool = bool(keep.lockdown_used) if keep.commander_id == "castellan" else bool(keep.rally_used)
	var ability_ready: bool = keep.wave_active and keep.command_points > 0 and not ability_spent
	var ability_status: String = "READY" if ability_ready else "SPENT" if ability_spent else "UNAVAILABLE"
	var active_focus: bool = focused_enemy_index >= 0 and focused_enemy_index < keep.enemies.size() and not bool(keep.enemies[focused_enemy_index].get("defeated", false))
	var focus_name: String = ""
	if active_focus:
		var focus_enemy_id: String = String(keep.enemies[focused_enemy_index].get("enemy_id", ""))
		focus_name = String(keep.enemy_definition(focus_enemy_id).get("name", focus_enemy_id.replace("_", " ").capitalize()))

	var beat: Dictionary = BattleBeatPresentationView.ambient(keep, assault_ready_reason, focused_enemy_index)
	state_text += "\nPRESSURE READ — %s" % String(beat.get("label", "SETTLE"))
	return {
		"phase": keep.wave_index,
		"phase_count": maxi(1, keep.authored_wave_count()),
		"tick": keep.battle_step,
		"paused": battle_paused,
		"ready": not assault_ready_reason.is_empty(),
		"speed": battle_speed,
		"state_text": state_text,
		"beat": beat,
		"pause_text": "Sound the bell (Space)" if not assault_ready_reason.is_empty() else "Resume battle (Space)" if battle_paused else "Pause battle (Space)",
		"manual_step_enabled": keep.wave_active and battle_paused and assault_ready_reason.is_empty(),
		"speed_text": "Speed: %.1fx (1/2/3)" % battle_speed,
		"ability": {
			"name": String(commander.get("ability_name", "Ability")),
			"commander": String(commander.get("name", keep.commander_id)).replace("The ", ""),
			"tooltip": String(commander.get("ability_text", "Use once per assault phase.")),
			"ready": ability_ready,
			"status": ability_status,
		},
		"focus": {
			"active": active_focus,
			"index": focused_enemy_index,
			"name": focus_name,
			"button_text": "Inspect focused threat — %s" % focus_name if active_focus else "Inspect focused threat",
		},
		"response_text": _response_text(keep, focused_enemy_index, battle_paused),
	}

static func _response_text(keep: Object, focused_enemy_index: int, battle_paused: bool) -> String:
	if focused_enemy_index < 0 or focused_enemy_index >= keep.enemies.size() or bool(keep.enemies[focused_enemy_index].get("defeated", false)):
		return "RESPONSE — Select an active enemy on the map or press Tab. Tactical controls contain the fallback list."
	var inspection: Dictionary = keep.inspect_enemy(focused_enemy_index)
	var ability_name: String = String(keep.commander_definition(keep.commander_id).get("ability_name", "Ability"))
	var ability_state: String = "available" if keep.command_points > 0 and not bool(keep.lockdown_used if keep.commander_id == "castellan" else keep.rally_used) else "spent or unavailable"
	var timing_text: String = "PAUSED PREVIEW — commit when ready" if battle_paused else "RUNNING — pause to inspect before committing"
	var target_text: String = String(keep.enemy_target_readout(focused_enemy_index).get("summary", "Approaching"))
	var counter_id: String = String(inspection.get("counter", ""))
	var counter_name: String = String(keep.piece_definition(counter_id).get("name", counter_id.replace("_", " ").capitalize())) if not counter_id.is_empty() else "Read the forecast"
	var response: Dictionary = keep.defender_response_preview(focused_enemy_index)
	var strike_timing: Dictionary = keep.enemy_attack_timing(focused_enemy_index)
	var strike_text: String = "STRIKE: cadence unavailable"
	if bool(strike_timing.get("ok", false)):
		var interval: int = int(strike_timing.get("attack_interval", 1))
		if bool(strike_timing.get("within_wave", true)):
			strike_text = "STRIKE: every %d tick%s · next T%d" % [interval, "" if interval == 1 else "s", int(strike_timing.get("next_attack_step", 0))]
		else:
			strike_text = "STRIKE: cadence complete for this assault phase"
	var attacker_names: Array[String] = []
	for attacker in response.get("attackers", []):
		attacker_names.append("%s (%d)" % [String(attacker.get("name", "Defender")), int(attacker.get("damage", 0))])
	var engagement_text: String = "NEXT STEP: no ready defender commits to this target"
	if not attacker_names.is_empty():
		engagement_text = "NEXT STEP: %s → %d damage · projected %d hp" % [", ".join(attacker_names), int(response.get("expected_damage", 0)), int(response.get("projected_health", 0))]
	return "RESPONSE — FOCUSED %d: %s\n%s\nTHREAT: %s | TARGET: %s | %s\n%s\n%s\nCOUNTERS: %s\n%s: %s (%d command)" % [focused_enemy_index + 1, String(inspection.get("name", "enemy")), timing_text, String(inspection.get("doctrine", "approaching")).replace("_", " ").to_upper(), target_text, String(response.get("contact_state", "APPROACH")), strike_text, engagement_text, counter_name, ability_name, ability_state, keep.command_points]
