class_name TutorialDirector
extends RefCounted

const TUTORIAL_ID := "first_watch"
const VERSION := 1

const STEPS: Array[Dictionary] = [
	{"id": "intro_keep", "screen": "title", "speaker": "THE CASTELLAN", "title": "Greywatch Needs a Keeper", "body": "This fortress protects the road behind it. Its Gate draws the first attack; its rooms keep the defense supplied, armed, and able to recover.", "objective": "Learn what you are defending.", "action": "continue", "focus": "tutorial_continue"},
	{"id": "intro_resources", "screen": "title", "speaker": "MARA VENN · ENGINEER", "title": "Three Things Keep Us Standing", "body": "Materials build and repair. Morale measures whether the garrison can continue. Command points power your commander’s intervention during an assault.", "objective": "Review the resources used by every defense.", "action": "continue", "focus": "tutorial_continue"},
	{"id": "intro_cycle", "screen": "title", "speaker": "THE CASTELLAN", "title": "Prepare, Read, Adapt", "body": "Choose a plan, place defenders, inspect the enemy, then recover from what gets through. A Hold is clean. A Partial Breach can be repaired. Collapse ends the defense.", "objective": "Begin your First Watch at the War Council.", "action": "continue", "focus": "tutorial_continue"},
	{"id": "war_council", "screen": "setup", "speaker": "THE CASTELLAN", "title": "The Gatehouse Lock", "body": "I reinforce nearby defenses and can order Lockdown once each assault. Gatehouse Lock begins with direct Raiders, then tests our support rooms and upper approaches.", "objective": "Enter Greywatch with the selected commander and scenario.", "action": "confirm_setup", "focus": "setup_confirm"},
	{"id": "inspect_gate", "screen": "preparation", "speaker": "MARA VENN · ENGINEER", "title": "Know the Fortress", "body": "Rooms are more than scenery. The Gate is critical; the Workshop supports recovery. Select the Gate on the ground floor to read its purpose and condition.", "objective": "Inspect the Gate.", "action": "inspect_room:gate", "focus": "board_gate", "checkpoint": true},
	{"id": "open_pike_line", "screen": "preparation", "speaker": "THE CASTELLAN", "title": "Open a Coherent Pack", "body": "Pike Line spends materials to unlock a frontline squad and a fortification. Packs are strategic commitments, not random stat bundles.", "objective": "Select Pike Line and open the pack.", "action": "open_pack:pike_line", "focus": "pack_open"},
	{"id": "place_pike", "screen": "preparation", "speaker": "THE CASTELLAN", "title": "Place the Fighting Line", "body": "Pike Squad attacks unit-hunters at close range. Position it beside the Gate where it can meet Raiders and later take a specialist assignment.", "objective": "Place Pike Squad in the highlighted gate-line position.", "action": "place_piece:pike_squad", "focus": "board_pike"},
	{"id": "place_gate", "screen": "preparation", "speaker": "MARA VENN · ENGINEER", "title": "Shape the Approach", "body": "Narrow Gate deals no damage. It concentrates pressure and gives the enemy another frontline obstacle to break.", "objective": "Place Narrow Gate in the highlighted gate position.", "action": "place_piece:narrow_gate", "focus": "board_narrow_gate"},
	{"id": "inspect_pike", "screen": "preparation", "speaker": "THE CASTELLAN", "title": "Read Unit Behavior", "body": "Every defender card names its role, health, attack style, valid targets, assignment, and positioning question. Select Pike Squad on the fort.", "objective": "Inspect Pike Squad.", "action": "inspect_piece:pike_squad", "focus": "board_pike"},
	{"id": "forecast", "screen": "preparation", "speaker": "MARA VENN · ENGINEER", "title": "Read Before the Bell", "body": "The forecast names the enemy doctrine, likely target, uncertainty, and known actors. Raiders hunt living frontline defenders before they ever touch a room.", "objective": "Review the Gate Assault forecast.", "action": "continue", "focus": "forecast"},
	{"id": "start_first", "screen": "preparation", "speaker": "THE CASTELLAN", "title": "Sound the First Bell", "body": "The assault will open paused so you can identify the threat before time moves.", "objective": "Begin assault phase one.", "action": "start_wave", "focus": "primary_action"},
	{"id": "inspect_raider", "screen": "battle", "speaker": "THE CASTELLAN", "title": "Analyse the Raider", "body": "Select a Raider. Its card shows route, current target, health, next strike, and the defender family that counters it.", "objective": "Inspect a Raider before resuming.", "action": "inspect_enemy:raider", "focus": "enemy_inspector", "checkpoint": true},
	{"id": "resume_first", "screen": "battle", "speaker": "MARA VENN · ENGINEER", "title": "Watch the Exchange", "body": "Defenders commit once each combat tick. Health bars, target lines, projectiles, and melee strikes show which exchange is actually resolving.", "objective": "Resume the assault and watch the line hold.", "action": "resume_battle", "focus": "primary_action"},
	{"id": "observe_first", "screen": "battle", "speaker": "THE CASTELLAN", "title": "Hold the Gate", "body": "Pause whenever you need to inspect. The lesson advances when the assault is resolved.", "objective": "Complete assault phase one.", "action": "observe_wave", "focus": "fort"},
	{"id": "repair_defender", "screen": "results", "speaker": "MARA VENN · ENGINEER", "title": "Repair the Line", "body": "Recovery has only two actions. Repairing a damaged defender preserves an experienced fighting line but leaves less time for rooms or assignments.", "objective": "Repair the highlighted damaged defender.", "action": "repair_piece", "focus": "repair_piece", "checkpoint": true},
	{"id": "assign_gate", "screen": "results", "speaker": "THE CASTELLAN", "title": "Give the Squad a Duty", "body": "Assignments commit specialists to a room until a later recovery. Pike Squad assigned to Gate gains its +2 Gate Road hold bonus.", "objective": "Assign Pike Squad to Gate.", "action": "assign_piece:gate", "focus": "assign_piece"},
	{"id": "release_second", "screen": "results", "speaker": "THE CASTELLAN", "title": "The Second Bell", "body": "The next doctrine splits pressure between the line and the Workshop. End the lull when you are ready.", "objective": "Release assault phase two.", "action": "finish_interval", "focus": "primary_action"},
	{"id": "inspect_sapper", "screen": "battle", "speaker": "MARA VENN · ENGINEER", "title": "Structure Attacker", "body": "Sappers are different from Raiders: they seek support pieces or rooms. Select the Sapper and confirm what it intends to damage.", "objective": "Inspect the Sapper before resuming.", "action": "inspect_enemy:sapper", "focus": "enemy_inspector", "checkpoint": true},
	{"id": "resume_second", "screen": "battle", "speaker": "THE CASTELLAN", "title": "Two Pressures", "body": "One enemy clears defenders while the other attacks a keep function. A strong line does not remove the need for recovery.", "objective": "Resume assault phase two.", "action": "resume_battle", "focus": "primary_action"},
	{"id": "observe_second", "screen": "battle", "speaker": "THE CASTELLAN", "title": "Protect What Matters", "body": "Let the phase resolve. The room condition bars show structural damage separately from defender health.", "objective": "Complete assault phase two.", "action": "observe_wave", "focus": "fort"},
	{"id": "repair_room", "screen": "results", "speaker": "MARA VENN · ENGINEER", "title": "Restore a Keep Function", "body": "The Sapper chooses the weakest exposed support room. Room repair restores condition and can remove a breach, using the same action budget as defender repair and assignment.", "objective": "Repair the highlighted damaged room.", "action": "repair_room", "focus": "repair_room", "checkpoint": true},
	{"id": "release_final", "screen": "results", "speaker": "THE CASTELLAN", "title": "The Final Bell", "body": "The last phase combines Gate pressure, an upper bypass, and sabotage. Preserve the keep by reading roles instead of chasing every marker.", "objective": "Release assault phase three.", "action": "finish_interval", "focus": "primary_action"},
	{"id": "inspect_climber", "screen": "battle", "speaker": "THE CASTELLAN", "title": "The Bypass Threat", "body": "Climbers hunt upper-floor defenders and punish a plan that only watches the Gate. Select the Climber before committing your intervention.", "objective": "Inspect the Climber.", "action": "inspect_enemy:climber", "focus": "enemy_inspector", "checkpoint": true},
	{"id": "use_lockdown", "screen": "battle", "speaker": "THE CASTELLAN", "title": "Commander Intervention", "body": "Lockdown reduces the next contact and restores a small amount of defender health. Command points are scarce, so timing matters.", "objective": "Order Lockdown before resuming.", "action": "use_ability", "focus": "commander_ability"},
	{"id": "resume_final", "screen": "battle", "speaker": "MARA VENN · ENGINEER", "title": "Trust the Plan", "body": "The keep now has a line, an assignment, repaired structure, and a timed intervention. Resume and watch the combined doctrine resolve.", "objective": "Resume the final assault.", "action": "resume_battle", "focus": "primary_action"},
	{"id": "observe_final", "screen": "battle", "speaker": "THE CASTELLAN", "title": "Complete the First Watch", "body": "A clean Hold is ideal, but a recoverable Partial Breach still completes the lesson. Collapse will offer a retry from this phase.", "objective": "Finish the scenario without collapse.", "action": "observe_wave", "focus": "fort"},
	{"id": "complete", "screen": "results", "speaker": "THE CASTELLAN", "title": "Greywatch Holds", "body": "You read the keep, built a doctrine, analysed enemy roles, repaired both people and stone, and used command at the decisive moment.", "objective": "Complete the tutorial and return to the War Council.", "action": "finish_tutorial", "focus": "tutorial_continue"}
]

