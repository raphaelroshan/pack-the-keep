class_name LocalPlaytestObserver
extends RefCounted

const SCHEMA_VERSION := 1

var enabled: bool = false
var started: bool = false
var current_screen: String = ""
var screen_durations: Dictionary = {}
var first_action: String = ""
var action_counts: Dictionary = {}
var primary_action_paths: Dictionary = {}
var recovery_choices: Dictionary = {}
var pause_count: int = 0
var focus_count: int = 0
var result_type: String = ""

func set_enabled(value: bool, screen: String = "") -> void:
	enabled = value
	if value:
		started = true
		if not screen.is_empty():
			current_screen = screen
			_ensure_screen(screen)

func reset(screen: String = "") -> void:
	enabled = false
	started = false
	current_screen = screen
	screen_durations.clear()
	first_action = ""
	action_counts.clear()
	primary_action_paths.clear()
	recovery_choices.clear()
	pause_count = 0
	focus_count = 0
	result_type = ""

func advance(delta: float) -> void:
	if not enabled or current_screen.is_empty() or delta <= 0.0:
		return
	_ensure_screen(current_screen)
	screen_durations[current_screen] = float(screen_durations[current_screen]) + delta

func record_screen(screen: String) -> void:
	if not enabled or screen.is_empty():
		return
	current_screen = screen
	_ensure_screen(screen)

func record_action(action_id: String, details: Dictionary = {}) -> void:
	if not enabled or action_id.is_empty():
		return
	if first_action.is_empty():
		first_action = action_id
	action_counts[action_id] = int(action_counts.get(action_id, 0)) + 1
	if action_id == "pause_toggle":
		pause_count += 1
	elif action_id == "focus_threat":
		focus_count += 1
	var primary_path: String = String(details.get("primary_path", ""))
	if not primary_path.is_empty():
		primary_action_paths[primary_path] = int(primary_action_paths.get(primary_path, 0)) + 1
	var recovery_choice: String = String(details.get("recovery_choice", ""))
	if not recovery_choice.is_empty():
		recovery_choices[recovery_choice] = int(recovery_choices.get(recovery_choice, 0)) + 1

func record_result(outcome: String) -> void:
	if enabled and not outcome.is_empty():
		result_type = outcome

func snapshot() -> Dictionary:
	var rounded_durations: Dictionary = {}
	for screen_key in screen_durations.keys():
		rounded_durations[String(screen_key)] = snappedf(float(screen_durations[screen_key]), 0.001)
	return {
		"schema_version": SCHEMA_VERSION,
		"local_only": true,
		"human_evidence": false,
		"collection_started": started,
		"collection_enabled": enabled,
		"screen_durations_seconds": rounded_durations,
		"first_action": first_action,
		"action_counts": action_counts.duplicate(true),
		"pause_count": pause_count,
		"focus_count": focus_count,
		"primary_action_paths": primary_action_paths.duplicate(true),
		"recovery_choices": recovery_choices.duplicate(true),
		"result_type": result_type,
	}

func export_json(path: String, context: Dictionary = {}) -> Dictionary:
	if not started:
		return {"ok": false, "reason": "observation has not been enabled this session"}
	var payload: Dictionary = snapshot()
	payload["context"] = context.duplicate(true)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "reason": "could not open local export path"}
	file.store_string(JSON.stringify(payload, "  "))
	file.flush()
	file.close()
	return {"ok": true, "path": path, "payload": payload}

func _ensure_screen(screen: String) -> void:
	if not screen_durations.has(screen):
		screen_durations[screen] = 0.0
