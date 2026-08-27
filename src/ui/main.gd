extends Control

const PackKeepState = preload("res://src/core/keep_state.gd")
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
var gameplay_columns: Control
var command_scroll: ScrollContainer
var title_card: PanelContainer
var screen_label: Label
var screen_hint: Label
var art_banner: TextureRect
var pause_button: Button
var speed_button: Button
var mute_button: Button
var contrast_button: Button
var input_help_label: Label
var quick_test_button: Button
var screen: String = "title"
var battle_paused: bool = true
var battle_speed_index: int = 1
var audio_muted: bool = false
var high_contrast: bool = false
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
	_setup_audio()
	_build_ui()
	_set_screen("title")

func _process(delta: float) -> void:
	if battle_paused or not keep.wave_active:
		return
	var result: Dictionary = keep.advance_wave(delta * _battle_speed())
	if bool(result.get("resolved", false)):
		battle_paused = true
		_set_feedback(Color("#bfe8cf"))
		_set_event("Wave resolved: %s. Read the report before rebuilding." % String(result.get("outcome", "unknown")).replace("_", " "))
		_set_screen("results")
	else:
		if keep.battle_report.size() > last_log_size:
			_set_feedback(Color("#d26155"))
			last_log_size = keep.battle_report.size()
		_refresh_ui()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
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
	elif event.is_action_pressed("focus_cycle_backward"):
		_cycle_enemy_focus(-1)
	elif event.is_action_pressed("focus_cycle_forward"):
		_cycle_enemy_focus(1)
	elif event.is_action_pressed("focus_enemy"):
		_focus_selected_enemy()

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

func _set_feedback(color: Color) -> void:
	if keep_canvas != null:
		keep_canvas.call("set_feedback", color)
	if not audio_muted:
		_play_tone(440.0 if color.g > color.r else 150.0)

func _play_tone(frequency: float) -> void:
	if audio_player == null or audio_muted:
		return
	var playback: AudioStreamGeneratorPlayback = audio_player.get_stream_playback()
	if playback == null:
		return
	var frame_count: int = int(audio_stream.mix_rate * 0.09)
	for frame in range(frame_count):
		var envelope: float = 1.0 - float(frame) / float(frame_count)
		var sample: float = sin(TAU * frequency * float(frame) / audio_stream.mix_rate) * 0.08 * envelope
		playback.push_frame(Vector2(sample, sample))

func _toggle_battle_pause() -> void:
	if not keep.wave_active:
		_set_event("Pause is available during an active invasion.")
		return
	battle_paused = not battle_paused
	_set_event("Battle paused. Read the forecast and report." if battle_paused else "Battle resumed at %.1fx speed." % _battle_speed())
	_play_tone(330.0 if battle_paused else 520.0)
	_refresh_ui()

func _set_battle_speed(index: int) -> void:
	battle_speed_index = clampi(index, 0, 2)
	_set_event("Battle speed set to %.1fx. Space pauses; N advances one manual step." % _battle_speed())
	_refresh_ui()

func _cycle_battle_speed() -> void:
	_set_battle_speed((battle_speed_index + 1) % 3)

func _toggle_mute() -> void:
	audio_muted = not audio_muted
	_set_event("Feedback tones muted." if audio_muted else "Feedback tones enabled.")
	_refresh_ui()

func _toggle_contrast() -> void:
	high_contrast = not high_contrast
	if keep_canvas != null:
		keep_canvas.call("set_accessibility", high_contrast)
	_set_event("High-contrast cues enabled." if high_contrast else "Standard color cues restored.")
	_refresh_ui()