var active: bool = false
var step_index: int = 0
var failure_active: bool = false
var failure_message: String = ""

func _init() -> void:
	_validate_steps()

func _validate_steps() -> void:
	var seen: Array[String] = []
	for step in STEPS:
		for field in ["id", "screen", "speaker", "title", "body", "objective", "action", "focus"]:
			assert(step.has(field) and step[field] is String and not String(step[field]).is_empty(), "invalid tutorial step field %s" % field)
		assert(not seen.has(String(step.id)), "duplicate tutorial step id")
		seen.append(String(step.id))

func start() -> void:
	active = true
	step_index = 0
	failure_active = false
	failure_message = ""

func stop() -> void:
	active = false
	failure_active = false
	failure_message = ""

func current_step() -> Dictionary:
	if not active or step_index < 0 or step_index >= STEPS.size():
		return {}
	return STEPS[step_index].duplicate(true)

func current_id() -> String:
	return String(current_step().get("id", ""))

func expected_action() -> String:
	return "retry_phase" if failure_active else String(current_step().get("action", ""))

func allows(action_id: String) -> bool:
	if not active:
		return true
	if action_id in ["settings", "help", "skip_tutorial"]:
		return true
	if failure_active:
		return action_id == "retry_phase"
	if current_id().begins_with("observe_"):
		return action_id in ["pause_battle", "resume_battle", "inspect_enemy", "speed", "observe_wave"]
	var expected: String = expected_action()
	return action_id == expected or (expected.begins_with("inspect_enemy:") and action_id == "inspect_enemy")

