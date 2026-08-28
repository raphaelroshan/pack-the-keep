extends Control

const AuthoredEventPanelView = preload("res://src/ui/authored_event_panel.gd")

const PackKeepState = preload("res://src/core/keep_state.gd")
const PackagedSmoke = preload("res://src/platform/packaged_smoke.gd")
const GREYWATCH_BACKGROUND = preload("res://assets/greywatch_background.png")
const CASTELLAN_PORTRAIT = preload("res://assets/castellan_portrait.png")
const PIKE_ICON = preload("res://assets/pike_squad_icon.png")
const REPAIR_ICON = preload("res://assets/repair_station_icon.png")
const FIRE_ICON = preload("res://assets/fire_team_icon.png")
const SCOUT_ICON = preload("res://assets/scout_post_icon.png")
const GATE_ICON = preload("res://assets/narrow_gate_icon.png")
const RAIDER_ICON = preload("res://assets/raider_icon.png")
const SAPPER_ICON = preload("res://assets/sapper_icon.png")
const CLIMBER_ICON = preload("res://assets/climber_icon.png")
const SAVE_PATH := "user://pack_the_keep_prototype.save"
const SAVE_TEMP_PATH := "user://pack_the_keep_prototype.save.tmp"
const SAVE_BACKUP_PATH := "user://pack_the_keep_prototype.save.bak"
const SETTINGS_SCHEMA_VERSION := 4
const SETTINGS_PATH := "user://pack_the_keep_settings.json"
const SETTINGS_TEMP_PATH := "user://pack_the_keep_settings.json.tmp"
const SETTINGS_BACKUP_PATH := "user://pack_the_keep_settings.json.bak"
const UI_SCALE_PRESETS := [0.8, 1.0, 1.25, 1.5, 2.0]
const WINDOW_SIZE_PRESETS := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440)]
const EFFECTS_VOLUME_PRESETS := [0.25, 0.5, 0.75, 1.0]
const EVENT_FEED_RETENTION_PRESETS := [4, 8, 16, 32]
const RESERVED_CONTROLLER_NAVIGATION_BUTTONS := [0, 11, 12, 13, 14]
const REMAPPABLE_ACTIONS := [
	"battle_pause", "battle_manual_step", "commander_ability", "placement_arm", "placement_cancel",
	"focus_cycle_forward", "focus_enemy", "report_focus"
]
const ACTION_LABELS := {
	"battle_pause": "Pause / resume battle",
	"battle_manual_step": "Advance one battle step",
	"commander_ability": "Commander ability",
	"placement_arm": "Arm placement",
	"placement_cancel": "Cancel placement",
	"focus_cycle_forward": "Cycle focused enemy",
	"focus_enemy": "Inspect focused enemy",
	"report_focus": "Focus combat report"
}

var keep: PackKeepState
var status_label: Label
var forecast_label: Label
var enemy_label: Label
var metrics_label: Label
var combat_explain_label: Label
var availability_label: Label
var pack_preview_label: Label
var inspector_label: Label
var placement_label: Label
var event_label: Label
var log_label: Label
var commander_option: OptionButton
var commander_portrait: TextureRect
var commander_profile_label: Label
var commander_ability_button: Button
var scenario_option: OptionButton
var scenario_preview_label: Label
var authored_event_panel: VBoxContainer
var authored_event_title: Label
var authored_event_setup: Label
var authored_event_choice_buttons: Array[Button] = []
var authored_event_choice_details: Array[Label] = []
var campaign_ledger_panel: VBoxContainer
var campaign_ledger_label: Label
var campaign_modifier_option: OptionButton
var campaign_modifier_button: Button
var pack_option: OptionButton
var piece_option: OptionButton
var floor_option: OptionButton
var doctrine_option: OptionButton
var room_option: OptionButton
var enemy_option: OptionButton
var keep_canvas: Control
var placement_mode: bool = false
var preview_floor: String = "ground"
var preview_origin: Vector2i = Vector2i.ZERO
var preview_valid: bool = false
var selected_instance_id: String = ""
var inspected_text: String = "Click a room or placed piece on the keep to inspect its authoritative state."
var gameplay_columns: BoxContainer
var gameplay_main_column: VBoxContainer
var page_scroll: ScrollContainer
var command_scroll: ScrollContainer
var command_panel: PanelContainer
var title_card: PanelContainer
var build_identity_label: Label
var screen_label: Label
var screen_hint: Label
var art_banner: TextureRect
var main_title_label: Label
var main_subtitle_label: Label
var setup_overview_panel: PanelContainer
var setup_summary_panel: PanelContainer
var setup_overview_label: Label
var settings_overview_panel: PanelContainer
var command_panel_title: Label
var setup_confirm_button: Button
var setup_back_button: Button
var settings_back_button: Button
var title_custom_button: Button
var title_settings_button: Button
var title_continue_button: Button
var pause_button: Button
var manual_step_button: Button
var speed_button: Button
var mute_button: Button
var contrast_button: Button
var reduced_motion_button: Button
var ui_scale_button: Button
var window_mode_button: Button
var resolution_button: Button
var effects_volume_button: Button
var feedback_cue_label: Label
var event_feed_button: Button
var auto_pause_button: Button
var rebind_action_option: OptionButton
var rebind_button: Button
var reset_bindings_button: Button
var binding_summary_label: Label
var input_help_label: Label
var quick_test_button: Button
var screen: String = "title"
var battle_paused: bool = true
var battle_speed_index: int = 1
var audio_muted: bool = false
var high_contrast: bool = false
var reduced_motion: bool = false
var ui_scale_index: int = 1
var window_size_index: int = 1
var fullscreen_enabled: bool = false
var effects_volume_index: int = 3
var event_feed_retention_index: int = 0
var auto_pause_on_threat: bool = false
var save_path: String = SAVE_PATH
var save_temp_path: String = SAVE_TEMP_PATH
var save_backup_path: String = SAVE_BACKUP_PATH
var settings_path: String = SETTINGS_PATH
var settings_temp_path: String = SETTINGS_TEMP_PATH
var settings_backup_path: String = SETTINGS_BACKUP_PATH
var preferences_persistence_enabled: bool = true
var display_application_enabled: bool = true
var rebind_waiting_action: String = ""
var last_auto_pause_wave_index: int = -1
var last_cue_id: String = "none"
var menu_buttons: Dictionary = {}
var setup_controls: Array[Control] = []
var event_controls: Array[Control] = []
var preparation_controls: Array[Control] = []
var battle_controls: Array[Control] = []
var inspection_controls: Array[Control] = []
var run_controls: Array[Control] = []
var settings_controls: Array[Control] = []
var guided_setup: bool = true
var setup_confirmed: bool = false
var settings_return_screen: String = "title"
var audio_player: AudioStreamPlayer
var audio_stream: AudioStreamGenerator
var last_log_size: int = 0
var focused_enemy_index: int = -1
var response_preview_label: Label
var recovery_priority_label: Label
var recovery_actions_panel: VBoxContainer
var recovery_stage_label: Label
var recovery_room_card_title: Label
var recovery_room_card_detail: Label
var recovery_room_button: Button
var recovery_piece_card_title: Label
var recovery_piece_card_detail: Label
var recovery_piece_button: Button
var recovery_assign_card_title: Label
var recovery_assign_card_detail: Label
var recovery_assign_button: Button
var recovery_clear_card_title: Label
var recovery_clear_card_detail: Label
var recovery_clear_button: Button
var finish_interval_button: Button
var guidance_label: Label
var result_explain_label: Label
var scorecard_label: Label
var layout_lens_label: Label
var playtest_button: Button
var playtest_status_label: Label

func _ready() -> void:
	keep = PackKeepState.new(3307)
	_restore_default_input_bindings()
	_ensure_controller_navigation_bindings()
	preferences_persistence_enabled = DisplayServer.get_name() != "headless"
	display_application_enabled = DisplayServer.get_name() != "headless"
	if preferences_persistence_enabled:
		_load_preferences()
	else:
		_apply_ui_scale()
	if DisplayServer.get_name() != "headless":
		_setup_audio()
	_build_ui()
	_set_screen("title")
	if OS.get_cmdline_user_args().has("--packaged-smoke") and OS.get_environment("PACK_THE_KEEP_PACKAGED_SMOKE") == "1":
		call_deferred("_start_packaged_smoke")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		call_deferred("_apply_responsive_layout")

func _start_packaged_smoke() -> void:
	var smoke_harness: Node = PackagedSmoke.new()
	get_tree().root.add_child(smoke_harness)
	smoke_harness.call_deferred("run", self)

func _process(delta: float) -> void:
	if battle_paused or not keep.wave_active:
		return
	var battle_step_before: int = keep.battle_step
	var breach_before: int = keep.breach_level
	var engagement_traces: Array[Dictionary] = _next_engagement_traces()
	var target_snapshot: Dictionary = _combat_target_snapshot()
	var advance_delta: float = delta * _battle_speed()
	if auto_pause_on_threat and battle_step_before == 0 and last_auto_pause_wave_index != keep.wave_index:
		advance_delta = minf(advance_delta, maxf(0.0, 1.0 - keep.battle_clock))
	var result: Dictionary = keep.advance_wave(advance_delta)
	if keep_canvas != null:
		keep_canvas.queue_redraw()
	var target_impacts: Array[Dictionary] = []
	if keep.battle_step > battle_step_before:
		target_impacts = _resolved_target_impacts(target_snapshot)
		if keep_canvas != null:
			keep_canvas.call("show_combat_exchange", engagement_traces, target_impacts)
		_ensure_enemy_focus()
	if bool(result.get("resolved", false)):
		battle_paused = true
		_set_feedback(Color("#bfe8cf"), _outcome_cue(String(result.get("outcome", "unknown"))))
		_set_event("Assault phase resolved: %s. Use the recovery lull before the next pressure arrives." % String(result.get("outcome", "unknown")).replace("_", " "))
		_set_screen("results")
	else:
		if keep.battle_report.size() > last_log_size:
			var exchange_cue: String = "impact" if not target_impacts.is_empty() else "volley" if not engagement_traces.is_empty() else "contact"
			_set_feedback(Color("#d26155") if not target_impacts.is_empty() else Color("#d7a35b"), exchange_cue)
			last_log_size = keep.battle_report.size()
		var first_threat_step: bool = keep.battle_step > battle_step_before and battle_step_before == 0 and last_auto_pause_wave_index != keep.wave_index
		var new_breach: bool = keep.breach_level > breach_before
		if auto_pause_on_threat and (first_threat_step or new_breach):
			battle_paused = true
			if first_threat_step:
				last_auto_pause_wave_index = keep.wave_index
			_play_cue("warning")
			_set_event("Accessibility auto-pause: %s resolved. Inspect the board, then resume when ready." % ("first threat step" if first_threat_step else "new breach"))
			_refresh_ui()
		elif keep.battle_step > battle_step_before:
			_refresh_ui()

func _input(event: InputEvent) -> void:
	if not rebind_waiting_action.is_empty() and _capture_rebind_input(event):
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if _capture_rebind_input(event):
		get_viewport().set_input_as_handled()
		return
	if _handle_named_action(event):
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
	_handle_named_action(event)

func _handle_named_action(event: InputEvent) -> bool:
	if not event.is_pressed() or (event is InputEventKey and event.echo):
		return false
	if event.is_action_pressed("battle_pause"):
		_toggle_battle_pause()
	elif event.is_action_pressed("battle_advance"):
		_on_advance_wave()
	elif event.is_action_pressed("battle_speed_half"):
		_set_battle_speed(0)
	elif event.is_action_pressed("battle_speed_normal"):
		_set_battle_speed(1)
	elif event.is_action_pressed("battle_speed_double"):
		_set_battle_speed(2)
	elif event.is_action_pressed("battle_manual_step"):
		_on_advance_wave()
	elif event.is_action_pressed("placement_arm"):
		_arm_selected_piece()
	elif event.is_action_pressed("placement_cancel"):
		_on_cancel_placement()
	elif event.is_action_pressed("report_focus"):
		_focus_report()
	elif event.is_action_pressed("feedback_mute"):
		_toggle_mute()
	elif event.is_action_pressed("contrast_toggle"):
		_toggle_contrast()
	elif event.is_action_pressed("reduced_motion_toggle"):
		_toggle_reduced_motion()
	elif event.is_action_pressed("focus_cycle_backward"):
		_cycle_enemy_focus(-1)
	elif event.is_action_pressed("focus_cycle_forward"):
		_cycle_enemy_focus(1)
	elif event.is_action_pressed("focus_enemy"):
		_focus_selected_enemy()
	else:
		return false
	return true

func _setup_audio() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_stream = AudioStreamGenerator.new()
	audio_stream.mix_rate = 44100.0
	audio_stream.buffer_length = 0.35
	audio_player.stream = audio_stream
	add_child(audio_player)
	audio_player.play()

func _battle_speed() -> float:
	return [0.5, 1.0, 2.0][battle_speed_index]

func _next_engagement_traces() -> Array[Dictionary]:
	var traces: Array[Dictionary] = []
	if not keep.wave_active:
		return traces
	for enemy_index in range(keep.enemies.size()):
		if bool(keep.enemies[enemy_index].get("defeated", false)):
			continue
		var response: Dictionary = keep.defender_response_preview(enemy_index)
		for attacker in response.get("attackers", []):
			var piece_id: String = String(attacker.get("piece_id", ""))
			var piece: Dictionary = keep.piece_definition(piece_id)
			traces.append({
				"attacker_id": String(attacker.get("id", "")),
				"piece_id": piece_id,
				"style": String(piece.get("combat_style", "melee")),
				"enemy_index": enemy_index,
				"damage": int(attacker.get("damage", 0))
			})
	return traces

func _combat_target_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	for room_id in keep.rooms.keys():
		snapshot["room:%s" % String(room_id)] = keep.room_condition(String(room_id))
	for instance_id in keep.pieces.keys():
		snapshot["piece:%s" % String(instance_id)] = int(keep.pieces[instance_id].get("health", 0))
	return snapshot

func _resolved_target_impacts(before: Dictionary) -> Array[Dictionary]:
	var impacts: Array[Dictionary] = []
	for target_key_value in before.keys():
		var target_key: String = String(target_key_value)
		var parts: PackedStringArray = target_key.split(":", true, 1)
		if parts.size() != 2:
			continue
		var target_kind: String = parts[0]
		var target_id: String = parts[1]
		var after_value: int = int(before[target_key])
		if target_kind == "room" and keep.rooms.has(target_id):
			after_value = keep.room_condition(target_id)
		elif target_kind == "piece" and keep.pieces.has(target_id):
			after_value = int(keep.pieces[target_id].get("health", 0))
		var damage: int = int(before[target_key]) - after_value
		if damage <= 0:
			continue
		var source_enemy_index: int = -1
		for enemy_index in range(keep.enemies.size()):
			if String(keep.enemies[enemy_index].get("target", "")) == target_id and not bool(keep.enemies[enemy_index].get("defeated", false)):
				source_enemy_index = enemy_index
				break
		impacts.append({"target_kind": target_kind, "target_id": target_id, "enemy_index": source_enemy_index, "damage": damage})
	return impacts

func _set_feedback(color: Color, cue_id: String = "") -> void:
	if keep_canvas != null:
		keep_canvas.call("set_feedback", color)
	_play_cue(cue_id if not cue_id.is_empty() else "confirm" if color.g > color.r else "contact")

func _cue_profile(cue_id: String) -> Dictionary:
	var profiles: Dictionary = {
		"warning": {"frequencies": [330.0, 440.0], "duration": 0.055, "gain": 0.9},
		"contact": {"frequencies": [160.0], "duration": 0.085, "gain": 1.0},
		"volley": {"frequencies": [610.0, 780.0], "duration": 0.04, "gain": 0.7},
		"impact": {"frequencies": [135.0, 190.0], "duration": 0.065, "gain": 0.9},
		"confirm": {"frequencies": [480.0], "duration": 0.07, "gain": 0.75},
		"repair": {"frequencies": [390.0, 520.0], "duration": 0.06, "gain": 0.8},
		"ability": {"frequencies": [520.0, 660.0], "duration": 0.065, "gain": 0.9},
		"error": {"frequencies": [140.0], "duration": 0.1, "gain": 1.0},
		"pause": {"frequencies": [300.0], "duration": 0.055, "gain": 0.65},
		"resume": {"frequencies": [500.0], "duration": 0.055, "gain": 0.65},
		"hold": {"frequencies": [520.0, 660.0, 780.0], "duration": 0.055, "gain": 0.85},
		"partial_breach": {"frequencies": [360.0, 250.0], "duration": 0.075, "gain": 0.9},
		"collapse": {"frequencies": [220.0, 150.0], "duration": 0.09, "gain": 1.0}
	}
	return Dictionary(profiles.get(cue_id, {})).duplicate(true)

func _outcome_cue(outcome: String) -> String:
	if outcome in ["hold", "held"]:
		return "hold"
	if outcome == "partial_breach":
		return "partial_breach"
	return "collapse" if outcome == "collapse" else "confirm"

func _play_cue(cue_id: String) -> void:
	var profile: Dictionary = _cue_profile(cue_id)
	if profile.is_empty():
		return
	last_cue_id = cue_id
	if audio_muted:
		return
	for frequency in profile.frequencies:
		_play_tone(float(frequency), float(profile.duration), float(profile.gain))

func _play_tone(frequency: float, duration: float = 0.09, cue_gain: float = 1.0) -> void:
	if audio_player == null or audio_muted:
		return
	var playback: AudioStreamGeneratorPlayback = audio_player.get_stream_playback()
	if playback == null:
		return
	var frame_count: int = int(audio_stream.mix_rate * duration)
	for frame in range(frame_count):
		var envelope: float = 1.0 - float(frame) / float(frame_count)
		var sample: float = sin(TAU * frequency * float(frame) / audio_stream.mix_rate) * 0.08 * _effects_gain() * cue_gain * envelope
		playback.push_frame(Vector2(sample, sample))

func _effects_gain() -> float:
	return float(EFFECTS_VOLUME_PRESETS[effects_volume_index])

func _toggle_battle_pause() -> void:
	if not keep.wave_active:
		_set_event("Pause is available during an active invasion.")
		return
	battle_paused = not battle_paused
	_set_event("Battle paused. Read the forecast and report." if battle_paused else "Battle resumed at %.1fx speed." % _battle_speed())
	_play_cue("pause" if battle_paused else "resume")
	_refresh_ui()

func _set_battle_speed(index: int) -> void:
	battle_speed_index = clampi(index, 0, 2)
	_save_preferences()
	_set_event("Battle speed set to %.1fx. Space pauses; N advances one manual step." % _battle_speed())
	_refresh_ui()

func _cycle_battle_speed() -> void:
	_set_battle_speed((battle_speed_index + 1) % 3)

func _toggle_mute() -> void:
	audio_muted = not audio_muted
	_save_preferences()
	_set_event("Feedback tones muted." if audio_muted else "Feedback tones enabled.")
	_refresh_ui()

func _toggle_contrast() -> void:
	high_contrast = not high_contrast
	if keep_canvas != null:
		keep_canvas.call("set_accessibility", high_contrast)
	_save_preferences()
	_set_event("High-contrast cues enabled." if high_contrast else "Standard color cues restored.")
	_refresh_ui()

func _toggle_reduced_motion() -> void:
	reduced_motion = not reduced_motion
	if keep_canvas != null:
		keep_canvas.call("set_reduced_motion", reduced_motion)
	_save_preferences()
	_set_event("Reduced motion enabled; transient board flashes are suppressed." if reduced_motion else "Standard motion feedback restored.")
	_refresh_ui()

func _set_ui_scale(index: int) -> void:
	ui_scale_index = clampi(index, 0, UI_SCALE_PRESETS.size() - 1)
	_apply_ui_scale()
	_save_preferences()
	_set_event("UI scale set to %d%%. Layout remains scrollable at larger sizes." % int(UI_SCALE_PRESETS[ui_scale_index] * 100.0))
	_refresh_ui()

func _cycle_ui_scale() -> void:
	_set_ui_scale((ui_scale_index + 1) % UI_SCALE_PRESETS.size())

func _toggle_fullscreen() -> void:
	fullscreen_enabled = not fullscreen_enabled
	_apply_display_settings()
	_save_preferences()
	_set_event("Fullscreen enabled." if fullscreen_enabled else "Windowed mode restored at %s." % _window_size_text())
	_refresh_ui()

func _set_window_size(index: int) -> void:
	window_size_index = clampi(index, 0, WINDOW_SIZE_PRESETS.size() - 1)
	if window_size_index == 3 and ui_scale_index < 2:
		ui_scale_index = 2
	_apply_display_settings()
	_apply_ui_scale()
	_save_preferences()
	_set_event("Windowed resolution set to %s%s%s." % [_window_size_text(), " for the next windowed session" if fullscreen_enabled else "", " with 125% UI scale for 1440p readability" if window_size_index == 3 and ui_scale_index == 2 else ""])
	_refresh_ui()

func _cycle_window_size() -> void:
	_set_window_size((window_size_index + 1) % WINDOW_SIZE_PRESETS.size())

func _set_effects_volume(index: int) -> void:
	effects_volume_index = clampi(index, 0, EFFECTS_VOLUME_PRESETS.size() - 1)
	_save_preferences()
	_set_event("Effects volume set to %d%%." % int(_effects_gain() * 100.0))
	_refresh_ui()

func _cycle_effects_volume() -> void:
	_set_effects_volume((effects_volume_index + 1) % EFFECTS_VOLUME_PRESETS.size())

func _set_event_feed_retention(index: int) -> void:
	event_feed_retention_index = clampi(index, 0, EVENT_FEED_RETENTION_PRESETS.size() - 1)
	_save_preferences()
	_set_event("Combat event feed now retains the newest %d entries." % _event_feed_retention())
	_refresh_ui()

func _cycle_event_feed_retention() -> void:
	_set_event_feed_retention((event_feed_retention_index + 1) % EVENT_FEED_RETENTION_PRESETS.size())

func _event_feed_retention() -> int:
	return int(EVENT_FEED_RETENTION_PRESETS[event_feed_retention_index])

func _toggle_auto_pause_on_threat() -> void:
	auto_pause_on_threat = not auto_pause_on_threat
	_save_preferences()
	_set_event("Threat auto-pause enabled; real-time play stops after the first threat step and new breaches." if auto_pause_on_threat else "Threat auto-pause disabled.")
	_refresh_ui()

func _window_size_text() -> String:
	var size: Vector2i = WINDOW_SIZE_PRESETS[window_size_index]
	return "%d×%d" % [size.x, size.y]

func _apply_display_settings() -> void:
	if not display_application_enabled:
		return
	if fullscreen_enabled:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = WINDOW_SIZE_PRESETS[window_size_index]

func _apply_ui_scale() -> void:
	get_window().content_scale_factor = float(UI_SCALE_PRESETS[ui_scale_index])
	_apply_responsive_layout()

func _apply_responsive_layout() -> void:
	if gameplay_columns == null:
		return
	var logical_width: float = size.x
	var stacked: bool = logical_width < 1160.0
	gameplay_columns.vertical = stacked
	gameplay_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if gameplay_main_column != null:
		gameplay_main_column.custom_minimum_size.x = 810.0
		gameplay_main_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if command_panel != null:
		command_panel.custom_minimum_size.x = 810.0 if stacked else 360.0 if logical_width >= 1500.0 else 292.0
		command_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if stacked else Control.SIZE_SHRINK_BEGIN
	if keep_canvas != null:
		keep_canvas.custom_minimum_size.y = 452.0 if not stacked and size.y >= 900.0 else 346.0
		keep_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		keep_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _begin_rebind(action: String = "") -> void:
	if action.is_empty() and rebind_action_option != null and rebind_action_option.selected >= 0:
		action = String(rebind_action_option.get_item_metadata(rebind_action_option.selected))
	if not action in REMAPPABLE_ACTIONS:
		return
	rebind_waiting_action = action
	if rebind_button != null:
		rebind_button.text = "Press a key or controller button…"
	_set_event("Listening for a new %s binding. Escape cancels." % String(ACTION_LABELS.get(action, action)))