func _focus_report() -> void:
	if log_label != null:
		log_label.grab_focus()
	_set_event("Causal report focused. Use the command table to intervene.")

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color("#17141d")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var shell: VBoxContainer = VBoxContainer.new()
	shell.add_theme_constant_override("separation", 10)
	margin.add_child(shell)

	var menu_bar: HBoxContainer = HBoxContainer.new()
	menu_bar.add_theme_constant_override("separation", 8)
	screen_label = Label.new()
	screen_label.custom_minimum_size = Vector2(170, 0)
	screen_label.add_theme_font_size_override("font_size", 16)
	screen_label.add_theme_color_override("font_color", Color("#e2bd84"))
	menu_bar.add_child(screen_label)
	for menu_item in ["title", "preparation", "battle", "results"]:
		var menu_button: Button = Button.new()
		menu_button.text = String(menu_item).capitalize()
		menu_button.pressed.connect(func() -> void: _set_screen(String(menu_item)))
		menu_bar.add_child(menu_button)
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

	var columns: HBoxContainer = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 14)
	columns.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	gameplay_columns = columns
	shell.add_child(columns)

	var left: VBoxContainer = VBoxContainer.new()
	left.custom_minimum_size = Vector2(810, 0)
	left.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	left.add_theme_constant_override("separation", 8)
	columns.add_child(left)

	var title: Label = Label.new()
	title.text = "PACK THE KEEP — GREYWATCH"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#e2bd84"))
	left.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "The Castellan’s first defense: connect the floors, read the doctrine, hold what matters."
	subtitle.add_theme_color_override("font_color", Color("#c0b2c8"))
	left.add_child(subtitle)

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
	keep_canvas.custom_minimum_size = Vector2(810, 292)
	keep_canvas.keep = keep
	keep_canvas.connect("map_hovered", Callable(self, "_on_map_hovered"))
	keep_canvas.connect("map_clicked", Callable(self, "_on_map_clicked"))
	keep_canvas.connect("enemy_clicked", Callable(self, "_on_enemy_clicked"))
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

	var right: PanelContainer = PanelContainer.new()
	right.custom_minimum_size = Vector2(292, 0)
	right.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	columns.add_child(right)
	command_scroll = ScrollContainer.new()
	command_scroll.custom_minimum_size = Vector2(286, 520)
	command_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(command_scroll)
	var controls: VBoxContainer = VBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	controls.custom_minimum_size = Vector2(278, 0)
	command_scroll.add_child(controls)

	var panel_title: Label = Label.new()
	panel_title.text = "COMMAND TABLE"
	panel_title.add_theme_font_size_override("font_size", 19)
	panel_title.add_theme_color_override("font_color", Color("#e2bd84"))
	controls.add_child(panel_title)
	input_help_label = Label.new()
	input_help_label.text = "P3 INPUT — Space pause | 1/2/3 speed | N step | R place | Esc cancel | Tab focus | E enemy | M mute | C contrast"
	input_help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	input_help_label.add_theme_font_size_override("font_size", 10)
	input_help_label.add_theme_color_override("font_color", Color("#aab1b2"))
	controls.add_child(input_help_label)
	commander_portrait = TextureRect.new()
	commander_portrait.texture = CASTELLAN_PORTRAIT
	commander_portrait.custom_minimum_size = Vector2(0, 92)
	commander_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	commander_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	commander_portrait.tooltip_text = "Commander portrait; Warden portrait art is pending the next asset-generation window."
	controls.add_child(commander_portrait)
	commander_profile_label = Label.new()
	commander_profile_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	commander_profile_label.custom_minimum_size = Vector2(292, 78)
	commander_profile_label.add_theme_color_override("font_color", Color("#c9bfd0"))
	controls.add_child(commander_profile_label)
	layout_lens_label = Label.new()
	layout_lens_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout_lens_label.custom_minimum_size = Vector2(292, 142)
	layout_lens_label.add_theme_color_override("font_color", Color("#d8c389"))
	controls.add_child(layout_lens_label)

	commander_option = OptionButton.new()
	for commander_id in keep.commander_ids():
		commander_option.add_item(String(keep.commander_definition(commander_id).get("name", commander_id)))
		commander_option.set_item_metadata(commander_option.item_count - 1, commander_id)
	controls.add_child(_labeled_control("Commander", commander_option))
	var commander_button: Button = Button.new()
	commander_button.text = "Take command"
	commander_button.pressed.connect(_on_select_commander)
	controls.add_child(commander_button)

	scenario_option = OptionButton.new()
	scenario_option.item_selected.connect(func(_index: int) -> void: _on_select_scenario())
	for scenario_id in PackKeepState.SCENARIOS.keys():
		scenario_option.add_item(String(PackKeepState.SCENARIOS[scenario_id].get("name", scenario_id)))
		scenario_option.set_item_metadata(scenario_option.item_count - 1, scenario_id)
	controls.add_child(_labeled_control("Greywatch scenario", scenario_option))
	scenario_preview_label = Label.new()
	scenario_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scenario_preview_label.custom_minimum_size = Vector2(292, 82)
	scenario_preview_label.add_theme_color_override("font_color", Color("#d8c389"))
	controls.add_child(scenario_preview_label)

	pack_option = OptionButton.new()
	pack_option.item_selected.connect(func(_index: int) -> void: _refresh_pack_preview())
	for pack_id in keep.pack_ids():
		pack_option.add_item(String(keep.pack_definition(pack_id).get("name", pack_id)))
		pack_option.set_item_metadata(pack_option.item_count - 1, pack_id)
	controls.add_child(_labeled_control("Pack offer", pack_option))
	var pack_button: Button = Button.new()
	pack_button.text = "Open pack"
	pack_button.pressed.connect(_on_open_pack)
	controls.add_child(pack_button)
	availability_label = Label.new()
	availability_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	availability_label.add_theme_color_override("font_color", Color("#aab1b2"))
	controls.add_child(availability_label)
	pack_preview_label = Label.new()
	pack_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pack_preview_label.custom_minimum_size = Vector2(292, 112)
	pack_preview_label.add_theme_color_override("font_color", Color("#d8c389"))
	controls.add_child(pack_preview_label)
	var reserve_button: Button = Button.new()
	reserve_button.text = "Reserve selected pack"
	reserve_button.tooltip_text = "Hold this offer without granting its pieces; opening it later consumes a preparation opening and its shown material cost."
	reserve_button.pressed.connect(_on_reserve_pack)
	controls.add_child(reserve_button)
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
	controls.add_child(asset_strip)

	piece_option = OptionButton.new()
	piece_option.item_selected.connect(func(_index: int) -> void: _on_piece_option_changed())
	for piece_id in PackKeepState.PIECES.keys():
		piece_option.add_item(String(PackKeepState.PIECES[piece_id].get("name", piece_id)))
		piece_option.set_item_metadata(piece_option.item_count - 1, piece_id)
		piece_option.set_item_disabled(piece_option.item_count - 1, not keep.available_pieces.has(String(piece_id)))
	controls.add_child(_labeled_control("Available piece", piece_option))

	floor_option = OptionButton.new()
	floor_option.item_selected.connect(func(_index: int) -> void: _arm_selected_piece())
	floor_option.add_item("Ground floor")
	floor_option.set_item_metadata(0, "ground")
	floor_option.add_item("Upper floor")
	floor_option.set_item_metadata(1, "upper")
	controls.add_child(_labeled_control("Floor", floor_option))
	room_option = OptionButton.new()
	room_option.item_selected.connect(func(_index: int) -> void: _refresh_recovery_action_cards())
	for room_id in PackKeepState.ROOMS.keys():
		room_option.add_item(String(PackKeepState.ROOMS[room_id].get("name", room_id)))
		room_option.set_item_metadata(room_option.item_count - 1, room_id)
	controls.add_child(_labeled_control("Room", room_option))
	var map_place_button: Button = Button.new()
	map_place_button.text = "Arm selected piece for map"
	map_place_button.tooltip_text = "Select a cell on either keep floor. The green footprint is authoritative; red means the state will reject it."
	map_place_button.pressed.connect(_arm_selected_piece)
	controls.add_child(map_place_button)
	var recommended_layout_button: Button = Button.new()
	recommended_layout_button.text = "Use recommended starter layout"
	recommended_layout_button.tooltip_text = "Places Pike Squad and Narrow Gate in a readable first-battle arrangement; each placement remains authoritative."
	recommended_layout_button.pressed.connect(_on_recommended_layout)
	controls.add_child(recommended_layout_button)
	var remove_piece_button: Button = Button.new()
	remove_piece_button.text = "Remove selected piece"
	remove_piece_button.tooltip_text = "Preparation-only: remove the inspected piece so you can test a different layout. Materials are not refunded."
	remove_piece_button.pressed.connect(_on_remove_piece)
	controls.add_child(remove_piece_button)
	var cancel_place_button: Button = Button.new()
	cancel_place_button.text = "Cancel map placement"
	cancel_place_button.pressed.connect(_on_cancel_placement)
	controls.add_child(cancel_place_button)
	var place_button: Button = Button.new()
	place_button.text = "Fallback: place at next slot"
	place_button.pressed.connect(_on_place_piece)
	controls.add_child(place_button)

	doctrine_option = OptionButton.new()
	for doctrine_id in ["gate_assault", "distributed_sabotage", "feint_and_flank", "area_pressure"]:
		doctrine_option.add_item(doctrine_id.replace("_", " ").capitalize())
		doctrine_option.set_item_metadata(doctrine_option.item_count - 1, doctrine_id)
	controls.add_child(_labeled_control("Invasion doctrine", doctrine_option))
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
	controls.move_child(recovery_actions_panel, 2)

	var start_button: Button = Button.new()
	start_button.text = "Start invasion"
	start_button.pressed.connect(_on_start_wave)
	controls.add_child(start_button)

	var advance_button: Button = Button.new()
	advance_button.text = "Advance one battle step"
	advance_button.tooltip_text = "Resolve one readable step; pause here to inspect the report."
	advance_button.pressed.connect(_on_advance_wave)
	advance_button.focus_mode = Control.FOCUS_ALL
	controls.add_child(advance_button)
	pause_button = Button.new()
	pause_button.text = "Pause battle (Space)"
	pause_button.tooltip_text = "Pause or resume automatic battle timing. Manual N steps remain deterministic."
	pause_button.pressed.connect(_toggle_battle_pause)
	controls.add_child(pause_button)
	speed_button = Button.new()
	speed_button.text = "Speed: 1.0x (1/2/3)"
	speed_button.tooltip_text = "Cycle battle speed; speed changes timing only, never outcomes."
	speed_button.pressed.connect(_cycle_battle_speed)
	controls.add_child(speed_button)

	commander_ability_button = Button.new()
	commander_ability_button.text = "Lockdown (Castellan)"
	commander_ability_button.tooltip_text = "Use the active commander ability once per wave."
	commander_ability_button.pressed.connect(_on_use_ability)
	controls.add_child(commander_ability_button)

	var repair_gate_button: Button = Button.new()
	repair_gate_button.text = "Repair Gate"
	repair_gate_button.pressed.connect(func() -> void: _run_result(keep.repair_room("gate"), "Repair"))
	controls.add_child(repair_gate_button)

	enemy_option = OptionButton.new()
	controls.add_child(_labeled_control("Enemy to inspect", enemy_option))
	var inspect_enemy_button: Button = Button.new()
	inspect_enemy_button.text = "Inspect selected enemy"
	inspect_enemy_button.pressed.connect(_on_inspect_enemy)
	controls.add_child(inspect_enemy_button)
	inspector_label = Label.new()
	inspector_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector_label.custom_minimum_size = Vector2(292, 92)
	inspector_label.add_theme_color_override("font_color", Color("#c9bfd0"))
	controls.add_child(inspector_label)
	response_preview_label = Label.new()
	response_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	response_preview_label.custom_minimum_size = Vector2(292, 90)
	response_preview_label.add_theme_color_override("font_color", Color("#d8c389"))
	controls.add_child(response_preview_label)
	recovery_priority_label = Label.new()
	recovery_priority_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recovery_priority_label.custom_minimum_size = Vector2(292, 80)
	recovery_priority_label.add_theme_color_override("font_color", Color("#bfe8cf"))
	controls.add_child(recovery_priority_label)
	var save_button: Button = Button.new()
	save_button.text = "Save keep state"
	save_button.pressed.connect(_on_save)
	controls.add_child(save_button)
	var load_button: Button = Button.new()
	load_button.text = "Load keep state"
	load_button.pressed.connect(_on_load)
	controls.add_child(load_button)
	var reset_button: Button = Button.new()
	reset_button.text = "New run / reset"
	reset_button.pressed.connect(_on_reset_run)
	controls.add_child(reset_button)
	mute_button = Button.new()
	mute_button.text = "Feedback tones: ON"
	mute_button.pressed.connect(_toggle_mute)
	controls.add_child(mute_button)
	contrast_button = Button.new()
	contrast_button.text = "High-contrast cues: OFF"
	contrast_button.pressed.connect(_toggle_contrast)
	contrast_button.tooltip_text = "Adds shape/text cues so doctrine and damage are not color-dependent."
	controls.add_child(contrast_button)

