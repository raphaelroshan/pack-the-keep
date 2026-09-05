extends SceneTree

var output_dir: String = ""
var captured_files: Array[String] = []
var state_trace: Array[Dictionary] = []
var capture_size: Vector2i = Vector2i(1600, 900)
var capture_scale_index: int = 1
var capture_commander_id: String = "castellan"
var capture_scenario_id: String = "gatehouse_lock"
var capture_pack_offer: bool = false
var capture_spatial_transition: bool = false
var capture_route_delay: bool = false
var capture_route_reveal: bool = false
var capture_twilight_road: bool = false
var capture_twilight_choice: bool = false
var capture_starting_defender: bool = false
var capture_battle_exchange: bool = false
var capture_battle_exchange_progress: float = 0.28
var capture_battle_inspection: bool = false
var capture_repair_feedback: bool = false
var capture_intervention: bool = false
var capture_setup_only: bool = false
var capture_first_plan_transition: bool = false
var capture_settings_only: bool = false
var capture_tutorial_intro_only: bool = false
var battle_inspection_completed: bool = false
var intervention_completed: bool = false
var repair_feedback_completed: bool = false
var terminal_after_early_phase: bool = false

func _initialize() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Vertical-slice capture requires a graphical renderer; remove --headless.")
		quit(2)
		return
	output_dir = _argument_value("--output-dir=")
	capture_size.x = maxi(640, int(_argument_value("--width=").to_int())) if not _argument_value("--width=").is_empty() else 1600
	capture_size.y = maxi(360, int(_argument_value("--height=").to_int())) if not _argument_value("--height=").is_empty() else 900
	capture_scale_index = clampi(int(_argument_value("--ui-scale-index=").to_int()), 0, 4) if not _argument_value("--ui-scale-index=").is_empty() else 1
	capture_commander_id = _argument_value("--commander=") if not _argument_value("--commander=").is_empty() else "castellan"
	capture_scenario_id = _argument_value("--scenario=") if not _argument_value("--scenario=").is_empty() else "gatehouse_lock"
	capture_pack_offer = OS.get_cmdline_user_args().has("--capture-pack-offer")
	capture_spatial_transition = OS.get_cmdline_user_args().has("--capture-spatial-transition")
	capture_route_delay = OS.get_cmdline_user_args().has("--capture-route-delay")
	capture_route_reveal = OS.get_cmdline_user_args().has("--capture-route-reveal")
	capture_twilight_road = OS.get_cmdline_user_args().has("--capture-twilight-road")
	capture_twilight_choice = OS.get_cmdline_user_args().has("--capture-twilight-choice")
	capture_starting_defender = OS.get_cmdline_user_args().has("--inspect-starting-defender")
	capture_battle_exchange = OS.get_cmdline_user_args().has("--capture-battle-exchange")
	capture_battle_inspection = OS.get_cmdline_user_args().has("--capture-battle-inspection")
	capture_repair_feedback = OS.get_cmdline_user_args().has("--capture-repair-feedback")
	capture_intervention = OS.get_cmdline_user_args().has("--capture-intervention")
	capture_setup_only = OS.get_cmdline_user_args().has("--capture-setup-only")
	capture_first_plan_transition = OS.get_cmdline_user_args().has("--capture-first-plan-transition")
	capture_settings_only = OS.get_cmdline_user_args().has("--capture-settings-only")
	capture_tutorial_intro_only = OS.get_cmdline_user_args().has("--capture-tutorial-intro-only")
	if not _argument_value("--battle-exchange-progress=").is_empty():
		capture_battle_exchange_progress = clampf(float(_argument_value("--battle-exchange-progress=")), 0.0, 0.99)
	if output_dir.is_empty():
		output_dir = ProjectSettings.globalize_path("user://visual-captures")
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(output_dir)
	if directory_error != OK:
		push_error("Could not create capture directory: %s" % output_dir)
		quit(2)
		return
	call_deferred("_run_capture")

