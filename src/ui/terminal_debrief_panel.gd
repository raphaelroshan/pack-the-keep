class_name TerminalDebriefPanel
extends PanelContainer

signal primary_requested
signal save_requested
signal menu_requested

var eyebrow_label: Label
var outcome_label: Label
var identity_label: Label
var resource_label: Label
var timeline_box: VBoxContainer
var causal_label: Label
var fortress_label: Label
var consequence_label: Label
var replay_label: Label
var primary_button: Button
var save_button: Button
var menu_button: Button

func _init() -> void:
	name = "TerminalDebriefPanel"
	custom_minimum_size = Vector2(420, 0)
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_stylebox_override("panel", _panel_style(Color("#201b26"), Color("#b88b52"), 10))

	var frame: VBoxContainer = VBoxContainer.new()
	frame.add_theme_constant_override("separation", 8)
	add_child(frame)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "TerminalDebriefScroll"
	scroll.custom_minimum_size = Vector2(410, 430)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(scroll)

	var body: VBoxContainer = VBoxContainer.new()
	body.custom_minimum_size = Vector2(394, 0)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 9)
	scroll.add_child(body)

	eyebrow_label = _label("FINAL DEFENSE", 12, Color("#8fc6d1"))
	body.add_child(eyebrow_label)
	outcome_label = _label("DEFENSE COMPLETE", 28, Color("#f1d28e"))
	body.add_child(outcome_label)
	identity_label = _label("", 14, Color("#c9bfd0"))
	body.add_child(identity_label)

	resource_label = _label("", 14, Color("#f0dca8"))
	resource_label.add_theme_stylebox_override("normal", _panel_style(Color("#292331"), Color("#55495f"), 7))
	resource_label.add_theme_constant_override("outline_size", 0)
	body.add_child(resource_label)

	body.add_child(_section_heading("WHY THIS DEFENSE ENDED THIS WAY"))
	causal_label = _label("", 13, Color("#ded4c4"))
	body.add_child(causal_label)

	body.add_child(_section_heading("ASSAULT TIMELINE"))
	timeline_box = VBoxContainer.new()
	timeline_box.add_theme_constant_override("separation", 5)
	body.add_child(timeline_box)

	body.add_child(_section_heading("FORTRESS CONDITION"))
	fortress_label = _label("", 13, Color("#d8c389"))
	body.add_child(fortress_label)

	consequence_label = _label("", 12, Color("#aab1b2"))
	body.add_child(consequence_label)

	var replay_panel: PanelContainer = PanelContainer.new()
	replay_panel.add_theme_stylebox_override("panel", _panel_style(Color("#252d2d"), Color("#5d9b82"), 8))
	replay_label = _label("", 14, Color("#bfe8cf"))
	replay_panel.add_child(replay_label)
	body.add_child(replay_panel)

	primary_button = Button.new()
	primary_button.name = "TerminalPrimaryAction"
	primary_button.custom_minimum_size = Vector2(0, 44)
	primary_button.pressed.connect(func() -> void: primary_requested.emit())
	_style_button(primary_button, true)
	frame.add_child(primary_button)

	var secondary_actions: HBoxContainer = HBoxContainer.new()
	secondary_actions.add_theme_constant_override("separation", 7)
	frame.add_child(secondary_actions)
	save_button = Button.new()
	save_button.text = "Save Result"
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.tooltip_text = "Save this completed fortress state before leaving the debrief."
	save_button.pressed.connect(func() -> void: save_requested.emit())
	_style_button(save_button, false)
	secondary_actions.add_child(save_button)
	menu_button = Button.new()
	menu_button.text = "Return to Main Menu"
	menu_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_button.tooltip_text = "Return without changing the run. Save first if this result is not already stored."
	menu_button.pressed.connect(func() -> void: menu_requested.emit())
	_style_button(menu_button, false)
	secondary_actions.add_child(menu_button)