func _build_title_card() -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 170)
	var content: VBoxContainer = VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)
	card.add_child(content)
	var heading: Label = Label.new()
	heading.text = "GREYWATCH KEEP"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 34)
	heading.add_theme_color_override("font_color", Color("#e2bd84"))
	content.add_child(heading)
	var copy: Label = Label.new()
	copy.text = "Pack the Keep — a readable, deterministic defense of one two-floor stronghold.\nChoose a pack, place the defense, read the enemy doctrine, and recover what survives."
	copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	copy.add_theme_color_override("font_color", Color("#c0b2c8"))
	content.add_child(copy)
	var start_button: Button = Button.new()
	start_button.text = "Start Game — Quick Playtest"
	start_button.tooltip_text = "Open a deterministic preset Greywatch state with Pike Squad and Narrow Gate already placed."
	start_button.custom_minimum_size = Vector2(280, 38)
	start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_button.pressed.connect(_on_start_quick_playtest)
	content.add_child(start_button)
	var empty_button: Button = Button.new()
	empty_button.text = "Open Empty Preparation"
	empty_button.tooltip_text = "Enter the normal preparation screen without the quick-playtest preset."
	empty_button.custom_minimum_size = Vector2(220, 30)
	empty_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	empty_button.pressed.connect(func() -> void: _set_screen("preparation"))
	content.add_child(empty_button)
	return card

func _set_screen(next_screen: String) -> void:
	screen = next_screen
	if gameplay_columns:
		gameplay_columns.visible = screen != "title"
	if title_card:
		title_card.visible = screen == "title"
	if art_banner:
		art_banner.visible = screen == "title"
	if forecast_label:
		forecast_label.visible = screen != "results"
	if enemy_label:
		enemy_label.visible = screen != "results"
	if metrics_label:
		metrics_label.visible = screen != "title"
	if result_explain_label:
		result_explain_label.visible = screen == "results"
	if scorecard_label:
		scorecard_label.visible = screen == "results"
	if combat_explain_label:
		combat_explain_label.visible = screen != "results"
	if placement_label:
		placement_label.visible = screen != "results"
	if event_label:
		event_label.visible = screen != "results"
	if log_label:
		log_label.visible = screen != "results"
	if screen_label:
		screen_label.text = "GREYWATCH / %s" % screen.capitalize()
	if screen_hint:
		if screen == "preparation":
			screen_hint.text = "Place and assign before opening the next doctrine."
		elif screen == "battle":
			screen_hint.text = "Advance one step; inspect enemies before spending Lockdown."
		elif screen == "results":
			if keep and keep.repair_interval_active and keep.has_next_wave():
				screen_hint.text = "Repair or assign, then finish the interval to start the next wave automatically."
			else:
				screen_hint.text = "Read the report, repair what matters, then return to preparation."
		else:
			screen_hint.text = "A compact two-floor defense about pressure and recovery."
	_refresh_ui()
	if screen == "results" and keep and keep.repair_interval_active:
		call_deferred("_focus_recovery_controls")

