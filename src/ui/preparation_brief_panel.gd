class_name PreparationBriefPanel
extends PanelContainer

var question_label: Label
var answer_label: Label
var weakness_label: Label
var plan_label: Label
var summary_row: BoxContainer
var full_plan_text: String = ""
var compact_plan_text: String = ""
var board_first_mode: bool = false

func _init() -> void:
	name = "PreparationBriefPanel"
	custom_minimum_size = Vector2(800, 158)
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
	var stack: VBoxContainer = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	add_child(stack)
	summary_row = BoxContainer.new()
	summary_row.add_theme_constant_override("separation", 12)
	stack.add_child(summary_row)
	question_label = _column(summary_row, "CURRENT QUESTION", Color("#8fc6d1"))
	answer_label = _column(summary_row, "VISIBLE ANSWER", Color("#bfe8cf"))
	weakness_label = _column(summary_row, "OPEN WEAKNESS", Color("#e7bd72"))
	plan_label = Label.new()
	plan_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	plan_label.add_theme_font_size_override("font_size", 12)
	plan_label.add_theme_color_override("font_color", Color("#f1d6a3"))
	stack.add_child(plan_label)

func render(view_model: Dictionary) -> void:
	question_label.text = "CURRENT QUESTION\n%s" % String(view_model.get("question", "Read the next pressure."))
	answer_label.text = "VISIBLE ANSWER\n%s" % String(view_model.get("answer", "No defense placed yet."))
	weakness_label.text = "OPEN WEAKNESS\n%s" % String(view_model.get("weakness", "The keep still needs a committed answer."))
	full_plan_text = String(view_model.get("plan", "FIRST PLAN — Choose one readable opening."))
	compact_plan_text = String(view_model.get("compact_plan", full_plan_text))
	_render_plan()

func set_responsive_layout(compact: bool, available_width: float, board_first: bool = false) -> void:
	board_first_mode = board_first
	custom_minimum_size.x = minf(800.0, maxf(0.0, available_width))
	summary_row.vertical = compact
	var column_width: float = 0.0 if compact else minf(245.0, maxf(180.0, (available_width - 48.0) / 3.0))
	for label in [question_label, answer_label, weakness_label]:
		label.custom_minimum_size.x = column_width
		label.custom_minimum_size.y = 0.0 if compact else 76.0
	plan_label.custom_minimum_size.y = 0.0 if compact else 42.0 if board_first else 48.0
	_render_plan()

func _render_plan() -> void:
	if plan_label == null:
		return
	plan_label.text = compact_plan_text if board_first_mode and not compact_plan_text.is_empty() else full_plan_text

func _column(row: BoxContainer, heading: String, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = heading
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(245, 76)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", color)
	row.add_child(label)
	return label
