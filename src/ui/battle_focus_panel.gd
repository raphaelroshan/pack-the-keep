class_name BattleFocusPanel
extends PanelContainer

var eyebrow_label: Label
var name_label: Label
var condition_label: Label
var target_label: Label
var timing_label: Label
var response_label: Label
var counter_label: Label
var action_label: Label

func _init() -> void:
	name = "BattleFocusPanel"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#1c242c")
	style.border_color = Color("#4d7280")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 9
	style.content_margin_right = 9
	style.content_margin_top = 7
	style.content_margin_bottom = 8
	add_theme_stylebox_override("panel", style)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 3)
	add_child(body)
	eyebrow_label = _label("FOCUSED THREAT", Color("#8fc6d1"), 10)
	body.add_child(eyebrow_label)
	name_label = _label("No threat focused", Color("#fff0c7"), 17)
	body.add_child(name_label)
	condition_label = _label("Select a threat on the keep or contact line.", Color("#efb28f"), 11)
	body.add_child(condition_label)
	target_label = _label("TARGET — unknown · ROUTE — unknown", Color("#c9bfd0"), 11)
	body.add_child(target_label)
	timing_label = _label("STRIKE — unknown", Color("#efc779"), 11)
	body.add_child(timing_label)
	response_label = _label("DEFENSE — no committed response", Color("#bfe8cf"), 11)
	body.add_child(response_label)
	counter_label = _label("COUNTER — read the forecast", Color("#9fd6e2"), 11)
	body.add_child(counter_label)
	action_label = _label("Pause before committing command.", Color("#d8c389"), 11)
	body.add_child(action_label)

func render(view_model: Dictionary) -> void:
	var active: bool = bool(view_model.get("active", false))
	eyebrow_label.text = String(view_model.get("eyebrow", "FOCUSED THREAT"))
	name_label.text = String(view_model.get("name", "No threat focused"))
	condition_label.text = String(view_model.get("condition", "Select a threat on the keep or contact line."))
	target_label.text = String(view_model.get("target_route", "TARGET — unknown · ROUTE — unknown"))
	timing_label.text = String(view_model.get("timing", "STRIKE — unknown"))
	response_label.text = String(view_model.get("response", "DEFENSE — no committed response"))
	counter_label.text = String(view_model.get("counter", "COUNTER — read the forecast"))
	action_label.text = String(view_model.get("action", "Pause before committing command."))
	condition_label.add_theme_color_override("font_color", Color("#efb28f") if active else Color("#aab1b2"))
	tooltip_text = "Focused threat target, timing, committed response, and counter"

func _label(value: String, color: Color, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
