class_name PreparationBriefPanel
extends PanelContainer

var question_label: Label
var answer_label: Label
var weakness_label: Label

func _init() -> void:
	name = "PreparationBriefPanel"
	custom_minimum_size = Vector2(800, 104)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#20252c")
	style.border_color = Color("#4d7280")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	add_theme_stylebox_override("panel", style)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	add_child(row)
	question_label = _column(row, "CURRENT QUESTION", Color("#8fc6d1"))
	answer_label = _column(row, "VISIBLE ANSWER", Color("#bfe8cf"))
	weakness_label = _column(row, "OPEN WEAKNESS", Color("#e7bd72"))

func render(view_model: Dictionary) -> void:
	question_label.text = "CURRENT QUESTION\n%s" % String(view_model.get("question", "Read the next pressure."))
	answer_label.text = "VISIBLE ANSWER\n%s" % String(view_model.get("answer", "No defense placed yet."))
	weakness_label.text = "OPEN WEAKNESS\n%s" % String(view_model.get("weakness", "The keep still needs a committed answer."))

func _column(row: HBoxContainer, heading: String, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = heading
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(245, 76)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", color)
	row.add_child(label)
	return label
