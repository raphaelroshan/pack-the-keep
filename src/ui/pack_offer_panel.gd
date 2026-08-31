class_name PackOfferPanel
extends PanelContainer

signal previous_requested
signal next_requested
signal open_requested
signal reserve_requested

var status_label: Label
var name_label: Label
var role_label: Label
var detail_label: Label
var previous_button: Button
var next_button: Button
var open_button: Button
var reserve_button: Button

func _init() -> void:
	name = "PackOfferPanel"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#222934")
	style.border_color = Color("#526c78")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 9
	style.content_margin_right = 9
	style.content_margin_top = 8
	style.content_margin_bottom = 9
	add_theme_stylebox_override("panel", style)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 5)
	add_child(body)
	status_label = _label("PACK OFFER", Color("#8fc6d1"), 10)
	body.add_child(status_label)
	name_label = _label("", Color("#fff0c7"), 19)
	body.add_child(name_label)
	var navigation: HBoxContainer = HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 6)
	body.add_child(navigation)
	previous_button = _button("← PREVIOUS")
	next_button = _button("NEXT →")
	navigation.add_child(previous_button)
	navigation.add_child(next_button)
	role_label = _label("", Color("#c9bfd0"), 11)
	body.add_child(role_label)
	detail_label = _label("", Color("#d8c389"), 11)
	body.add_child(detail_label)
	open_button = _button("Open pack")
	body.add_child(open_button)
	reserve_button = _button("Reserve selected pack")
	body.add_child(reserve_button)
	previous_button.pressed.connect(func() -> void: previous_requested.emit())
	next_button.pressed.connect(func() -> void: next_requested.emit())
	open_button.pressed.connect(func() -> void: open_requested.emit())
	reserve_button.pressed.connect(func() -> void: reserve_requested.emit())

func render(view_model: Dictionary) -> void:
	status_label.text = "PACK %d / %d  •  %d OPENING(S)  •  %d MATERIALS  •  %s" % [int(view_model.get("index", 0)), int(view_model.get("count", 0)), int(view_model.get("openings", 0)), int(view_model.get("materials", 0)), String(view_model.get("state", "AVAILABLE"))]
	name_label.text = String(view_model.get("name", "Pack"))
	role_label.text = "%s\nQUESTION — %s" % [String(view_model.get("role", "Choose a defensive doctrine.")), String(view_model.get("question", "What does this pack ask of the keep?"))]
	detail_label.text = "PACK PREVIEW — %s\nDOCTRINE — %s  •  OPEN COST — %s\nADDS — %s\nSOLVES — %s\nLIMITATION — %s\nSPACE — %s\nTRADE-OFF — %s" % [String(view_model.get("name", "Pack")), String(view_model.get("doctrine", "")), String(view_model.get("cost_text", view_model.get("cost", 0))), String(view_model.get("pieces", "")), String(view_model.get("strength", "")), String(view_model.get("weakness", "")), String(view_model.get("space", "")), String(view_model.get("choice", ""))]
	previous_button.disabled = bool(view_model.get("selection_locked", false))
	next_button.disabled = previous_button.disabled
	open_button.disabled = not bool(view_model.get("can_open", false))
	reserve_button.disabled = not bool(view_model.get("can_reserve", false))
	open_button.text = "Pack already opened" if bool(view_model.get("owned", false)) else "Open pack — %d materials" % int(view_model.get("cost", 0))
	reserve_button.text = "Clear reserved pack" if bool(view_model.get("reserved", false)) else "Reserve selected pack"
	open_button.tooltip_text = String(view_model.get("open_reason", "Open this pack through the authoritative preparation command."))
	reserve_button.tooltip_text = String(view_model.get("reserve_reason", "Hold this offer for the next Preparation without granting its pieces."))

func _label(value: String, color: Color, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(text_value: String) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button
