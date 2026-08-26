extends Control

const PackKeepState = preload("res://src/core/keep_state.gd")

var keep: PackKeepState
var status_label: Label
var event_label: Label
var commander_option: OptionButton
var pack_option: OptionButton
var piece_option: OptionButton
var doctrine_option: OptionButton
var keep_canvas: Control

func _ready() -> void:
	keep = PackKeepState.new(3307)
	_build_ui()
	_refresh_ui()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#17121c")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	keep_canvas = KeepCanvas.new()
	keep_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	keep_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(keep_canvas)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	margin.add_child(columns)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(720, 0)
	left.add_theme_constant_override("separation", 10)
	columns.add_child(left)

	var title := Label.new()
	title.text = "PACK THE KEEP"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#e2bd84"))
	left.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Choose a doctrine. Arrange the fort. Survive the wave."
	subtitle.add_theme_color_override("font_color", Color("#bda9c8"))
	left.add_child(subtitle)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 17)
	status_label.add_theme_color_override("font_color", Color("#f2e5d1"))
	left.add_child(status_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 380)
	left.add_child(spacer)

	event_label = Label.new()
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_label.custom_minimum_size = Vector2(690, 90)
	event_label.add_theme_color_override("font_color", Color("#e2bd84"))
	left.add_child(event_label)

	var right := PanelContainer.new()
	right.custom_minimum_size = Vector2(360, 0)
	columns.add_child(right)
	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 9)
	right.add_child(controls)

	var panel_title := Label.new()
	panel_title.text = "COMMAND TABLE"
	panel_title.add_theme_font_size_override("font_size", 20)
	panel_title.add_theme_color_override("font_color", Color("#e2bd84"))
	controls.add_child(panel_title)

	commander_option = OptionButton.new()
	for id in PackKeepState.COMMANDERS.keys():
		commander_option.add_item(PackKeepState.COMMANDERS[id].name)
		commander_option.set_item_metadata(commander_option.item_count - 1, id)
	controls.add_child(_labeled_control("Commander", commander_option))
	var commander_button := Button.new()
	commander_button.text = "Take command"
	commander_button.pressed.connect(_on_select_commander)
	controls.add_child(commander_button)

	pack_option = OptionButton.new()
	for id in PackKeepState.PACKS.keys():
		pack_option.add_item(PackKeepState.PACKS[id].name)
		pack_option.set_item_metadata(pack_option.item_count - 1, id)
	controls.add_child(_labeled_control("Pack", pack_option))
	var pack_button := Button.new()
	pack_button.text = "Open pack"
	pack_button.pressed.connect(_on_open_pack)
	controls.add_child(pack_button)

	piece_option = OptionButton.new()
	for id in PackKeepState.PIECES.keys():
		piece_option.add_item(PackKeepState.PIECES[id].name)
		piece_option.set_item_metadata(piece_option.item_count - 1, id)
	controls.add_child(_labeled_control("Piece", piece_option))
	var place_button := Button.new()
	place_button.text = "Place at next slot"
	place_button.pressed.connect(_on_place_piece)
	controls.add_child(place_button)

	doctrine_option = OptionButton.new()
	for id in ["gate_assault", "distributed_sabotage", "feint_and_flank"]:
		doctrine_option.add_item(id.replace("_", " ").capitalize())
		doctrine_option.set_item_metadata(doctrine_option.item_count - 1, id)
	controls.add_child(_labeled_control("Invasion", doctrine_option))
	var start_button := Button.new()
	start_button.text = "Start invasion"
	start_button.pressed.connect(_on_start_wave)
	controls.add_child(start_button)

	var advance_button := Button.new()
	advance_button.text = "Advance wave clock"
	advance_button.pressed.connect(_on_advance_wave)
	controls.add_child(advance_button)

	var ability_button := Button.new()
	ability_button.text = "Use commander ability"
	ability_button.pressed.connect(_on_use_ability)
	controls.add_child(ability_button)

	var save_button := Button.new()
	save_button.text = "Save keep state"
	save_button.pressed.connect(_on_save)
	controls.add_child(save_button)

func _labeled_control(label_text: String, control: Control) -> VBoxContainer:
	var group := VBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", Color("#bda9c8"))
	group.add_child(label)
	group.add_child(control)
	return group

func _selected_id(option: OptionButton) -> String:
	return String(option.get_item_metadata(option.selected))

func _next_slot() -> Vector2i:
	var index := keep.pieces.size()
	return Vector2i(2 + (index % 4) * 2, 2 + (index / 4) * 2)

