extends SceneTree

var output_dir: String = ""
var captured_files: Array[String] = []
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
var capture_repair_feedback: bool = false

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
	capture_repair_feedback = OS.get_cmdline_user_args().has("--capture-repair-feedback")
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
	await _capture("01_title", ui)
	ui._on_start_quick_playtest()
	if ui.keep.commander_ids().has(capture_commander_id):
		ui._select_option_metadata(ui.commander_option, capture_commander_id)
		ui.keep.select_commander(capture_commander_id)
	if ui.keep.scenario_ids().has(capture_scenario_id):
		ui._select_option_metadata(ui.scenario_option, capture_scenario_id)
		ui.keep.select_scenario(capture_scenario_id)
	if capture_spatial_transition or capture_route_delay or capture_route_reveal or capture_twilight_road or capture_twilight_choice:
		ui.guided_setup = false
	ui._refresh_ui()
	await _capture("02_war_council", ui)
	ui._on_confirm_setup()
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
	if capture_battle_exchange:
		ui.keep_canvas.set_process(true)
		ui.keep_canvas._process(ui.keep_canvas.engagement_duration)
	await _resolve_phase(ui)
	await _capture("05_recovery_phase_1", ui)
	ui._on_finish_interval()
	await _capture("06_assault_phase_2", ui)
	await _resolve_phase(ui)
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
			ui.keep_canvas.set_process(true)
			break
	if ui.keep.active_event_id == "twilight_crossroads":
		ui._on_authored_event_choice_id("carry_lamp_oil")
		await _capture("07b_lamp_route_prepared", ui)
	ui._on_finish_interval()
	await _capture("08_assault_phase_3", ui)
	await _resolve_phase(ui)
	await _capture("09_terminal_results", ui)
	_write_manifest()
	ui.queue_free()
	await process_frame
	print("Vertical-slice capture: PASS (%d screens at %s)" % [captured_files.size(), output_dir])
	quit(0)

func _resolve_phase(ui: Control) -> void:
	if not ui.assault_ready_reason.is_empty():
		ui._toggle_battle_pause()
	ui.battle_paused = true
	while ui.keep.wave_active:
		ui._on_advance_wave()
		await process_frame

func _capture(stem: String, ui: Control) -> void:
	await process_frame
	await process_frame
	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("No framebuffer available for %s" % stem)
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
	print("Captured %s (%s)" % [filename, ui.screen])

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
		"repair_feedback_captured": capture_repair_feedback,
		"files": captured_files,
		"debug_ui": OS.get_cmdline_user_args().has("--debug-ui"),
		"human_evidence": false,
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
