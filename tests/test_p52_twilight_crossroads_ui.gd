extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _resolve_wave(ui: Control) -> void:
	while ui.keep.wave_active:
		ui.keep.advance_wave(1.0)

func _inside_horizontal_viewport(control: Control) -> bool:
	var rect: Rect2 = control.get_global_rect()
	return rect.position.x >= -1.0 and rect.end.x <= float(root.size.x) + 1.0

func _apply_layout(ui: Control, viewport_size: Vector2i, scale_index: int) -> void:
	root.content_scale_factor = 1.0
	root.size = viewport_size
	ui.ui_scale_index = scale_index
	ui._apply_ui_scale()
	await process_frame
	await process_frame

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._select_option_metadata(ui.scenario_option, "the_twilight_road")
	ui._on_select_scenario()
	ui._refresh_ui()
	await process_frame
	var council_variation_text: String = String(ui.war_council_choice_panel.summary_label.text)
	_check(council_variation_text.contains("final pressure") and council_variation_text.contains("FOCUS —"), "War Council should disclose the seeded final composition and its preparation emphasis")
	ui._on_confirm_setup()
	ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	for pack_id in ["road_wardens", "crossbow_watch"]:
		ui._select_option_metadata(ui.pack_option, pack_id)
		ui._on_open_pack()
	for placement in [
		["stake_line", Vector2i(1, 2), "ground"],
		["hook_guard", Vector2i(4, 3), "ground"],
		["crossbow_patrol", Vector2i(1, 1), "upper"],
		["watch_banner", Vector2i(4, 1), "upper"],
	]:
		ui.keep.place_piece(placement[0], placement[1], placement[2])
	ui.keep.start_wave("rapid_breakthrough")
	_resolve_wave(ui)
	ui.keep.finish_repair_interval()
	_resolve_wave(ui)
	ui._set_screen("results")
	await process_frame
	await process_frame

	_check(ui.keep.active_event_id == "twilight_crossroads", "phase-two Recovery should open Twilight Crossroads")
	_check(ui.authored_event_panel.visible and String(ui.authored_event_title.text).begins_with("RECOVERY DECISION"), "Recovery should present the event as a player-facing decision")
	_check(not String(ui.authored_event_title.text).contains("AUTHORED EVENT"), "Recovery should not expose implementation vocabulary")
	_check(String(ui.command_panel_title.text) == "MAKE THE RECOVERY CHOICE", "the command rail should lead with the blocking route choice")
	_check(String(ui.guidance_label.text).contains("Choose which route receives the crews"), "the main guidance should explain why recovery is paused")
	_check(not ui.recovery_actions_panel.visible and not ui.recovery_brief_panel.visible, "ordinary recovery controls should wait until the blocking route choice resolves")
	_check(ui.authored_event_choice_buttons.size() == 2 and not ui.authored_event_choice_buttons[0].disabled and not ui.authored_event_choice_buttons[1].disabled, "both route preparations should be available")
	_check(String(ui.authored_event_choice_details[0].text).contains("Every Outrider") and String(ui.authored_event_choice_details[1].text).contains("Every Gloam Knife"), "choice cards should name their exact final-wave consequence")
	_check(root.gui_get_focus_owner() == ui.authored_event_choice_buttons[0], "controller focus should land on the first route choice")

	var authoritative_before_layout: String = JSON.stringify(ui.keep.serialize())
	await _apply_layout(ui, Vector2i(1280, 720), 1)
	ui._focus_screen_control()
	await process_frame
	_check(ui.gameplay_columns.vertical and _inside_horizontal_viewport(ui.authored_event_panel), "1280x720 should stack the route decision without horizontal clipping")
	_check(ui.authored_event_choice_buttons[0].is_visible_in_tree(), "the first route choice should remain reachable at 1280x720")
	await _apply_layout(ui, Vector2i(2560, 1440), 3)
	ui._focus_screen_control()
	await process_frame
	_check(not ui.gameplay_columns.vertical and _inside_horizontal_viewport(ui.authored_event_panel), "2560x1440 at 150 percent should retain a readable two-column route decision")
	_check(JSON.stringify(ui.keep.serialize()) == authoritative_before_layout, "responsive recovery rendering must not mutate the run")

	ui.authored_event_choice_buttons[1].pressed.emit()
	await process_frame
	_check(not ui.authored_event_panel.visible and ui.recovery_actions_panel.visible and ui.recovery_brief_panel.visible and ui.keep.repair_actions_remaining == 1, "choosing lamp oil should reveal ordinary recovery with one action remaining")
	var prepared_forecast: Dictionary = ui.keep.forecast()
	_check(bool(prepared_forecast.get("momentum_delayed", false)) and bool(prepared_forecast.get("concealment_revealed", false)), "the mixed defense plus lamp choice should visibly answer both final routes")
	ui._on_finish_interval()
	await process_frame
	_check(ui.screen == "battle" and ui.keep.wave_index == 3, "closing recovery should enter the combined final assault")
	_check(String(ui.forecast_label.text).contains("Charge: DELAYED") and String(ui.forecast_label.text).contains("Visibility: REVEALED"), "Battle should retain the selected recovery consequence in the forecast")
	_check(String(ui.enemy_label.text).contains("visibility REVEALED"), "the battle roster should expose the lamp-oil result on Gloam Knives")
	_resolve_wave(ui)
	ui._set_screen("results")
	await process_frame
	await process_frame
	var terminal_mastery: String = String(ui.terminal_debrief_panel.causal_label.text)
	_check(terminal_mastery.contains("final pressure") and terminal_mastery.contains("preparation focus"), "terminal Results should retain the seeded composition and preparation emphasis")
	_check(ui.terminal_debrief_panel.visible and terminal_mastery.contains("RECOVERY BRANCH") and terminal_mastery.contains("Stair lamps revealed") and terminal_mastery.contains("COMPLEMENTARY"), "terminal Results should explain the selected route and its build fit")
	_check(terminal_mastery.contains("FORGONE PREPARATION") and terminal_mastery.contains("Road stakes were not reinforced"), "terminal Results should name the route preparation that was declined")
	_check(String(ui.terminal_debrief_panel.replay_label.text).contains("road stakes"), "terminal replay guidance should propose the opposite recovery branch")
	await _apply_layout(ui, Vector2i(2560, 1440), 3)
	ui._refresh_terminal_debrief()
	await process_frame
	await process_frame
	_check(ui.gameplay_columns.vertical and _inside_horizontal_viewport(ui.terminal_debrief_panel), "2560x1440 at 150 percent should stack terminal Results before the debrief clips beyond the right edge")
	_check(ui.terminal_debrief_panel.primary_button.is_visible_in_tree(), "large-text 1440p Results should keep its primary replay action reachable")
	var page_rect: Rect2 = ui.page_scroll.get_global_rect()
	var replay_rect: Rect2 = ui.terminal_debrief_panel.primary_button.get_global_rect()
	_check(replay_rect.position.y >= page_rect.position.y and replay_rect.end.y <= page_rect.end.y, "large-text 1440p Results should scroll the focused replay action into the visible page")

	root.content_scale_factor = 1.0
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P52 Twilight Crossroads UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
