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

var keep: PackKeepState
var status_label: Label
var forecast_label: Label
var enemy_label: Label
var metrics_label: Label
var availability_label: Label
var event_label: Label
var log_label: Label
var commander_option: OptionButton
var pack_option: OptionButton
var piece_option: OptionButton
var floor_option: OptionButton
var doctrine_option: OptionButton
var room_option: OptionButton
var keep_canvas: Control
var gameplay_columns: Control
var title_card: PanelContainer
var screen_label: Label
var screen_hint: Label
var screen: String = "title"

func _ready() -> void:
	keep = PackKeepState.new(3307)
	_build_ui()
	_refresh_ui()

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

	var art_banner: TextureRect = TextureRect.new()
	art_banner.texture = GREYWATCH_BACKGROUND
	art_banner.custom_minimum_size = Vector2(0, 150)
	art_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art_banner.modulate = Color(1.0, 1.0, 1.0, 0.78)
	shell.add_child(art_banner)

	title_card = _build_title_card()
	shell.add_child(title_card)

	var columns: HBoxContainer = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 22)
	gameplay_columns = columns
	shell.add_child(columns)

	var left: VBoxContainer = VBoxContainer.new()
	left.custom_minimum_size = Vector2(820, 0)
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
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color("#f2e5d1"))
	left.add_child(status_label)

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

	keep_canvas = KeepCanvas.new()
	keep_canvas.custom_minimum_size = Vector2(810, 390)
	keep_canvas.keep = keep
	left.add_child(keep_canvas)

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
	right.custom_minimum_size = Vector2(320, 0)
	columns.add_child(right)
	var controls: VBoxContainer = VBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	right.add_child(controls)

	var panel_title: Label = Label.new()
	panel_title.text = "COMMAND TABLE"
	panel_title.add_theme_font_size_override("font_size", 19)
	panel_title.add_theme_color_override("font_color", Color("#e2bd84"))
	controls.add_child(panel_title)
	var commander_portrait: TextureRect = TextureRect.new()
	commander_portrait.texture = CASTELLAN_PORTRAIT
	commander_portrait.custom_minimum_size = Vector2(0, 92)
	commander_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	commander_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	commander_portrait.tooltip_text = "The Castellan — Layered Masonry and Lockdown"
	controls.add_child(commander_portrait)

	commander_option = OptionButton.new()
	for commander_id in PackKeepState.COMMANDERS.keys():
		commander_option.add_item(String(PackKeepState.COMMANDERS[commander_id].get("name", commander_id)))
		commander_option.set_item_metadata(commander_option.item_count - 1, commander_id)
	controls.add_child(_labeled_control("Commander", commander_option))
	var commander_button: Button = Button.new()
	commander_button.text = "Take command"
	commander_button.pressed.connect(_on_select_commander)
	controls.add_child(commander_button)

	pack_option = OptionButton.new()
	for pack_id in PackKeepState.PACKS.keys():
		pack_option.add_item(String(PackKeepState.PACKS[pack_id].get("name", pack_id)))
		pack_option.set_item_metadata(pack_option.item_count - 1, pack_id)
	controls.add_child(_labeled_control("Pack", pack_option))
	var pack_button: Button = Button.new()
	pack_button.text = "Open pack"
	pack_button.pressed.connect(_on_open_pack)
	controls.add_child(pack_button)
	availability_label = Label.new()
	availability_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	availability_label.add_theme_color_override("font_color", Color("#aab1b2"))
	controls.add_child(availability_label)
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
	for piece_id in PackKeepState.PIECES.keys():
		piece_option.add_item(String(PackKeepState.PIECES[piece_id].get("name", piece_id)))
		piece_option.set_item_metadata(piece_option.item_count - 1, piece_id)
		piece_option.set_item_disabled(piece_option.item_count - 1, not keep.available_pieces.has(String(piece_id)))
	controls.add_child(_labeled_control("Available piece", piece_option))

	floor_option = OptionButton.new()
	floor_option.add_item("Ground floor")
	floor_option.set_item_metadata(0, "ground")
	floor_option.add_item("Upper floor")
	floor_option.set_item_metadata(1, "upper")
	controls.add_child(_labeled_control("Floor", floor_option))
	room_option = OptionButton.new()
	for room_id in PackKeepState.ROOMS.keys():
		room_option.add_item(String(PackKeepState.ROOMS[room_id].get("name", room_id)))
		room_option.set_item_metadata(room_option.item_count - 1, room_id)
	controls.add_child(_labeled_control("Room", room_option))
	var place_button: Button = Button.new()
	place_button.text = "Place at next slot"
	place_button.pressed.connect(_on_place_piece)
	controls.add_child(place_button)

	doctrine_option = OptionButton.new()
	for doctrine_id in ["gate_assault", "distributed_sabotage", "feint_and_flank"]:
		doctrine_option.add_item(doctrine_id.replace("_", " ").capitalize())
		doctrine_option.set_item_metadata(doctrine_option.item_count - 1, doctrine_id)
	controls.add_child(_labeled_control("Invasion doctrine", doctrine_option))
	var assign_button: Button = Button.new()
	assign_button.text = "Assign selected piece to room"
	assign_button.tooltip_text = "Consumes one repair-interval action and activates the unit’s room behavior."
	assign_button.pressed.connect(_on_assign_piece)
	controls.add_child(assign_button)

	var clear_assignment_button: Button = Button.new()
	clear_assignment_button.text = "Clear selected assignment"
	clear_assignment_button.pressed.connect(_on_clear_assignment)
	controls.add_child(clear_assignment_button)

	var repair_room_button: Button = Button.new()
	repair_room_button.text = "Repair selected room"
	repair_room_button.tooltip_text = "Consumes one repair-interval action and 8 materials."
	repair_room_button.pressed.connect(_on_repair_room)
	controls.add_child(repair_room_button)

	var finish_interval_button: Button = Button.new()
	finish_interval_button.text = "Finish repair interval"
	finish_interval_button.tooltip_text = "Close recovery and unlock the next invasion."
	finish_interval_button.pressed.connect(_on_finish_interval)
	controls.add_child(finish_interval_button)

	var start_button: Button = Button.new()
	start_button.text = "Start invasion"
	start_button.pressed.connect(_on_start_wave)
	controls.add_child(start_button)

	var advance_button: Button = Button.new()
	advance_button.text = "Advance one battle step"
	advance_button.tooltip_text = "Resolve one readable step; pause here to inspect the report."
	advance_button.pressed.connect(_on_advance_wave)
	controls.add_child(advance_button)

	var ability_button: Button = Button.new()
	ability_button.text = "Lockdown (Castellan)"
	ability_button.tooltip_text = "Halve the next room hit and restore 5% piece condition; once per wave."
	ability_button.pressed.connect(_on_use_ability)
	controls.add_child(ability_button)

	var repair_gate_button: Button = Button.new()
	repair_gate_button.text = "Repair Gate"
	repair_gate_button.pressed.connect(func() -> void: _run_result(keep.repair_room("gate"), "Repair"))
	controls.add_child(repair_gate_button)

	var save_button: Button = Button.new()
	save_button.text = "Save keep state"
	save_button.pressed.connect(_on_save)
	controls.add_child(save_button)

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
	start_button.text = "Begin preparation"
	start_button.custom_minimum_size = Vector2(220, 34)
	start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_button.pressed.connect(func() -> void: _set_screen("preparation"))
	content.add_child(start_button)
	return card