func _capture_rebind_input(event: InputEvent) -> bool:
	if rebind_waiting_action.is_empty():
		return false
	if event is InputEventKey:
		if not event.pressed or event.echo:
			return true
		if event.physical_keycode == KEY_ESCAPE:
			rebind_waiting_action = ""
			_refresh_binding_controls()
			_set_event("Input rebinding cancelled.")
			return true
		_replace_binding_family(rebind_waiting_action, _normalized_binding(event))
	elif event is InputEventJoypadButton:
		if not event.pressed:
			return true
		if event.button_index in RESERVED_CONTROLLER_NAVIGATION_BUTTONS:
			_set_event("That controller button is reserved for menu navigation. Choose another button or press Escape to cancel.")
			return true
		_replace_binding_family(rebind_waiting_action, _normalized_binding(event))
	else:
		return true
	var action: String = rebind_waiting_action
	rebind_waiting_action = ""
	_save_preferences()
	_refresh_binding_controls()
	_set_event("Updated %s binding." % String(ACTION_LABELS.get(action, action)))
	return true

func _normalized_binding(event: InputEvent) -> InputEvent:
	if event is InputEventKey:
		var key_event: InputEventKey = InputEventKey.new()
		key_event.physical_keycode = event.physical_keycode
		key_event.shift_pressed = event.shift_pressed
		key_event.ctrl_pressed = event.ctrl_pressed
		key_event.alt_pressed = event.alt_pressed
		key_event.meta_pressed = event.meta_pressed
		return key_event
	var source_joy: InputEventJoypadButton = event as InputEventJoypadButton
	var joy_event: InputEventJoypadButton = InputEventJoypadButton.new()
	joy_event.button_index = source_joy.button_index
	return joy_event

func _replace_binding_family(action: String, replacement: InputEvent) -> void:
	for other_action in REMAPPABLE_ACTIONS:
		if other_action == action:
			continue
		for existing in InputMap.action_get_events(other_action):
			if _bindings_match(existing, replacement):
				InputMap.action_erase_event(other_action, existing)
	var retained: Array[InputEvent] = []
	for existing in InputMap.action_get_events(action):
		if replacement is InputEventKey and existing is InputEventKey:
			continue
		if replacement is InputEventJoypadButton and existing is InputEventJoypadButton:
			continue
		retained.append(existing)
	InputMap.action_erase_events(action)
	for existing in retained:
		InputMap.action_add_event(action, existing)
	InputMap.action_add_event(action, replacement)

func _bindings_match(first: InputEvent, second: InputEvent) -> bool:
	if first is InputEventJoypadButton and second is InputEventJoypadButton:
		return first.button_index == second.button_index
	if first is InputEventKey and second is InputEventKey:
		return first.physical_keycode == second.physical_keycode and first.shift_pressed == second.shift_pressed and first.ctrl_pressed == second.ctrl_pressed and first.alt_pressed == second.alt_pressed and first.meta_pressed == second.meta_pressed
	return false

func _restore_default_input_bindings() -> void:
	for action in REMAPPABLE_ACTIONS:
		if not InputMap.has_action(action):
			continue
		var definition: Variant = ProjectSettings.get_setting("input/%s" % action, {})
		if not definition is Dictionary or not definition.get("events", []) is Array:
			continue
		InputMap.action_erase_events(action)
		for event in definition.get("events", []):
			if event is InputEvent:
				InputMap.action_add_event(action, event)

func _ensure_controller_navigation_bindings() -> void:
	var navigation_buttons: Dictionary = {
		"ui_accept": 0, "ui_cancel": 1, "ui_up": 11,
		"ui_down": 12, "ui_left": 13, "ui_right": 14
	}
	for action in navigation_buttons:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var button_index: int = int(navigation_buttons[action])
		var already_bound: bool = false
		for event in InputMap.action_get_events(action):
			if event is InputEventJoypadButton and event.button_index == button_index:
				already_bound = true
				break
		if not already_bound:
			var joy_event: InputEventJoypadButton = InputEventJoypadButton.new()
			joy_event.button_index = button_index
			InputMap.action_add_event(action, joy_event)

func _reset_input_bindings() -> void:
	rebind_waiting_action = ""
	_restore_default_input_bindings()
	_save_preferences()
	_refresh_binding_controls()
	_set_event("Keyboard and controller bindings restored to project defaults.")

func _serialize_input_bindings() -> Dictionary:
	var serialized: Dictionary = {}
	for action in REMAPPABLE_ACTIONS:
		var events: Array[Dictionary] = []
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				events.append({
					"type": "key", "physical_keycode": int(event.physical_keycode),
					"shift": event.shift_pressed, "ctrl": event.ctrl_pressed,
					"alt": event.alt_pressed, "meta": event.meta_pressed
				})
			elif event is InputEventJoypadButton:
				events.append({"type": "joypad_button", "button_index": event.button_index})
		serialized[action] = events
	return serialized

func _apply_saved_input_bindings(saved: Variant) -> void:
	if not saved is Dictionary:
		return
	for action in REMAPPABLE_ACTIONS:
		var records: Variant = saved.get(action)
		if not records is Array:
			continue
		var events: Array[InputEvent] = []
		for record in records:
			if not record is Dictionary:
				continue
			if record.get("type") == "key" and (record.get("physical_keycode") is int or record.get("physical_keycode") is float) and float(record.get("physical_keycode")) == floor(float(record.get("physical_keycode"))) and int(record.get("physical_keycode")) > 0:
				var key_event: InputEventKey = InputEventKey.new()
				key_event.physical_keycode = int(record.physical_keycode)
				key_event.shift_pressed = bool(record.get("shift", false))
				key_event.ctrl_pressed = bool(record.get("ctrl", false))
				key_event.alt_pressed = bool(record.get("alt", false))
				key_event.meta_pressed = bool(record.get("meta", false))
				events.append(key_event)
			elif record.get("type") == "joypad_button" and (record.get("button_index") is int or record.get("button_index") is float) and float(record.get("button_index")) == floor(float(record.get("button_index"))) and int(record.get("button_index")) >= 0 and int(record.get("button_index")) < 128 and int(record.get("button_index")) not in RESERVED_CONTROLLER_NAVIGATION_BUTTONS:
				var joy_event: InputEventJoypadButton = InputEventJoypadButton.new()
				joy_event.button_index = int(record.button_index)
				events.append(joy_event)
		if events.is_empty():
			continue
		InputMap.action_erase_events(action)
		for event in events:
			InputMap.action_add_event(action, event)

func _binding_text(action: String) -> String:
	var labels: Array[String] = []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey or event is InputEventJoypadButton:
			labels.append(event.as_text())
	return " / ".join(labels) if not labels.is_empty() else "Unbound"

func _refresh_binding_controls() -> void:
	if rebind_button == null or binding_summary_label == null or rebind_action_option == null:
		return
	if not rebind_waiting_action.is_empty():
		rebind_button.text = "Press a key or controller button…"
		return
	rebind_button.text = "Rebind selected action"
	var action: String = String(rebind_action_option.get_item_metadata(rebind_action_option.selected))
	binding_summary_label.text = "%s: %s" % [String(ACTION_LABELS.get(action, action)), _binding_text(action)]

func _load_preferences() -> void:
	battle_speed_index = 1
	audio_muted = false
	high_contrast = false
	reduced_motion = false
	ui_scale_index = 1
	window_size_index = 1
	fullscreen_enabled = false
	effects_volume_index = 3
	event_feed_retention_index = 0
	auto_pause_on_threat = false
	_restore_default_input_bindings()
	var selected: Dictionary = _load_preferences_candidate(settings_path)
	if not bool(selected.get("ok", false)):
		selected = _load_preferences_candidate(settings_backup_path)
	if not bool(selected.get("ok", false)):
		_apply_ui_scale()
		_apply_display_settings()
		return
	var payload: Dictionary = selected.payload
	var schema_version: int = int(selected.schema_version)
	var saved_speed: Variant = payload.get("battle_speed_index")
	if (saved_speed is int or saved_speed is float) and float(saved_speed) == floor(float(saved_speed)) and int(saved_speed) >= 0 and int(saved_speed) <= 2:
		battle_speed_index = int(saved_speed)
	if payload.get("audio_muted") is bool:
		audio_muted = bool(payload.audio_muted)
	if payload.get("high_contrast") is bool:
		high_contrast = bool(payload.high_contrast)
	if payload.get("reduced_motion") is bool:
		reduced_motion = bool(payload.reduced_motion)
	if schema_version >= 2:
		var saved_scale: Variant = payload.get("ui_scale_index")
		if (saved_scale is int or saved_scale is float) and float(saved_scale) == floor(float(saved_scale)) and int(saved_scale) >= 0 and int(saved_scale) < UI_SCALE_PRESETS.size():
			ui_scale_index = int(saved_scale)
		_apply_saved_input_bindings(payload.get("input_bindings", {}))
	if schema_version >= 3:
		var saved_window_size: Variant = payload.get("window_size_index")
		if (saved_window_size is int or saved_window_size is float) and float(saved_window_size) == floor(float(saved_window_size)) and int(saved_window_size) >= 0 and int(saved_window_size) < WINDOW_SIZE_PRESETS.size():
			window_size_index = int(saved_window_size)
		if payload.get("fullscreen_enabled") is bool:
			fullscreen_enabled = bool(payload.fullscreen_enabled)
		var saved_effects_volume: Variant = payload.get("effects_volume_index")
		if (saved_effects_volume is int or saved_effects_volume is float) and float(saved_effects_volume) == floor(float(saved_effects_volume)) and int(saved_effects_volume) >= 0 and int(saved_effects_volume) < EFFECTS_VOLUME_PRESETS.size():
			effects_volume_index = int(saved_effects_volume)
	if schema_version >= 4:
		var saved_feed_retention: Variant = payload.get("event_feed_retention_index")
		if (saved_feed_retention is int or saved_feed_retention is float) and float(saved_feed_retention) == floor(float(saved_feed_retention)) and int(saved_feed_retention) >= 0 and int(saved_feed_retention) < EVENT_FEED_RETENTION_PRESETS.size():
			event_feed_retention_index = int(saved_feed_retention)
		if payload.get("auto_pause_on_threat") is bool:
			auto_pause_on_threat = bool(payload.auto_pause_on_threat)
	_apply_ui_scale()
	_apply_display_settings()

func _load_preferences_candidate(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "reason": "is missing"}
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		return {"ok": false, "reason": "is not valid JSON settings"}
	var payload: Dictionary = parser.data
	var schema_value: Variant = payload.get("schema_version")
	if not (schema_value is int or schema_value is float) or float(schema_value) != floor(float(schema_value)):
		return {"ok": false, "reason": "has an invalid schema version"}
	var schema_version: int = int(schema_value)
	if schema_version < 1 or schema_version > SETTINGS_SCHEMA_VERSION:
		return {"ok": false, "reason": "uses an unsupported schema version"}
	return {"ok": true, "payload": payload, "schema_version": schema_version}

func _save_preferences() -> bool:
	if not preferences_persistence_enabled:
		return true
	var file: FileAccess = FileAccess.open(settings_temp_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"schema_version": SETTINGS_SCHEMA_VERSION, "battle_speed_index": battle_speed_index, "audio_muted": audio_muted, "high_contrast": high_contrast, "reduced_motion": reduced_motion, "ui_scale_index": ui_scale_index, "input_bindings": _serialize_input_bindings(), "window_size_index": window_size_index, "fullscreen_enabled": fullscreen_enabled, "effects_volume_index": effects_volume_index, "event_feed_retention_index": event_feed_retention_index, "auto_pause_on_threat": auto_pause_on_threat}))
	file.flush()
	file.close()
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		return false
	if FileAccess.file_exists(settings_backup_path):
		directory.remove(settings_backup_path.get_file())
	if FileAccess.file_exists(settings_path):
		var backup_error: Error = directory.rename(settings_path.get_file(), settings_backup_path.get_file())
		if backup_error != OK:
			return false
	var rename_error: Error = directory.rename(settings_temp_path.get_file(), settings_path.get_file())
	if rename_error != OK:
		if FileAccess.file_exists(settings_backup_path):
			directory.rename(settings_backup_path.get_file(), settings_path.get_file())
		return false
	if FileAccess.file_exists(settings_backup_path):
		directory.remove(settings_backup_path.get_file())
	return true