func _focus_recovery_controls() -> void:
	if command_scroll and recovery_actions_panel and recovery_actions_panel.visible:
		command_scroll.scroll_vertical = 0

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
	var size: Vector2i = PackKeepState.PIECES[piece_id].size
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
	scenario_preview_label.text = "SCENARIO — %s\nObjective: %s\nLesson: %s\nWaves: %d | Seed variation: %s" % [String(preview.get("name", "")), String(preview.get("objective", "")), String(preview.get("lesson", "")), int(preview.get("wave_count", 0)), String(preview.get("variation_id", "standard"))]

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
	if placement_mode and PackKeepState.PIECES.has(piece_id):
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
			added.append(String(PackKeepState.PIECES[piece_id].get("name", piece_id)))
		else:
			blocked.append("%s: %s" % [String(PackKeepState.PIECES[piece_id].get("name", piece_id)), String(result.get("reason", "blocked"))])
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
		return "INSPECTOR — ENEMY %s\n%s via %s | %d/%d hp | damage %d\nCounter: %s | Target: %s" % [String(data.name), String(data.doctrine).replace("_", " "), String(data.route).replace("_", " "), int(data.health), int(data.max_health), int(data.damage), String(data.counter), String(data.target if not String(data.target).is_empty() else "approaching")]
	return "INSPECTOR — %s\n%s floor | %s zone | %d/%d hp | %s\n%s %d attack | Defense %d | Range %d | Ammo %d/%d\nSkill: %s\nAssignment %s" % [String(data.name), String(data.floor).capitalize(), String(data.placement_zone).to_upper(), int(data.health), int(data.max_health), String(data.role), String(data.combat_style).to_upper(), int(data.attack), int(data.defense), int(data.range), int(data.ammo), int(data.max_ammo), String(data.skill), String(data.assignment if not String(data.assignment).is_empty() else "none")]

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

func _select_enemy_focus(index: int, source: String) -> void:
	if index < 0 or index >= keep.enemies.size() or bool(keep.enemies[index].get("defeated", false)):
		return
	focused_enemy_index = index
	var inspection: Dictionary = keep.inspect_enemy(index)
	inspected_text = _format_inspection(inspection)
	for option_index in range(enemy_option.item_count):
		if int(enemy_option.get_item_metadata(option_index)) == index:
			enemy_option.select(option_index)
			break
	_set_event("Enemy %d focused via %s. Pause and choose the response." % [index + 1, source])
	keep_canvas.call("set_focus", focused_enemy_index)
	_refresh_ui()

func _on_enemy_clicked(index: int) -> void:
	_select_enemy_focus(index, "map click")

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
	response_preview_label.text = "RESPONSE — FOCUSED %d: %s\n%s\nTHREAT: %s | TARGET: %s\nCOUNTERS: %s\n%s: %s (%d command)" % [focused_enemy_index + 1, String(inspection.get("name", "enemy")), timing_text, String(inspection.get("doctrine", "approaching")).replace("_", " ").to_upper(), target_text, String(inspection.get("counter", "read the forecast")), ability_name, ability_state, keep.command_points]

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
	layout_lens_label.text = "LAYOUT SUMMARY — Ground %d | Upper %d | Wall %d | Courtyard %d | Keep %d\nCoverage — room edge %d | open lane %d | support %d | assigned %d\nCASTELLAN [%s] — %s Risk: %s\nWARDEN [%s] — %s Risk: %s\nWARNINGS — %s" % [int(counts.get("ground", 0)), int(counts.get("upper", 0)), int(counts.get("wall", 0)), int(counts.get("courtyard", 0)), int(counts.get("keep", 0)), int(summary.get("room_edge_count", 0)), int(summary.get("open_lane_count", 0)), int(summary.get("support_piece_count", 0)), int(summary.get("assigned_specialist_count", 0)), castellan_marker, String(castellan.get("summary", "")), String(castellan.get("risk", "")), warden_marker, String(warden.get("summary", "")), String(warden.get("risk", "")), " | ".join(warnings)]

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
		var critical: bool = bool(PackKeepState.ROOMS[id].get("critical", false))
		var score: int = 0
		if state == "breached":
			score = 400 if critical else 300
		elif state == "damaged":
			score = 200 if critical else 100
		elif state == "strained":
			score = 50
		score += 100 - condition
		priorities.append({"id": id, "name": String(PackKeepState.ROOMS[id].get("name", id)), "state": state.to_upper(), "condition": condition, "score": score})
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
	recovery_actions_panel.visible = keep.repair_interval_active
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
	finish_interval_button.disabled = false
	if keep.has_next_wave():
		finish_interval_button.text = "CONTINUE — START WAVE %d/%d" % [keep.wave_index + 1, keep.authored_wave_count()]
	else:
		finish_interval_button.text = "FINISH RECOVERY"

func _on_remove_piece() -> void:
	if keep.wave_active or keep.repair_interval_active:
		_set_event("Piece removal is preparation-only; finish the active wave or recovery interval first.")
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
		battle_paused = true
		last_log_size = keep.battle_report.size()
		_set_screen("battle")
		_set_event("Invasion staged. Battle is paused for inspection; press Space to run or N to step.")
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
			battle_paused = true
			focused_enemy_index = -1
			last_log_size = 0
			_set_screen("battle")
			_set_event("Next wave staged automatically. Battle is paused for inspection; press Space to run or N to step.")
			_refresh_ui()
		else:
			_set_screen("preparation")

func _on_advance_wave() -> void:
	var result: Dictionary = keep.advance_wave(1.0)
	if not bool(result.get("ok", false)):
		_set_event("Battle blocked: %s." % String(result.get("reason", "unknown")))
	elif bool(result.get("resolved", false)):
		_set_feedback(Color("#bfe8cf"))
		if keep.has_next_wave() and keep.repair_interval_active:
			_set_event("Wave %d resolved: %s. Recovery is open; finish the interval to start wave %d automatically." % [keep.wave_index, String(result.get("outcome", "unknown")).replace("_", " "), keep.wave_index + 1])
		else:
			_set_event("Wave %d resolved: %s. Read the final report." % [keep.wave_index, String(result.get("outcome", "unknown")).replace("_", " ")])
		_set_screen("results")
	else:
		_set_feedback(Color("#d7a35b"))
		_set_event("Battle step %d resolved. Pause and inspect the named target before committing the commander ability." % int(result.get("step", 0)))
	_refresh_ui()

func _on_use_ability() -> void:
	_run_result(keep.use_commander_ability(), "Ability")