func _run_capture() -> void:
	root.size = capture_size
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui.ui_scale_index = capture_scale_index
	ui._apply_ui_scale()
	root.size = capture_size
	ui._apply_responsive_layout()
	# Large GL compatibility viewports can need one additional fixed draw pair
	# after resize before the first framebuffer is populated.
	await process_frame
	await process_frame
	await _capture("01_title", ui)
	if capture_settings_only:
		ui._on_open_settings()
		await _capture("02_settings", ui)
		_write_manifest()
		ui.queue_free()
		await process_frame
		print("Vertical-slice capture: PASS (%d settings screens at %s)" % [captured_files.size(), output_dir])
		quit(0)
		return
	if capture_tutorial_intro_only:
		ui._start_tutorial()
		await _capture("02_tutorial_keep", ui)
		ui._on_tutorial_continue()
		await _capture("03_tutorial_resources", ui)
		ui._on_tutorial_continue()
		await _capture("04_tutorial_cycle", ui)
		ui._on_tutorial_continue()
		await _capture("05_tutorial_war_council", ui)
		_write_manifest()
		ui.queue_free()
		await process_frame
		print("Vertical-slice capture: PASS (%d tutorial screens at %s)" % [captured_files.size(), output_dir])
		quit(0)
		return
	ui._on_start_quick_playtest()
	if ui.keep.commander_ids().has(capture_commander_id):
		ui._select_option_metadata(ui.commander_option, capture_commander_id)
		ui.keep.select_commander(capture_commander_id)
	if ui.keep.scenario_ids().has(capture_scenario_id):
		ui._select_option_metadata(ui.scenario_option, capture_scenario_id)
		ui.keep.select_scenario(capture_scenario_id)
	if capture_first_plan_transition:
		ui.guided_setup = false
	if capture_spatial_transition or capture_route_delay or capture_route_reveal or capture_twilight_road or capture_twilight_choice:
		ui.guided_setup = false
	ui._refresh_ui()
	await _capture("02_war_council", ui)
	ui._on_confirm_setup()
	if not ui.keep.active_event_id.is_empty():
		var opening_event: Dictionary = ui.keep.current_event()
		var opening_choices: Array = opening_event.get("choices", [])
		if not opening_choices.is_empty():
			ui._on_authored_event_choice_id(String(opening_choices[0].get("id", "")))
	if capture_spatial_transition and capture_scenario_id == "the_divided_bell":
		ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
		ui._refresh_ui()
	elif capture_route_delay and capture_scenario_id == "before_the_horn":
		ui.keep.open_pack("road_wardens")
		ui.keep.place_piece("hook_guard", Vector2i(4, 3), "ground")
		ui._refresh_ui()
	elif capture_route_reveal and capture_scenario_id == "the_unlit_stair":
		ui.keep.open_pack("lantern_watch")
		ui.keep.place_piece("dusk_bow", Vector2i(1, 1), "upper")
		ui._refresh_ui()
	elif capture_twilight_choice and capture_scenario_id == "the_twilight_road":
		ui.keep.open_pack("road_wardens")
		ui.keep.open_pack("crossbow_watch")
		ui.keep.place_piece("hook_guard", Vector2i(4, 3), "ground")
		ui.keep.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
		ui._refresh_ui()
	elif capture_twilight_road and capture_scenario_id == "the_twilight_road":
		ui.keep.open_pack("road_wardens")
		ui.keep.open_pack("lantern_watch")
		ui.keep.place_piece("hook_guard", Vector2i(4, 3), "ground")
		ui.keep.place_piece("dusk_bow", Vector2i(1, 1), "upper")
		ui._refresh_ui()
	elif capture_starting_defender:
		ui._on_map_clicked("ground", Vector2i(4, 5))
	await _capture("03_preparation", ui)
	if capture_first_plan_transition:
		ui._on_recommended_layout()
		await _capture("03a_first_plan_ready", ui)
	if capture_setup_only:
		_write_manifest()
		ui.queue_free()
		await process_frame
		print("Vertical-slice capture: PASS (%d setup screens at %s)" % [captured_files.size(), output_dir])
		quit(0)
		return
	if capture_spatial_transition and capture_scenario_id == "the_divided_bell":
		ui.keep.open_pack("runner_network")
		ui.keep.place_piece("runner_pair", Vector2i(9, 3), "ground")
		ui._refresh_ui()
		await _capture("03c_spatial_rule_active", ui)
	if capture_route_delay and capture_scenario_id == "before_the_horn":
		ui.keep.place_piece("stake_line", Vector2i(1, 2), "ground")
		ui._refresh_ui()
		await _capture("03c_route_delay_ready", ui)
	if capture_route_reveal and capture_scenario_id == "the_unlit_stair":
		ui.keep.place_piece("lantern_post", Vector2i(7, 1), "upper")
		ui._refresh_ui()
		await _capture("03c_route_reveal_ready", ui)
	if capture_twilight_choice and capture_scenario_id == "the_twilight_road":
		ui.keep.place_piece("stake_line", Vector2i(1, 2), "ground")
		ui.keep.place_piece("watch_banner", Vector2i(4, 1), "upper")
		ui._refresh_ui()
		await _capture("03c_mixed_routes_ready", ui)
	elif capture_twilight_road and capture_scenario_id == "the_twilight_road":
		ui.keep.place_piece("stake_line", Vector2i(1, 2), "ground")
		ui.keep.place_piece("lantern_post", Vector2i(7, 1), "upper")
		ui._refresh_ui()
		await _capture("03c_combined_routes_ready", ui)
	if capture_pack_offer:
		ui._scroll_page_to_control(ui.preparation_pack_offer_panel)
		await _capture("03b_pack_offer", ui)
	ui._on_start_wave()
	if capture_battle_exchange:
		ui._toggle_battle_pause()
		ui.battle_paused = true
		ui._on_advance_wave()
		ui.keep_canvas.engagement_ttl = ui.keep_canvas.engagement_duration * (1.0 - capture_battle_exchange_progress)
		ui.keep_canvas.set_process(false)
		ui.keep_canvas.queue_redraw()
	await _capture("04_assault_phase_1", ui)
	if capture_battle_inspection:
		if not ui.assault_ready_reason.is_empty():
			ui._toggle_battle_pause()
			ui.battle_paused = true
			ui._on_advance_wave()
		if ui.keep.wave_active:
			ui.command_scroll.scroll_vertical = 0
			await _capture("04a_paused_threat_dossier", ui)
			battle_inspection_completed = true
	if capture_intervention and ui.keep.wave_active:
		if not ui.assault_ready_reason.is_empty():
			ui._toggle_battle_pause()
			ui.battle_paused = true
			ui._on_advance_wave()
		if ui.keep.wave_active:
			ui._on_use_ability()
			await _capture("04b_emergency_intervention", ui)
			intervention_completed = true
	if capture_battle_exchange:
		ui.keep_canvas.set_process(true)
		ui.keep_canvas._process(ui.keep_canvas.engagement_duration)
	await _resolve_phase(ui)
	if await _finish_early_terminal_capture(ui):
		return
	await _capture("05_recovery_phase_1", ui)
	_resolve_open_event(ui)
	ui._on_finish_interval()
	await _capture("06_assault_phase_2", ui)
	await _resolve_phase(ui)
	if await _finish_early_terminal_capture(ui):
		return
	await _capture("07_recovery_phase_2", ui)
	if capture_repair_feedback and ui.keep.repair_interval_active and ui.keep.active_event_id.is_empty():
		for room_id_value in ui.keep.room_definitions().keys():
			var room_id: String = String(room_id_value)
			if ui.keep.room_condition(room_id) >= 100:
				continue
			ui._select_option_metadata(ui.room_option, room_id)
			ui._on_repair_room()
			ui.keep_canvas.set_process(false)
			ui.keep_canvas.queue_redraw()
			await _capture("07c_room_repair_feedback", ui)
			repair_feedback_completed = true
			ui.keep_canvas.set_process(true)
			break
	if ui.keep.active_event_id == "twilight_crossroads":
		ui._on_authored_event_choice_id("carry_lamp_oil")
		await _capture("07b_lamp_route_prepared", ui)
	else:
		_resolve_open_event(ui)
	ui._on_finish_interval()
	await _capture("08_assault_phase_3", ui)
	await _resolve_phase(ui)
	await _capture("09_terminal_results", ui)
	_write_manifest()
	ui.queue_free()
	await process_frame
	print("Vertical-slice capture: PASS (%d screens at %s)" % [captured_files.size(), output_dir])
	quit(0)