func _focus_report() -> void:
	if log_label != null:
		log_label.grab_focus()
	_set_event("Causal report focused. Use the command table to intervene.")

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color("#17141d")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	page_scroll = ScrollContainer.new()
	page_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	page_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(page_scroll)

	var margin: MarginContainer = MarginContainer.new()
	margin.custom_minimum_size = Vector2(0, 720)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	page_scroll.add_child(margin)

	var shell: VBoxContainer = VBoxContainer.new()
	shell.add_theme_constant_override("separation", 10)
	margin.add_child(shell)

	var menu_bar: HBoxContainer = HBoxContainer.new()
	menu_bar.add_theme_constant_override("separation", 8)
	screen_label = Label.new()
	screen_label.custom_minimum_size = Vector2(150, 0)
	screen_label.text = "PACK THE KEEP"
	screen_label.add_theme_font_size_override("font_size", 16)
	screen_label.add_theme_color_override("font_color", Color("#e2bd84"))
	menu_bar.add_child(screen_label)
	var navigation_labels: Dictionary = {
		"title": "Home", "setup": "Briefing", "preparation": "Prepare",
		"battle": "Battle", "results": "Report", "settings": "Settings"
	}
	for menu_item in ["title", "setup", "preparation", "battle", "results", "settings"]:
		var menu_button: Button = Button.new()
		menu_button.text = String(navigation_labels[menu_item])
		menu_button.pressed.connect(func() -> void: _on_navigation_requested(String(menu_item)))
		_style_button(menu_button, false)
		menu_bar.add_child(menu_button)
		menu_buttons[menu_item] = menu_button
	screen_hint = Label.new()
	screen_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	screen_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	screen_hint.add_theme_color_override("font_color", Color("#aab1b2"))
	menu_bar.add_child(screen_hint)
	shell.add_child(menu_bar)

	art_banner = TextureRect.new()
	art_banner.texture = GREYWATCH_BACKGROUND
	art_banner.custom_minimum_size = Vector2(0, 150)
	art_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art_banner.modulate = Color(1.0, 1.0, 1.0, 0.78)
	shell.add_child(art_banner)

	title_card = _build_title_card()
	shell.add_child(title_card)

	var columns: BoxContainer = BoxContainer.new()
	columns.vertical = ui_scale_index >= 2
	columns.add_theme_constant_override("separation", 14)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gameplay_columns = columns
	shell.add_child(columns)

	var left: VBoxContainer = VBoxContainer.new()
	left.custom_minimum_size = Vector2(810, 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 8)
	gameplay_main_column = left
	columns.add_child(left)

	main_title_label = Label.new()
	main_title_label.text = "PACK THE KEEP — GREYWATCH"
	main_title_label.add_theme_font_size_override("font_size", 28)
	main_title_label.add_theme_color_override("font_color", Color("#e2bd84"))
	left.add_child(main_title_label)

	main_subtitle_label = Label.new()
	main_subtitle_label.text = "Greywatch’s defense: connect the floors, read the doctrine, hold what matters."
	main_subtitle_label.add_theme_color_override("font_color", Color("#c0b2c8"))
	left.add_child(main_subtitle_label)

	setup_overview_panel = _build_overview_panel(
		"THE DEFENSE BRIEF",
		"Choose a commander lens and an authored scenario before touching the board. The guided route enters Gatehouse Lock with a readable two-piece baseline; custom setup leaves placement in your hands."
	)
	left.add_child(setup_overview_panel)
	setup_summary_panel = PanelContainer.new()
	_style_panel(setup_summary_panel, Color("#1e2830"), Color("#45606b"))
	left.add_child(setup_summary_panel)
	setup_overview_label = Label.new()
	setup_overview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	setup_overview_label.custom_minimum_size = Vector2(748, 118)
	setup_overview_label.add_theme_font_size_override("font_size", 16)
	setup_overview_label.add_theme_color_override("font_color", Color("#f0dca8"))
	setup_summary_panel.add_child(setup_overview_label)

	settings_overview_panel = _build_overview_panel(
		"READABILITY BEFORE PRESSURE",
		"Display, audio, input, and pacing preferences live on their own screen. They never alter the deterministic keep state, seed, target selection, or battle outcome."
	)
	left.add_child(settings_overview_panel)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size = Vector2(800, 36)
	status_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color("#f2e5d1"))
	left.add_child(status_label)
	guidance_label = Label.new()
	guidance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guidance_label.custom_minimum_size = Vector2(800, 64)
	guidance_label.add_theme_color_override("font_color", Color("#f0dca8"))
	left.add_child(guidance_label)
	playtest_button = Button.new()
	playtest_button.custom_minimum_size = Vector2(800, 36)
	playtest_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	playtest_button.pressed.connect(_on_playtest_primary_action)
	left.add_child(playtest_button)
	playtest_status_label = Label.new()
	playtest_status_label.custom_minimum_size = Vector2(800, 24)
	playtest_status_label.add_theme_color_override("font_color", Color("#8bd1b4"))
	left.add_child(playtest_status_label)

	keep_canvas = KeepCanvas.new()
	keep_canvas.custom_minimum_size = Vector2(810, 346)
	keep_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	keep_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	keep_canvas.keep = keep
	keep_canvas.connect("map_hovered", Callable(self, "_on_map_hovered"))
	keep_canvas.connect("map_clicked", Callable(self, "_on_map_clicked"))
	keep_canvas.connect("enemy_clicked", Callable(self, "_on_enemy_clicked"))
	keep_canvas.connect("timeline_enemy_clicked", Callable(self, "_on_timeline_enemy_clicked"))
	left.add_child(keep_canvas)

	forecast_label = Label.new()
	forecast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	forecast_label.custom_minimum_size = Vector2(800, 48)
	forecast_label.add_theme_color_override("font_color", Color("#d8c389"))
	left.add_child(forecast_label)

	enemy_label = Label.new()
	enemy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	enemy_label.custom_minimum_size = Vector2(800, 42)
	enemy_label.add_theme_color_override("font_color", Color("#e89270"))
	left.add_child(enemy_label)

	metrics_label = Label.new()
	metrics_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	metrics_label.custom_minimum_size = Vector2(800, 28)
	metrics_label.add_theme_color_override("font_color", Color("#aab1b2"))
	left.add_child(metrics_label)
	result_explain_label = Label.new()
	result_explain_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_explain_label.custom_minimum_size = Vector2(800, 118)
	result_explain_label.add_theme_color_override("font_color", Color("#f0dca8"))
	left.add_child(result_explain_label)
	scorecard_label = Label.new()
	scorecard_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scorecard_label.custom_minimum_size = Vector2(800, 126)
	scorecard_label.add_theme_color_override("font_color", Color("#c9bfd0"))
	left.add_child(scorecard_label)
	combat_explain_label = Label.new()
	combat_explain_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combat_explain_label.custom_minimum_size = Vector2(800, 36)
	combat_explain_label.add_theme_color_override("font_color", Color("#d8c389"))
	left.add_child(combat_explain_label)
	placement_label = Label.new()
	placement_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	placement_label.custom_minimum_size = Vector2(800, 42)
	placement_label.add_theme_color_override("font_color", Color("#8bd1b4"))
	left.add_child(placement_label)

	event_label = Label.new()
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_label.custom_minimum_size = Vector2(800, 72)
	event_label.add_theme_color_override("font_color", Color("#e2bd84"))
	left.add_child(event_label)

	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.custom_minimum_size = Vector2(800, 70)
	log_label.add_theme_color_override("font_color", Color("#aab1b2"))
	left.add_child(log_label)

	command_panel = PanelContainer.new()
	command_panel.custom_minimum_size = Vector2(810, 0) if ui_scale_index >= 2 else Vector2(292, 0)
	command_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if ui_scale_index >= 2 else Control.SIZE_SHRINK_BEGIN
	_style_panel(command_panel, Color("#211c29"), Color("#4e4357"), 8)
	columns.add_child(command_panel)
	command_scroll = ScrollContainer.new()
	command_scroll.custom_minimum_size = Vector2(286, 520)
	command_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	command_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	command_panel.add_child(command_scroll)
	var controls: VBoxContainer = VBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	controls.custom_minimum_size = Vector2(278, 0)
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command_scroll.add_child(controls)

	command_panel_title = Label.new()
	command_panel_title.text = "COMMAND TABLE"
	command_panel_title.add_theme_font_size_override("font_size", 19)
	command_panel_title.add_theme_color_override("font_color", Color("#e2bd84"))
	controls.add_child(command_panel_title)
	input_help_label = Label.new()
	input_help_label.text = "Tab/D-pad moves focus. Enter/A confirms. Screen-specific actions stay grouped below."
	input_help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	input_help_label.add_theme_font_size_override("font_size", 10)
	input_help_label.add_theme_color_override("font_color", Color("#aab1b2"))
	controls.add_child(input_help_label)
	var event_section: VBoxContainer = _build_command_section("DECISION")
	controls.add_child(event_section)
	event_controls.append(event_section)
	var setup_section: VBoxContainer = _build_command_section("CHOOSE THE DEFENSE")
	controls.add_child(setup_section)
	setup_controls.append(setup_section)
	var preparation_section: VBoxContainer = _build_command_section("BUILD THE ANSWER")
	controls.add_child(preparation_section)
	preparation_controls.append(preparation_section)
	var battle_section: VBoxContainer = _build_command_section("CONTROL THE PRESSURE")
	controls.add_child(battle_section)
	battle_controls.append(battle_section)
	var inspection_section: VBoxContainer = _build_command_section("INSPECT")
	controls.add_child(inspection_section)
	inspection_controls.append(inspection_section)
	var run_section: VBoxContainer = _build_command_section("RUN")
	controls.add_child(run_section)
	run_controls.append(run_section)
	var settings_section: VBoxContainer = _build_command_section("SETTINGS & ACCESSIBILITY")
	controls.add_child(settings_section)
	settings_controls.append(settings_section)
	commander_portrait = TextureRect.new()
	commander_portrait.texture = CASTELLAN_PORTRAIT
	commander_portrait.custom_minimum_size = Vector2(0, 92)
	commander_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	commander_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	commander_portrait.tooltip_text = "Commander portrait; Warden portrait art is pending the next asset-generation window."
	setup_section.add_child(commander_portrait)
	commander_profile_label = Label.new()
	commander_profile_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	commander_profile_label.custom_minimum_size = Vector2(292, 78)
	commander_profile_label.add_theme_color_override("font_color", Color("#c9bfd0"))
	setup_section.add_child(commander_profile_label)
	layout_lens_label = Label.new()
	layout_lens_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout_lens_label.custom_minimum_size = Vector2(292, 142)
	layout_lens_label.add_theme_color_override("font_color", Color("#d8c389"))
	preparation_section.add_child(layout_lens_label)

	commander_option = OptionButton.new()
	for commander_id in keep.commander_ids():
		commander_option.add_item(String(keep.commander_definition(commander_id).get("name", commander_id)))
		commander_option.set_item_metadata(commander_option.item_count - 1, commander_id)
	commander_option.item_selected.connect(func(_index: int) -> void: _on_select_commander())
	var commander_group: VBoxContainer = _labeled_control("Commander lens", commander_option)
	setup_section.add_child(commander_group)

	scenario_option = OptionButton.new()
	scenario_option.item_selected.connect(func(_index: int) -> void: _on_select_scenario())
	for scenario_id in keep.scenario_ids():
		scenario_option.add_item(String(keep.scenario_definition(scenario_id).get("name", scenario_id)))
		scenario_option.set_item_metadata(scenario_option.item_count - 1, scenario_id)
	var scenario_group: VBoxContainer = _labeled_control("Defensive scenario", scenario_option)
	setup_section.add_child(scenario_group)
	scenario_preview_label = Label.new()
	scenario_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scenario_preview_label.custom_minimum_size = Vector2(292, 82)
	scenario_preview_label.add_theme_color_override("font_color", Color("#d8c389"))
	setup_section.add_child(scenario_preview_label)
	authored_event_panel = AuthoredEventPanelView.new()
	authored_event_panel.build(2)
	authored_event_panel.choice_requested.connect(_on_authored_event_choice_id)
	event_section.add_child(authored_event_panel)
	authored_event_title = authored_event_panel.title_label
	authored_event_setup = authored_event_panel.setup_label
	authored_event_choice_details = authored_event_panel.choice_details
	authored_event_choice_buttons = authored_event_panel.choice_buttons
	campaign_ledger_panel = VBoxContainer.new()
	campaign_ledger_panel.add_theme_constant_override("separation", 4)
	setup_section.add_child(campaign_ledger_panel)
	campaign_ledger_label = Label.new()
	campaign_ledger_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	campaign_ledger_label.add_theme_color_override("font_color", Color("#bfe8cf"))
	campaign_ledger_panel.add_child(campaign_ledger_label)
	campaign_modifier_option = OptionButton.new()
	campaign_modifier_option.add_item("No modifier")
	campaign_modifier_option.set_item_metadata(0, "")
	for modifier_id in keep.modifier_ids():
		campaign_modifier_option.add_item(String(keep.modifier_definition(modifier_id).get("name", modifier_id)))
		campaign_modifier_option.set_item_metadata(campaign_modifier_option.item_count - 1, modifier_id)
	_select_option_metadata(campaign_modifier_option, keep.equipped_modifier_id)
	campaign_modifier_option.item_selected.connect(func(_index: int) -> void: _refresh_campaign_ledger())
	campaign_ledger_panel.add_child(_labeled_control("Ledger choice", campaign_modifier_option))
	campaign_modifier_button = Button.new()
	campaign_modifier_button.pressed.connect(_on_toggle_campaign_modifier)
	campaign_ledger_panel.add_child(campaign_modifier_button)
	setup_confirm_button = Button.new()
	setup_confirm_button.text = "Enter Keep — Recommended Layout"
	setup_confirm_button.tooltip_text = "Confirm this briefing and enter Preparation with the guided two-piece baseline."
	setup_confirm_button.pressed.connect(_on_confirm_setup)
	_style_button(setup_confirm_button, true)
	left.add_child(setup_confirm_button)
	setup_controls.append(setup_confirm_button)
	setup_back_button = Button.new()
	setup_back_button.text = "Back to Main Menu"
	setup_back_button.pressed.connect(func() -> void: _set_screen("title"))
	left.add_child(setup_back_button)
	setup_controls.append(setup_back_button)

	pack_option = OptionButton.new()
	pack_option.item_selected.connect(func(_index: int) -> void: _refresh_pack_preview())
	for pack_id in keep.pack_ids():
		pack_option.add_item(String(keep.pack_definition(pack_id).get("name", pack_id)))
		pack_option.set_item_metadata(pack_option.item_count - 1, pack_id)
	var pack_group: VBoxContainer = _labeled_control("Pack offer", pack_option)
	preparation_section.add_child(pack_group)
	var pack_button: Button = Button.new()
	pack_button.text = "Open pack"
	pack_button.pressed.connect(_on_open_pack)
	preparation_section.add_child(pack_button)
	availability_label = Label.new()
	availability_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	availability_label.add_theme_color_override("font_color", Color("#aab1b2"))
	preparation_section.add_child(availability_label)
	pack_preview_label = Label.new()
	pack_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pack_preview_label.custom_minimum_size = Vector2(292, 112)
	pack_preview_label.add_theme_color_override("font_color", Color("#d8c389"))
	preparation_section.add_child(pack_preview_label)
	var reserve_button: Button = Button.new()
	reserve_button.text = "Reserve selected pack"
	reserve_button.tooltip_text = "Hold this offer without granting its pieces; opening it later consumes a preparation opening and its shown material cost."
	reserve_button.pressed.connect(_on_reserve_pack)
	preparation_section.add_child(reserve_button)
	var asset_strip: VBoxContainer = VBoxContainer.new()
	for asset_row in [[PIKE_ICON, REPAIR_ICON, FIRE_ICON, SCOUT_ICON, GATE_ICON], [RAIDER_ICON, SAPPER_ICON, CLIMBER_ICON]]:
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		for asset in asset_row:
			var icon: TextureRect = TextureRect.new()
			icon.texture = asset
			icon.custom_minimum_size = Vector2(42, 42)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			row.add_child(icon)
		asset_strip.add_child(row)
	preparation_section.add_child(asset_strip)

	piece_option = OptionButton.new()
	piece_option.item_selected.connect(func(_index: int) -> void: _on_piece_option_changed())
	for piece_id in keep.piece_ids():
		piece_option.add_item(String(keep.piece_definition(piece_id).get("name", piece_id)))
		piece_option.set_item_metadata(piece_option.item_count - 1, piece_id)
		piece_option.set_item_disabled(piece_option.item_count - 1, not keep.available_pieces.has(String(piece_id)))
	var piece_group: VBoxContainer = _labeled_control("Piece", piece_option)
	inspection_section.add_child(piece_group)

	floor_option = OptionButton.new()
	floor_option.item_selected.connect(func(_index: int) -> void: _arm_selected_piece())
	floor_option.add_item("Ground floor")
	floor_option.set_item_metadata(0, "ground")
	floor_option.add_item("Upper floor")
	floor_option.set_item_metadata(1, "upper")
	var floor_group: VBoxContainer = _labeled_control("Placement floor", floor_option)
	preparation_section.add_child(floor_group)
	room_option = OptionButton.new()
	room_option.item_selected.connect(func(_index: int) -> void: _refresh_recovery_action_cards())
	_refresh_room_options()
	var room_group: VBoxContainer = _labeled_control("Room", room_option)
	inspection_section.add_child(room_group)
	var map_place_button: Button = Button.new()
	map_place_button.text = "Arm selected piece for map"
	map_place_button.tooltip_text = "Select a cell on either keep floor. The green footprint is authoritative; red means the state will reject it."
	map_place_button.pressed.connect(_arm_selected_piece)
	preparation_section.add_child(map_place_button)
	var recommended_layout_button: Button = Button.new()
	recommended_layout_button.text = "Use recommended starter layout"
	recommended_layout_button.tooltip_text = "Places Pike Squad and Narrow Gate in a readable first-battle arrangement; each placement remains authoritative."
	recommended_layout_button.pressed.connect(_on_recommended_layout)
	preparation_section.add_child(recommended_layout_button)
	var remove_piece_button: Button = Button.new()
	remove_piece_button.text = "Remove selected piece"
	remove_piece_button.tooltip_text = "Preparation-only: remove the inspected piece so you can test a different layout. Materials are not refunded."
	remove_piece_button.pressed.connect(_on_remove_piece)
	preparation_section.add_child(remove_piece_button)
	var cancel_place_button: Button = Button.new()
	cancel_place_button.text = "Cancel map placement"
	cancel_place_button.pressed.connect(_on_cancel_placement)
	preparation_section.add_child(cancel_place_button)
	doctrine_option = OptionButton.new()
	for doctrine_id in keep.doctrine_ids():
		doctrine_option.add_item(String(keep.doctrine_definition(doctrine_id).get("name", doctrine_id)))
		doctrine_option.set_item_metadata(doctrine_option.item_count - 1, doctrine_id)
	var doctrine_group: VBoxContainer = _labeled_control("Invasion doctrine", doctrine_option)
	preparation_section.add_child(doctrine_group)
	preparation_section.move_child(layout_lens_label, preparation_section.get_child_count() - 1)
	recovery_actions_panel = VBoxContainer.new()
	recovery_actions_panel.add_theme_constant_override("separation", 6)
	controls.add_child(recovery_actions_panel)
	var recovery_heading: Label = Label.new()
	recovery_heading.text = "RECOVERY ACTIONS"
	recovery_heading.add_theme_font_size_override("font_size", 16)
	recovery_heading.add_theme_color_override("font_color", Color("#e2bd84"))
	recovery_actions_panel.add_child(recovery_heading)
	recovery_stage_label = Label.new()
	recovery_stage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recovery_stage_label.add_theme_color_override("font_color", Color("#bfe8cf"))
	recovery_actions_panel.add_child(recovery_stage_label)

	var room_card: Dictionary = _build_recovery_action_card("REPAIR ROOM", "Repair selected room", _on_repair_room)
	recovery_room_card_title = room_card.title
	recovery_room_card_detail = room_card.detail
	recovery_room_button = room_card.button
	recovery_actions_panel.add_child(room_card.panel)

	var piece_card: Dictionary = _build_recovery_action_card("REPAIR PIECE", "Repair selected piece", _on_repair_piece)
	recovery_piece_card_title = piece_card.title
	recovery_piece_card_detail = piece_card.detail
	recovery_piece_button = piece_card.button
	recovery_actions_panel.add_child(piece_card.panel)

	var assign_card: Dictionary = _build_recovery_action_card("ASSIGN SPECIALIST", "Assign selected piece", _on_assign_piece)
	recovery_assign_card_title = assign_card.title
	recovery_assign_card_detail = assign_card.detail
	recovery_assign_button = assign_card.button
	recovery_actions_panel.add_child(assign_card.panel)

	var clear_card: Dictionary = _build_recovery_action_card("CLEAR ASSIGNMENT", "Clear selected assignment", _on_clear_assignment)
	recovery_clear_card_title = clear_card.title
	recovery_clear_card_detail = clear_card.detail
	recovery_clear_button = clear_card.button
	recovery_actions_panel.add_child(clear_card.panel)

	finish_interval_button = Button.new()
	finish_interval_button.text = "Finish recovery"
	finish_interval_button.tooltip_text = "Close recovery explicitly; unused actions are recorded and never spent automatically."
	finish_interval_button.pressed.connect(_on_finish_interval)
	recovery_actions_panel.add_child(finish_interval_button)
	controls.move_child(recovery_actions_panel, 3)

	pause_button = Button.new()
	pause_button.text = "Pause battle (Space)"
	pause_button.tooltip_text = "Pause or resume automatic battle timing. Manual N steps remain deterministic."
	pause_button.pressed.connect(_toggle_battle_pause)
	battle_section.add_child(pause_button)
	manual_step_button = Button.new()
	manual_step_button.text = "Step once while paused (N)"
	manual_step_button.tooltip_text = "Resolve exactly one deterministic combat tick while the assault is paused."
	manual_step_button.pressed.connect(_on_advance_wave)
	battle_section.add_child(manual_step_button)
	speed_button = Button.new()
	speed_button.text = "Speed: 1.0x (1/2/3)"
	speed_button.tooltip_text = "Cycle battle speed; speed changes timing only, never outcomes."
	speed_button.pressed.connect(_cycle_battle_speed)
	battle_section.add_child(speed_button)

	commander_ability_button = Button.new()
	commander_ability_button.text = "Lockdown (Castellan)"
	commander_ability_button.tooltip_text = "Use the active commander ability once per assault phase."
	commander_ability_button.pressed.connect(_on_use_ability)
	battle_section.add_child(commander_ability_button)

	enemy_option = OptionButton.new()
	var enemy_group: VBoxContainer = _labeled_control("Enemy to inspect", enemy_option)
	battle_section.add_child(enemy_group)
	var inspect_enemy_button: Button = Button.new()
	inspect_enemy_button.text = "Inspect selected enemy"
	inspect_enemy_button.pressed.connect(_on_inspect_enemy)
	battle_section.add_child(inspect_enemy_button)
	inspector_label = Label.new()
	inspector_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector_label.custom_minimum_size = Vector2(292, 92)
	inspector_label.add_theme_color_override("font_color", Color("#c9bfd0"))
	inspection_section.add_child(inspector_label)
	response_preview_label = Label.new()
	response_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	response_preview_label.custom_minimum_size = Vector2(292, 120)
	response_preview_label.add_theme_color_override("font_color", Color("#d8c389"))
	battle_section.add_child(response_preview_label)
	recovery_priority_label = Label.new()
	recovery_priority_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recovery_priority_label.custom_minimum_size = Vector2(292, 80)
	recovery_priority_label.add_theme_color_override("font_color", Color("#bfe8cf"))
	recovery_actions_panel.add_child(recovery_priority_label)
	var save_button: Button = Button.new()
	save_button.text = "Save keep state"
	save_button.pressed.connect(_on_save)
	run_section.add_child(save_button)
	var load_button: Button = Button.new()
	load_button.text = "Load keep state"
	load_button.pressed.connect(_on_load)
	run_section.add_child(load_button)
	var reset_button: Button = Button.new()
	reset_button.text = "Return to Briefing / New Run"
	reset_button.pressed.connect(_on_reset_run)
	run_section.add_child(reset_button)
	mute_button = Button.new()
	mute_button.text = "Feedback tones: ON"
	mute_button.pressed.connect(_toggle_mute)
	settings_section.add_child(mute_button)
	contrast_button = Button.new()
	contrast_button.text = "High-contrast cues: OFF"
	contrast_button.pressed.connect(_toggle_contrast)
	contrast_button.tooltip_text = "Adds shape/text cues so doctrine and damage are not color-dependent."
	settings_section.add_child(contrast_button)
	reduced_motion_button = Button.new()
	reduced_motion_button.text = "Reduced motion: OFF"
	reduced_motion_button.tooltip_text = "Suppress transient board flashes without changing simulation timing or outcomes."
	reduced_motion_button.pressed.connect(_toggle_reduced_motion)
	settings_section.add_child(reduced_motion_button)
	ui_scale_button = Button.new()
	ui_scale_button.text = "UI scale: 100%"
	ui_scale_button.tooltip_text = "Cycle 80%, 100%, 125%, and 150% interface scaling; the command rail remains scrollable."
	ui_scale_button.pressed.connect(_cycle_ui_scale)
	settings_section.add_child(ui_scale_button)
	window_mode_button = Button.new()
	window_mode_button.text = "Window mode: Windowed"
	window_mode_button.tooltip_text = "Toggle fullscreen without forgetting the selected windowed resolution."
	window_mode_button.pressed.connect(_toggle_fullscreen)
	settings_section.add_child(window_mode_button)
	resolution_button = Button.new()
	resolution_button.text = "Window size: 1280×720"
	resolution_button.tooltip_text = "Cycle the windowed resolution; fullscreen keeps this value for later restoration."
	resolution_button.pressed.connect(_cycle_window_size)
	settings_section.add_child(resolution_button)
	effects_volume_button = Button.new()
	effects_volume_button.text = "Effects volume: 100%"
	effects_volume_button.tooltip_text = "Adjust generated feedback tones independently from the mute preference."
	effects_volume_button.pressed.connect(_cycle_effects_volume)
	settings_section.add_child(effects_volume_button)
	feedback_cue_label = Label.new()
	feedback_cue_label.text = "Last feedback cue: NONE"
	feedback_cue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_cue_label.add_theme_color_override("font_color", Color("#aab1b2"))
	settings_section.add_child(feedback_cue_label)
	event_feed_button = Button.new()
	event_feed_button.text = "Event feed: newest 4"
	event_feed_button.tooltip_text = "Change only how many authoritative report entries are shown; the complete report remains saved."
	event_feed_button.pressed.connect(_cycle_event_feed_retention)
	settings_section.add_child(event_feed_button)
	auto_pause_button = Button.new()
	auto_pause_button.text = "Threat auto-pause: OFF"
	auto_pause_button.tooltip_text = "Pause after first contact in each assault phase and after a new breach; resume manually when ready."
	auto_pause_button.pressed.connect(_toggle_auto_pause_on_threat)
	settings_section.add_child(auto_pause_button)
	rebind_action_option = OptionButton.new()
	for action in REMAPPABLE_ACTIONS:
		rebind_action_option.add_item(String(ACTION_LABELS.get(action, action)))
		rebind_action_option.set_item_metadata(rebind_action_option.item_count - 1, action)
	rebind_action_option.item_selected.connect(func(_index: int) -> void: _refresh_binding_controls())
	var rebind_group: VBoxContainer = _labeled_control("Input action", rebind_action_option)
	settings_section.add_child(rebind_group)
	binding_summary_label = Label.new()
	binding_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	binding_summary_label.add_theme_color_override("font_color", Color("#c9bfd0"))
	settings_section.add_child(binding_summary_label)
	rebind_button = Button.new()
	rebind_button.text = "Rebind selected action"
	rebind_button.tooltip_text = "Capture one keyboard key or controller button while preserving the other device path."
	rebind_button.pressed.connect(func() -> void: _begin_rebind())
	settings_section.add_child(rebind_button)
	reset_bindings_button = Button.new()
	reset_bindings_button.text = "Reset input bindings"
	reset_bindings_button.pressed.connect(_reset_input_bindings)
	settings_section.add_child(reset_bindings_button)
	settings_back_button = Button.new()
	settings_back_button.text = "Back"
	settings_back_button.pressed.connect(_on_close_settings)
	left.add_child(settings_back_button)
	settings_controls.append(settings_back_button)
	_style_buttons_recursive(menu_bar)
	_style_buttons_recursive(command_panel)
	_style_button(quick_test_button, true)
	_style_button(playtest_button, true)
	_style_button(setup_confirm_button, true)
	_refresh_binding_controls()

func _build_title_card() -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 330)
	_style_panel(card, Color("#211c29"), Color("#6f5947"))
	var content: VBoxContainer = VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 12)
	card.add_child(content)
	var heading: Label = Label.new()
	heading.text = "PACK THE KEEP"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 42)
	heading.add_theme_color_override("font_color", Color("#e2bd84"))
	content.add_child(heading)
	var copy: Label = Label.new()
	copy.text = "Choose a doctrine. Shape the keep. Read the invasion before it breaks you.\nA deliberate top-down defense built for pausing, inspecting, and adapting."
	copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	copy.add_theme_font_size_override("font_size", 17)
	copy.add_theme_color_override("font_color", Color("#c0b2c8"))
	content.add_child(copy)
	var pillars: HBoxContainer = HBoxContainer.new()
	pillars.alignment = BoxContainer.ALIGNMENT_CENTER
	pillars.add_theme_constant_override("separation", 10)
	for pillar in [
		["CHOOSE", "Commander and scenario define what matters."],
		["BUILD", "Packs become a readable two-floor defense."],
		["HOLD", "Pause, inspect pressure, then recover deliberately."]
	]:
		pillars.add_child(_build_small_info_card(String(pillar[0]), String(pillar[1])))
	content.add_child(pillars)
	build_identity_label = Label.new()
	build_identity_label.name = "BuildIdentityLabel"
	build_identity_label.text = "PRE-ALPHA • BUILD %s • HUMAN EVIDENCE PENDING" % String(ProjectSettings.get_setting("application/config/version", "unknown"))
	build_identity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	build_identity_label.add_theme_color_override("font_color", Color("#aab1b2"))
	content.add_child(build_identity_label)
	quick_test_button = Button.new()
	quick_test_button.text = "Start Game — Quick Playtest"
	quick_test_button.tooltip_text = "Review the guided Gatehouse Lock briefing before entering a recommended starter defense."
	quick_test_button.custom_minimum_size = Vector2(300, 44)
	quick_test_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	quick_test_button.pressed.connect(_on_start_quick_playtest)
	_style_button(quick_test_button, true)
	content.add_child(quick_test_button)
	var secondary_actions: HBoxContainer = HBoxContainer.new()
	secondary_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	secondary_actions.add_theme_constant_override("separation", 8)
	title_custom_button = Button.new()
	title_custom_button.text = "Custom Defense"
	title_custom_button.tooltip_text = "Choose any commander and scenario, then build from an empty preparation board."
	title_custom_button.custom_minimum_size = Vector2(180, 34)
	title_custom_button.pressed.connect(_on_start_custom_setup)
	_style_button(title_custom_button, false)
	secondary_actions.add_child(title_custom_button)
	title_continue_button = Button.new()
	title_continue_button.text = "Continue Saved Run"
	title_continue_button.tooltip_text = "Load the latest valid primary or backup save and return to its correct phase."
	title_continue_button.custom_minimum_size = Vector2(180, 34)
	title_continue_button.pressed.connect(_on_continue_saved_run)
	_style_button(title_continue_button, false)
	secondary_actions.add_child(title_continue_button)
	title_settings_button = Button.new()
	title_settings_button.text = "Settings"
	title_settings_button.custom_minimum_size = Vector2(120, 34)
	title_settings_button.pressed.connect(_on_open_settings)
	_style_button(title_settings_button, false)
	secondary_actions.add_child(title_settings_button)
	content.add_child(secondary_actions)
	return card

func _build_overview_panel(title_text: String, body_text: String) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(800, 118)
	_style_panel(panel, Color("#211c29"), Color("#55495f"))
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	panel.add_child(body)
	var heading: Label = Label.new()
	heading.text = title_text
	heading.add_theme_font_size_override("font_size", 22)
	heading.add_theme_color_override("font_color", Color("#e2bd84"))
	body.add_child(heading)
	var copy: Label = Label.new()
	copy.text = body_text
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_theme_font_size_override("font_size", 16)
	copy.add_theme_color_override("font_color", Color("#c9bfd0"))
	body.add_child(copy)
	return panel

func _build_small_info_card(title_text: String, body_text: String) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(220, 74)
	_style_panel(panel, Color("#292231"), Color("#4e4357"), 8)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 3)
	panel.add_child(body)
	var heading: Label = Label.new()
	heading.text = title_text
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_color_override("font_color", Color("#e2bd84"))
	body.add_child(heading)
	var copy: Label = Label.new()
	copy.text = body_text
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	copy.add_theme_font_size_override("font_size", 11)
	copy.add_theme_color_override("font_color", Color("#aab1b2"))
	body.add_child(copy)
	return panel

func _build_command_section(title_text: String) -> VBoxContainer:
	var section: VBoxContainer = VBoxContainer.new()
	section.add_theme_constant_override("separation", 6)
	var heading: Label = Label.new()
	heading.text = title_text
	heading.add_theme_font_size_override("font_size", 15)
	heading.add_theme_color_override("font_color", Color("#e2bd84"))
	section.add_child(heading)
	return section

func _style_panel(panel: PanelContainer, background: Color, border: Color, radius: int = 10) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16
	style.content_margin_top = 14
	style.content_margin_right = 16
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)

func _style_button(button: Button, primary: bool) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color("#8f5f3d") if primary else Color("#302838")
	normal.border_color = Color("#e2bd84") if primary else Color("#5c4e65")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(6)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	button.add_theme_stylebox_override("normal", normal)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color("#aa7247") if primary else Color("#403548")
	button.add_theme_stylebox_override("hover", hover)
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color("#70472f") if primary else Color("#241f2a")
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color("#fff4df"))

func _style_buttons_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			_style_button(child, false)
		_style_buttons_recursive(child)