func _set_screen(next_screen: String) -> void:
	screen = next_screen
	if gameplay_columns:
		gameplay_columns.visible = screen != "title"
	if title_card:
		title_card.visible = screen == "title"
	if screen_label:
		screen_label.text = "GREYWATCH / %s" % screen.capitalize()
	if screen_hint:
		if screen == "preparation":
			screen_hint.text = "Place and assign before opening the next doctrine."
		elif screen == "battle":
			screen_hint.text = "Advance one step; inspect enemies before spending Lockdown."
		elif screen == "results":
			screen_hint.text = "Read the report, repair what matters, then return to preparation."
		else:
			screen_hint.text = "A compact two-floor defense about pressure and recovery."
	_refresh_ui()

func _labeled_control(label_text: String, control: Control) -> VBoxContainer:
	var group: VBoxContainer = VBoxContainer.new()
	var label: Label = Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", Color("#c0b2c8"))
	group.add_child(label)
	group.add_child(control)
	return group

func _selected_id(option: OptionButton) -> String:
	if option.selected < 0:
		return ""
	return String(option.get_item_metadata(option.selected))

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

func _on_open_pack() -> void:
	_run_result(keep.open_pack(_selected_id(pack_option)), "Pack")

func _on_place_piece() -> void:
	var piece_id: String = _selected_id(piece_option)
	var floor: String = _selected_id(floor_option)
	_run_result(keep.place_piece(piece_id, _next_slot(piece_id, floor), floor), "Placement")