func _run_result(result: Dictionary, label: String) -> void:
	if bool(result.get("ok", false)):
		_set_event("%s: %s" % [label, String(result.get("message", "command accepted"))])
		_set_feedback(Color("#9bd4c3") if label in ["Repair", "Assignment", "Placement"] else Color("#91b7da"))
	else:
		_set_event("%s blocked: %s." % [label, String(result.get("reason", "unknown"))])
		_set_feedback(Color("#d26155"))
	_refresh_ui()

func _on_save() -> void:
	var file: FileAccess = FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
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
	var had_previous_save: bool = FileAccess.file_exists(SAVE_PATH)
	if FileAccess.file_exists(SAVE_BACKUP_PATH):
		directory.remove(SAVE_BACKUP_PATH.get_file())
	if had_previous_save:
		var backup_error: Error = directory.rename(SAVE_PATH.get_file(), SAVE_BACKUP_PATH.get_file())
		if backup_error != OK:
			_set_event("Save failed: could not protect the previous save.")
			return
	var rename_error: Error = directory.rename(SAVE_TEMP_PATH.get_file(), SAVE_PATH.get_file())
	if rename_error != OK:
		if had_previous_save:
			directory.rename(SAVE_BACKUP_PATH.get_file(), SAVE_PATH.get_file())
		_set_event("Save failed: temporary save could not be committed; the previous save was retained.")
		return
	if FileAccess.file_exists(SAVE_BACKUP_PATH):
		directory.remove(SAVE_BACKUP_PATH.get_file())
	_set_event("Keep state saved safely with schema %d." % PackKeepState.SAVE_SCHEMA_VERSION)

func _on_load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_set_event("Load unavailable: no local keep save exists yet.")
		return
	var text: String = FileAccess.get_file_as_string(SAVE_PATH)
	var payload: Variant = JSON.parse_string(text)
	if not (payload is Dictionary):
		_set_event("Load rejected: the save is not valid JSON state. The current run is unchanged.")
		return
	var result: Dictionary = keep.load_serialized(payload)
	if not bool(result.get("ok", false)):
		_set_event("Load rejected: %s. The current run is unchanged." % String(result.get("reason", "unknown")))
		return
	_clear_placement_mode()
	selected_instance_id = ""
	inspected_text = "Save loaded. Click a room or piece to inspect the restored run."
	_set_event("Keep state loaded%s." % (" from a legacy save" if bool(result.get("legacy", false)) else ""))
	_refresh_ui()

func _on_playtest_primary_action() -> void:
	if screen == "results":
		if keep.repair_interval_active and keep.has_next_wave():
			_on_finish_interval()
		else:
			_on_start_quick_playtest()
	else:
		_on_quick_test_action()

func _on_start_quick_playtest() -> void:
	keep.reset_run(3307)
	focused_enemy_index = -1
	battle_paused = true
	battle_speed_index = 1
	last_log_size = 0
	_clear_placement_mode()
	selected_instance_id = ""
	for index in range(scenario_option.item_count):
		if String(scenario_option.get_item_metadata(index)) == "gatehouse_lock":
			scenario_option.select(index)
			break
	keep.select_scenario("gatehouse_lock")
	for index in range(doctrine_option.item_count):
		if String(doctrine_option.get_item_metadata(index)) == "gate_assault":
			doctrine_option.select(index)
			break
	_on_recommended_layout()
	_set_screen("preparation")
	_set_event("Quick playtest ready: Pike Squad and Narrow Gate are placed. Click Quick test: advance one battle step to stage the gate attack.")
	_refresh_ui()

func _on_quick_test_action() -> void:
	if screen == "title":
		_on_start_quick_playtest()
	if screen == "battle":
		if keep.wave_active:
			_on_advance_wave()
		else:
			_set_event("Battle is complete. Review Results or restart the quick playtest.")
			_refresh_ui()
		return
	if keep.wave_active:
		_set_event("Quick test already active. Press Space to run or use the primary action to advance one step.")
		_refresh_ui()
		return
	_on_start_wave()
	if keep.wave_active:
		_on_advance_wave()

func _on_reset_run() -> void:
	keep.reset_run(3307)
	focused_enemy_index = -1
	battle_paused = true
	battle_speed_index = 1
	last_log_size = 0
	_clear_placement_mode()
	selected_instance_id = ""
	inspected_text = "New Greywatch run started. Click a room or piece to inspect it."
	_set_screen("preparation")
	_set_event("New run started. Starter pieces are available and no save was overwritten.")
	_refresh_ui()

func _set_event(text: String) -> void:
	event_label.text = text

func _first_battle_guidance() -> String:
	if screen == "title":
		return ""
	if screen == "preparation":
		if keep.pieces.is_empty():
			return "FIRST BATTLE GUIDE — 1 Use the recommended starter layout, or place Pike Squad in the courtyard and Narrow Gate by the gate. 2 Open one pack if you want a second doctrine. 3 Start the invasion when the board reads clearly."
		return "FIRST BATTLE GUIDE — Layout ready. Read the FORECAST, then start the invasion. Battle begins paused; use Space to run or N to resolve one readable step."
	if screen == "battle":
		return "FIRST BATTLE GUIDE — The fort stays visible while enemies enter through the gate. Read the event feed after each step; use the focused enemy and response preview before spending the commander ability."
	if screen == "results":
		if keep.repair_interval_active and keep.has_next_wave():
			return "INTER-WAVE RECOVERY — Read the causal result, spend up to two repair or assignment actions, then finish the interval to start wave %d/%d automatically." % [keep.wave_index + 1, keep.authored_wave_count()]
		if keep.authored_wave_count() > 0 and keep.wave_index >= keep.authored_wave_count():
			return "SCENARIO COMPLETE — Read the final causal result, then restart the quick playtest to test a different doctrine response."
		return "FIRST BATTLE GUIDE — Read the causal result below, repair the highest-priority room, then finish the interval before the next doctrine. Change one placement at a time to learn the counter."
	return ""

func _scorecard_compact_text() -> String:
	var rows: Array[String] = []
	for index in range(keep.wave_history.size()):
		var wave: Dictionary = keep.wave_history[index]
		rows.append("W%d %s/%s" % [int(wave.get("wave", index + 1)), String(wave.get("doctrine", "")).replace("_", " "), String(wave.get("outcome", "")).replace("_", " ")])
	return " | ".join(rows) if not rows.is_empty() else "No resolved waves yet"