func _set_screen(next_screen: String) -> void:
	screen = next_screen
	var gameplay_screen: bool = screen in ["preparation", "battle", "results"]
	if gameplay_columns:
		gameplay_columns.visible = screen != "title"
	if title_card:
		title_card.visible = screen == "title"
	if art_banner:
		art_banner.visible = screen in ["title", "setup"]
		art_banner.custom_minimum_size.y = 100 if screen == "setup" else 150
	if main_title_label:
		main_title_label.visible = screen != "title"
	if main_subtitle_label:
		main_subtitle_label.visible = screen != "title"
	if setup_overview_panel:
		setup_overview_panel.visible = screen == "setup"
	if setup_overview_label:
		setup_overview_label.visible = screen == "setup"
	if setup_summary_panel:
		setup_summary_panel.visible = screen == "setup"
	if settings_overview_panel:
		settings_overview_panel.visible = screen == "settings"
	if status_label:
		status_label.visible = gameplay_screen
	if guidance_label:
		guidance_label.visible = gameplay_screen
	if playtest_button:
		playtest_button.visible = gameplay_screen
	if playtest_status_label:
		playtest_status_label.visible = gameplay_screen
	if keep_canvas:
		keep_canvas.visible = gameplay_screen
	if forecast_label:
		forecast_label.visible = screen in ["preparation", "battle"]
	if enemy_label:
		enemy_label.visible = screen == "battle"
	if metrics_label:
		metrics_label.visible = screen in ["battle", "results"]
	if result_explain_label:
		result_explain_label.visible = screen == "results"
	if scorecard_label:
		scorecard_label.visible = screen == "results"
	if combat_explain_label:
		combat_explain_label.visible = screen == "battle"
	if placement_label:
		placement_label.visible = screen == "preparation"
	if event_label:
		event_label.visible = screen in ["preparation", "battle"]
	if log_label:
		log_label.visible = screen == "battle"
	_set_group_visibility(setup_controls, screen == "setup")
	_set_group_visibility(preparation_controls, screen == "preparation")
	_set_group_visibility(battle_controls, screen == "battle")
	_set_group_visibility(inspection_controls, gameplay_screen)
	_set_group_visibility(run_controls, gameplay_screen)
	_set_group_visibility(settings_controls, screen == "settings")
	_set_group_visibility(event_controls, screen in ["preparation", "results"] and keep != null and not keep.active_event_id.is_empty())
	if screen_label:
		screen_label.text = "PACK THE KEEP / %s" % ("Briefing" if screen == "setup" else "Report" if screen == "results" else screen.capitalize())
	if main_title_label:
		if screen == "setup":
			main_title_label.text = "PLAYTEST BRIEFING"
			main_subtitle_label.text = "Choose the lens and pressure first; the board comes next."
		elif screen == "settings":
			main_title_label.text = "SETTINGS & ACCESSIBILITY"
			main_subtitle_label.text = "Tune readability and input without touching the simulation."
		else:
			main_title_label.text = "%s — %s" % [String(keep.keep_definition().get("name", "The Keep")).to_upper(), screen.to_upper()]
			main_subtitle_label.text = "Build a visible answer, inspect pressure, and preserve a recovery option."
	if command_panel_title:
		command_panel_title.text = {
			"setup": "BRIEFING CONTROLS", "preparation": "PREPARATION TOOLS",
			"battle": "BATTLE CONTROLS", "results": "RECOVERY & REPORT",
			"settings": "SETTINGS"
		}.get(screen, "COMMAND TABLE")
	if input_help_label:
		input_help_label.text = {
			"setup": "Choose the strategic context here. The board stays out of the way until the briefing is confirmed.",
			"preparation": "Open a pack, select a piece, then arm placement and click the fort. The main action starts the assault in real time.",
			"battle": "The assault runs continuously. Space pauses; N resolves one deterministic tick while paused.",
			"results": "Use the two recovery actions deliberately. The next assault phase resumes only after explicit confirmation.",
			"settings": "Every option here is presentation-only and remains separate from authoritative run state."
		}.get(screen, "Tab/D-pad moves focus. Enter/A confirms.")
	if screen_hint:
		if screen == "setup":
			screen_hint.text = "1 Briefing  ›  2 Prepare  ›  3 Battle  ›  4 Report"
		elif screen == "preparation":
			screen_hint.text = "Place and assign before opening the next doctrine."
		elif screen == "battle":
			screen_hint.text = "The assault is live; pause to inspect before spending the commander ability."
		elif screen == "results":
			if keep and keep.repair_interval_active and keep.has_next_wave():
				screen_hint.text = "Repair or assign during the lull, then release the next assault phase."
			else:
				screen_hint.text = "Read the report, repair what matters, then return to preparation."
		elif screen == "settings":
			screen_hint.text = "Presentation settings are saved separately from the run."
		else:
			screen_hint.text = "A compact two-floor defense about pressure and recovery."
	_refresh_ui()
	_refresh_navigation()
	call_deferred("_focus_screen_control")
	if screen == "results" and keep and keep.repair_interval_active:
		call_deferred("_focus_recovery_controls")

func _focus_screen_control() -> void:
	var target: Control
	if screen == "title":
		target = quick_test_button
	elif screen == "setup":
		target = commander_option
	elif screen == "preparation":
		target = playtest_button if not playtest_button.disabled else pack_option
	elif screen == "battle":
		target = pause_button
	elif screen == "results" and recovery_actions_panel.visible:
		target = recovery_room_button
	elif screen == "results":
		target = playtest_button
	elif screen == "settings":
		target = ui_scale_button
	else:
		target = menu_buttons.get("title")
	if target == null or not target.is_visible_in_tree():
		return
	target.grab_focus()
	if command_scroll != null and command_panel.is_ancestor_of(target):
		command_scroll.ensure_control_visible(target)
	if page_scroll != null:
		if ui_scale_index >= 2 and command_panel.is_ancestor_of(target):
			page_scroll.ensure_control_visible(target)
		else:
			page_scroll.scroll_horizontal = 0
			page_scroll.scroll_vertical = 0

func _focus_recovery_controls() -> void:
	if command_scroll and recovery_actions_panel and recovery_actions_panel.visible:
		command_scroll.scroll_vertical = 0

func _set_group_visibility(nodes: Array[Control], visible: bool) -> void:
	for node in nodes:
		if node != null:
			node.visible = visible

func _refresh_navigation() -> void:
	if menu_buttons.is_empty():
		return
	for target in menu_buttons.keys():
		var available: bool = true
		if target == "battle":
			available = keep.wave_active
		elif target == "results":
			available = keep.repair_interval_active or not keep.wave_history.is_empty()
		elif target == "preparation":
			available = setup_confirmed and keep.scenario_active and not keep.wave_active and not keep.repair_interval_active
		elif target == "setup":
			available = not keep.wave_active and not keep.repair_interval_active
		menu_buttons[target].disabled = not available or target == screen

func _on_navigation_requested(target: String) -> void:
	if target == "settings":
		_on_open_settings()
		return
	if target == "setup" and screen == "title":
		_on_start_custom_setup()
		return
	if target == "battle" and not keep.wave_active:
		return
	if target == "results" and keep.wave_history.is_empty() and not keep.repair_interval_active:
		return
	if target == "preparation" and (not setup_confirmed or not keep.scenario_active or keep.wave_active or keep.repair_interval_active):
		return
	_set_screen(target)

func _labeled_control(label_text: String, control: Control) -> VBoxContainer:
	var group: VBoxContainer = VBoxContainer.new()
	var label: Label = Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", Color("#c0b2c8"))
	group.add_child(label)
	group.add_child(control)
	return group

func _build_recovery_action_card(title_text: String, button_text: String, callback: Callable) -> Dictionary:
	var panel: PanelContainer = PanelContainer.new()
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 3)
	panel.add_child(body)
	var title: Label = Label.new()
	title.text = title_text
	title.add_theme_color_override("font_color", Color("#e2bd84"))
	body.add_child(title)
	var detail: Label = Label.new()
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.custom_minimum_size = Vector2(270, 72)
	detail.add_theme_font_size_override("font_size", 11)
	detail.add_theme_color_override("font_color", Color("#c9bfd0"))
	body.add_child(detail)
	var button: Button = Button.new()
	button.text = button_text
	button.pressed.connect(callback)
	body.add_child(button)
	return {"panel": panel, "title": title, "detail": detail, "button": button}

func _selected_id(option: OptionButton) -> String:
	if option.selected < 0:
		return ""
	return String(option.get_item_metadata(option.selected))

func _select_option_metadata(option: OptionButton, target: String) -> void:
	for index in range(option.item_count):
		if String(option.get_item_metadata(index)) == target:
			option.select(index)
			return

func _on_piece_option_changed() -> void:
	selected_instance_id = ""
	if keep.repair_interval_active:
		_clear_placement_mode()
		_refresh_ui()
		return
	_arm_selected_piece()

func _next_slot(piece_id: String, floor: String) -> Vector2i:
	var index: int = 0
	for instance in keep.pieces.values():
		if String(instance.get("floor", "ground")) == floor:
			index += 1
	var size: Vector2i = keep.piece_definition(piece_id).size
	var x: int = 1 + (index % 4) * 2
	var y: int = 1 + (index / 4) * 2
	if x + size.x > PackKeepState.GRID_SIZE.x:
		x = 0
	if y + size.y > PackKeepState.GRID_SIZE.y:
		y = 0
	return Vector2i(x, y)

func _on_select_commander() -> void:
	_run_result(keep.select_commander(_selected_id(commander_option)), "Commander")
	_refresh_scenario_preview()

func _on_select_scenario() -> void:
	var result: Dictionary = keep.select_scenario(_selected_id(scenario_option))
	_run_result(result, "Scenario")
	_refresh_room_options()
	_refresh_scenario_preview()
	if bool(result.get("ok", false)):
		var preview: Dictionary = keep.scenario_preview()
		var doctrine_id: String = String(preview.get("starting_doctrine", "gate_assault"))
		for index in range(doctrine_option.item_count):
			if String(doctrine_option.get_item_metadata(index)) == doctrine_id:
				doctrine_option.select(index)
				break

func _refresh_scenario_preview() -> void:
	if scenario_preview_label == null:
		return
	var preview: Dictionary = keep.scenario_preview(_selected_id(scenario_option))
	if not bool(preview.get("ok", false)):
		scenario_preview_label.text = "SCENARIO — %s" % String(preview.get("reason", "unavailable"))
		return
	var pack_names: Array[String] = []
	for pack_id in preview.get("recommended_packs", []):
		pack_names.append(String(keep.pack_definition(String(pack_id)).get("name", pack_id)))
	scenario_preview_label.text = "SCENARIO — %s / %s\nObjective: %s\nLesson: %s\nRecommended doctrine: %s\nAssault phases: %d | Seed variation: %s" % [String(preview.get("keep_name", "Keep")), String(preview.get("name", "")), String(preview.get("objective", "")), String(preview.get("lesson", "")), " + ".join(pack_names), int(preview.get("wave_count", 0)), String(preview.get("variation_id", "standard"))]

func _refresh_room_options() -> void:
	if room_option == null:
		return
	var selected_room_id: String = _selected_id(room_option)
	room_option.clear()
	for room_id in keep.room_definitions().keys():
		var definition: Dictionary = keep.room_definition(String(room_id))
		room_option.add_item(String(definition.get("name", room_id)))
		room_option.set_item_metadata(room_option.item_count - 1, String(room_id))
	if not selected_room_id.is_empty():
		_select_option_metadata(room_option, selected_room_id)

func _refresh_authored_event() -> void:
	if authored_event_panel == null:
		return
	authored_event_panel.render(keep.current_event())
	_set_group_visibility(event_controls, screen in ["preparation", "results"] and not keep.active_event_id.is_empty())

func _on_authored_event_choice(index: int) -> void:
	if index < 0 or index >= authored_event_choice_buttons.size():
		return
	var choice_id: String = String(authored_event_choice_buttons[index].get_meta("choice_id", ""))
	_on_authored_event_choice_id(choice_id)

func _on_authored_event_choice_id(choice_id: String) -> void:
	_run_result(keep.choose_event_option(choice_id), "Event")

func _refresh_campaign_ledger() -> void:
	if campaign_ledger_panel == null:
		return
	var modifier_id: String = _selected_id(campaign_modifier_option)
	var equipped: bool = keep.equipped_modifier_id == modifier_id
	var ledger_text: String = ""
	if modifier_id.is_empty():
		var current_name: String = "None" if keep.equipped_modifier_id.is_empty() else String(keep.modifier_definition(keep.equipped_modifier_id).get("name", keep.equipped_modifier_id))
		ledger_text = "CAMPAIGN LEDGER — EQUIPPED: %s\nSelected: No modifier\nRun the authored baseline without an information trade-off or challenge rule." % current_name
	else:
		var definition: Dictionary = keep.modifier_definition(modifier_id)
		var unlocked: bool = keep.unlocked_modifier_ids.has(modifier_id)
		var status: String = "EQUIPPED" if equipped else "UNLOCKED" if unlocked else "LOCKED"
		var effect_text: String = _modifier_effect_text(definition)
		ledger_text = "CAMPAIGN LEDGER — %s\n%s\n%s\nQuestion: %s\nLimitation: %s" % [status, String(definition.get("name", modifier_id)), effect_text, String(definition.get("question", "")), String(definition.get("limitation", ""))]
	campaign_ledger_label.text = "%s%s%s" % [ledger_text, _event_ledger_text(), _regional_report_text()]
	var target_id: String = "" if equipped else modifier_id
	var preview: Dictionary = keep.modifier_equip_preview(target_id)
	if modifier_id.is_empty():
		campaign_modifier_button.text = "Unequip for next run" if not keep.equipped_modifier_id.is_empty() else "No modifier equipped"
	else:
		var unlocked: bool = keep.unlocked_modifier_ids.has(modifier_id)
		campaign_modifier_button.text = "Unequip for next run" if equipped else "Equip for next run" if unlocked else "Complete The Relief Road to unlock"
	campaign_modifier_button.disabled = not bool(preview.get("ok", false))
	campaign_modifier_button.tooltip_text = String(preview.get("message", preview.get("reason", "")))

func _modifier_effect_text(definition: Dictionary) -> String:
	var effect: String = String(definition.get("effect", ""))
	if effect == "reveal_wave_composition":
		return "Effect: reveal the next authored assault composition. Cost: %d less starting morale." % int(definition.get("starting_morale_cost", 0))
	if effect == "enemy_health_bonus":
		return "Challenge: every enemy begins each assault phase with +%d health. Starting morale is unchanged." % int(definition.get("enemy_health_bonus", 0))
	return String(definition.get("short_role", "Unknown modifier effect."))

func _event_ledger_text() -> String:
	var snapshot: Dictionary = keep.event_ledger_snapshot(5)
	var entries: Array = snapshot.get("entries", [])
	var flags: Array = snapshot.get("flags", [])
	if entries.is_empty() and flags.is_empty():
		return "\nRECENT EVENTS — None resolved in this run."
	var rows: Array[String] = []
	if not entries.is_empty():
		var history_heading: String = "RECENT EVENTS — newest %d of %d" % [entries.size(), int(snapshot.get("total", entries.size()))] if bool(snapshot.get("truncated", false)) else "RECENT EVENTS — newest first"
		rows.append(history_heading)
		for entry in entries:
			rows.append("P%d %s → %s" % [int(entry.get("wave", 0)), _event_ledger_name(entry), String(entry.get("visible_result", ""))])
	if not flags.is_empty():
		rows.append("RUN FLAGS")
		for flag in flags:
			rows.append("%s: %s" % [String(flag.get("id", "flag")).replace("_", " ").capitalize(), "yes" if bool(flag.get("value", false)) else "no"])
	return "\n%s" % "\n".join(rows)

func _event_ledger_name(entry: Dictionary) -> String:
	var stable_name: String = String(entry.get("event_id", "event")).replace("_", " ").capitalize()
	var authored_title: String = String(entry.get("title", stable_name))
	return stable_name if authored_title == stable_name else "%s — %s" % [stable_name, authored_title]

func _regional_report_text(current_run_only: bool = false) -> String:
	var consequence: Dictionary = keep.current_regional_consequence() if current_run_only else keep.regional_consequence()
	if current_run_only and consequence.is_empty():
		return "\nREGIONAL REPORT — resolves when this defense reaches a terminal state."
	if consequence.is_empty() or String(consequence.get("consequence_id", "")).is_empty():
		return "\nREGIONAL REPORT — Low Mill is waiting for a proven route."
	var support_materials: int = int(consequence.get("next_run_materials", 0))
	var support_status: String = "No material support follows this route state."
	if support_materials > 0 and bool(consequence.get("pending_support", false)):
		support_status = "Next scenario: +%d starting materials pending." % support_materials
	elif support_materials > 0:
		support_status = "Support applied to %s: +%d starting materials." % [String(consequence.get("applied_to_scenario_id", "the next defense")).replace("_", " ").capitalize(), support_materials]
	return "\nREGIONAL REPORT — %s [%s]\n%s: %s\n%s\n%s" % [String(consequence.get("settlement_name", "Low Mill")), String(consequence.get("settlement_status", "unknown")).to_upper(), String(consequence.get("route_name", "Miller's Road")), String(consequence.get("route_status", "unknown")).to_upper(), String(consequence.get("summary", "")), support_status]

func _on_toggle_campaign_modifier() -> void:
	var selected_modifier_id: String = _selected_id(campaign_modifier_option)
	var modifier_id: String = "" if keep.equipped_modifier_id == selected_modifier_id else selected_modifier_id
	_run_result(keep.equip_modifier(modifier_id), "Campaign")

func _refresh_pack_preview() -> void:
	if pack_preview_label == null:
		return
	var preview: Dictionary = keep.pack_preview(_selected_id(pack_option))
	if not bool(preview.get("ok", false)):
		pack_preview_label.text = "PACK PREVIEW — %s" % String(preview.get("reason", "unavailable"))
		return
	var pieces: Array[String] = []
	for piece in preview.get("pieces", []):
		pieces.append("%s (%d)" % [String(piece.get("name", "")), int(piece.get("cost", 0))])
	pack_preview_label.text = "PACK PREVIEW — %s\nDoctrine: %s | Open cost: %d materials\nAdds: %s\nSolves: %s\nAsks: %s\n%s" % [String(preview.name), String(preview.doctrine).replace("_", " "), int(preview.cost), ", ".join(pieces), String(preview.solves), String(preview.asks), String(preview.preview)]

func _on_open_pack() -> void:
	_run_result(keep.open_pack(_selected_id(pack_option)), "Pack")
	_refresh_pack_preview()

func _on_reserve_pack() -> void:
	_run_result(keep.reserve_pack(_selected_id(pack_option)), "Reserve")
	_refresh_pack_preview()

func _arm_selected_piece() -> void:
	if keep.wave_active:
		_set_event("Placement is preparation-only. Resolve or finish the invasion before rebuilding.")
		return
	if keep.repair_interval_active:
		_clear_placement_mode()
		_set_event("Recovery uses the selected piece and room in the action cards; placement resumes after recovery closes.")
		_refresh_ui()
		return
	var piece_id: String = _selected_id(piece_option)
	placement_mode = not piece_id.is_empty()
	preview_floor = _selected_id(floor_option)
	preview_origin = Vector2i.ZERO
	preview_valid = false
	if placement_mode and not keep.piece_definition(piece_id).is_empty():
		var preview: Dictionary = keep.piece_preview(piece_id, preview_origin, preview_floor)
		preview_valid = bool(preview.get("valid", false))
		placement_label.text = "PLACEMENT ARMED — %s | %s zone | %s footprint | %d materials | click the %s floor grid" % [String(preview.get("name", piece_id)), String(preview.get("placement_zone", "keep")).to_upper(), str(preview.get("size", Vector2i.ONE)), int(preview.get("cost", 0)), preview_floor]
	keep_canvas.queue_redraw()

func _clear_placement_mode() -> void:
	placement_mode = false
	preview_valid = false
	keep_canvas.call("set_preview", false, "ground", Vector2i.ZERO, "", false)
	keep_canvas.queue_redraw()

func _on_cancel_placement() -> void:
	_clear_placement_mode()
	_set_event("Map placement cancelled. Click a room or placed piece to inspect it.")
	_refresh_ui()

func _has_piece_id(piece_id: String) -> bool:
	for instance in keep.pieces.values():
		if String(instance.get("piece_id", "")) == piece_id:
			return true
	return false

func _on_recommended_layout() -> void:
	if keep.wave_active:
		_set_event("Recommended layout is preparation-only. Resolve the invasion before rebuilding.")
		return
	if keep.repair_interval_active:
		_set_event("Recommended layout is locked during recovery. Finish the repair interval first.")
		return
	var placements: Array[Dictionary] = [
		{"piece_id": "pike_squad", "origin": Vector2i(4, 5), "floor": "ground"},
		{"piece_id": "narrow_gate", "origin": Vector2i(2, 5), "floor": "ground"}
	]
	var added: Array[String] = []
	var blocked: Array[String] = []
	for placement in placements:
		var piece_id: String = String(placement.get("piece_id", ""))
		if _has_piece_id(piece_id):
			continue
		var result: Dictionary = keep.place_piece(piece_id, placement.get("origin", Vector2i.ZERO), String(placement.get("floor", "ground")))
		if bool(result.get("ok", false)):
			added.append(String(keep.piece_definition(piece_id).get("name", piece_id)))
		else:
			blocked.append("%s: %s" % [String(keep.piece_definition(piece_id).get("name", piece_id)), String(result.get("reason", "blocked"))])
	if added.is_empty() and blocked.is_empty():
		_set_event("Recommended layout already placed. Modify it freely, then start the invasion when ready.")
	elif blocked.is_empty():
		_set_event("Recommended layout placed: %s. You can modify it with direct map placement." % ", ".join(added))
	else:
		_set_event("Recommended layout partly applied: %s. Blocked: %s" % [", ".join(added) if not added.is_empty() else "none", "; ".join(blocked)])
	_refresh_ui()

func _on_map_hovered(floor: String, cell: Vector2i) -> void:
	if not placement_mode:
		return
	preview_floor = floor
	preview_origin = cell
	var preview: Dictionary = keep.piece_preview(_selected_id(piece_option), cell, floor)
	preview_valid = bool(preview.get("valid", false))
	placement_label.text = "PLACEMENT PREVIEW — %s | %s zone | %s / %s: %s | cost %d | remaining %d" % [String(preview.get("name", "piece")), String(preview.get("placement_zone", "keep")).to_upper(), floor, str(cell), "VALID" if preview_valid else String(preview.get("reason", "invalid")), int(preview.get("cost", 0)), int(preview.get("remaining_materials", keep.materials))]
	keep_canvas.queue_redraw()

func _on_map_clicked(floor: String, cell: Vector2i) -> void:
	var piece_id: String = _selected_id(piece_option)
	if placement_mode:
		var result: Dictionary = keep.place_piece(piece_id, cell, floor)
		_run_result(result, "Placement")
		if bool(result.get("ok", false)):
			selected_instance_id = String(result.get("piece_instance", ""))
			_clear_placement_mode()
		return
	var instance_id: String = keep.piece_at_cell(floor, cell)
	if not instance_id.is_empty():
		selected_instance_id = instance_id
		var piece_inspection: Dictionary = keep.inspect_piece(instance_id)
		_select_option_metadata(piece_option, String(piece_inspection.get("piece_id", "")))
		inspected_text = _format_inspection(piece_inspection)
		_set_event("Inspector focused on %s." % String(piece_inspection.get("name", instance_id)))
		_refresh_ui()
		return
	var room_id: String = keep.room_at_cell(floor, cell)
	if not room_id.is_empty():
		if not keep.repair_interval_active:
			selected_instance_id = ""
		_select_option_metadata(room_option, room_id)
		inspected_text = _format_inspection(keep.inspect_room(room_id))
		_set_event("Inspector focused on %s." % String(keep.inspect_room(room_id).get("name", room_id)))
		_refresh_ui()