func _finish_early_terminal_capture(ui: Control) -> bool:
	if ui.screen != "results" or ui.keep.wave_active or ui.keep.has_next_wave() or ui.keep.repair_interval_active:
		return false
	terminal_after_early_phase = true
	await _capture("09_terminal_results", ui)
	_write_manifest()
	ui.queue_free()
	await process_frame
	print("Vertical-slice capture: PASS (%d screens; defense ended before the final authored phase at %s)" % [captured_files.size(), output_dir])
	quit(0)
	return true

func _resolve_phase(ui: Control) -> void:
	if not ui.assault_ready_reason.is_empty():
		ui._toggle_battle_pause()
	ui.battle_paused = true
	while ui.keep.wave_active:
		ui._on_advance_wave()
		await process_frame

func _resolve_open_event(ui: Control) -> void:
	if ui.keep.active_event_id.is_empty():
		return
	var event: Dictionary = ui.keep.current_event()
	var choices: Array = event.get("choices", [])
	if not choices.is_empty():
		ui._on_authored_event_choice_id(String(choices[0].get("id", "")))

func _capture(stem: String, ui: Control) -> void:
	await process_frame
	await process_frame
	var readiness: Dictionary = _capture_readiness(stem, ui)
	if not bool(readiness.get("ready", false)):
		push_error("Capture %s did not reach readiness: %s" % [stem, String(readiness.get("condition", "unknown"))])
		quit(2)
		return
	var image: Image = root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("No framebuffer available for %s" % stem)
		quit(2)
		return
	if image.get_size() != capture_size:
		push_error("Capture %s was %s, expected %s" % [stem, image.get_size(), capture_size])
		quit(2)
		return
	if _image_is_uniform(image):
		push_error("Capture %s was visually uniform before readiness" % stem)
		quit(2)
		return
	var filename: String = "%s.png" % stem
	var path: String = output_dir.path_join(filename)
	var save_error: Error = image.save_png(path)
	if save_error != OK:
		push_error("Could not save capture: %s" % path)
		quit(2)
		return
	captured_files.append(filename)
	state_trace.append({
		"state_id": _evidence_state_id(stem),
		"capture_id": stem,
		"screen": String(ui.screen),
		"wave_index": int(ui.keep.wave_index),
		"wave_active": bool(ui.keep.wave_active),
		"repair_interval_active": bool(ui.keep.repair_interval_active),
		"assault_readiness": String(ui.assault_ready_reason),
		"readiness_condition": String(readiness.get("condition", "")),
		"frames_after_transition": 2,
		"screenshot": filename,
	})
	print("Captured %s (%s)" % [filename, ui.screen])

