class_name InspectionPanel
extends PanelContainer

var kind_label: Label
var name_label: Label
var condition_label: Label
var purpose_label: Label
var next_action_label: Label
var detail_label: Label

func _init() -> void:
	name = "InspectionPanel"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#20262e")
	style.border_color = Color("#536d78")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 9
	style.content_margin_right = 9
	style.content_margin_top = 8
	style.content_margin_bottom = 9
	add_theme_stylebox_override("panel", style)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 4)
	add_child(body)
	kind_label = _label("FORTRESS INSPECTOR", Color("#8fc6d1"), 10)
	body.add_child(kind_label)
	name_label = _label("Select the keep", Color("#fff0c7"), 18)
	body.add_child(name_label)
	condition_label = _label("READY TO INSPECT", Color("#bfe8cf"), 11)
	body.add_child(condition_label)
	purpose_label = _label("WHY IT MATTERS\nRooms sustain the fort, defenders answer pressure, and enemies reveal what is at risk.", Color("#c9bfd0"), 11)
	body.add_child(purpose_label)
	next_action_label = _label("NEXT ACTION\nClick a room or defender on the board.", Color("#efc779"), 11)
	body.add_child(next_action_label)
	detail_label = _label("", Color("#aab1b2"), 10)
	body.add_child(detail_label)

func render(view_model: Dictionary) -> void:
	var kind: String = String(view_model.get("kind", "fortress"))
	kind_label.text = String(view_model.get("eyebrow", "FORTRESS INSPECTOR"))
	name_label.text = String(view_model.get("name", "Select the keep"))
	condition_label.text = String(view_model.get("condition", "READY TO INSPECT"))
	condition_label.add_theme_color_override("font_color", Color("#ef9d78") if bool(view_model.get("critical", false)) else Color("#bfe8cf"))
	purpose_label.text = "WHY IT MATTERS\n%s" % String(view_model.get("purpose", "Read the selected object's tactical role."))
	next_action_label.text = "NEXT ACTION\n%s" % String(view_model.get("next_action", "Select an object on the board."))
	detail_label.text = String(view_model.get("detail", ""))
	detail_label.visible = not detail_label.text.is_empty()
	tooltip_text = "%s inspection card" % kind

func _label(value: String, color: Color, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