func _format_inspection(data: Dictionary) -> String:
	if not bool(data.get("ok", false)):
		return "INSPECTOR — %s" % String(data.get("reason", "unknown"))
	if String(data.get("kind", "")) == "room":
		return "INSPECTOR — ROOM %s\n%s floor | %s | %d%% condition | %s\n%s" % [String(data.name), String(data.floor).capitalize(), "critical" if bool(data.critical) else "support", int(data.condition), String(data.state), String(data.role)]
	if String(data.get("kind", "")) == "enemy":
		var armor_text: String = " | armor %d" % int(data.get("armor", 0)) if int(data.get("armor", 0)) > 0 else ""
		var signal_text: String = " | signal DISRUPTED" if bool(data.get("signal_disrupted", false)) else " | signal RELAYED" if bool(data.get("has_signal_disruption", false)) else ""
		var protection_text: String = " | protection PIERCING" if bool(data.get("ignores_protection", false)) else ""
		return "INSPECTOR — ENEMY %s\n%s via %s | %d/%d hp | damage %d%s%s%s | contact step %d\nCounter: %s | Target: %s" % [String(data.name), String(data.doctrine).replace("_", " "), String(data.route).replace("_", " "), int(data.health), int(data.max_health), int(data.damage), armor_text, signal_text, protection_text, int(data.get("arrival_step", 0)), String(data.counter), String(data.target if not String(data.target).is_empty() else "approaching")]
	var special_state: String = ""
	if String(data.get("piece_id", "")) == "supply_cache":
		special_state = "\nReserve: %s" % ("SPENT" if bool(data.get("supply_spent", false)) else "READY")
	elif String(data.get("piece_id", "")) == "rear_guard":
		special_state = "\nFallback: %s" % ("ENGAGED" if bool(data.get("fallback_active", false)) else "RESERVE")
	return "INSPECTOR — %s\n%s floor | %s zone | %d/%d hp | %s\n%s %d attack | Defense %d | Range %d | Ammo %d/%d\nSkill: %s\nAssignment %s%s" % [String(data.name), String(data.floor).capitalize(), String(data.placement_zone).to_upper(), int(data.health), int(data.max_health), String(data.role), String(data.combat_style).to_upper(), int(data.attack), int(data.defense), int(data.range), int(data.ammo), int(data.max_ammo), String(data.skill), String(data.assignment if not String(data.assignment).is_empty() else "none"), special_state]

func _on_inspect_enemy() -> void:
	if enemy_option.selected < 0:
		return
	_select_enemy_focus(int(enemy_option.get_item_metadata(enemy_option.selected)), "Dropdown inspection")

func _active_enemy_indices() -> Array[int]:
	var indices: Array[int] = []
	for index in range(keep.enemies.size()):
		if not bool(keep.enemies[index].get("defeated", false)):
			indices.append(index)
	return indices

func _priority_enemy_index() -> int:
	var best_index: int = -1
	for index in _active_enemy_indices():
		if best_index < 0:
			best_index = index
			continue
		var candidate: Dictionary = keep.enemies[index]
		var selected: Dictionary = keep.enemies[best_index]
		var candidate_arrival: int = int(candidate.get("arrival_step", 1))
		var selected_arrival: int = int(selected.get("arrival_step", 1))
		var candidate_contact: bool = keep.battle_step >= candidate_arrival
		var selected_contact: bool = keep.battle_step >= selected_arrival
		if candidate_contact != selected_contact:
			if candidate_contact:
				best_index = index
			continue
		if candidate_arrival != selected_arrival:
			if candidate_arrival < selected_arrival:
				best_index = index
			continue
		var candidate_id: String = String(candidate.get("enemy_id", ""))
		var selected_id: String = String(selected.get("enemy_id", ""))
		var candidate_damage: int = int(keep.enemy_definition(candidate_id).get("damage", 0))
		var selected_damage: int = int(keep.enemy_definition(selected_id).get("damage", 0))
		if candidate_damage > selected_damage:
			best_index = index
	return best_index

func _apply_enemy_focus(index: int) -> bool:
	if index < 0 or index >= keep.enemies.size() or bool(keep.enemies[index].get("defeated", false)):
		return false
	focused_enemy_index = index
	inspected_text = _format_inspection(keep.inspect_enemy(index))
	if keep_canvas != null:
		keep_canvas.call("set_focus", focused_enemy_index)
	return true

func _ensure_enemy_focus() -> bool:
	if focused_enemy_index >= 0 and focused_enemy_index < keep.enemies.size() and not bool(keep.enemies[focused_enemy_index].get("defeated", false)):
		return false
	return _apply_enemy_focus(_priority_enemy_index())

func _select_enemy_focus(index: int, source: String) -> void:
	if not _apply_enemy_focus(index):
		return
	for option_index in range(enemy_option.item_count):
		if int(enemy_option.get_item_metadata(option_index)) == index:
			enemy_option.select(option_index)
			break
	_set_event("Enemy %d focused via %s. Pause and choose the response." % [index + 1, source])
	_refresh_ui()

func _on_enemy_clicked(index: int) -> void:
	_select_enemy_focus(index, "map click")

func _on_timeline_enemy_clicked(index: int) -> void:
	_select_enemy_focus(index, "timeline marker")

func _cycle_enemy_focus(direction: int) -> void:
	var active: Array[int] = _active_enemy_indices()
	if active.is_empty():
		_set_event("No active enemy can be focused yet. Start an invasion first.")
		return
	var current: int = active.find(focused_enemy_index)
	if current < 0:
		current = 0 if direction >= 0 else active.size() - 1
	else:
		current = posmod(current + direction, active.size())
	_select_enemy_focus(active[current], "focus cycle")

func _focus_selected_enemy() -> void:
	if focused_enemy_index >= 0 and focused_enemy_index in _active_enemy_indices():
		_select_enemy_focus(focused_enemy_index, "keyboard focus")
	else:
		_cycle_enemy_focus(1)

func _refresh_response_preview() -> void:
	if response_preview_label == null:
		return
	if focused_enemy_index < 0 or focused_enemy_index >= keep.enemies.size() or bool(keep.enemies[focused_enemy_index].get("defeated", false)):
		response_preview_label.text = "RESPONSE — Select an active enemy on the map or press Tab. The dropdown remains a fallback."
		return
	var inspection: Dictionary = keep.inspect_enemy(focused_enemy_index)
	var ability_name: String = String(keep.commander_definition(keep.commander_id).get("ability_name", "Ability"))
	var ability_state: String = "available" if keep.command_points > 0 and not bool(keep.lockdown_used if keep.commander_id == "castellan" else keep.rally_used) else "spent or unavailable"
	var timing_text: String = "PAUSED PREVIEW — commit when ready" if battle_paused else "RUNNING — pause to inspect before committing"
	var target_text: String = String(inspection.get("target", ""))
	if target_text.is_empty():
		target_text = "APPROACHING"
	var counter_id: String = String(inspection.get("counter", ""))
	var counter_name: String = String(keep.piece_definition(counter_id).get("name", counter_id.replace("_", " ").capitalize())) if not counter_id.is_empty() else "Read the forecast"
	var response: Dictionary = keep.defender_response_preview(focused_enemy_index)
	var attacker_names: Array[String] = []
	for attacker in response.get("attackers", []):
		attacker_names.append("%s (%d)" % [String(attacker.get("name", "Defender")), int(attacker.get("damage", 0))])
	var engagement_text: String = "NEXT STEP: no ready defender commits to this target"
	if not attacker_names.is_empty():
		engagement_text = "NEXT STEP: %s → %d damage · projected %d hp" % [", ".join(attacker_names), int(response.get("expected_damage", 0)), int(response.get("projected_health", 0))]
	response_preview_label.text = "RESPONSE — FOCUSED %d: %s\n%s\nTHREAT: %s | TARGET: %s | %s\n%s\nCOUNTERS: %s\n%s: %s (%d command)" % [focused_enemy_index + 1, String(inspection.get("name", "enemy")), timing_text, String(inspection.get("doctrine", "approaching")).replace("_", " ").to_upper(), target_text, String(response.get("contact_state", "APPROACH")), engagement_text, counter_name, ability_name, ability_state, keep.command_points]

func _refresh_layout_lens() -> void:
	if layout_lens_label == null:
		return
	var summary: Dictionary = keep.layout_summary()
	var counts: Dictionary = summary.get("counts", {})
	var comparison: Dictionary = summary.get("commander_comparison", {})
	var castellan: Dictionary = comparison.get("castellan", {})
	var warden: Dictionary = comparison.get("warden", {})
	var warnings: Array[String] = []
	for warning in summary.get("duplicate_role_warnings", []):
		warnings.append(String(warning))
	var castellan_marker: String = "CURRENT" if keep.commander_id == "castellan" else "COMPARE"
	var warden_marker: String = "CURRENT" if keep.commander_id == "warden" else "COMPARE"
	var spatial_rule: Dictionary = summary.get("spatial_rule", {})
	var spatial_state: String = "ACTIVE" if bool(spatial_rule.get("active", false)) else "INACTIVE" if String(spatial_rule.get("id", "")) == "clear_causeway" else "BASELINE"
	layout_lens_label.text = "LAYOUT SUMMARY — %s | Ground %d | Upper %d | Wall %d | Courtyard %d | Keep %d\nSpatial rule [%s] — %s\nCoverage — room edge %d | open lane %d | support %d | assigned %d\nCASTELLAN [%s] — %s Risk: %s\nWARDEN [%s] — %s Risk: %s\nWARNINGS — %s" % [String(summary.get("keep_name", keep.keep_id)), int(counts.get("ground", 0)), int(counts.get("upper", 0)), int(counts.get("wall", 0)), int(counts.get("courtyard", 0)), int(counts.get("keep", 0)), spatial_state, String(spatial_rule.get("label", "No special spatial rule.")), int(summary.get("room_edge_count", 0)), int(summary.get("open_lane_count", 0)), int(summary.get("support_piece_count", 0)), int(summary.get("assigned_specialist_count", 0)), castellan_marker, String(castellan.get("summary", "")), String(castellan.get("risk", "")), warden_marker, String(warden.get("summary", "")), String(warden.get("risk", "")), " | ".join(warnings)]

func _refresh_recovery_priorities() -> void:
	if recovery_priority_label == null:
		return
	if not keep.repair_interval_active and keep.last_outcome.is_empty():
		recovery_priority_label.text = "RECOVERY PRIORITIES — Appear after a Hold or Partial Breach. The ranking is advisory; repair commands remain authoritative."
		return
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
	for outer in range(priorities.size()):
		for inner in range(outer + 1, priorities.size()):
			var left: Dictionary = priorities[outer]
			var right: Dictionary = priorities[inner]
			if int(right.get("score", 0)) > int(left.get("score", 0)) or (int(right.get("score", 0)) == int(left.get("score", 0)) and String(right.get("id", "")) < String(left.get("id", ""))):
				priorities[outer] = right
				priorities[inner] = left
	var rows: Array[String] = []
	for index in range(mini(3, priorities.size())):
		var row: Dictionary = priorities[index]
		rows.append("%s — %s %d%%" % [String(row.get("name", "room")), String(row.get("state", "STABLE")), int(row.get("condition", 0))])
	var advice: Dictionary = keep.recovery_advice()
	if bool(advice.get("ok", false)):
		recovery_priority_label.text = "RECOVERY PRIORITIES — %s\n%s\nNEXT: %s | %s\nTRADE-OFF: %s" % ["advisory order", " | ".join(rows), String(advice.get("next_doctrine", "next doctrine")).replace("_", " "), String(advice.get("target", "preserve the most important function")), String(advice.get("tradeoff", "choose deliberately"))]
	else:
		recovery_priority_label.text = "RECOVERY PRIORITIES — %s\n%s" % ["advisory order", " | ".join(rows)]

func _apply_recovery_action_card(title: Label, detail: Label, button: Button, action_name: String, preview: Dictionary) -> void:
	var target_name: String = String(preview.get("target_name", "Select a target"))
	var material_cost: int = int(preview.get("material_cost", 0))
	var cost_text: String = "%d material%s + 1 action" % [material_cost, "" if material_cost == 1 else "s"] if material_cost > 0 else "1 recovery action"
	var ready: bool = bool(preview.get("ok", false))
	var status_text: String = "READY" if ready else "BLOCKED — %s" % String(preview.get("reason", "unavailable"))
	title.text = "%s — %s" % [action_name, target_name]
	detail.text = "COST — %s\nBENEFIT — %s\nTRADE-OFF — %s\n%s" % [cost_text, String(preview.get("benefit", "")), String(preview.get("tradeoff", "")), status_text]
	detail.add_theme_color_override("font_color", Color("#bfe8cf") if ready else Color("#c99a9a"))
	button.disabled = not ready
	button.tooltip_text = String(preview.get("benefit", "")) if ready else String(preview.get("reason", "unavailable"))

func _refresh_recovery_action_cards() -> void:
	if recovery_actions_panel == null:
		return
	recovery_actions_panel.visible = screen == "results" and keep.repair_interval_active
	if not keep.repair_interval_active:
		return
	var action_number: int = 3 - keep.repair_actions_remaining
	if keep.repair_actions_remaining > 0:
		recovery_stage_label.text = "ACTION %d OF 2 — choose one priority. %d material(s) available." % [action_number, keep.materials]
	else:
		recovery_stage_label.text = "ACTIONS COMPLETE — continue explicitly when the keep is ready."
	var instance_id: String = _selected_piece_instance()
	var room_id: String = _selected_id(room_option)
	_apply_recovery_action_card(recovery_room_card_title, recovery_room_card_detail, recovery_room_button, "REPAIR ROOM", keep.recovery_action_preview("repair_room", "", room_id))
	_apply_recovery_action_card(recovery_piece_card_title, recovery_piece_card_detail, recovery_piece_button, "REPAIR PIECE", keep.recovery_action_preview("repair_piece", instance_id))
	_apply_recovery_action_card(recovery_assign_card_title, recovery_assign_card_detail, recovery_assign_button, "ASSIGN SPECIALIST", keep.recovery_action_preview("assign_piece", instance_id, room_id))
	_apply_recovery_action_card(recovery_clear_card_title, recovery_clear_card_detail, recovery_clear_button, "CLEAR ASSIGNMENT", keep.recovery_action_preview("clear_assignment", instance_id))
	finish_interval_button.disabled = not keep.active_event_id.is_empty()
	finish_interval_button.tooltip_text = "Resolve the active event before continuing." if finish_interval_button.disabled else "Close recovery explicitly; unused actions are recorded and never spent automatically."
	if keep.has_next_wave():
		finish_interval_button.text = "END LULL — RELEASE PHASE %d/%d" % [keep.wave_index + 1, keep.authored_wave_count()]
	else:
		finish_interval_button.text = "FINISH RECOVERY"

func _on_remove_piece() -> void:
	if keep.wave_active or keep.repair_interval_active:
		_set_event("Piece removal is preparation-only; finish the active assault phase or recovery lull first.")
		return
	var instance_id: String = _selected_piece_instance()
	if instance_id.is_empty():
		_set_event("Select a placed piece on the fort before removing it.")
		return
	var removed: Dictionary = keep.remove_piece(instance_id)
	if bool(removed.get("ok", false)):
		selected_instance_id = ""
		inspected_text = "Piece removed. Use the placement preview to test a different layout."
	_run_result(removed, "Layout")

func _on_place_piece() -> void:
	var piece_id: String = _selected_id(piece_option)
	var floor: String = _selected_id(floor_option)
	_run_result(keep.place_piece(piece_id, _next_slot(piece_id, floor), floor), "Placement")

func _on_start_wave() -> void:
	_clear_placement_mode()
	focused_enemy_index = -1
	var result: Dictionary = keep.start_wave(_selected_id(doctrine_option))
	_run_result(result, "Invasion")
	if bool(result.get("ok", false)):
		battle_paused = false
		last_log_size = keep.battle_report.size()
		focused_enemy_index = -1
		_ensure_enemy_focus()
		_set_screen("battle")
		_set_event("Assault underway at %.1fx. Press Space to pause and inspect; N advances one tick while paused." % _battle_speed())
		_refresh_ui()

func _selected_piece_instance() -> String:
	if not selected_instance_id.is_empty() and keep.pieces.has(selected_instance_id):
		return selected_instance_id
	var piece_id: String = _selected_id(piece_option)
	for instance_id in keep.pieces.keys():
		if String(keep.pieces[instance_id].get("piece_id", "")) == piece_id:
			return String(instance_id)
	return ""

func _on_assign_piece() -> void:
	_run_result(keep.assign_piece_to_room(_selected_piece_instance(), _selected_id(room_option)), "Assignment")

func _on_clear_assignment() -> void:
	_run_result(keep.clear_piece_assignment(_selected_piece_instance()), "Assignment")

func _on_repair_room() -> void:
	_run_result(keep.repair_room(_selected_id(room_option)), "Repair")

func _on_repair_piece() -> void:
	_run_result(keep.repair_piece(_selected_piece_instance()), "Repair")

func _on_finish_interval() -> void:
	var result: Dictionary = keep.finish_repair_interval()
	_run_result(result, "Interval")
	if bool(result.get("ok", false)):
		if bool(result.get("next_wave_started", false)):
			battle_paused = false
			focused_enemy_index = -1
			last_log_size = 0
			_ensure_enemy_focus()
			_set_screen("battle")
			_set_event("The recovery lull ends and assault phase %d begins in real time." % keep.wave_index)
			_refresh_ui()
		else:
			_set_screen("preparation")

func _on_advance_wave() -> void:
	var engagement_traces: Array[Dictionary] = _next_engagement_traces()
	var target_snapshot: Dictionary = _combat_target_snapshot()
	var result: Dictionary = keep.advance_wave(1.0)
	var target_impacts: Array[Dictionary] = _resolved_target_impacts(target_snapshot) if bool(result.get("ok", false)) else []
	if bool(result.get("ok", false)) and keep_canvas != null:
		keep_canvas.call("show_combat_exchange", engagement_traces, target_impacts)
	if bool(result.get("ok", false)):
		_ensure_enemy_focus()
	if not bool(result.get("ok", false)):
		_set_event("Battle blocked: %s." % String(result.get("reason", "unknown")))
		_play_cue("error")
	elif bool(result.get("resolved", false)):
		battle_paused = true
		_set_feedback(Color("#bfe8cf"), _outcome_cue(String(result.get("outcome", "unknown"))))
		if keep.has_next_wave() and keep.repair_interval_active:
			_set_event("Assault phase %d resolved: %s. Recovery lull open before phase %d." % [keep.wave_index, String(result.get("outcome", "unknown")).replace("_", " "), keep.wave_index + 1])
		else:
			_set_event("Final assault phase resolved: %s. Read the report." % String(result.get("outcome", "unknown")).replace("_", " "))
		_set_screen("results")
	else:
		var exchange_cue: String = "impact" if not target_impacts.is_empty() else "volley" if not engagement_traces.is_empty() else "contact"
		_set_feedback(Color("#d26155") if not target_impacts.is_empty() else Color("#d7a35b"), exchange_cue)
		_set_event("Combat tick %d resolved. Inspect the exchange before committing the commander ability." % int(result.get("step", 0)))
	_refresh_ui()

func _on_use_ability() -> void:
	_run_result(keep.use_commander_ability(), "Ability")

func _run_result(result: Dictionary, label: String) -> void:
	if bool(result.get("ok", false)):
		_set_event("%s: %s" % [label, String(result.get("message", "command accepted"))])
		var cue_id: String = "repair" if label == "Repair" else "ability" if label == "Ability" else "warning" if label == "Invasion" else "confirm"
		_set_feedback(Color("#9bd4c3") if label in ["Repair", "Assignment", "Placement"] else Color("#91b7da"), cue_id)
	else:
		_set_event("%s blocked: %s." % [label, String(result.get("reason", "unknown"))])
		_set_feedback(Color("#d26155"), "error")
	_refresh_ui()

func _on_save() -> void:
	var file: FileAccess = FileAccess.open(save_temp_path, FileAccess.WRITE)
	if file == null:
		_set_event("Save failed: could not open the temporary save path.")
		return
	file.store_string(JSON.stringify(keep.serialize()))
	file.flush()
	file.close()
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		_set_event("Save failed: could not access the user data directory.")
		return
	var had_previous_save: bool = FileAccess.file_exists(save_path)
	if FileAccess.file_exists(save_backup_path):
		directory.remove(save_backup_path.get_file())
	if had_previous_save:
		var backup_error: Error = directory.rename(save_path.get_file(), save_backup_path.get_file())
		if backup_error != OK:
			_set_event("Save failed: could not protect the previous save.")
			return
	var rename_error: Error = directory.rename(save_temp_path.get_file(), save_path.get_file())
	if rename_error != OK:
		if had_previous_save:
			directory.rename(save_backup_path.get_file(), save_path.get_file())
		_set_event("Save failed: temporary save could not be committed; the previous save was retained.")
		return
	if FileAccess.file_exists(save_backup_path):
		directory.remove(save_backup_path.get_file())
	_set_event("Keep state saved safely with schema %d." % PackKeepState.SAVE_SCHEMA_VERSION)

func _on_load() -> void:
	var primary: Dictionary = _load_save_candidate(save_path)
	var loaded_from_backup: bool = false
	var selected: Dictionary = primary
	if not bool(primary.get("ok", false)):
		var backup: Dictionary = _load_save_candidate(save_backup_path)
		if bool(backup.get("ok", false)):
			selected = backup
			loaded_from_backup = true
		else:
			var primary_reason: String = String(primary.get("reason", "unknown primary failure"))
			var backup_reason: String = String(backup.get("reason", "unknown backup failure"))
			_set_event("Load rejected: primary %s; backup %s. The current run is unchanged." % [primary_reason, backup_reason])
			return
	keep = selected.state
	var result: Dictionary = selected.result
	_clear_placement_mode()
	selected_instance_id = ""
	inspected_text = "Save loaded. Click a room or piece to inspect the restored run."
	_select_option_metadata(campaign_modifier_option, keep.equipped_modifier_id)
	var source_text: String = " from backup" if loaded_from_backup else ""
	var migration_text: String = " with legacy migration" if bool(result.get("migrated", false)) else ""
	_set_event("Keep state loaded%s%s." % [source_text, migration_text])
	_refresh_ui()

func _load_save_candidate(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "reason": "is missing"}
	var text: String = FileAccess.get_file_as_string(path)
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK:
		return {"ok": false, "reason": "is not valid JSON state"}
	var payload: Variant = parser.data
	if not (payload is Dictionary):
		return {"ok": false, "reason": "is not valid JSON state"}
	var candidate: PackKeepState = PackKeepState.new(0)
	var result: Dictionary = candidate.load_serialized(payload)
	if not bool(result.get("ok", false)):
		return {"ok": false, "reason": String(result.get("reason", "failed validation"))}
	return {"ok": true, "state": candidate, "result": result}

func _on_playtest_primary_action() -> void:
	if screen == "results":
		if keep.repair_interval_active and keep.has_next_wave():
			_on_finish_interval()
		else:
			_on_start_quick_playtest()
	elif screen == "preparation":
		_on_start_wave()
	elif screen == "battle":
		_toggle_battle_pause()

func _on_start_quick_playtest() -> void:
	_reset_for_setup()
	guided_setup = true
	_select_option_metadata(commander_option, "castellan")
	keep.select_commander("castellan")
	_select_option_metadata(scenario_option, "gatehouse_lock")
	keep.select_scenario("gatehouse_lock")
	_select_option_metadata(doctrine_option, "gate_assault")
	_set_screen("setup")
	_refresh_ui()

func _on_start_custom_setup() -> void:
	_reset_for_setup()
	guided_setup = false
	keep.select_commander(_selected_id(commander_option))
	keep.select_scenario(_selected_id(scenario_option))
	_set_screen("setup")
	_refresh_ui()

func _reset_for_setup() -> void:
	keep.reset_run(3307)
	setup_confirmed = false
	focused_enemy_index = -1
	battle_paused = true
	last_auto_pause_wave_index = -1
	last_log_size = 0
	_clear_placement_mode()
	selected_instance_id = ""

