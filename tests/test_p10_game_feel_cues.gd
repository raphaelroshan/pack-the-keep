extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	_check(ui.audio_player == null, "headless validation should not initialize an audio playback device")
	var state_before: String = JSON.stringify(ui.keep.serialize())

	var required_cues: Array[String] = ["warning", "contact", "volley", "impact", "confirm", "repair", "ability", "error", "pause", "resume", "hold", "partial_breach", "collapse"]
	var signatures: Dictionary = {}
	for cue_id in required_cues:
		var profile: Dictionary = ui._cue_profile(cue_id)
		_check(not profile.is_empty() and profile.get("frequencies", []) is Array and not profile.get("frequencies", []).is_empty(), "%s should resolve to a playable cue profile" % cue_id)
		signatures[cue_id] = JSON.stringify(profile)
	_check(signatures.hold != signatures.partial_breach and signatures.partial_breach != signatures.collapse and signatures.hold != signatures.collapse, "terminal outcomes should have distinct cue profiles")
	_check(signatures.volley != signatures.impact and signatures.impact != signatures.contact, "defender volleys, enemy impacts, and general contact should have distinct cue profiles")

	ui.audio_muted = true
	ui._play_cue("repair")
	ui._refresh_ui()
	_check(ui.last_cue_id == "repair" and String(ui.feedback_cue_label.text).contains("REPAIR"), "muted cues should still expose their semantic state in text")
	_check(JSON.stringify(ui.keep.serialize()) == state_before, "cue playback should not mutate authoritative state")

	ui._run_result({"ok": true, "message": "fixture repair"}, "Repair")
	_check(ui.last_cue_id == "repair", "successful repair commands should use the repair cue")
	ui._run_result({"ok": true, "message": "fixture ability"}, "Ability")
	_check(ui.last_cue_id == "ability", "successful commander abilities should use the ability cue")
	ui._run_result({"ok": false, "reason": "fixture blocked"}, "Ability")
	_check(ui.last_cue_id == "error", "blocked commands should use the error cue")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P10 semantic feedback cues: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