func _capture_readiness(stem: String, ui: Control) -> Dictionary:
	var state_id := _evidence_state_id(stem)
	match state_id:
		"title":
			return {"ready": ui.screen == "title", "condition": "title screen rendered"}
		"war_council":
			return {"ready": ui.screen == "setup" and ui.keep.scenario_id == capture_scenario_id, "condition": "War Council rendered with selected scenario"}
		"tutorial_keep":
			return {"ready": ui.screen == "title" and ui.tutorial.active and ui.tutorial.current_id() == "intro_keep", "condition": "First Watch keep briefing rendered"}
		"tutorial_resources":
			return {"ready": ui.screen == "title" and ui.tutorial.active and ui.tutorial.current_id() == "intro_resources", "condition": "First Watch resource briefing rendered"}
		"tutorial_cycle":
			return {"ready": ui.screen == "title" and ui.tutorial.active and ui.tutorial.current_id() == "intro_cycle", "condition": "First Watch defense-cycle briefing rendered"}
		"tutorial_war_council":
			return {"ready": ui.screen == "setup" and ui.tutorial.active and ui.tutorial.current_id() == "war_council", "condition": "First Watch War Council rendered"}
		"preparation":
			return {"ready": ui.screen == "preparation", "condition": "Preparation rendered after scenario entry"}
		"forecast":
			return {"ready": ui.screen == "battle" and ui.keep.wave_active and not ui.assault_ready_reason.is_empty(), "condition": "battle tick-zero forecast ready"}
		"battle_wave_1", "battle_wave_2", "battle_wave_3":
			var expected_wave := int(state_id.trim_prefix("battle_wave_"))
			return {"ready": ui.screen == "battle" and ui.keep.wave_active and ui.keep.wave_index == expected_wave, "condition": "battle wave %d authoritative state ready" % expected_wave}
		"recovery":
			return {"ready": ui.screen == "results" and ui.keep.repair_interval_active, "condition": "Recovery rendered with active repair interval"}
		"results":
			return {"ready": ui.screen == "results" and not ui.keep.wave_active and not ui.keep.has_next_wave(), "condition": "terminal Results rendered after final assault"}
	return {"ready": true, "condition": "%s rendered" % state_id}