func render(view_model: Dictionary) -> void:
	var outcome: String = String(view_model.get("outcome", "unknown"))
	eyebrow_label.text = String(view_model.get("eyebrow", "FINAL DEFENSE"))
	outcome_label.text = String(view_model.get("outcome_title", "DEFENSE COMPLETE"))
	outcome_label.add_theme_color_override("font_color", _outcome_color(outcome))
	identity_label.text = "%s · %s" % [String(view_model.get("scenario_name", "Scenario")), String(view_model.get("commander_name", "Commander"))]
	resource_label.text = "  %s  ·  MORALE %d  ·  MATERIALS %d\n  DEFENDERS %d ACTIVE / %d DISABLED  ·  BREACH %d  " % [outcome.replace("_", " ").to_upper(), int(view_model.get("morale", 0)), int(view_model.get("materials", 0)), int(view_model.get("surviving_pieces", 0)), int(view_model.get("disabled_pieces", 0)), int(view_model.get("breach_level", 0))]
	_render_timeline(view_model.get("waves", []))
	causal_label.text = "%s\n\n%s\n\n%s" % [String(view_model.get("causal_summary", "DECISIVE PATTERN — Review the phase evidence below.")), String(view_model.get("mastery_summary", "SEED PRESSURE — Baseline pressure.")), _causal_text(view_model.get("what_worked", []), view_model.get("what_failed", []))]
	fortress_label.text = _fortress_text(view_model.get("damaged_rooms", []), view_model.get("damaged_pieces", []))
	consequence_label.text = String(view_model.get("consequence_text", "")).strip_edges()
	consequence_label.visible = not consequence_label.text.is_empty()
	replay_label.text = "TRY NEXT\n%s" % String(view_model.get("replay_experiment", "Replay one changed decision."))
	primary_button.text = String(view_model.get("primary_label", "REVIEW SETUP — PLAY AGAIN"))
	primary_button.tooltip_text = String(view_model.get("primary_tooltip", "Return to the War Council with this result in mind."))
	primary_button.disabled = not bool(view_model.get("primary_enabled", true))
	save_button.visible = bool(view_model.get("show_save", true))
	menu_button.visible = bool(view_model.get("show_menu", true))

func focus_primary() -> void:
	if visible and primary_button.visible and not primary_button.disabled:
		primary_button.grab_focus()

func _render_timeline(waves: Array) -> void:
	for child in timeline_box.get_children():
		child.queue_free()
	if waves.is_empty():
		timeline_box.add_child(_label("No resolved assault phases.", 12, Color("#aab1b2")))
		return
	for wave_value in waves:
		var wave: Dictionary = wave_value if wave_value is Dictionary else {}
		var row: PanelContainer = PanelContainer.new()
		row.add_theme_stylebox_override("panel", _panel_style(Color("#292331"), _outcome_color(String(wave.get("outcome", "unknown"))), 6))
		var text_label: Label = _label("PHASE %d  ·  %s  ·  %s\n%s\n%d defeated  ·  %d room  ·  %d defender  ·  %d recovery" % [int(wave.get("wave", 0)), String(wave.get("doctrine", "")).replace("_", " ").capitalize(), String(wave.get("outcome", "")).replace("_", " ").to_upper(), String(wave.get("principal_pressure", "Unknown pressure")), int(wave.get("defeated_enemies", 0)), int(wave.get("room_damage", 0)), int(wave.get("piece_damage", 0)), int(wave.get("recovery_actions_used", 0))], 12, Color("#ded4c4"))
		row.add_child(text_label)
		timeline_box.add_child(row)

func _causal_text(worked: Array, failed: Array) -> String:
	var lines: Array[String] = ["WHAT HELD"]
	for item in worked:
		lines.append("• %s" % String(item))
	lines.append("WHAT GAVE WAY")
	for item in failed:
		lines.append("• %s" % String(item))
	return "\n".join(lines)

func _fortress_text(rooms: Array, pieces: Array) -> String:
	var lines: Array[String] = []
	for room_value in rooms:
		var room: Dictionary = room_value if room_value is Dictionary else {}
		lines.append("ROOM · %s — %d%% %s" % [String(room.get("name", "Room")), int(room.get("condition", 0)), String(room.get("state", "damaged")).to_upper()])
	for piece_value in pieces:
		var piece: Dictionary = piece_value if piece_value is Dictionary else {}
		lines.append("DEFENDER · %s — %d/%d HP%s" % [String(piece.get("name", "Defender")), int(piece.get("health", 0)), int(piece.get("max_health", 0)), " · DISABLED" if bool(piece.get("disabled", false)) else ""])
	return "Fortress intact. No persistent room or defender damage." if lines.is_empty() else "\n".join(lines)

func _section_heading(text_value: String) -> Label:
	return _label(text_value, 13, Color("#e2bd84"))

func _label(text_value: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _panel_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _style_button(button: Button, primary: bool) -> void:
	var normal: StyleBoxFlat = _panel_style(Color("#9a623d") if primary else Color("#302838"), Color("#d6b277") if primary else Color("#5a4c64"), 7)
	button.add_theme_stylebox_override("normal", normal)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color("#ad744b") if primary else Color("#403448")
	button.add_theme_stylebox_override("hover", hover)
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color("#70472f") if primary else Color("#241f2a")
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color("#fff4df"))

func _outcome_color(outcome: String) -> Color:
	if outcome in ["held", "hold"]:
		return Color("#9fe0bd")
	if outcome == "partial_breach":
		return Color("#e7bd72")
	if outcome == "collapse":
		return Color("#e58a78")
	return Color("#f1d28e")
