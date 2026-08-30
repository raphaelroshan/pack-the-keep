class_name RecoveryBriefPanel
extends PanelContainer

var heading_label: Label
var changed_label: Label
var matters_label: Label
var next_label: Label
var priority_label: Label

func _init() -> void:
	name = "RecoveryBriefPanel"
	custom_minimum_size = Vector2(800, 126)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#27242b")
	style.border_color = Color("#8a7258")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	add_theme_stylebox_override("panel", style)

	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 7)
	add_child(body)
	heading_label = Label.new()
	heading_label.add_theme_font_size_override("font_size", 14)
	heading_label.add_theme_color_override("font_color", Color("#f0c982"))
	body.add_child(heading_label)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	body.add_child(row)
	changed_label = _column(row, Color("#d7b58b"))
	matters_label = _column(row, Color("#e9d9bc"))
	next_label = _column(row, Color("#9fd3d1"))
	priority_label = Label.new()
	priority_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	priority_label.add_theme_font_size_override("font_size", 11)
	priority_label.add_theme_color_override("font_color", Color("#bfe8cf"))
	body.add_child(priority_label)

func _column(row: HBoxContainer, color: Color) -> Label:
	var label: Label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(245, 56)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", color)
	row.add_child(label)
	return label

func render(view_model: Dictionary) -> void:
	heading_label.text = "RECOVERY LULL · %d ACTION%s LEFT · %d MATERIALS" % [int(view_model.get("actions_remaining", 0)), "" if int(view_model.get("actions_remaining", 0)) == 1 else "S", int(view_model.get("materials", 0))]
	changed_label.text = "WHAT CHANGED\n%s" % String(view_model.get("changed", "The assault ended."))
	matters_label.text = "WHY IT MATTERS\n%s" % String(view_model.get("matters", "Choose what must remain functional."))
	next_label.text = "NEXT PRESSURE\n%s" % String(view_model.get("next", "Read the next doctrine before committing."))
	priority_label.text = "FIRST PRIORITY — %s\nSACRIFICE — %s\nTRADE-OFF — %s" % [String(view_model.get("priority", "Preserve the most important function.")), String(view_model.get("sacrifice", "Every action leaves another need unanswered.")), String(view_model.get("tradeoff", "Every action leaves another need unanswered."))]