func _refresh_result_explanation() -> void:
	if result_explain_label == null:
		return
	if keep.last_outcome.is_empty():
		result_explain_label.text = "RESULT GUIDE — Finish a wave to see what the forecast, placement, and response produced."
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
		score_rows.append("W%d — %s — %s\nPressure: %s | Defeated %d | Room %d | Piece %d | recovery actions %d" % [int(wave.get("wave", score_rows.size() + 1)), String(wave.get("doctrine", "")).replace("_", " ").capitalize(), String(wave.get("outcome", "")).replace("_", " ").to_upper(), String(wave.get("principal_pressure", "Unknown pressure")), int(wave.get("defeated_enemies", 0)), int(wave.get("room_damage", 0)), int(wave.get("piece_damage", 0)), int(wave.get("recovery_actions_used", 0))])
	var report_heading: String = "SCENARIO REPORT" if String(report.get("status", "in_progress")) == "complete" else "RUN SO FAR"
	scorecard_label.text = "%s — %s | %s\n%s\nREPLAY KEY — %s" % [report_heading, String(report.get("scenario_name", keep.scenario_id)), String(report.get("commander_name", keep.commander_id)), "\n".join(score_rows) if not score_rows.is_empty() else "No resolved waves yet.", String(report.get("replay_key", ""))]

func _refresh_ui() -> void:
	_refresh_pack_preview()
	_refresh_scenario_preview()
	var interval_text: String = "closed"
	if keep.repair_interval_active:
		interval_text = "%d action(s): %s" % [keep.repair_actions_remaining, keep.repair_interval_reason]
	status_label.text = "%s | %s | Materials %d | Command %d | Morale %d | Pieces %d | Wave %d | Step %d | Breach %d | %s | Repair %s" % [keep.summary().get("commander", "Commander"), String(keep.scenario_preview().get("name", "Free drill")), keep.materials, keep.command_points, keep.morale, keep.pieces.size(), keep.wave_index, keep.battle_step, keep.breach_level, "PAUSED" if battle_paused else "RUNNING %.1fx" % _battle_speed(), interval_text]
	var commander: Dictionary = keep.commander_definition(keep.commander_id)
	commander_profile_label.text = "%s\nPassive: %s\nAbility: %s — %s\nLimitation: %s" % [String(commander.get("name", keep.commander_id)), String(commander.get("passive", "")), String(commander.get("ability_name", "")), String(commander.get("ability_text", "")), String(commander.get("limitation", ""))]
	commander_portrait.modulate = Color("#9fb9c3") if keep.commander_id == "warden" else Color.WHITE
	commander_portrait.tooltip_text = "The Warden — Open Lanes and Rally" if keep.commander_id == "warden" else "The Castellan — Layered Masonry and Lockdown"
	commander_ability_button.text = "%s (%s)" % [String(commander.get("ability_name", "Ability")), String(commander.get("name", keep.commander_id)).replace("The ", "")]
	commander_ability_button.tooltip_text = String(commander.get("ability_text", "Use once per wave."))
	var forecast: Dictionary = keep.forecast()
	forecast_label.text = "FORECAST — %s | Likely target: %s | Uncertainty: %s | Scout: %s" % [String(forecast.get("doctrine", "")).replace("_", " "), String(forecast.get("likely_target", "")), String(forecast.get("uncertainty", "")), "revealed" if bool(forecast.get("scout_bonus", false)) else "not revealed"]
	var enemy_lines: Array[String] = []
	for enemy in keep.enemies:
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		var enemy_state: String = "defeated" if bool(enemy.get("defeated", false)) else "%d/%d hp" % [int(enemy.get("hp", 0)), int(enemy.get("max_health", PackKeepState.ENEMIES[enemy_id].get("health", 0)))]
		var phase: String = "contact" if keep.battle_step >= int(PackKeepState.ENEMIES[enemy_id].get("arrival_step", 0)) else "approach"
		var target: String = String(enemy.get("target", ""))
		if target.is_empty():
			target = "approach"
		enemy_lines.append("%s [%s] — %s/%s — route %s — target %s" % [String(PackKeepState.ENEMIES[enemy_id].get("name", enemy_id)), enemy_id, phase, enemy_state, String(PackKeepState.ENEMIES[enemy_id].get("route", "")), target])
	enemy_label.text = "ENEMIES — " + (" | ".join(enemy_lines) if not enemy_lines.is_empty() else "No active enemies. Start an invasion to see doctrine-driven actors.")
	var metrics: Dictionary = keep.combat_metrics
	metrics_label.text = "METRICS — steps %d | unit attacks %d | damage dealt %d | ammo spent %d | enemy attacks %d | room damage %d | piece damage %d | repairs %d | disabled %d | defeated %d" % [int(metrics.get("battle_steps", 0)), int(metrics.get("unit_attacks", 0)), int(metrics.get("damage_dealt", 0)), int(metrics.get("ammo_spent", 0)), int(metrics.get("enemy_attacks", 0)), int(metrics.get("room_damage", 0)), int(metrics.get("piece_damage", 0)), int(metrics.get("repairs", 0)), int(metrics.get("disabled_units", 0)), int(metrics.get("defeated_enemies", 0))]
	combat_explain_label.text = "COMBAT — real-time auto-battle: enemies follow named routes toward behavior targets; defenders auto-attack when their style, floor, counter, cooldown, and ammunition allow. Pause to inspect; skills modify the next resolved step."
	var available_names: Array[String] = []
	for available_id in keep.available_pieces:
		available_names.append(String(PackKeepState.PIECES[available_id].get("name", available_id)))
	availability_label.text = "AVAILABLE — %s\nPack openings this Preparation: %d/%d" % [", ".join(available_names), keep.pack_openings_this_preparation, 2 if keep.wave_index == 0 else 1]
	for piece_index in range(piece_option.item_count):
		var piece_id: String = String(piece_option.get_item_metadata(piece_index))
		piece_option.set_item_disabled(piece_index, not keep.available_pieces.has(piece_id))
	enemy_option.clear()
	for enemy_index in range(keep.enemies.size()):
		var enemy_id: String = String(keep.enemies[enemy_index].get("enemy_id", ""))
		enemy_option.add_item("%d — %s" % [enemy_index + 1, String(PackKeepState.ENEMIES[enemy_id].get("name", enemy_id))])
		enemy_option.set_item_metadata(enemy_option.item_count - 1, enemy_index)
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
			playtest_button.text = "RUN QUICK TEST — ONE BATTLE STEP"
			playtest_button.disabled = keep.pieces.is_empty() or keep.repair_interval_active
			playtest_button.tooltip_text = "Start the preset invasion and leave Battle paused after one deterministic step."
			playtest_status_label.text = "TEST READY — %d starter piece(s) placed. One click starts the gate attack and leaves it paused." % keep.pieces.size() if not keep.pieces.is_empty() else "TEST WAITING — use the recommended layout or place at least one defender first."
		elif screen == "battle":
			playtest_button.text = "ADVANCE ONE STEP — INSPECT"
			playtest_button.disabled = not keep.wave_active
			playtest_button.tooltip_text = "Resolve one deterministic battle step and remain paused for inspection."
			playtest_status_label.text = "STEP %d — Battle is %s. Use this button or N for one step; use Space for real-time play." % [keep.battle_step, "paused" if battle_paused else "running"]
		elif screen == "results":
			if keep.repair_interval_active and keep.has_next_wave():
				playtest_button.text = "CONTINUE — START WAVE %d/%d" % [keep.wave_index + 1, keep.authored_wave_count()]
				playtest_button.disabled = false
				playtest_button.tooltip_text = "Close recovery and automatically start the next authored wave."
				playtest_status_label.text = "RECOVERY — %d action(s) remain. Repair or assign, then continue. %s" % [keep.repair_actions_remaining, _scorecard_compact_text()]
			else:
				playtest_button.text = "RESTART QUICK PLAYTEST"
				playtest_button.disabled = false
				playtest_button.tooltip_text = "Reset seed 3307 and replay the preset Gatehouse Lock test."
				playtest_status_label.text = "FINAL RESULTS — %s | Replay %s" % [_scorecard_compact_text(), String(keep.scenario_scorecard().get("replay_key", ""))]
	var recent: Array[String] = []
	var start: int = maxi(0, keep.battle_report.size() - 4)
	for index in range(start, keep.battle_report.size()):
		recent.append(keep.battle_report[index])
	recent.reverse()
	log_label.text = "COMBAT EVENT FEED — newest first\n" + ("\n".join(recent) if not recent.is_empty() else "No wave has started. This feed will name the forecast, response, target, damage, and recovery.")

	pause_button.text = "Resume battle (Space)" if battle_paused else "Pause battle (Space)"
	speed_button.text = "Speed: %.1fx (1/2/3)" % _battle_speed()
	mute_button.text = "Feedback tones: OFF" if audio_muted else "Feedback tones: ON"
	contrast_button.text = "High-contrast cues: ON" if high_contrast else "High-contrast cues: OFF"
	_refresh_response_preview()
	_refresh_layout_lens()
	_refresh_recovery_priorities()
	_refresh_recovery_action_cards()
	_refresh_result_explanation()
	keep_canvas.keep = keep
	keep_canvas.call("set_focus", focused_enemy_index)
	keep_canvas.queue_redraw()