func _on_confirm_setup() -> void:
	keep.select_commander(_selected_id(commander_option))
	keep.select_scenario(_selected_id(scenario_option))
	if guided_setup and keep.pieces.is_empty():
		_on_recommended_layout()
	setup_confirmed = true
	_set_screen("preparation")
	_set_event(
		"Guided preparation ready: inspect the recommended layout and forecast, then start the invasion."
		if guided_setup else
		"Custom preparation ready: open a pack, place a readable defense, then start the invasion."
	)
	_refresh_ui()

func _on_open_settings() -> void:
	if screen != "settings":
		settings_return_screen = screen
	_set_screen("settings")

func _on_close_settings() -> void:
	var target: String = settings_return_screen
	if target == "battle" and not keep.wave_active:
		target = "results" if not keep.wave_history.is_empty() else "preparation"
	_set_screen(target)

func _on_continue_saved_run() -> void:
	_on_load()
	setup_confirmed = keep.scenario_active
	if keep.wave_active:
		battle_paused = false
		_ensure_enemy_focus()
		_set_screen("battle")
	elif keep.repair_interval_active or not keep.wave_history.is_empty():
		_set_screen("results")
	elif keep.scenario_active:
		_set_screen("preparation")

func _on_quick_test_action() -> void:
	if screen == "title":
		_on_start_quick_playtest()
		return
	if screen == "setup":
		_on_confirm_setup()
		return
	if screen == "battle":
		if keep.wave_active:
			_toggle_battle_pause()
		else:
			_set_event("Battle is complete. Review Results or restart the quick playtest.")
			_refresh_ui()
		return
	if keep.wave_active:
		_set_event("Quick test already active. Press Space to run or use the primary action to advance one step.")
		_refresh_ui()
		return
	_on_start_wave()

func _on_reset_run() -> void:
	keep.reset_run(3307)
	guided_setup = false
	setup_confirmed = false
	focused_enemy_index = -1
	battle_paused = true
	last_auto_pause_wave_index = -1
	last_log_size = 0
	_clear_placement_mode()
	selected_instance_id = ""
	inspected_text = "New run ready. Choose the briefing before entering the keep."
	_set_screen("setup")
	_set_event("New run started. Choose a commander and scenario; no save was overwritten.")
	_refresh_ui()

func _set_event(text: String) -> void:
	event_label.text = text

func _first_battle_guidance() -> String:
	if screen == "title":
		return ""
	if screen == "preparation":
		if not keep.active_event_id.is_empty():
			return "FIRST BATTLE GUIDE — Resolve the authored forecast choice in the command table, then place the defense and start the invasion."
		if keep.pieces.is_empty():
			return "FIRST BATTLE GUIDE — 1 Use the recommended starter layout, or place Pike Squad in the courtyard and Narrow Gate by the gate. 2 Open one pack if you want a second doctrine. 3 Start the invasion when the board reads clearly."
		return "FIRST BATTLE GUIDE — Layout ready. Read the FORECAST, then begin the assault. It runs immediately; use Space to pause or N to resolve one readable tick while paused."
	if screen == "battle":
		return "FIRST BATTLE GUIDE — The fort stays visible while enemies move continuously toward contact. Pause when needed; the focused response preview shows the next committed defenders."
	if screen == "results":
		if keep.repair_interval_active and keep.has_next_wave():
			return "RECOVERY LULL — Read the causal result, spend up to two repair or assignment actions, then release assault phase %d/%d." % [keep.wave_index + 1, keep.authored_wave_count()]
		if keep.authored_wave_count() > 0 and keep.wave_index >= keep.authored_wave_count():
			return "SCENARIO COMPLETE — Read the final causal result, then restart the quick playtest to test a different doctrine response."
		return "FIRST BATTLE GUIDE — Read the causal result below, repair the highest-priority room, then finish the interval before the next doctrine. Change one placement at a time to learn the counter."
	return ""

func _scorecard_compact_text() -> String:
	var rows: Array[String] = []
	for index in range(keep.wave_history.size()):
		var wave: Dictionary = keep.wave_history[index]
		rows.append("P%d %s/%s" % [int(wave.get("wave", index + 1)), String(wave.get("doctrine", "")).replace("_", " "), String(wave.get("outcome", "")).replace("_", " ")])
	return " | ".join(rows) if not rows.is_empty() else "No resolved assault phases yet"

func _refresh_result_explanation() -> void:
	if result_explain_label == null:
		return
	if keep.last_outcome.is_empty():
		result_explain_label.text = "RESULT GUIDE — Finish an assault phase to see what the forecast, placement, and response produced."
		return
	var report: Dictionary = keep.scenario_report()
	var final_state: Dictionary = report.get("final_state", {})
	var worked_lines: Array[String] = []
	for item in report.get("what_worked", []):
		worked_lines.append("- %s" % String(item))
	var failed_lines: Array[String] = []
	for item in report.get("what_failed", []):
		failed_lines.append("- %s" % String(item))
	result_explain_label.text = "CAUSAL RESULT — FINAL KEEP\nMorale %d | Breach %d | Materials %d | Defenders %d active / %d disabled\nWHAT WORKED\n%s\nWHAT FAILED\n%s\nTRY NEXT — %s" % [int(final_state.get("morale", 0)), int(final_state.get("breach_level", 0)), int(final_state.get("materials", 0)), int(final_state.get("surviving_pieces", 0)), int(final_state.get("disabled_pieces", 0)), "\n".join(worked_lines), "\n".join(failed_lines), String(report.get("suggested_experiment", "Replay one changed decision."))]
	var score_rows: Array[String] = []
	for wave in report.get("wave_rows", []):
		score_rows.append("PHASE %d — %s — %s\nPressure: %s | Defeated %d | Room %d | Piece %d | recovery actions %d" % [int(wave.get("wave", score_rows.size() + 1)), String(wave.get("doctrine", "")).replace("_", " ").capitalize(), String(wave.get("outcome", "")).replace("_", " ").to_upper(), String(wave.get("principal_pressure", "Unknown pressure")), int(wave.get("defeated_enemies", 0)), int(wave.get("room_damage", 0)), int(wave.get("piece_damage", 0)), int(wave.get("recovery_actions_used", 0))])
	var report_heading: String = "SCENARIO REPORT" if String(report.get("status", "in_progress")) == "complete" else "RUN SO FAR"
	var event_snapshot: Dictionary = keep.event_ledger_snapshot(5)
	var event_rows: Array[String] = []
	for event_entry in event_snapshot.get("entries", []):
		event_rows.append("P%d %s → %s" % [int(event_entry.get("wave", 0)), _event_ledger_name(event_entry), String(event_entry.get("visible_result", ""))])
	var event_heading: String = "EVENT CONSEQUENCES — newest %d of %d" % [event_rows.size(), int(event_snapshot.get("total", event_rows.size()))] if bool(event_snapshot.get("truncated", false)) else "EVENT CONSEQUENCES — newest first"
	var event_report: String = "\n%s\n%s" % [event_heading, "\n".join(event_rows)] if not event_rows.is_empty() else ""
	scorecard_label.text = "%s — %s | %s\n%s%s%s\nREPLAY KEY — %s" % [report_heading, String(report.get("scenario_name", keep.scenario_id)), String(report.get("commander_name", keep.commander_id)), "\n".join(score_rows) if not score_rows.is_empty() else "No resolved assault phases yet.", event_report, _regional_report_text(true), String(report.get("replay_key", ""))]

func _refresh_ui() -> void:
	_refresh_room_options()
	_refresh_pack_preview()
	_refresh_scenario_preview()
	_refresh_authored_event()
	_refresh_campaign_ledger()
	if setup_overview_label:
		var selected_commander: Dictionary = keep.commander_definition(_selected_id(commander_option))
		var selected_scenario: Dictionary = keep.scenario_preview(_selected_id(scenario_option))
		var setup_mode: String = "GUIDED PLAYTEST" if guided_setup else "CUSTOM DEFENSE"
		var modifier_name: String = "None"
		if not keep.equipped_modifier_id.is_empty():
			modifier_name = String(keep.modifier_definition(keep.equipped_modifier_id).get("name", keep.equipped_modifier_id))
		setup_overview_label.text = "%s\nCOMMANDER — %s · %s\nSCENARIO — %s · %s\nMODIFIER — %s" % [
			setup_mode,
			String(selected_commander.get("name", "Commander")),
			String(selected_commander.get("passive", "Choose a doctrine lens.")),
			String(selected_scenario.get("name", "Scenario")),
			String(selected_scenario.get("objective", "Choose the pressure to test.")),
			modifier_name,
		]
	if setup_confirm_button:
		setup_confirm_button.text = "Enter Keep — Recommended Layout" if guided_setup else "Enter Keep — Build Defense"
		setup_confirm_button.tooltip_text = "Enter Preparation with the guided two-piece baseline." if guided_setup else "Enter Preparation with an empty board and the selected starting pieces available."
	if title_continue_button:
		title_continue_button.disabled = not FileAccess.file_exists(save_path) and not FileAccess.file_exists(save_backup_path)
	var interval_text: String = "closed"
	if keep.repair_interval_active:
		interval_text = "%d action(s): %s" % [keep.repair_actions_remaining, keep.repair_interval_reason]
	status_label.text = "%s | %s / %s | Materials %d | Command %d | Morale %d | Pieces %d | Assault %d | Tick %d | Breach %d | %s | Recovery %s" % [keep.summary().get("commander", "Commander"), String(keep.keep_definition().get("name", keep.keep_id)), String(keep.scenario_preview().get("name", "Free drill")), keep.materials, keep.command_points, keep.morale, keep.pieces.size(), keep.wave_index, keep.battle_step, keep.breach_level, "PAUSED" if battle_paused else "LIVE %.1fx" % _battle_speed(), interval_text]
	var commander: Dictionary = keep.commander_definition(keep.commander_id)
	commander_profile_label.text = "%s\nPassive: %s\nAbility: %s — %s\nLimitation: %s" % [String(commander.get("name", keep.commander_id)), String(commander.get("passive", "")), String(commander.get("ability_name", "")), String(commander.get("ability_text", "")), String(commander.get("limitation", ""))]
	commander_portrait.modulate = Color("#9fb9c3") if keep.commander_id == "warden" else Color.WHITE
	commander_portrait.tooltip_text = "The Warden — Open Lanes and Rally" if keep.commander_id == "warden" else "The Castellan — Layered Masonry and Lockdown"
	commander_ability_button.text = "%s (%s)" % [String(commander.get("ability_name", "Ability")), String(commander.get("name", keep.commander_id)).replace("The ", "")]
	commander_ability_button.tooltip_text = String(commander.get("ability_text", "Use once per assault phase."))
	var forecast: Dictionary = keep.forecast()
	forecast_label.text = "FORECAST — %s | Likely target: %s | Uncertainty: %s | Scout: %s" % [String(forecast.get("doctrine", "")).replace("_", " "), String(forecast.get("likely_target", "")), String(forecast.get("uncertainty", "")), "revealed" if bool(forecast.get("scout_bonus", false)) else "not revealed"]
	if bool(forecast.get("signal_disrupted", false)):
		forecast_label.text += " | Signal: DISRUPTED"
	elif bool(forecast.get("signal_network_active", false)):
		forecast_label.text += " | Signal: REDUNDANT"
	if bool(forecast.get("composition_revealed", false)):
		var actor_names: Array[String] = []
		for enemy_id in forecast.get("composition", []):
			actor_names.append(String(keep.enemy_definition(String(enemy_id)).get("name", enemy_id)))
		forecast_label.text += " | Actors: %s" % ", ".join(actor_names)
	var enemy_lines: Array[String] = []
	for enemy in keep.enemies:
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		var enemy_definition: Dictionary = keep.enemy_definition(enemy_id)
		var enemy_state: String = "defeated" if bool(enemy.get("defeated", false)) else "%d/%d hp" % [int(enemy.get("hp", 0)), int(enemy.get("max_health", enemy_definition.get("health", 0)))]
		var phase: String = "contact" if keep.battle_step >= int(enemy.get("arrival_step", enemy_definition.get("arrival_step", 0))) else "approach"
		var target: String = String(enemy.get("target", ""))
		if target.is_empty():
			target = "approach"
		var armor_text: String = " — armor %d" % int(enemy_definition.get("armor", 0)) if int(enemy_definition.get("armor", 0)) > 0 else ""
		var signal_text: String = " — signal DISRUPTED" if bool(enemy.get("signal_disrupted", false)) else " — signal RELAYED" if enemy_definition.get("disruption_profile") is Dictionary else ""
		var protection_text: String = " — protection PIERCING" if bool(enemy_definition.get("ignores_protection", false)) else ""
		enemy_lines.append("%s [%s] — %s/%s%s%s%s — route %s — target %s" % [String(enemy_definition.get("name", enemy_id)), enemy_id, phase, enemy_state, armor_text, signal_text, protection_text, String(enemy_definition.get("route", "")), target])
	enemy_label.text = "ENEMIES — " + (" | ".join(enemy_lines) if not enemy_lines.is_empty() else "No active enemies. Start an invasion to see doctrine-driven actors.")
	var metrics: Dictionary = keep.combat_metrics
	metrics_label.text = "METRICS — steps %d | unit attacks %d | damage dealt %d | ammo spent %d | enemy attacks %d | room damage %d | piece damage %d | repairs %d | disabled %d | defeated %d" % [int(metrics.get("battle_steps", 0)), int(metrics.get("unit_attacks", 0)), int(metrics.get("damage_dealt", 0)), int(metrics.get("ammo_spent", 0)), int(metrics.get("enemy_attacks", 0)), int(metrics.get("room_damage", 0)), int(metrics.get("piece_damage", 0)), int(metrics.get("repairs", 0)), int(metrics.get("disabled_units", 0)), int(metrics.get("defeated_enemies", 0))]
	combat_explain_label.text = "REAL-TIME ASSAULT — enemies move continuously while deterministic combat ticks resolve underneath. Defenders commit once per tick before contact. Pause at any time to inspect the next response."
	var available_names: Array[String] = []
	for available_id in keep.available_pieces:
		available_names.append(String(keep.piece_definition(available_id).get("name", available_id)))
	availability_label.text = "AVAILABLE — %s\nPack openings this Preparation: %d/%d" % [", ".join(available_names), keep.pack_openings_this_preparation, 2 if keep.wave_index == 0 else 1]
	for piece_index in range(piece_option.item_count):
		var piece_id: String = String(piece_option.get_item_metadata(piece_index))
		piece_option.set_item_disabled(piece_index, not keep.available_pieces.has(piece_id))
	enemy_option.clear()
	for enemy_index in range(keep.enemies.size()):
		var enemy_id: String = String(keep.enemies[enemy_index].get("enemy_id", ""))
		enemy_option.add_item("%d — %s" % [enemy_index + 1, String(keep.enemy_definition(enemy_id).get("name", enemy_id))])
		enemy_option.set_item_metadata(enemy_option.item_count - 1, enemy_index)
		if enemy_index == focused_enemy_index:
			enemy_option.select(enemy_option.item_count - 1)
	inspector_label.text = inspected_text
	if placement_mode:
		var selected_id: String = _selected_id(piece_option)
		var preview: Dictionary = keep.piece_preview(selected_id, preview_origin, preview_floor)
		preview_valid = bool(preview.get("valid", false))
		placement_label.text = "PLACEMENT PREVIEW — %s | %s zone | %s / %s: %s | cost %d | remaining %d" % [String(preview.get("name", selected_id)), String(preview.get("placement_zone", "keep")).to_upper(), preview_floor, str(preview_origin), "VALID" if preview_valid else String(preview.get("reason", "invalid")), int(preview.get("cost", 0)), int(preview.get("remaining_materials", keep.materials))]
	else:
		placement_label.text = "MAP READY — click a room or placed piece to inspect it; arm a piece to preview a direct placement."
	keep_canvas.call("set_preview", placement_mode, preview_floor, preview_origin, _selected_id(piece_option), preview_valid)
	if event_label.text.is_empty():
		event_label.text = "Open Pike Line or Field Engineers, place a defense on either floor, start First Bell, and advance one step at a time."
	guidance_label.text = _first_battle_guidance()
	if playtest_button:
		if screen == "preparation":
			playtest_button.text = "BEGIN ASSAULT — REAL TIME"
			playtest_button.disabled = keep.pieces.is_empty() or keep.repair_interval_active or not keep.active_event_id.is_empty()
			playtest_button.tooltip_text = "Begin the selected assault immediately at the chosen speed. Space pauses at any time."
			if not keep.active_event_id.is_empty():
				playtest_status_label.text = "EVENT WAITING — choose an authored response before the invasion can begin."
			else:
				playtest_status_label.text = "DEFENSE READY — %d piece(s) placed. The assault begins live; Space pauses for inspection." % keep.pieces.size() if not keep.pieces.is_empty() else "DEFENSE WAITING — use the recommended layout or place at least one defender first."
		elif screen == "battle":
			playtest_button.text = "RESUME ASSAULT" if battle_paused else "PAUSE — INSPECT"
			playtest_button.disabled = not keep.wave_active
			playtest_button.tooltip_text = "Resume continuous combat." if battle_paused else "Pause immediately without advancing authoritative combat."
			playtest_status_label.text = "ASSAULT PHASE %d/%d · TICK %d · %s — Space toggles pause; N advances one tick while paused." % [keep.wave_index, maxi(1, keep.authored_wave_count()), keep.battle_step, "PAUSED" if battle_paused else "LIVE %.1fx" % _battle_speed()]
		elif screen == "results":
			if keep.repair_interval_active and keep.has_next_wave():
				playtest_button.text = "END LULL — RELEASE PHASE %d/%d" % [keep.wave_index + 1, keep.authored_wave_count()]
				playtest_button.disabled = false
				playtest_button.tooltip_text = "Close recovery and return immediately to the live assault."
				playtest_status_label.text = "RECOVERY — %d action(s) remain. Repair or assign, then continue. %s" % [keep.repair_actions_remaining, _scorecard_compact_text()]
			else:
				playtest_button.text = "REVIEW SETUP — PLAY AGAIN"
				playtest_button.disabled = false
				playtest_button.tooltip_text = "Return to the guided briefing before replaying the deterministic candidate."
				playtest_status_label.text = "FINAL RESULTS — %s | Replay %s" % [_scorecard_compact_text(), String(keep.scenario_scorecard().get("replay_key", ""))]
	var recent: Array[String] = []
	var start: int = maxi(0, keep.battle_report.size() - _event_feed_retention())
	for index in range(start, keep.battle_report.size()):
		recent.append(keep.battle_report[index])
	recent.reverse()
	log_label.text = "COMBAT EVENT FEED — newest %d, newest first\n" % _event_feed_retention() + ("\n".join(recent) if not recent.is_empty() else "No assault has started. This feed will name the forecast, response, target, damage, and recovery.")

	pause_button.text = "Resume battle (Space)" if battle_paused else "Pause battle (Space)"
	manual_step_button.disabled = not keep.wave_active or not battle_paused
	speed_button.text = "Speed: %.1fx (1/2/3)" % _battle_speed()
	mute_button.text = "Feedback tones: OFF" if audio_muted else "Feedback tones: ON"
	contrast_button.text = "High-contrast cues: ON" if high_contrast else "High-contrast cues: OFF"
	reduced_motion_button.text = "Reduced motion: ON" if reduced_motion else "Reduced motion: OFF"
	ui_scale_button.text = "UI scale: %d%%" % int(UI_SCALE_PRESETS[ui_scale_index] * 100.0)
	window_mode_button.text = "Window mode: Fullscreen" if fullscreen_enabled else "Window mode: Windowed"
	resolution_button.text = "Window size: %s%s" % [_window_size_text(), " (saved)" if fullscreen_enabled else ""]
	effects_volume_button.text = "Effects volume: %d%%" % int(_effects_gain() * 100.0)
	feedback_cue_label.text = "Last feedback cue: %s" % last_cue_id.replace("_", " ").to_upper()
	event_feed_button.text = "Event feed: newest %d" % _event_feed_retention()
	auto_pause_button.text = "Threat auto-pause: ON" if auto_pause_on_threat else "Threat auto-pause: OFF"
	_refresh_binding_controls()
	_refresh_response_preview()
	_refresh_layout_lens()
	_refresh_recovery_priorities()
	_refresh_recovery_action_cards()
	_refresh_result_explanation()
	_refresh_navigation()
	keep_canvas.keep = keep
	keep_canvas.call("set_focus", focused_enemy_index)
	keep_canvas.call("set_accessibility", high_contrast)
	keep_canvas.call("set_reduced_motion", reduced_motion)
	keep_canvas.queue_redraw()