func _image_is_uniform(image: Image) -> bool:
	var minimum: float = 1.0
	var maximum: float = 0.0
	for sample_y in range(1, 8):
		for sample_x in range(1, 12):
			var point := Vector2i(
				int(float(image.get_width() - 1) * float(sample_x) / 12.0),
				int(float(image.get_height() - 1) * float(sample_y) / 8.0),
			)
			var color: Color = image.get_pixelv(point)
			var luminance: float = color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			minimum = minf(minimum, luminance)
			maximum = maxf(maximum, luminance)
	return maximum - minimum < 0.01

func _evidence_state_id(stem: String) -> String:
	if stem == "01_title":
		return "title"
	if stem == "02_tutorial_keep":
		return "tutorial_keep"
	if stem == "03_tutorial_resources":
		return "tutorial_resources"
	if stem == "04_tutorial_cycle":
		return "tutorial_cycle"
	if stem == "05_tutorial_war_council":
		return "tutorial_war_council"
	if stem == "02_war_council":
		return "war_council"
	if stem.begins_with("03"):
		return "preparation"
	if stem == "04_assault_phase_1":
		return "forecast"
	if stem.begins_with("04"):
		return "battle_wave_1"
	if stem == "05_recovery_phase_1" or stem.begins_with("07"):
		return "recovery"
	if stem == "06_assault_phase_2":
		return "battle_wave_2"
	if stem == "08_assault_phase_3":
		return "battle_wave_3"
	if stem == "09_terminal_results":
		return "results"
	return stem

func _write_manifest() -> void:
	var payload: Dictionary = {
		"schema_version": 1,
		"build_version": String(ProjectSettings.get_setting("application/config/version", "unknown")),
		"resolution": {"width": capture_size.x, "height": capture_size.y},
		"ui_scale_percent": int(ui_scale_percent()),
		"commander": capture_commander_id,
		"scenario": capture_scenario_id,
		"pack_offer_captured": capture_pack_offer,
		"spatial_transition_captured": capture_spatial_transition,
		"route_delay_captured": capture_route_delay,
		"route_reveal_captured": capture_route_reveal,
		"twilight_road_captured": capture_twilight_road,
		"twilight_choice_captured": capture_twilight_choice,
		"starting_defender_inspected": capture_starting_defender,
		"battle_exchange_staged": capture_battle_exchange,
		"battle_exchange_progress": capture_battle_exchange_progress if capture_battle_exchange else null,
		"battle_inspection_requested": capture_battle_inspection,
		"battle_inspection_captured": battle_inspection_completed,
		"repair_feedback_requested": capture_repair_feedback,
		"repair_feedback_captured": repair_feedback_completed,
		"intervention_requested": capture_intervention,
		"intervention_captured": intervention_completed,
		"terminal_after_early_phase": terminal_after_early_phase,
		"setup_only": capture_setup_only,
		"first_plan_transition_captured": capture_first_plan_transition,
		"settings_only": capture_settings_only,
		"tutorial_intro_only": capture_tutorial_intro_only,
		"files": captured_files,
		"debug_ui": OS.get_cmdline_user_args().has("--debug-ui"),
		"human_evidence": false,
		"renderer": String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "unknown")),
		"locale": TranslationServer.get_locale(),
		"state_trace": state_trace,
	}
	var file: FileAccess = FileAccess.open(output_dir.path_join("capture-manifest.json"), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload, "  "))
		file.close()

func _argument_value(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""

func ui_scale_percent() -> float:
	return [0.8, 1.0, 1.25, 1.5, 2.0][capture_scale_index] * 100.0