class KeepCanvas extends Control:
	signal map_hovered(floor: String, cell: Vector2i)
	signal map_clicked(floor: String, cell: Vector2i)
	signal enemy_clicked(index: int)
	var keep: PackKeepState
	const CELL_X := 18.0
	const CELL_Y := 28.0
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
	var focused_enemy_index: int = -1

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
		feedback_ttl = 0.38 if not high_contrast_mode else 0.18
		queue_redraw()

	func set_accessibility(enabled: bool) -> void:
		high_contrast_mode = enabled
		queue_redraw()

	func _process(delta: float) -> void:
		if feedback_ttl > 0.0:
			feedback_ttl = maxf(0.0, feedback_ttl - delta)
			queue_redraw()

	func _enemy_origin(index: int) -> Vector2:
		var enemy: Dictionary = keep.enemies[index]
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		var entry_offset: Vector2 = Vector2(-16.0 + float(index % 2) * 32.0, float(index) * 5.0)
		var gate_start: Vector2 = MAP_ORIGIN + Vector2(MAP_SIZE.x * 0.5, MAP_SIZE.y - 10) + entry_offset
		var courtyard_target: Vector2 = MAP_ORIGIN + Vector2(MAP_SIZE.x * 0.5, MAP_SIZE.y * 0.55) + entry_offset * 0.35
		var origin: Vector2 = gate_start.lerp(courtyard_target, clampf(keep.wave_progress, 0.0, 1.0))
		if enemy_id == "climber":
			var wall_start: Vector2 = UPPER_ORIGIN + Vector2(MAP_SIZE.x + 30, MAP_SIZE.y * 0.35 + index * 18)
			var wall_target: Vector2 = UPPER_ORIGIN + Vector2(MAP_SIZE.x * 0.45, 18 + index * 18)
			origin = wall_start.lerp(wall_target, clampf(keep.wave_progress, 0.0, 1.0))
		elif enemy_id == "siege_beast":
			origin = gate_start.lerp(courtyard_target + Vector2(0, 18), clampf(keep.wave_progress, 0.0, 1.0))
		return origin

	func _enemy_hit(position: Vector2) -> int:
		if keep == null or not keep.wave_active:
			return -1
		var best_index: int = -1
		var best_distance: float = INF
		for index in range(keep.enemies.size()):
			var enemy: Dictionary = keep.enemies[index]
			if bool(enemy.get("defeated", false)):
				continue
			var enemy_id: String = String(enemy.get("enemy_id", ""))
			var radius: float = 12.0 if enemy_id == "siege_beast" else 8.0
			var distance: float = position.distance_to(_enemy_origin(index))
			if distance <= radius + 8.0 and (distance < best_distance or (is_equal_approx(distance, best_distance) and index < best_index)):
				best_index = index
				best_distance = distance
		return best_index

	func _map_hit(position: Vector2) -> Dictionary:
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
			var hit: Dictionary = _map_hit(event.position)
			if not String(hit.get("floor", "")).is_empty():
				emit_signal("map_clicked", String(hit.get("floor", "")), hit.get("cell", Vector2i.ZERO))

	func _room_rect(room_id: String, origin: Vector2) -> Rect2:
		var room: Dictionary = PackKeepState.ROOMS[room_id]
		return Rect2(origin + Vector2(room.origin.x * CELL_X, room.origin.y * CELL_Y), Vector2(room.size.x * CELL_X, room.size.y * CELL_Y))

	func _placement_box_rect(room_id: String, origin: Vector2) -> Rect2:
		var room: Dictionary = PackKeepState.ROOMS[room_id]
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
			if not PackKeepState.PIECES.has(piece_id):
				continue
			var piece: Dictionary = PackKeepState.PIECES[piece_id]
			var piece_origin: Vector2i = instance.get("origin", Vector2i.ZERO)
			var piece_rect := Rect2(origin + Vector2(piece_origin.x * CELL_X, piece_origin.y * CELL_Y), Vector2(piece.size.x * CELL_X, piece.size.y * CELL_Y))
			if box.intersects(piece_rect):
				return true
		return false

	func _draw_placement_boxes(floor_name: String, origin: Vector2, outline_only: bool = false) -> void:
		for room_id in PackKeepState.ROOMS.keys():
			var room: Dictionary = PackKeepState.ROOMS[room_id]
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
		draw_string(ThemeDB.fallback_font, courtyard.position + Vector2(8, courtyard.size.y - 8), "KEEP ROOMS / DEFENSE BOARD", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#a68f9e"))
		var gate: Rect2 = Rect2(origin + Vector2(CELL_X * 5.0, MAP_SIZE.y - CELL_Y + 4.0), Vector2(CELL_X * 2.0, CELL_Y - 8.0))
		draw_rect(gate, Color("#211b27"), true)
		draw_line(gate.position + Vector2(0, 5), gate.position + Vector2(gate.size.x, 5), Color("#e89270"), 3.0)
		draw_string(ThemeDB.fallback_font, origin + Vector2(MAP_SIZE.x * 0.5 - 22, MAP_SIZE.y - 8), "OPEN GATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#ffd19d"))
		draw_string(ThemeDB.fallback_font, courtyard.position + Vector2(12, courtyard.size.y * 0.5), "OPEN COURTYARD", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#8bd1b4"))

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
		for room_id in PackKeepState.ROOMS.keys():
			var room: Dictionary = PackKeepState.ROOMS[room_id]
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
		_draw_placement_boxes(floor_name, origin)
		for instance in keep.pieces.values():
			if String(instance.get("floor", "ground")) != floor_name:
				continue
			var piece_id: String = String(instance.get("piece_id", ""))
			var piece: Dictionary = PackKeepState.PIECES[piece_id]
			var piece_origin: Vector2i = instance.get("origin", Vector2i.ZERO)
			var piece_rect: Rect2 = Rect2(origin + Vector2(piece_origin.x * CELL_X, piece_origin.y * CELL_Y), Vector2(piece.size.x * CELL_X, piece.size.y * CELL_Y))
			var color: Color = Color("#7598aa") if piece_id == "pike_squad" else Color("#83a47d") if piece_id == "repair_station" else Color("#ba6f55") if piece_id == "fire_team" else Color("#cbb56f")
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
			if float(instance.get("condition", 0.0)) < 1.0 or not assignment.is_empty() or high_contrast_mode:
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

	func _draw_enemies() -> void:
		if keep == null or not keep.wave_active:
			return
		_draw_gate_entry_path()
		for index in range(keep.enemies.size()):
			var enemy: Dictionary = keep.enemies[index]
			if bool(enemy.get("defeated", false)):
				continue
			var enemy_id: String = String(enemy.get("enemy_id", ""))
			var enemy_def: Dictionary = PackKeepState.ENEMIES[enemy_id]
			var enemy_origin: Vector2 = _enemy_origin(index)
			var enemy_color: Color = Color("#d26155") if enemy_id == "raider" else Color("#d7a35b") if enemy_id == "sapper" else Color("#a77bd1") if enemy_id == "climber" else Color("#b36c45")
			var marker_radius: float = 12.0 if enemy_id == "siege_beast" else 8.0
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
			var target_id: String = String(enemy.get("target", ""))
			if not target_id.is_empty() and PackKeepState.ROOMS.has(target_id):
				var target_room: Dictionary = PackKeepState.ROOMS[target_id]
				var target_origin: Vector2 = UPPER_ORIGIN if String(target_room.get("floor", "ground")) == "upper" else MAP_ORIGIN
				var target_rect: Rect2 = _room_rect(target_id, target_origin)
				draw_line(enemy_origin, target_rect.get_center(), Color("#fff4df") if index == focused_enemy_index else Color(0.95, 0.38, 0.28, 0.7), 2.5 if index == focused_enemy_index else 1.5)
				draw_circle(target_rect.get_center(), 8.0, Color("#fff4df") if index == focused_enemy_index else Color("#ffb0a6"), false, 2.0)
				if index == focused_enemy_index:
					draw_string(ThemeDB.fallback_font, target_rect.position + Vector2(2, -4), "TARGET", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#fff4df"))
			var doctrine_initial: String = "R" if enemy_id == "raider" else "S" if enemy_id == "sapper" else "C" if enemy_id == "climber" else "B"
			draw_string(ThemeDB.fallback_font, enemy_origin + Vector2(-3, 4), doctrine_initial, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#271b22"))

	func _draw() -> void:
		if keep == null:
			return
		_draw_floor("GROUND FLOOR — Gate, Yard, Workshop, Supply", "ground", MAP_ORIGIN)
		_draw_floor("UPPER FLOOR — Outer Wall, North Tower, Chapel", "upper", UPPER_ORIGIN)
		if preview_active and PackKeepState.PIECES.has(preview_piece_id):
			var preview_size: Vector2i = PackKeepState.PIECES[preview_piece_id].size
			var preview_origin_pixel: Vector2 = MAP_ORIGIN if preview_floor == "ground" else UPPER_ORIGIN
			var rect: Rect2 = Rect2(preview_origin_pixel + Vector2(preview_origin.x * CELL_X, preview_origin.y * CELL_Y), Vector2(preview_size.x * CELL_X, preview_size.y * CELL_Y)).grow(-2)
			var preview_color: Color = Color(0.27, 0.82, 0.55, 0.42) if preview_valid else Color(0.86, 0.28, 0.32, 0.42)
			draw_rect(rect, preview_color, true)
			draw_rect(rect, Color("#bff0cc") if preview_valid else Color("#ffb0a6"), false, 2.0)
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(3, 12), "VALID" if preview_valid else "INVALID", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#fff4df"))
		_draw_enemies()
		if keep.wave_active:
			var progress_width: float = 2.0 * MAP_SIZE.x * keep.wave_progress
			draw_rect(Rect2(MAP_ORIGIN + Vector2(0, MAP_SIZE.y + 12), Vector2(2.0 * MAP_SIZE.x, 8)), Color("#402630"), true)
			draw_rect(Rect2(MAP_ORIGIN + Vector2(0, MAP_SIZE.y + 12), Vector2(progress_width, 8)), Color("#d26155"), true)
			draw_string(ThemeDB.fallback_font, MAP_ORIGIN + Vector2(0, MAP_SIZE.y + 34), "RED = active invasion | Lines = declared target | AREA = Siege Beast pressure | State text is authoritative", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#bfaeaa"))
		if feedback_ttl > 0.0:
			var feedback_alpha: float = minf(0.32, feedback_ttl * 0.9)
			draw_rect(Rect2(Vector2.ZERO, size), Color(feedback_color, feedback_alpha), false, 5.0)
			draw_string(ThemeDB.fallback_font, Vector2(14, size.y - 12), "IMPACT / RECOVERY CUE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(feedback_color, minf(0.95, feedback_alpha + 0.45)))
