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
	_check(ui.battle_audio_cues != null and ui.audio_player == null, "headless mode should create the semantic cue service without opening an audio device")

	var expected: Dictionary = {
		"assault_start": "warning",
		"contact": "contact",
		"defender_response": "volley",
		"hostile_impact": "impact",
		"breach": "breach",
		"recovery": "repair",
		"terminal_hold": "hold",
		"terminal_partial_breach": "partial_breach",
		"terminal_collapse": "collapse"
	}
	var semantic: Dictionary = ui.battle_audio_cues.semantic_snapshot()
	_check(semantic.get("battle_beats", {}) == expected, "battle-loop beats should map to one stable cue vocabulary")
	_check(bool(semantic.get("authored_sample_assets", false)) and not bool(semantic.get("temporary_sample_assets", true)), "semantic cues should disclose original authored sample provenance")
	_check(String(semantic.get("sample_source", "")).contains("Pack the Keep original"), "semantic cues should name the original Pack the Keep sound source")
	_check(int(semantic.get("sample_pool_size", -1)) == 0, "headless startup should not allocate sample players")
	var signatures: Dictionary = {}
	var sample_signatures: Dictionary = {}
	for beat_id in expected.keys():
		var cue_id: String = ui.battle_audio_cues.cue_for_beat(String(beat_id))
		var profile: Dictionary = ui.battle_audio_cues.profile(cue_id)
		_check(not profile.is_empty() and String(profile.get("beat", "")) == String(beat_id), "%s should resolve to a complete semantic cue profile" % beat_id)
		_check(ui.battle_audio_cues.sample_available(cue_id), "%s should resolve to a loadable authored sample" % beat_id)
		_check(String(profile.get("sample_path", "")).begins_with("res://assets/audio/semantic/"), "%s should not depend on the temporary asset tree" % beat_id)
		signatures[String(beat_id)] = JSON.stringify(profile.get("frequencies", []))
		sample_signatures[String(beat_id)] = String(profile.get("sample_path", ""))
	_check(signatures.contact != signatures.defender_response and signatures.defender_response != signatures.hostile_impact, "contact, defender response, and hostile impact should sound distinct")
	_check(signatures.breach != signatures.terminal_partial_breach and signatures.terminal_hold != signatures.terminal_collapse, "breach and terminal outcomes should retain distinct signatures")
	_check(sample_signatures.contact != sample_signatures.defender_response and sample_signatures.defender_response != sample_signatures.hostile_impact, "contact, response, and impact should use distinct authored samples")
	_check(sample_signatures.breach != sample_signatures.terminal_partial_breach and sample_signatures.terminal_hold != sample_signatures.terminal_collapse, "breach and terminal outcomes should use distinct authored samples")
	for cue_variant in BattleAudioCueService.CUE_PROFILES.keys():
		var cue_id := String(cue_variant)
		_check(ui.battle_audio_cues.sample_available(cue_id), "%s should resolve to a loadable authored sample" % cue_id)

	var state_before: String = JSON.stringify(ui.keep.serialize())
	var step_before: int = ui.keep.battle_step
	var clock_before: float = ui.keep.battle_clock
	var muted_request: Dictionary = ui.battle_audio_cues.play_beat("hostile_impact", true, 1.0)
	_check(not bool(muted_request.get("played", true)) and String(muted_request.get("reason", "")) == "muted", "mute should suppress playback while recording the hostile-impact cue")
	var zero_request: Dictionary = ui.battle_audio_cues.play_beat("recovery", false, 0.0)
	_check(not bool(zero_request.get("played", true)) and String(zero_request.get("reason", "")) == "zero_volume", "zero effects volume should suppress playback independently of mute")
	var reduced_request: Dictionary = ui.battle_audio_cues.play_beat("assault_start", false, 0.5, true)
	_check(String(reduced_request.get("reason", "")) == "no_audio_device" and bool(reduced_request.get("reduced_motion", false)), "reduced-motion state should reach the cue service without creating a headless device")
	_check(JSON.stringify(ui.keep.serialize()) == state_before and ui.keep.battle_step == step_before and is_equal_approx(ui.keep.battle_clock, clock_before), "cue selection and playback requests should never advance or mutate the simulation")

	var output_service: BattleAudioCueService = BattleAudioCueService.new()
	root.add_child(output_service)
	output_service.setup_output(true)
	_check(output_service.sample_players.size() == BattleAudioCueService.SAMPLE_POOL_SIZE, "audio output should use one bounded four-player sample pool")
	var sample_request: Dictionary = output_service.play_beat("hostile_impact", false, 0.5)
	_check(bool(sample_request.get("played", false)) and String(sample_request.get("playback", "")) == "sample", "available hostile-impact foley should use sample playback")
	output_service.sample_cache["impact"] = null
	output_service.sample_path_overrides["impact"] = "res://assets/temporary/missing-impact.ogg"
	var fallback_request: Dictionary = output_service.play_cue("impact", false, 0.5)
	_check(bool(fallback_request.get("played", false)) and String(fallback_request.get("playback", "")) == "tone_fallback", "missing samples should retain the generated-tone fallback")
	output_service.shutdown_output()
	await create_timer(0.5).timeout
	output_service.queue_free()
	await process_frame

	ui.audio_muted = true
	ui._play_battle_beat("breach")
	ui._refresh_ui()
	_check(ui.last_cue_id == "breach" and String(ui.feedback_cue_label.text).contains("BREACH"), "muted semantic cues should remain visible as text")
	ui._run_result({"ok": true, "message": "fixture invasion"}, "Invasion")
	_check(ui.last_cue_id == "warning", "starting an invasion should route through the assault-start semantic beat")
	ui._run_result({"ok": true, "message": "fixture repair"}, "Repair")
	_check(ui.last_cue_id == "repair", "recovery commands should route through the recovery semantic beat")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P35 battle audio cues: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