func _on_start_wave() -> void:
	var result: Dictionary = keep.start_wave(_selected_id(doctrine_option))
	_run_result(result, "Invasion")
	if bool(result.get("ok", false)):
		_set_screen("battle")

func _selected_piece_instance() -> String:
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

func _on_finish_interval() -> void:
	var result: Dictionary = keep.finish_repair_interval()
	_run_result(result, "Interval")
	if bool(result.get("ok", false)):
		_set_screen("preparation")

func _on_advance_wave() -> void:
	var result: Dictionary = keep.advance_wave(1.0)
	if not bool(result.get("ok", false)):
		_set_event("Battle blocked: %s." % String(result.get("reason", "unknown")))
	elif bool(result.get("resolved", false)):
			_set_event("Wave resolved: %s. Read the report before rebuilding." % String(result.get("outcome", "unknown")).replace("_", " "))
			_set_screen("results")
	else:
		_set_event("Battle step %d resolved. Pause and inspect the named target before committing Lockdown." % int(result.get("step", 0)))
	_refresh_ui()

func _on_use_ability() -> void:
	_run_result(keep.use_commander_ability(), "Ability")

func _run_result(result: Dictionary, label: String) -> void:
	if bool(result.get("ok", false)):
		_set_event("%s: %s" % [label, String(result.get("message", "command accepted"))])
	else:
		_set_event("%s blocked: %s." % [label, String(result.get("reason", "unknown"))])
	_refresh_ui()

