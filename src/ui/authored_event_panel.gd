extends VBoxContainer
class_name AuthoredEventPanel

signal choice_requested(choice_id: String)

var title_label: Label
var setup_label: Label
var choice_buttons: Array[Button] = []
var choice_details: Array[Label] = []

func build(choice_capacity: int = 2) -> void:
	add_theme_constant_override("separation", 4)
	title_label = Label.new()
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color("#e2bd84"))
	add_child(title_label)
	setup_label = Label.new()
	setup_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	setup_label.add_theme_color_override("font_color", Color("#c9bfd0"))
	add_child(setup_label)
	for choice_index in range(choice_capacity):
		var detail: Label = Label.new()
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail.add_theme_color_override("font_color", Color("#aab1b2"))
		add_child(detail)
		choice_details.append(detail)
		var button: Button = Button.new()
		button.pressed.connect(_emit_choice.bind(choice_index))
		add_child(button)
		choice_buttons.append(button)

func render(event: Dictionary) -> void:
	visible = bool(event.get("ok", false))
	if not visible:
		return
	title_label.text = "AUTHORED EVENT — %s | %s" % [String(event.get("title", "")), String(event.get("phase", "")).to_upper()]
	setup_label.text = String(event.get("setup", ""))
	var choices: Array = event.get("choices", [])
	for index in range(choice_buttons.size()):
		var button: Button = choice_buttons[index]
		var detail: Label = choice_details[index]
		var has_choice: bool = index < choices.size()
		button.visible = has_choice
		detail.visible = has_choice
		if not has_choice:
			button.set_meta("choice_id", "")
			continue
		var choice: Dictionary = choices[index]
		button.text = String(choice.get("label", "Choose"))
		button.disabled = not bool(choice.get("available", false))
		button.set_meta("choice_id", String(choice.get("id", "")))
		var reason: String = String(choice.get("reason", ""))
		detail.text = "%s%s" % [String(choice.get("visible_result", "")), "\nBLOCKED — %s" % reason.replace("_", " ") if not reason.is_empty() else ""]

func _emit_choice(index: int) -> void:
	if index < 0 or index >= choice_buttons.size():
		return
	var choice_id: String = String(choice_buttons[index].get_meta("choice_id", ""))
	if not choice_id.is_empty():
		choice_requested.emit(choice_id)