func _on_select_commander() -> void:
	var result := keep.select_commander(_selected_id(commander_option))
	_set_event(result.message if result.ok else "Commander blocked: %s." % result.reason)
	_refresh_ui()

func _on_open_pack() -> void:
	var id := _selected_id(pack_option)
	var result := keep.open_pack(id)
	_set_event(result.message if result.ok else "Pack blocked: %s." % result.reason)
	_refresh_ui()

func _on_place_piece() -> void:
	var id := _selected_id(piece_option)
	var result := keep.place_piece(id, _next_slot())
	_set_event(result.message if result.ok else "Placement blocked: %s." % result.reason)
	_refresh_ui()

func _on_start_wave() -> void:
	var result := keep.start_wave(_selected_id(doctrine_option))
	_set_event(result.message if result.ok else "Invasion blocked: %s." % result.reason)
	_refresh_ui()

func _on_advance_wave() -> void:
	var result := keep.advance_wave(1.0)
	if not result.ok:
		_set_event("No active invasion. Start a wave after placing a defense.")
	elif result.resolved:
		_set_event("Wave resolved: %s. Review the breach state and adapt the doctrine." % result.outcome.replace("_", " "))
	else:
		_set_event("Invasion progress: %.0f%%. Pause, inspect, and intervene before the keep breaks." % [result.progress * 100.0])
	_refresh_ui()

func _on_use_ability() -> void:
	var result := keep.use_commander_ability()
	_set_event(result.message if result.ok else "Ability blocked: %s." % result.reason)
	_refresh_ui()

func _on_save() -> void:
	var file := FileAccess.open("user://pack_the_keep_prototype.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(keep.serialize()))
	_set_event("Keep state saved. Production builds will add migrations and platform cloud adapters.")

func _set_event(text: String) -> void:
	event_label.text = text

func _refresh_ui() -> void:
	status_label.text = "Commander %s   |   Materials %d   |   Command %d   |   Morale %d   |   Pieces %d   |   Wave %d   |   Breach %d" % [keep.commander_id.capitalize(), keep.materials, keep.command_points, keep.morale, keep.pieces.size(), keep.wave_index, keep.breach_level]
	if event_label.text.is_empty():
		event_label.text = "Choose a commander, open a pack, place a defensive piece, and start a gate assault."
	if keep_canvas:
		keep_canvas.keep = keep
		keep_canvas.queue_redraw()

class KeepCanvas extends Control:
	var keep: PackKeepState

	func _draw() -> void:
		if keep == null:
			return
		var origin := Vector2(120, 120)
		var cell := 42.0
		var fort_rect := Rect2(origin, Vector2(PackKeepState.GRID_SIZE.x * cell, PackKeepState.GRID_SIZE.y * cell))
		draw_rect(fort_rect, Color("#352b43"), true)
		draw_rect(fort_rect, Color("#a78362"), false, 8.0)
		for x in range(PackKeepState.GRID_SIZE.x + 1):
			draw_line(origin + Vector2(x * cell, 0), origin + Vector2(x * cell, PackKeepState.GRID_SIZE.y * cell), Color(0.3, 0.24, 0.34, 0.35), 1.0)
		for y in range(PackKeepState.GRID_SIZE.y + 1):
			draw_line(origin + Vector2(0, y * cell), origin + Vector2(PackKeepState.GRID_SIZE.x * cell, y * cell), Color(0.3, 0.24, 0.34, 0.35), 1.0)
		for instance in keep.pieces.values():
			var piece_id: String = instance.piece_id
			var p: Vector2 = origin + Vector2(instance.origin.x * cell, instance.origin.y * cell)
			var size: Vector2i = PackKeepState.PIECES[piece_id].size
			var rect := Rect2(p + Vector2(3, 3), Vector2(size.x * cell - 6, size.y * cell - 6))
			var color := Color("#c47b54")
			if piece_id.contains("pike"):
				color = Color("#7696a8")
			elif piece_id.contains("repair") or piece_id.contains("brace"):
				color = Color("#8fac78")
			elif piece_id.contains("scout") or piece_id.contains("signal"):
				color = Color("#c9b36f")
			draw_rect(rect, color, true)
			draw_rect(rect, Color("#f1dfb8"), false, 2.0)
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(6, 22), piece_id.replace("_", " ").capitalize(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#201a25"))
		if keep.wave_active:
			var bar := Rect2(origin + Vector2(0, -36), Vector2(fort_rect.size.x * keep.wave_progress, 10))
			draw_rect(Rect2(origin + Vector2(0, -36), Vector2(fort_rect.size.x, 10)), Color("#402630"), true)
			draw_rect(bar, Color("#d26155"), true)