func observe(action_id: String) -> bool:
	if not active or failure_active or action_id != expected_action():
		return false
	step_index = mini(step_index + 1, STEPS.size() - 1)
	return true

func advance_if_matching(action_id: String, subject_id: String = "") -> bool:
	var combined: String = action_id if subject_id.is_empty() else "%s:%s" % [action_id, subject_id]
	if combined == expected_action():
		return observe(combined)
	return false

func sync_wave_result(wave_index: int, outcome: String) -> bool:
	if not active:
		return false
	var expected_wave: int = 1 if current_id() == "observe_first" else 2 if current_id() == "observe_second" else 3 if current_id() == "observe_final" else 0
	if expected_wave == 0 or wave_index != expected_wave:
		return false
	if outcome == "collapse":
		failure_active = true
		failure_message = "The defense collapsed. Retry this phase from its checkpoint and apply the lesson before releasing the assault."
		return true
	step_index = mini(step_index + 1, STEPS.size() - 1)
	return true

func serialize_progress() -> Dictionary:
	return {"tutorial_id": TUTORIAL_ID, "version": VERSION, "active": active, "step_id": current_id(), "failure_active": failure_active, "failure_message": failure_message}

func restore_progress(data: Dictionary) -> bool:
	if String(data.get("tutorial_id", "")) != TUTORIAL_ID or int(data.get("version", 0)) != VERSION:
		return false
	var step_id: String = String(data.get("step_id", ""))
	for index in range(STEPS.size()):
		if String(STEPS[index].id) == step_id:
			step_index = index
			active = bool(data.get("active", true))
			failure_active = bool(data.get("failure_active", false))
			failure_message = String(data.get("failure_message", ""))
			return true
	return false