class KeepCanvas extends Control:
	signal map_hovered(floor: String, cell: Vector2i)
	signal map_clicked(floor: String, cell: Vector2i)
	signal enemy_clicked(index: int)
	signal timeline_enemy_clicked(index: int)
	var keep: PackKeepState
	const CELL_X := 18.0
	const CELL_Y := 28.0
	const BASE_CANVAS_SIZE := Vector2(810, 346)
	const COMBAT_EFFECT_DURATION := 0.52
	const ASSAULT_TICK_COUNT := 6
	const ASSAULT_TIMELINE_TOP := 300.0
	const MAP_ORIGIN := Vector2(12, 28)
	const UPPER_ORIGIN := Vector2(436, 28)
	const MAP_SIZE := Vector2(12 * CELL_X, 8 * CELL_Y)
	var preview_active: bool = false
	var preview_floor: String = "ground"
	var preview_origin: Vector2i = Vector2i.ZERO
	var preview_piece_id: String = ""
	var preview_valid: bool = false
	var feedback_color: Color = Color.TRANSPARENT
	var feedback_ttl: float = 0.0
	var high_contrast_mode: bool = false
	var reduced_motion_mode: bool = false
	var focused_enemy_index: int = -1
	var engagement_traces: Array[Dictionary] = []
	var target_impacts: Array[Dictionary] = []
	var engagement_ttl: float = 0.0

	func set_focus(index: int) -> void:
		focused_enemy_index = index
		queue_redraw()

	func set_preview(active: bool, floor: String, origin: Vector2i, piece_id: String, valid: bool) -> void:
		preview_active = active
		preview_floor = floor
		preview_origin = origin
		preview_piece_id = piece_id
		preview_valid = valid
		queue_redraw()

	func set_feedback(color: Color) -> void:
		feedback_color = color
		feedback_ttl = 0.0 if reduced_motion_mode else 0.38 if not high_contrast_mode else 0.18
		queue_redraw()

	func set_accessibility(enabled: bool) -> void:
		high_contrast_mode = enabled
		queue_redraw()

	func set_reduced_motion(enabled: bool) -> void:
		reduced_motion_mode = enabled
		if enabled:
			feedback_ttl = 0.0
			engagement_ttl = minf(engagement_ttl, 0.22)
		queue_redraw()

	func show_engagements(traces: Array[Dictionary]) -> void:
		var no_impacts: Array[Dictionary] = []
		show_combat_exchange(traces, no_impacts)

	func show_combat_exchange(traces: Array[Dictionary], impacts: Array[Dictionary]) -> void:
		engagement_traces = traces.duplicate(true)
		target_impacts = impacts.duplicate(true)
		engagement_ttl = 0.22 if reduced_motion_mode else COMBAT_EFFECT_DURATION
		queue_redraw()

	func _process(delta: float) -> void:
		if feedback_ttl > 0.0:
			feedback_ttl = maxf(0.0, feedback_ttl - delta)
			queue_redraw()
		if engagement_ttl > 0.0:
			engagement_ttl = maxf(0.0, engagement_ttl - delta)
			if engagement_ttl <= 0.0:
				engagement_traces.clear()
				target_impacts.clear()
			queue_redraw()
		if keep != null and keep.wave_active:
			queue_redraw()

	func _board_scale() -> float:
		return maxf(0.01, minf(size.x / BASE_CANVAS_SIZE.x, size.y / BASE_CANVAS_SIZE.y))

	func _board_offset() -> Vector2:
		var scale_factor: float = _board_scale()
		return (size - BASE_CANVAS_SIZE * scale_factor) * 0.5

	func _view_to_board(position: Vector2) -> Vector2:
		return (position - _board_offset()) / _board_scale()

	func _piece_board_origin(instance_id: String) -> Vector2:
		if not keep.pieces.has(instance_id):
			return Vector2.ZERO
		var instance: Dictionary = keep.pieces[instance_id]
		var piece_id: String = String(instance.get("piece_id", ""))
		var piece: Dictionary = keep.piece_definition(piece_id)
		var floor_origin: Vector2 = UPPER_ORIGIN if String(instance.get("floor", "ground")) == "upper" else MAP_ORIGIN
		var cell: Vector2i = instance.get("origin", Vector2i.ZERO)
		return floor_origin + Vector2(cell.x * CELL_X, cell.y * CELL_Y) + Vector2(piece.size.x * CELL_X, piece.size.y * CELL_Y) * 0.5

	func _enemy_contact_point(index: int, fallback: Vector2) -> Vector2:
		var enemy: Dictionary = keep.enemies[index]
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		var target_id: String = String(enemy.get("target", ""))
		if target_id.is_empty():
			var target_rooms: Array = keep.enemy_definition(enemy_id).get("target_rooms", [])
			if not target_rooms.is_empty():
				target_id = String(target_rooms[0])
		if keep.room_definitions().has(target_id):
			var target_room: Dictionary = keep.room_definition(target_id)
			var room_origin: Vector2 = UPPER_ORIGIN if String(target_room.get("floor", "ground")) == "upper" else MAP_ORIGIN
			return _room_rect(target_id, room_origin).get_center()
		if keep.pieces.has(target_id):
			return _piece_board_origin(target_id)
		return fallback

	func _enemy_origin(index: int) -> Vector2:
		var enemy: Dictionary = keep.enemies[index]
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		var entry_offset: Vector2 = Vector2(-16.0 + float(index % 2) * 32.0, float(index) * 5.0)
		var gate_start: Vector2 = MAP_ORIGIN + Vector2(MAP_SIZE.x * 0.5, MAP_SIZE.y - 10) + entry_offset
		var fallback_target: Vector2 = MAP_ORIGIN + Vector2(MAP_SIZE.x * 0.5, MAP_SIZE.y * 0.55) + entry_offset * 0.35
		var start: Vector2 = gate_start
		if enemy_id == "climber":
			start = UPPER_ORIGIN + Vector2(MAP_SIZE.x + 30, MAP_SIZE.y * 0.35 + index * 18)
			fallback_target = UPPER_ORIGIN + Vector2(MAP_SIZE.x * 0.45, 18 + index * 18)
		elif enemy_id == "siege_beast":
			fallback_target += Vector2(0, 18)
		var arrival_step: float = maxf(1.0, float(enemy.get("arrival_step", 1)))
		var continuous_time: float = float(keep.battle_step)
		if not reduced_motion_mode:
			continuous_time += keep.battle_clock
		var progress: float = clampf(continuous_time / arrival_step, 0.0, 1.0)
		progress = progress * progress * (3.0 - 2.0 * progress)
		return start.lerp(_enemy_contact_point(index, fallback_target), progress)

	func _combat_effect_progress() -> float:
		if engagement_ttl <= 0.0:
			return 1.0
		var duration: float = 0.22 if reduced_motion_mode else COMBAT_EFFECT_DURATION
		return clampf(1.0 - engagement_ttl / duration, 0.0, 1.0)

	func _enemy_reaction_offset(index: int) -> Vector2:
		if reduced_motion_mode or engagement_ttl <= 0.0:
			return Vector2.ZERO
		var was_hit: bool = false
		for trace in engagement_traces:
			if int(trace.get("enemy_index", -1)) == index:
				was_hit = true
				break
		if not was_hit:
			return Vector2.ZERO
		var progress: float = _combat_effect_progress()
		if progress < 0.45:
			return Vector2.ZERO
		var decay: float = 1.0 - progress
		return Vector2(sin(progress * PI * 8.0) * 3.5 * decay, 0.0)

	func _target_board_origin(target_kind: String, target_id: String) -> Vector2:
		if target_kind == "piece" and keep.pieces.has(target_id):
			return _piece_board_origin(target_id)
		if target_kind == "room" and keep.room_definitions().has(target_id):
			var room: Dictionary = keep.room_definition(target_id)
			var floor_origin: Vector2 = UPPER_ORIGIN if String(room.get("floor", "ground")) == "upper" else MAP_ORIGIN
			return _room_rect(target_id, floor_origin).get_center()
		return Vector2.ZERO

	func _enemy_contact_remaining(index: int) -> float:
		if keep == null or index < 0 or index >= keep.enemies.size():
			return INF
		var enemy: Dictionary = keep.enemies[index]
		return float(enemy.get("arrival_step", 1)) - (float(keep.battle_step) + keep.battle_clock)

	func _enemy_contact_is_imminent(index: int) -> bool:
		var remaining: float = _enemy_contact_remaining(index)
		return remaining > 0.0 and remaining <= 1.0

	func assault_timeline_snapshot() -> Dictionary:
		var arrivals: Dictionary = {}
		var next_arrival_step: int = -1
		var next_arrival_names: Array[String] = []
		var continuous_time: float = float(keep.battle_step) + keep.battle_clock if keep != null else 0.0
		if keep != null:
			for index in range(keep.enemies.size()):
				var enemy: Dictionary = keep.enemies[index]
				if bool(enemy.get("defeated", false)):
					continue
				var arrival_step: int = clampi(int(enemy.get("arrival_step", 1)), 1, ASSAULT_TICK_COUNT)
				var arrival_key: String = str(arrival_step)
				if not arrivals.has(arrival_key):
					arrivals[arrival_key] = []
				var enemy_id: String = String(enemy.get("enemy_id", ""))
				arrivals[arrival_key].append({"index": index, "enemy_id": enemy_id, "name": String(keep.enemy_definition(enemy_id).get("name", enemy_id))})
				if float(arrival_step) > continuous_time:
					if next_arrival_step < 0 or arrival_step < next_arrival_step:
						next_arrival_step = arrival_step
						next_arrival_names = [String(keep.enemy_definition(enemy_id).get("name", enemy_id))]
					elif arrival_step == next_arrival_step:
						next_arrival_names.append(String(keep.enemy_definition(enemy_id).get("name", enemy_id)))
		return {
			"tick_count": ASSAULT_TICK_COUNT,
			"resolved_ticks": keep.battle_step if keep != null else 0,
			"fractional_tick": keep.battle_clock if keep != null else 0.0,
			"progress": clampf(continuous_time / float(ASSAULT_TICK_COUNT), 0.0, 1.0),
			"arrivals": arrivals,
			"next_arrival_step": next_arrival_step,
			"next_arrival_names": next_arrival_names
		}

	func _enemy_hit(position: Vector2) -> int:
		if keep == null or not keep.wave_active:
			return -1
		var board_position: Vector2 = _view_to_board(position)
		var best_index: int = -1
		var best_distance: float = INF
		for index in range(keep.enemies.size()):
			var enemy: Dictionary = keep.enemies[index]
			if bool(enemy.get("defeated", false)):
				continue
			var enemy_id: String = String(enemy.get("enemy_id", ""))
			var radius: float = 12.0 if enemy_id == "siege_beast" else 8.0
			var distance: float = board_position.distance_to(_enemy_origin(index))
			if distance <= radius + 8.0 and (distance < best_distance or (is_equal_approx(distance, best_distance) and index < best_index)):
				best_index = index
				best_distance = distance
		return best_index

	func _timeline_layout() -> Dictionary:
		var left: float = MAP_ORIGIN.x
		var right: float = UPPER_ORIGIN.x + MAP_SIZE.x
		var top: float = ASSAULT_TIMELINE_TOP
		var gap: float = 3.0
		return {"left": left, "right": right, "top": top, "gap": gap, "segment_width": (right - left - gap * float(ASSAULT_TICK_COUNT - 1)) / float(ASSAULT_TICK_COUNT)}

	func assault_lane_spacing_snapshot() -> Dictionary:
		var approach_label_bottom: float = MAP_ORIGIN.y + MAP_SIZE.y
		if keep != null and keep.wave_active:
			for index in range(keep.enemies.size()):
				if bool(keep.enemies[index].get("defeated", false)):
					continue
				approach_label_bottom = maxf(approach_label_bottom, _enemy_origin(index).y + 28.0)
		return {
			"approach_label_bottom": approach_label_bottom,
			"timeline_top": ASSAULT_TIMELINE_TOP,
			"clearance": ASSAULT_TIMELINE_TOP - approach_label_bottom,
			"summary_bottom": ASSAULT_TIMELINE_TOP + 36.0,
			"canvas_bottom": BASE_CANVAS_SIZE.y
		}

	func _timeline_marker_origin(tick_number: int, marker_index: int, marker_count: int) -> Vector2:
		var layout: Dictionary = _timeline_layout()
		var segment_width: float = float(layout.segment_width)
		var segment_left: float = float(layout.left) + float(tick_number - 1) * (segment_width + float(layout.gap))
		return Vector2(segment_left + segment_width * 0.5 + (float(marker_index) - float(marker_count - 1) * 0.5) * 10.0, float(layout.top) - 5.0)

	func _timeline_enemy_hit(position: Vector2) -> int:
		if keep == null or not keep.wave_active:
			return -1
		var board_position: Vector2 = _view_to_board(position)
		var timeline: Dictionary = assault_timeline_snapshot()
		for tick_number in range(1, ASSAULT_TICK_COUNT + 1):
			var arrival_rows: Array = timeline.get("arrivals", {}).get(str(tick_number), [])
			for marker_index in range(arrival_rows.size()):
				if board_position.distance_to(_timeline_marker_origin(tick_number, marker_index, arrival_rows.size())) <= 9.0:
					return int(arrival_rows[marker_index].get("index", -1))
		return -1

	func _enemy_tooltip(index: int) -> String:
		if keep == null or index < 0 or index >= keep.enemies.size() or bool(keep.enemies[index].get("defeated", false)):
			return ""
		var inspection: Dictionary = keep.inspect_enemy(index)
		var counter_id: String = String(inspection.get("counter", ""))
		var counter_name: String = String(keep.piece_definition(counter_id).get("name", counter_id.replace("_", " ").capitalize())) if not counter_id.is_empty() else "Read the forecast"
		return "%s — %s\nRoute: %s | HP %d/%d | Contact T%d\nCounter: %s" % [String(inspection.get("name", "Threat")), String(inspection.get("doctrine", "unknown")).replace("_", " ").capitalize(), String(inspection.get("route", "unknown")).replace("_", " ").capitalize(), int(inspection.get("health", 0)), int(inspection.get("max_health", 0)), int(inspection.get("arrival_step", 0)), counter_name]

	func _get_tooltip(at_position: Vector2) -> String:
		var enemy_index: int = _enemy_hit(at_position)
		if enemy_index < 0:
			enemy_index = _timeline_enemy_hit(at_position)
		return _enemy_tooltip(enemy_index)

	func _map_hit(position: Vector2) -> Dictionary:
		position = _view_to_board(position)
		var hit_floor: String = ""
		var origin: Vector2 = MAP_ORIGIN
		if Rect2(MAP_ORIGIN, MAP_SIZE).has_point(position):
			hit_floor = "ground"
		elif Rect2(UPPER_ORIGIN, MAP_SIZE).has_point(position):
			hit_floor = "upper"
			origin = UPPER_ORIGIN
		if hit_floor.is_empty():
			return {"floor": "", "cell": Vector2i.ZERO}
		var local: Vector2 = position - origin
		return {"floor": hit_floor, "cell": Vector2i(floor(local.x / CELL_X), floor(local.y / CELL_Y))}

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseMotion:
			var hit: Dictionary = _map_hit(event.position)
			if not String(hit.get("floor", "")).is_empty():
				emit_signal("map_hovered", String(hit.get("floor", "")), hit.get("cell", Vector2i.ZERO))
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var enemy_index: int = _enemy_hit(event.position)
			if enemy_index >= 0:
				emit_signal("enemy_clicked", enemy_index)
				return
			var timeline_enemy_index: int = _timeline_enemy_hit(event.position)
			if timeline_enemy_index >= 0:
				emit_signal("timeline_enemy_clicked", timeline_enemy_index)
				return
			var hit: Dictionary = _map_hit(event.position)
			if not String(hit.get("floor", "")).is_empty():
				emit_signal("map_clicked", String(hit.get("floor", "")), hit.get("cell", Vector2i.ZERO))

	func _room_rect(room_id: String, origin: Vector2) -> Rect2:
		var room: Dictionary = keep.room_definition(room_id)
		return Rect2(origin + Vector2(room.origin.x * CELL_X, room.origin.y * CELL_Y), Vector2(room.size.x * CELL_X, room.size.y * CELL_Y))

	func _placement_box_rect(room_id: String, origin: Vector2) -> Rect2:
		var room: Dictionary = keep.room_definition(room_id)
		var box_width: int = mini(2, int(room.size.x))
		var box_height: int = mini(1, int(room.size.y))
		var box_origin: Vector2i = room.origin
		return Rect2(origin + Vector2(box_origin.x * CELL_X, box_origin.y * CELL_Y) + Vector2(3, 3), Vector2(box_width * CELL_X - 6, box_height * CELL_Y - 6))

	func _placement_box_occupied(box: Rect2, floor_name: String, origin: Vector2) -> bool:
		if keep == null:
			return false
		for instance in keep.pieces.values():
			if String(instance.get("floor", "ground")) != floor_name:
				continue
			var piece_id: String = String(instance.get("piece_id", ""))
			if keep.piece_definition(piece_id).is_empty():
				continue
			var piece: Dictionary = keep.piece_definition(piece_id)
			var piece_origin: Vector2i = instance.get("origin", Vector2i.ZERO)
			var piece_rect := Rect2(origin + Vector2(piece_origin.x * CELL_X, piece_origin.y * CELL_Y), Vector2(piece.size.x * CELL_X, piece.size.y * CELL_Y))
			if box.intersects(piece_rect):
				return true
		return false

	func _draw_placement_boxes(floor_name: String, origin: Vector2, outline_only: bool = false) -> void:
		for room_id in keep.room_definitions().keys():
			var room: Dictionary = keep.room_definition(String(room_id))
			if String(room.get("floor", "ground")) != floor_name:
				continue
			var box: Rect2 = _placement_box_rect(String(room_id), origin)
			var occupied: bool = _placement_box_occupied(box, floor_name, origin)
			var box_color := Color(0.93, 0.75, 0.42, 0.72) if not occupied else Color(0.78, 0.88, 0.71, 0.58)
			draw_rect(box, box_color, false, 2.0)
			if not outline_only and not occupied:
				draw_string(ThemeDB.fallback_font, box.position + Vector2(3, 10), "PLACE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.98, 0.88, 0.62, 0.9))

	func _room_color(room_id: String) -> Color:
		if keep == null:
			return Color("#3b3344")
		var room_state: String = keep.room_state(room_id)
		if high_contrast_mode:
			if room_state == "breached":
				return Color("#9d3441")
			if room_state == "damaged":
				return Color("#a66b27")
			if room_state == "strained":
				return Color("#81741b")
			return Color("#24526b")
		if room_state == "breached":
			return Color("#733b45")
		if room_state == "damaged":
			return Color("#8a684d")
		if room_state == "strained":
			return Color("#6f6544")
		return Color("#3d4b55")

	func _draw_fort_backdrop(origin: Vector2) -> void:
		var keep_definition: Dictionary = keep.keep_definition()
		var visual: Dictionary = keep_definition.get("visual", {})
		if String(visual.get("terrain", "fort")) == "river":
			_draw_river_backdrop(origin, visual)
			return
		var outer: Rect2 = Rect2(origin + Vector2(CELL_X, CELL_Y), MAP_SIZE - Vector2(CELL_X * 2.0, CELL_Y * 2.0))
		var courtyard: Rect2 = Rect2(origin + Vector2(CELL_X * 3.0, CELL_Y * 2.0), Vector2(CELL_X * 6.0, CELL_Y * 4.0))
		draw_rect(outer, Color("#514451"), true)
		draw_rect(outer, Color("#d4a66f"), false, 4.0)
		draw_rect(courtyard, Color("#332c38"), true)
		for y in range(4):
			draw_line(courtyard.position + Vector2(0, (y + 1) * CELL_Y), courtyard.position + Vector2(courtyard.size.x, (y + 1) * CELL_Y), Color(0.66, 0.55, 0.48, 0.2), 1.0)
		for x in range(6):
			draw_line(courtyard.position + Vector2((x + 1) * CELL_X, 0), courtyard.position + Vector2((x + 1) * CELL_X, courtyard.size.y), Color(0.66, 0.55, 0.48, 0.2), 1.0)
		for x in range(2, 10, 2):
			var top_block: Rect2 = Rect2(origin + Vector2(x * CELL_X + 2, CELL_Y + 2), Vector2(CELL_X - 4, 6))
			var bottom_block: Rect2 = Rect2(origin + Vector2(x * CELL_X + 2, MAP_SIZE.y - CELL_Y - 8), Vector2(CELL_X - 4, 6))
			draw_rect(top_block, Color("#d4a66f"), true)
			draw_rect(bottom_block, Color("#d4a66f"), true)
		for y in range(2, 6, 2):
			var left_block: Rect2 = Rect2(origin + Vector2(CELL_X + 2, y * CELL_Y + 2), Vector2(6, CELL_Y - 4))
			var right_block: Rect2 = Rect2(origin + Vector2(MAP_SIZE.x - CELL_X - 8, y * CELL_Y + 2), Vector2(6, CELL_Y - 4))
			draw_rect(left_block, Color("#d4a66f"), true)
			draw_rect(right_block, Color("#d4a66f"), true)
		var tower_size: Vector2 = Vector2(CELL_X * 1.6, CELL_Y * 1.35)
		for tower_position in [origin + Vector2(CELL_X, CELL_Y), origin + Vector2(MAP_SIZE.x - CELL_X - tower_size.x, CELL_Y), origin + Vector2(CELL_X, MAP_SIZE.y - CELL_Y - tower_size.y), origin + Vector2(MAP_SIZE.x - CELL_X - tower_size.x, MAP_SIZE.y - CELL_Y - tower_size.y)]:
			draw_rect(Rect2(tower_position, tower_size), Color("#665562"), true)
			draw_rect(Rect2(tower_position, tower_size), Color("#edbd79"), false, 2.0)
			draw_circle(tower_position + tower_size * 0.5, 4.0, Color("#f3bf6b"))
		draw_string(ThemeDB.fallback_font, courtyard.position + Vector2(8, courtyard.size.y - 8), String(visual.get("board_label", "KEEP ROOMS / DEFENSE BOARD")), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#a68f9e"))
		var gate: Rect2 = Rect2(origin + Vector2(CELL_X * 5.0, MAP_SIZE.y - CELL_Y + 4.0), Vector2(CELL_X * 2.0, CELL_Y - 8.0))
		draw_rect(gate, Color("#211b27"), true)
		draw_line(gate.position + Vector2(0, 5), gate.position + Vector2(gate.size.x, 5), Color("#e89270"), 3.0)
		draw_string(ThemeDB.fallback_font, origin + Vector2(MAP_SIZE.x * 0.5 - 22, MAP_SIZE.y - 8), "OPEN GATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#ffd19d"))
		draw_string(ThemeDB.fallback_font, courtyard.position + Vector2(12, courtyard.size.y * 0.5), "OPEN COURTYARD", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#8bd1b4"))

	func _draw_river_backdrop(origin: Vector2, visual: Dictionary) -> void:
		draw_rect(Rect2(origin, MAP_SIZE), Color("#263745"), true)
		for y in range(PackKeepState.GRID_SIZE.y):
			var wave_y: float = origin.y + float(y) * CELL_Y + CELL_Y * 0.5
			draw_line(origin + Vector2(0, wave_y - origin.y), origin + Vector2(MAP_SIZE.x, wave_y - origin.y), Color(0.36, 0.63, 0.69, 0.18), 1.0)
		draw_string(ThemeDB.fallback_font, origin + Vector2(8, 16), String(visual.get("board_label", "ASH FORD / CROSSING DEFENSE")), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#bcdbe0"))

	func _draw_spatial_overlay(floor_name: String, origin: Vector2) -> void:
		if floor_name != "ground":
			return
		var rule: Dictionary = keep.spatial_rule_state()
		if String(rule.get("id", "")) != "clear_causeway":
			return
		for lane_cell in rule.get("lane_cells", []):
			var lane_rect: Rect2 = Rect2(origin + Vector2(lane_cell.x * CELL_X, lane_cell.y * CELL_Y), Vector2(CELL_X, CELL_Y)).grow(-2)
			draw_rect(lane_rect, Color(0.71, 0.49, 0.25, 0.38) if bool(rule.get("active", false)) else Color(0.61, 0.25, 0.28, 0.46), true)
			draw_rect(lane_rect, Color("#e6c98b"), false, 1.0)
		draw_string(ThemeDB.fallback_font, origin + Vector2(58, 108), "CLEAR CAUSEWAY" if bool(rule.get("active", false)) else "CAUSEWAY BLOCKED", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#f3d39c"))

	func _draw_floor(label_text: String, floor_name: String, origin: Vector2) -> void:
		draw_string(ThemeDB.fallback_font, origin + Vector2(0, -10), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#e2bd84"))
		draw_rect(Rect2(origin, MAP_SIZE), Color("#27212e"), true)
		if floor_name == "ground":
			_draw_fort_backdrop(origin)
		else:
			draw_rect(Rect2(origin + Vector2(CELL_X, CELL_Y), MAP_SIZE - Vector2(CELL_X * 2.0, CELL_Y * 2.0)), Color("#3d5260"), true)
			draw_string(ThemeDB.fallback_font, origin + Vector2(14, 18), "WALL WALK / UPPER POSTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#c8e0d1"))
		draw_rect(Rect2(origin, MAP_SIZE), Color("#ae896d"), false, 3.0)
		for x in range(PackKeepState.GRID_SIZE.x + 1):
			draw_line(origin + Vector2(x * CELL_X, 0), origin + Vector2(x * CELL_X, MAP_SIZE.y), Color(0.4, 0.32, 0.42, 0.35), 1.0)
		for y in range(PackKeepState.GRID_SIZE.y + 1):
			draw_line(origin + Vector2(0, y * CELL_Y), origin + Vector2(MAP_SIZE.x, y * CELL_Y), Color(0.4, 0.32, 0.42, 0.35), 1.0)
		for connection in keep.keep_definition().get("connections", []):
			var first_room: Dictionary = keep.room_definition(String(connection[0]))
			var second_room: Dictionary = keep.room_definition(String(connection[1]))
			if String(first_room.get("floor", "ground")) != floor_name or String(second_room.get("floor", "ground")) != floor_name:
				continue
			var first_center: Vector2 = _room_rect(String(connection[0]), origin).get_center()
			var second_center: Vector2 = _room_rect(String(connection[1]), origin).get_center()
			draw_line(first_center, second_center, Color(0.9, 0.77, 0.52, 0.48), 3.0)
		for room_id in keep.room_definitions().keys():
			var room: Dictionary = keep.room_definition(String(room_id))
			if String(room.get("floor", "ground")) != floor_name:
				continue
			var rect: Rect2 = _room_rect(String(room_id), origin)
			draw_rect(rect, _room_color(String(room_id)), true)
			draw_rect(rect, Color("#c8b6a0"), false, 1.0)
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(2, 12), String(room.name), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 4, 9, Color("#eadfce"))
			var condition: int = keep.room_condition(String(room_id))
			var state_text: String = keep.room_state(String(room_id)).to_upper()
			draw_rect(Rect2(rect.position + Vector2(2, rect.size.y - 12), Vector2(maxf(4.0, (rect.size.x - 4.0) * float(condition) / 100.0), 4)), Color("#bfe8cf") if condition >= 70 else Color("#d7a35b") if condition >= 35 else Color("#d26155"), true)
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(2, rect.size.y - 3), "%s %d%%" % [state_text, condition], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 4, 8, Color("#fff4df"))
		_draw_spatial_overlay(floor_name, origin)
		_draw_placement_boxes(floor_name, origin)
		for instance in keep.pieces.values():
			if String(instance.get("floor", "ground")) != floor_name:
				continue
			var piece_id: String = String(instance.get("piece_id", ""))
			var piece: Dictionary = keep.piece_definition(piece_id)
			var piece_origin: Vector2i = instance.get("origin", Vector2i.ZERO)
			var piece_rect: Rect2 = Rect2(origin + Vector2(piece_origin.x * CELL_X, piece_origin.y * CELL_Y), Vector2(piece.size.x * CELL_X, piece.size.y * CELL_Y))
			var color: Color = Color("#7598aa") if piece_id == "pike_squad" else Color("#83a47d") if piece_id == "repair_station" else Color("#ba6f55") if piece_id == "fire_team" else Color("#cbb56f")
			if ["runner_pair", "supply_cache"].has(piece_id):
				color = Color("#61aeb5")
			elif ["rear_guard", "breakaway_barricade"].has(piece_id):
				color = Color("#c88c5a")
			elif ["crossbow_patrol", "watch_banner"].has(piece_id):
				color = Color("#9272b8")
			elif piece_id == "bellkeepers":
				color = Color("#d3b65f")
			elif ["shield_wardens", "emergency_shutters"].has(piece_id):
				color = Color("#6f839d")
			draw_rect(piece_rect.grow(-2), color, true)
			draw_rect(piece_rect.grow(-2), Color("#f1dfb8"), false, 1.5)
			_draw_piece_glyph(piece_rect, piece_id, color)
			draw_string(ThemeDB.fallback_font, piece_rect.position + Vector2(2, 11), String(piece.name), HORIZONTAL_ALIGNMENT_LEFT, piece_rect.size.x - 12, 8, Color("#201a25"))
			var piece_status: String = "%d/%d hp" % [int(instance.get("health", 0)), int(instance.get("max_health", piece.get("max_health", 0)))]
			var max_ammo: int = int(instance.get("max_ammo", piece.get("max_ammo", 0)))
			if max_ammo > 0:
				piece_status += " AMMO %d/%d" % [int(instance.get("ammo", max_ammo)), max_ammo]
			if bool(instance.get("disabled", false)):
				piece_status += " DISABLED"
			elif piece_id == "supply_cache":
				piece_status += " " + ("SPENT" if bool(instance.get("supply_spent", false)) else "READY")
			elif piece_id == "rear_guard":
				piece_status += " " + ("ENGAGED" if keep.fallback_active() else "RESERVE")
			var assignment: String = String(instance.get("assignment", ""))
			var zone: String = String(instance.get("placement_zone", "keep"))
			piece_status += " " + zone.to_upper()
			if not assignment.is_empty():
				piece_status += " " + assignment
			var piece_health: int = int(instance.get("health", 0))
			var piece_max_health: int = int(instance.get("max_health", piece.get("max_health", 0)))
			var health_ratio: float = float(piece_health) / float(maxi(1, piece_max_health))
			draw_rect(Rect2(piece_rect.position + Vector2(2, 14), Vector2(maxf(3.0, (piece_rect.size.x - 4.0) * health_ratio), 3)), Color("#bfe8cf") if health_ratio >= 0.7 else Color("#d7a35b") if health_ratio >= 0.35 else Color("#d26155"), true)
			draw_string(ThemeDB.fallback_font, piece_rect.position + Vector2(2, piece_rect.size.y - 3), zone.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, piece_rect.size.x - 4, 7, Color("#201a25"))
			if float(instance.get("condition", 0.0)) < 1.0 or not assignment.is_empty() or high_contrast_mode or ["supply_cache", "rear_guard"].has(piece_id):
				draw_string(ThemeDB.fallback_font, piece_rect.position + Vector2(2, piece_rect.size.y - 11), piece_status, HORIZONTAL_ALIGNMENT_LEFT, piece_rect.size.x - 4, 7, Color("#201a25"))
		_draw_placement_boxes(floor_name, origin, true)

	func _draw_piece_glyph(rect: Rect2, piece_id: String, color: Color) -> void:
		var center: Vector2 = rect.position + Vector2(rect.size.x - 9.0, rect.size.y * 0.5 + 2.0)
		if piece_id == "pike_squad":
			for offset in [-4.0, 0.0, 4.0]:
				draw_line(center + Vector2(offset, 6), center + Vector2(offset, -6), Color("#f7e3b7"), 1.5)
		elif piece_id == "fire_team":
			draw_circle(center, 5.0, Color("#f7e3b7"), false, 1.5)
			draw_line(center + Vector2(-6, 2), center + Vector2(6, -4), Color("#f7e3b7"), 2.0)
		elif piece_id == "repair_station":
			draw_line(center + Vector2(-6, 0), center + Vector2(6, 0), Color("#f7e3b7"), 2.0)
			draw_line(center + Vector2(0, -6), center + Vector2(0, 6), Color("#f7e3b7"), 2.0)
		elif piece_id == "scout_post":
			draw_circle(center, 5.0, Color("#f7e3b7"), false, 1.5)
			draw_circle(center, 1.5, Color("#f7e3b7"))
		elif piece_id == "runner_pair":
			draw_circle(center + Vector2(-4, 0), 3.0, Color("#f7e3b7"), false, 1.5)
			draw_circle(center + Vector2(4, 0), 3.0, Color("#f7e3b7"), false, 1.5)
			draw_line(center + Vector2(-1, 0), center + Vector2(1, 0), Color("#fff4df"), 2.0)
		elif piece_id == "supply_cache":
			draw_rect(Rect2(center - Vector2(6, 5), Vector2(12, 10)), Color("#f7e3b7"), false, 1.5)
			draw_line(center + Vector2(-3, 0), center + Vector2(3, 0), Color("#fff4df"), 1.5)
			draw_line(center + Vector2(0, -3), center + Vector2(0, 3), Color("#fff4df"), 1.5)
		elif piece_id == "rear_guard":
			draw_polyline(PackedVector2Array([center + Vector2(0, -6), center + Vector2(5, -3), center + Vector2(4, 4), center + Vector2(0, 7), center + Vector2(-4, 4), center + Vector2(-5, -3), center + Vector2(0, -6)]), Color("#f7e3b7"), 1.5)
			draw_line(center + Vector2(7, -6), center + Vector2(7, 7), Color("#fff4df"), 1.5)
		elif piece_id == "breakaway_barricade":
			draw_line(center + Vector2(-6, 6), center + Vector2(6, -6), Color("#f7e3b7"), 2.0)
			draw_line(center + Vector2(-6, -6), center + Vector2(6, 6), Color("#f7e3b7"), 2.0)
			draw_line(center + Vector2(-7, 0), center + Vector2(7, 0), Color("#fff4df"), 1.5)
		elif piece_id == "crossbow_patrol":
			draw_line(center + Vector2(-6, -5), center + Vector2(6, 5), Color("#f7e3b7"), 1.5)
			draw_line(center + Vector2(-6, 5), center + Vector2(6, -5), Color("#f7e3b7"), 1.5)
			draw_line(center + Vector2(-7, 0), center + Vector2(7, 0), Color("#fff4df"), 2.0)
		elif piece_id == "watch_banner":
			draw_line(center + Vector2(-4, 7), center + Vector2(-4, -7), Color("#f7e3b7"), 2.0)
			draw_colored_polygon(PackedVector2Array([center + Vector2(-3, -7), center + Vector2(6, -4), center + Vector2(-3, 0)]), Color("#f7e3b7"))
		elif piece_id == "bellkeepers":
			draw_arc(center + Vector2(0, 1), 6.0, PI, TAU, 12, Color("#fff4df"), 2.0)
			draw_line(center + Vector2(-6, 1), center + Vector2(6, 1), Color("#f7e3b7"), 1.5)
			draw_circle(center + Vector2(0, 6), 1.8, Color("#fff4df"))
		elif piece_id == "shield_wardens":
			draw_arc(center, 7.0, -PI * 0.75, PI * 0.75, 12, Color("#fff4df"), 2.0)
			draw_line(center + Vector2(-5, 5), center + Vector2(5, 5), Color("#f7e3b7"), 2.0)
		elif piece_id == "emergency_shutters":
			for offset in [-5, 0, 5]:
				draw_line(center + Vector2(-7, offset), center + Vector2(7, offset), Color("#f7e3b7"), 1.5)
		else:
			draw_circle(center + Vector2(0, -2), 4.0, Color("#f7e3b7"))
			draw_line(center + Vector2(-5, 5), center + Vector2(0, -7), Color("#f7e3b7"), 2.0)
			draw_line(center + Vector2(5, 5), center + Vector2(0, -7), Color("#f7e3b7"), 2.0)

	func _draw_gate_entry_path() -> void:
		var gate_point: Vector2 = MAP_ORIGIN + Vector2(MAP_SIZE.x * 0.5, MAP_SIZE.y - 4.0)
		var courtyard_point: Vector2 = MAP_ORIGIN + Vector2(MAP_SIZE.x * 0.5, MAP_SIZE.y * 0.55)
		draw_line(gate_point, courtyard_point, Color(0.95, 0.58, 0.38, 0.55), 3.0)
		draw_circle(gate_point, 5.0, Color("#ffd19d"), false, 2.0)
		draw_string(ThemeDB.fallback_font, gate_point + Vector2(8, -4), "GATE ENTRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#ffd19d"))

	func _enemy_marker_color(enemy_id: String) -> Color:
		return Color("#d26155") if enemy_id == "raider" else Color("#d7a35b") if enemy_id == "sapper" else Color("#a77bd1") if enemy_id == "climber" else Color("#9e3f48") if enemy_id == "shield_guard" else Color("#77727b") if enemy_id == "ash_slinger" else Color("#78453c") if enemy_id == "shieldbreaker" else Color("#b36c45")

	func _enemy_marker_initial(enemy_id: String) -> String:
		return "R" if enemy_id == "raider" else "S" if enemy_id == "sapper" else "C" if enemy_id == "climber" else "G" if enemy_id == "shield_guard" else "A" if enemy_id == "ash_slinger" else "X" if enemy_id == "shieldbreaker" else "B"

	func _draw_enemies() -> void:
		if keep == null or not keep.wave_active:
			return
		_draw_gate_entry_path()
		for index in range(keep.enemies.size()):
			var enemy: Dictionary = keep.enemies[index]
			if bool(enemy.get("defeated", false)):
				continue
			var enemy_id: String = String(enemy.get("enemy_id", ""))
			var enemy_def: Dictionary = keep.enemy_definition(enemy_id)
			var enemy_origin: Vector2 = _enemy_origin(index) + _enemy_reaction_offset(index)
			var enemy_color: Color = _enemy_marker_color(enemy_id)
			var marker_radius: float = 12.0 if enemy_id == "siege_beast" else 9.0 if enemy_id == "shield_guard" else 8.0
			draw_circle(enemy_origin, marker_radius, enemy_color)
			draw_circle(enemy_origin, marker_radius, Color("#f1dfb8"), false, 1.5)
			if index == focused_enemy_index:
				draw_circle(enemy_origin, marker_radius + 5.0, Color("#fff4df"), false, 2.5)
				draw_circle(enemy_origin, marker_radius + 9.0, Color("#e2bd84"), false, 1.5)
				draw_string(ThemeDB.fallback_font, enemy_origin + Vector2(-18, 28), "FOCUSED", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#fff4df"))
			if enemy_id == "siege_beast":
				draw_circle(enemy_origin, marker_radius + 5.0, Color(0.7, 0.3, 0.15, 0.35), false, 2.0)
				draw_circle(enemy_origin, marker_radius + 18.0, Color(0.86, 0.35, 0.18, 0.22), false, 2.0)
				draw_string(ThemeDB.fallback_font, enemy_origin + Vector2(-16, -18), "AREA", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#ffd19d"))
			elif enemy_id == "shield_guard":
				draw_arc(enemy_origin, marker_radius + 3.0, -PI * 0.75, PI * 0.75, 10, Color("#fff4df"), 2.0)
				draw_string(ThemeDB.fallback_font, enemy_origin + Vector2(-17, -16), "ARMOR 2", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#fff4df"))
			elif enemy_id == "ash_slinger":
				draw_circle(enemy_origin + Vector2(-5, -4), 5.0, Color(0.75, 0.72, 0.76, 0.35))
				draw_circle(enemy_origin + Vector2(4, -5), 6.0, Color(0.75, 0.72, 0.76, 0.35))
				draw_string(ThemeDB.fallback_font, enemy_origin + Vector2(-16, -17), "SMOKE", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#fff4df"))
			elif enemy_id == "shieldbreaker":
				draw_line(enemy_origin + Vector2(-6, -6), enemy_origin + Vector2(6, 6), Color("#fff4df"), 3.0)
				draw_line(enemy_origin + Vector2(2, -8), enemy_origin + Vector2(8, -2), Color("#f1dfb8"), 3.0)
				draw_string(ThemeDB.fallback_font, enemy_origin + Vector2(-18, -18), "BREAK", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#fff4df"))
			var target_id: String = String(enemy.get("target", ""))
			if not target_id.is_empty() and keep.room_definitions().has(target_id):
				var target_room: Dictionary = keep.room_definition(target_id)
				var target_origin: Vector2 = UPPER_ORIGIN if String(target_room.get("floor", "ground")) == "upper" else MAP_ORIGIN
				var target_rect: Rect2 = _room_rect(target_id, target_origin)
				draw_line(enemy_origin, target_rect.get_center(), Color("#fff4df") if index == focused_enemy_index else Color(0.95, 0.38, 0.28, 0.7), 2.5 if index == focused_enemy_index else 1.5)
				draw_circle(target_rect.get_center(), 8.0, Color("#fff4df") if index == focused_enemy_index else Color("#ffb0a6"), false, 2.0)
				if index == focused_enemy_index:
					draw_string(ThemeDB.fallback_font, target_rect.position + Vector2(2, -4), "TARGET", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#fff4df"))
			var doctrine_initial: String = _enemy_marker_initial(enemy_id)
			draw_string(ThemeDB.fallback_font, enemy_origin + Vector2(-3, 4), doctrine_initial, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#271b22"))

	func _draw_assault_timeline() -> void:
		if keep == null or not keep.wave_active:
			return
		var timeline: Dictionary = assault_timeline_snapshot()
		var layout: Dictionary = _timeline_layout()
		var left: float = float(layout.left)
		var right: float = float(layout.right)
		var top: float = float(layout.top)
		var gap: float = float(layout.gap)
		var segment_width: float = float(layout.segment_width)
		var resolved_ticks: int = int(timeline.get("resolved_ticks", 0))
		var fractional_tick: float = float(timeline.get("fractional_tick", 0.0))
		var completed_color: Color = Color("#77c7a0") if high_contrast_mode else Color("#4f9278")
		var active_color: Color = Color("#ffd166") if high_contrast_mode else Color("#d26155")
		for tick_index in range(ASSAULT_TICK_COUNT):
			var tick_number: int = tick_index + 1
			var segment: Rect2 = Rect2(Vector2(left + float(tick_index) * (segment_width + gap), top), Vector2(segment_width, 11.0))
			draw_rect(segment, Color("#342936"), true)
			draw_rect(segment, Color("#8c7286"), false, 1.0)
			if tick_number <= resolved_ticks:
				draw_rect(segment.grow(-1.0), completed_color, true)
			elif tick_number == resolved_ticks + 1 and resolved_ticks < ASSAULT_TICK_COUNT:
				draw_rect(Rect2(segment.position + Vector2.ONE, Vector2(maxf(0.0, (segment.size.x - 2.0) * fractional_tick), segment.size.y - 2.0)), active_color, true)
			draw_string(ThemeDB.fallback_font, segment.position + Vector2(4, 9), "T%d" % tick_number, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#fff4df"))
			var arrival_rows: Array = timeline.get("arrivals", {}).get(str(tick_number), [])
			for marker_index in range(arrival_rows.size()):
				var marker: Dictionary = arrival_rows[marker_index]
				var enemy_id: String = String(marker.get("enemy_id", ""))
				var marker_origin: Vector2 = _timeline_marker_origin(tick_number, marker_index, arrival_rows.size())
				draw_circle(marker_origin, 5.0, _enemy_marker_color(enemy_id))
				draw_circle(marker_origin, 5.0, Color("#fff4df"), false, 1.0)
				if int(marker.get("index", -1)) == focused_enemy_index:
					draw_circle(marker_origin, 8.0, Color("#fff4df"), false, 2.0)
					draw_circle(marker_origin, 10.5, Color("#e2bd84"), false, 1.0)
				draw_string(ThemeDB.fallback_font, marker_origin + Vector2(-2.5, 2.8), _enemy_marker_initial(enemy_id), HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#211a24"))
		var next_step: int = int(timeline.get("next_arrival_step", -1))
		var next_names: Array[String] = []
		for enemy_name in timeline.get("next_arrival_names", []):
			next_names.append(String(enemy_name))
		var summary: String = "ALL ACTIVE THREATS IN CONTACT" if next_step < 0 else "NEXT CONTACT — T%d %s" % [next_step, " + ".join(next_names)]
		draw_string(ThemeDB.fallback_font, Vector2(left, top + 28.0), "%s | TICKS RESOLVE DETERMINISTICALLY" % summary, HORIZONTAL_ALIGNMENT_LEFT, right - left, 9, Color("#c8b6a0"))

	func _draw_contact_telegraphs() -> void:
		if keep == null or not keep.wave_active:
			return
		for index in range(keep.enemies.size()):
			if bool(keep.enemies[index].get("defeated", false)) or not _enemy_contact_is_imminent(index):
				continue
			var remaining: float = _enemy_contact_remaining(index)
			var urgency: float = 1.0 - clampf(remaining, 0.0, 1.0)
			var pulse: float = 0.0 if reduced_motion_mode else sin(urgency * PI * 4.0) * 2.0
			var origin: Vector2 = _enemy_origin(index)
			var color: Color = Color("#fff4df") if high_contrast_mode else Color("#ef8d62")
			draw_circle(origin, 14.0 + urgency * 5.0 + pulse, Color(color, 0.28 + urgency * 0.42), false, 2.0)
			draw_string(ThemeDB.fallback_font, origin + Vector2(-18, -17), "CONTACT", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, color)

	func _draw_engagement_traces() -> void:
		if engagement_ttl <= 0.0 or (engagement_traces.is_empty() and target_impacts.is_empty()):
			return
		var progress: float = _combat_effect_progress()
		for trace in engagement_traces:
			var attacker_id: String = String(trace.get("attacker_id", ""))
			var enemy_index: int = int(trace.get("enemy_index", -1))
			if not keep.pieces.has(attacker_id) or enemy_index < 0 or enemy_index >= keep.enemies.size():
				continue
			var start: Vector2 = _piece_board_origin(attacker_id)
			var target: Vector2 = _enemy_origin(enemy_index) + _enemy_reaction_offset(enemy_index)
			var style: String = String(trace.get("style", "melee"))
			var trace_color: Color = Color("#ffe08a") if style == "ranged" else Color("#9fe1c0")
			if reduced_motion_mode:
				draw_circle(target, 10.0, Color(trace_color, 0.8), false, 2.5)
			elif style == "ranged":
				var travel: float = clampf(progress / 0.72, 0.0, 1.0)
				var projectile: Vector2 = start.lerp(target, travel)
				var tail: Vector2 = start.lerp(target, maxf(0.0, travel - 0.16))
				draw_line(start, target, Color(trace_color, 0.18), 1.0)
				draw_line(tail, projectile, Color(trace_color, 0.92), 3.0)
				draw_circle(projectile, 3.5, trace_color)
			else:
				var direction: Vector2 = start.direction_to(target)
				var lunge: float = sin(clampf(progress / 0.72, 0.0, 1.0) * PI) * minf(28.0, start.distance_to(target) * 0.28)
				draw_line(start, start + direction * lunge, Color(trace_color, 0.9), 4.0)
				draw_arc(start + direction * lunge, 7.0, -PI * 0.35, PI * 0.35, 8, trace_color, 2.0)
			if reduced_motion_mode or progress >= 0.58:
				var impact_strength: float = 1.0 if reduced_motion_mode else 1.0 - progress
				draw_circle(target, 7.0 + impact_strength * 7.0, Color(trace_color, 0.75), false, 2.5)
				draw_string(ThemeDB.fallback_font, target + Vector2(10, -8), "-%d" % int(trace.get("damage", 0)), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#fff4df"))
		for impact in target_impacts:
			var target: Vector2 = _target_board_origin(String(impact.get("target_kind", "")), String(impact.get("target_id", "")))
			if target == Vector2.ZERO:
				continue
			var source_index: int = int(impact.get("enemy_index", -1))
			var source: Vector2 = _enemy_origin(source_index) if source_index >= 0 and source_index < keep.enemies.size() else target + Vector2(0, 28)
			var pressure_color: Color = Color("#ff796f")
			if not reduced_motion_mode:
				var strike_progress: float = clampf(progress / 0.62, 0.0, 1.0)
				draw_line(source, source.lerp(target, strike_progress), Color(pressure_color, 0.82), 3.0)
			if reduced_motion_mode or progress >= 0.48:
				draw_circle(target, 9.0 + (1.0 - progress) * 8.0, Color(pressure_color, 0.85), false, 3.0)
				draw_string(ThemeDB.fallback_font, target + Vector2(10, 12), "-%d STRUCTURE" % int(impact.get("damage", 0)), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#ffb0a6"))

	func _draw() -> void:
		if keep == null:
			return
		var scale_factor: float = _board_scale()
		draw_set_transform(_board_offset(), 0.0, Vector2(scale_factor, scale_factor))
		var visual: Dictionary = keep.keep_definition().get("visual", {})
		_draw_floor(String(visual.get("ground_label", "GROUND FLOOR")), "ground", MAP_ORIGIN)
		_draw_floor(String(visual.get("upper_label", "UPPER FLOOR")), "upper", UPPER_ORIGIN)
		if preview_active and not keep.piece_definition(preview_piece_id).is_empty():
			var preview_size: Vector2i = keep.piece_definition(preview_piece_id).size
			var preview_origin_pixel: Vector2 = MAP_ORIGIN if preview_floor == "ground" else UPPER_ORIGIN
			var rect: Rect2 = Rect2(preview_origin_pixel + Vector2(preview_origin.x * CELL_X, preview_origin.y * CELL_Y), Vector2(preview_size.x * CELL_X, preview_size.y * CELL_Y)).grow(-2)
			var preview_color: Color = Color(0.27, 0.82, 0.55, 0.42) if preview_valid else Color(0.86, 0.28, 0.32, 0.42)
			draw_rect(rect, preview_color, true)
			draw_rect(rect, Color("#bff0cc") if preview_valid else Color("#ffb0a6"), false, 2.0)
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(3, 12), "VALID" if preview_valid else "INVALID", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#fff4df"))
		_draw_contact_telegraphs()
		_draw_enemies()
		_draw_engagement_traces()
		_draw_assault_timeline()
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if feedback_ttl > 0.0:
			var feedback_alpha: float = minf(0.32, feedback_ttl * 0.9)
			draw_rect(Rect2(Vector2.ZERO, size), Color(feedback_color, feedback_alpha), false, 5.0)
			draw_string(ThemeDB.fallback_font, Vector2(14, size.y - 12), "IMPACT / RECOVERY CUE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(feedback_color, minf(0.95, feedback_alpha + 0.45)))