func _on_save() -> void:
	var file: FileAccess = FileAccess.open("user://pack_the_keep_prototype.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(keep.serialize()))
	_set_event("Keep state saved. Production builds will add migrations and platform cloud adapters.")

func _set_event(text: String) -> void:
	event_label.text = text

func _refresh_ui() -> void:
	var interval_text: String = "closed"
	if keep.repair_interval_active:
		interval_text = "%d action(s): %s" % [keep.repair_actions_remaining, keep.repair_interval_reason]
	status_label.text = "Castellan | Materials %d | Command %d | Morale %d | Pieces %d | Wave %d | Step %d | Breach %d | Outcome %s | Repair %s" % [keep.materials, keep.command_points, keep.morale, keep.pieces.size(), keep.wave_index, keep.battle_step, keep.breach_level, keep.last_outcome if not keep.last_outcome.is_empty() else "active", interval_text]
	var forecast: Dictionary = keep.forecast()
	forecast_label.text = "FORECAST — %s | Likely target: %s | Uncertainty: %s | Scout: %s" % [String(forecast.get("doctrine", "")).replace("_", " "), String(forecast.get("likely_target", "")), String(forecast.get("uncertainty", "")), "revealed" if bool(forecast.get("scout_bonus", false)) else "not revealed"]
	var enemy_lines: Array[String] = []
	for enemy in keep.enemies:
		var enemy_id: String = String(enemy.get("enemy_id", ""))
		var enemy_state: String = "defeated" if bool(enemy.get("defeated", false)) else "%d/%d hp" % [int(enemy.get("hp", 0)), int(enemy.get("max_health", PackKeepState.ENEMIES[enemy_id].get("health", 0)))]
		var target: String = String(enemy.get("target", ""))
		if target.is_empty():
			target = "approach"
		enemy_lines.append("%s [%s] — %s — route %s — target %s" % [String(PackKeepState.ENEMIES[enemy_id].get("name", enemy_id)), enemy_id, enemy_state, String(PackKeepState.ENEMIES[enemy_id].get("route", "")), target])
	enemy_label.text = "ENEMIES — " + (" | ".join(enemy_lines) if not enemy_lines.is_empty() else "No active enemies. Start an invasion to see doctrine-driven actors.")
	var metrics: Dictionary = keep.combat_metrics
	metrics_label.text = "METRICS — steps %d | unit attacks %d | damage dealt %d | enemy attacks %d | room damage %d | piece damage %d | repairs %d | disabled %d | defeated %d" % [int(metrics.get("battle_steps", 0)), int(metrics.get("unit_attacks", 0)), int(metrics.get("damage_dealt", 0)), int(metrics.get("enemy_attacks", 0)), int(metrics.get("room_damage", 0)), int(metrics.get("piece_damage", 0)), int(metrics.get("repairs", 0)), int(metrics.get("disabled_units", 0)), int(metrics.get("defeated_enemies", 0))]
	var available_names: Array[String] = []
	for available_id in keep.available_pieces:
		available_names.append(String(PackKeepState.PIECES[available_id].get("name", available_id)))
	availability_label.text = "AVAILABLE — %s\nPack openings this Preparation: %d/%d" % [", ".join(available_names), keep.pack_openings_this_preparation, 2 if keep.wave_index == 0 else 1]
	for piece_index in range(piece_option.item_count):
		var piece_id: String = String(piece_option.get_item_metadata(piece_index))
		piece_option.set_item_disabled(piece_index, not keep.available_pieces.has(piece_id))
	if event_label.text.is_empty():
		event_label.text = "Open Pike Line or Field Engineers, place a defense on either floor, start First Bell, and advance one step at a time."
	var recent: Array[String] = []
	var start: int = maxi(0, keep.battle_report.size() - 3)
	for index in range(start, keep.battle_report.size()):
		recent.append(keep.battle_report[index])
	log_label.text = "Recent causal report: " + (" | ".join(recent) if not recent.is_empty() else "No wave has started. The report will name the forecast, counter, target, damage, and recovery.")
	keep_canvas.keep = keep
	keep_canvas.queue_redraw()

class KeepCanvas extends Control:
	var keep: PackKeepState
	const CELL := 22.0
	const MAP_ORIGIN := Vector2(12, 42)
	const MAP_SIZE := Vector2(12 * CELL, 8 * CELL)

	func _room_rect(room_id: String, origin: Vector2) -> Rect2:
		var room: Dictionary = PackKeepState.ROOMS[room_id]
		return Rect2(origin + Vector2(room.origin.x * CELL, room.origin.y * CELL), Vector2(room.size.x * CELL, room.size.y * CELL))

	func _room_color(room_id: String) -> Color:
		if keep == null:
			return Color("#3b3344")
		var state: String = keep.room_state(room_id)
		if state == "breached":
			return Color("#733b45")
		if state == "damaged":
			return Color("#8a684d")
		if state == "strained":
			return Color("#6f6544")
		return Color("#3d4b55")

	func _draw_floor(label_text: String, floor: String, origin: Vector2) -> void:
		draw_string(ThemeDB.fallback_font, origin + Vector2(0, -10), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#e2bd84"))
		draw_rect(Rect2(origin, MAP_SIZE), Color("#27212e"), true)
		draw_rect(Rect2(origin, MAP_SIZE), Color("#ae896d"), false, 3.0)
		for x in range(PackKeepState.GRID_SIZE.x + 1):
			draw_line(origin + Vector2(x * CELL, 0), origin + Vector2(x * CELL, MAP_SIZE.y), Color(0.4, 0.32, 0.42, 0.35), 1.0)
		for y in range(PackKeepState.GRID_SIZE.y + 1):
			draw_line(origin + Vector2(0, y * CELL), origin + Vector2(MAP_SIZE.x, y * CELL), Color(0.4, 0.32, 0.42, 0.35), 1.0)
		for room_id in PackKeepState.ROOMS.keys():
			var room: Dictionary = PackKeepState.ROOMS[room_id]
			if String(room.floor) != floor:
				continue
			var rect: Rect2 = _room_rect(String(room_id), origin)
			draw_rect(rect, _room_color(String(room_id)), true)
			draw_rect(rect, Color("#c8b6a0"), false, 1.0)
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(2, 12), String(room.name), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 4, 9, Color("#eadfce"))
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(2, rect.size.y - 3), "%d%%" % keep.room_condition(String(room_id)), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#f2e5d1"))
		for instance in keep.pieces.values():
			if String(instance.get("floor", "ground")) != floor:
				continue
			var piece_id: String = String(instance.get("piece_id", ""))
			var piece: Dictionary = PackKeepState.PIECES[piece_id]
			var piece_origin: Vector2i = instance.get("origin", Vector2i.ZERO)
			var piece_rect: Rect2 = Rect2(origin + Vector2(piece_origin.x * CELL, piece_origin.y * CELL), Vector2(piece.size.x * CELL, piece.size.y * CELL))
			var color: Color = Color("#7598aa") if piece_id == "pike_squad" else Color("#83a47d") if piece_id == "repair_station" else Color("#ba6f55") if piece_id == "fire_team" else Color("#cbb56f")
			draw_rect(piece_rect.grow(-2), color, true)
			draw_rect(piece_rect.grow(-2), Color("#f1dfb8"), false, 1.5)
			draw_string(ThemeDB.fallback_font, piece_rect.position + Vector2(2, 11), String(piece.name), HORIZONTAL_ALIGNMENT_LEFT, piece_rect.size.x - 4, 8, Color("#201a25"))
			var piece_status: String = "%d/%d hp" % [int(instance.get("health", 0)), int(instance.get("max_health", piece.get("max_health", 0)))]
			if bool(instance.get("disabled", false)):
				piece_status += " DISABLED"
			var assignment: String = String(instance.get("assignment", ""))
			if not assignment.is_empty():
				piece_status += " " + assignment
			if float(instance.get("condition", 0.0)) < 1.0 or not assignment.is_empty():
				draw_string(ThemeDB.fallback_font, piece_rect.position + Vector2(2, piece_rect.size.y - 3), piece_status, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#201a25"))

	func _draw_enemies() -> void:
		if keep == null or not keep.wave_active:
			return
		for index in range(keep.enemies.size()):
			var enemy: Dictionary = keep.enemies[index]
			if bool(enemy.get("defeated", false)):
				continue
			var enemy_id: String = String(enemy.get("enemy_id", ""))
			var enemy_def: Dictionary = PackKeepState.ENEMIES[enemy_id]
			var enemy_origin: Vector2 = MAP_ORIGIN + Vector2(20 + keep.wave_progress * 220.0, MAP_SIZE.y + 54 + index * 18)
			if enemy_id == "climber":
				enemy_origin = MAP_ORIGIN + Vector2(424 + 20 + keep.wave_progress * 220.0, -10 + index * 18)
			elif enemy_id == "sapper":
				enemy_origin = MAP_ORIGIN + Vector2(20 + keep.wave_progress * 220.0, MAP_SIZE.y + 54 + index * 18)
			var enemy_color: Color = Color("#d26155") if enemy_id == "raider" else Color("#d7a35b") if enemy_id == "sapper" else Color("#a77bd1")
			draw_circle(enemy_origin, 8.0, enemy_color)
			draw_circle(enemy_origin, 8.0, Color("#f1dfb8"), false, 1.5)
			draw_string(ThemeDB.fallback_font, enemy_origin + Vector2(12, 4), "%s %dhp" % [String(enemy_def.get("name", enemy_id)), int(enemy.get("hp", 0))], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#f2e5d1"))

	func _draw() -> void:
		if keep == null:
			return
		_draw_floor("GROUND FLOOR — Gate, Yard, Workshop, Supply", "ground", MAP_ORIGIN)
		_draw_floor("UPPER FLOOR — Outer Wall, North Tower, Chapel", "upper", MAP_ORIGIN + Vector2(424, 0))
		_draw_enemies()
		if keep.wave_active:
			var progress_width: float = 2.0 * MAP_SIZE.x * keep.wave_progress
			draw_rect(Rect2(MAP_ORIGIN + Vector2(0, MAP_SIZE.y + 12), Vector2(2.0 * MAP_SIZE.x, 8)), Color("#402630"), true)
			draw_rect(Rect2(MAP_ORIGIN + Vector2(0, MAP_SIZE.y + 12), Vector2(progress_width, 8)), Color("#d26155"), true)
			draw_string(ThemeDB.fallback_font, MAP_ORIGIN + Vector2(0, MAP_SIZE.y + 34), "RED = active invasion progress | Room colors: stable / strained / damaged / breached", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#bfaeaa"))
