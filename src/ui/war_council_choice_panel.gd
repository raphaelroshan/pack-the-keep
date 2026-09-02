class_name WarCouncilChoicePanel
extends PanelContainer

signal commander_previous_requested
signal commander_next_requested
signal scenario_previous_requested
signal scenario_next_requested
signal confirm_requested

var summary_label: Label
var choice_row: BoxContainer
var commander_index_label: Label
var commander_name_label: Label
var commander_identity_label: Label
var commander_strength_label: Label
var commander_ability_label: Label
var commander_limitation_label: Label
var commander_question_label: Label
var commander_previous_button: Button
var commander_next_button: Button
var scenario_index_label: Label
var scenario_name_label: Label
var scenario_identity_label: Label
var scenario_objective_label: Label
var scenario_arc_label: Label
var scenario_risk_label: Label
var scenario_fixed_label: Label
var scenario_previous_button: Button
var scenario_next_button: Button
var lock_label: Label
var confirm_button: Button
var commander_card: PanelContainer
var scenario_card: PanelContainer

func _init() -> void:
	name = "WarCouncilChoicePanel"
	custom_minimum_size = Vector2(800, 0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var shell_style: StyleBoxFlat = StyleBoxFlat.new()
	shell_style.bg_color = Color("#171c23")
	shell_style.border_color = Color("#5d7180")
	shell_style.set_border_width_all(1)
	shell_style.set_corner_radius_all(10)
	shell_style.content_margin_left = 12
	shell_style.content_margin_right = 12
	shell_style.content_margin_top = 10
	shell_style.content_margin_bottom = 12
	add_theme_stylebox_override("panel", shell_style)

	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	add_child(body)

	var heading: Label = Label.new()
	heading.text = "COMMIT THE DEFENSE"
	heading.add_theme_font_size_override("font_size", 17)
	heading.add_theme_color_override("font_color", Color("#e2bd84"))
	body.add_child(heading)

	summary_label = Label.new()
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.add_theme_font_size_override("font_size", 12)
	summary_label.add_theme_color_override("font_color", Color("#bfe8cf"))
	body.add_child(summary_label)

	lock_label = Label.new()
	lock_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lock_label.add_theme_color_override("font_color", Color("#efc779"))
	lock_label.visible = false
	body.add_child(lock_label)

	confirm_button = Button.new()
	confirm_button.text = "ENTER KEEP — BUILD DEFENSE"
	confirm_button.tooltip_text = "Commit the selected commander and defense, then enter Preparation."
	confirm_button.custom_minimum_size.y = 40
	confirm_button.pressed.connect(func() -> void: confirm_requested.emit())
	body.add_child(confirm_button)

	choice_row = BoxContainer.new()
	choice_row.add_theme_constant_override("separation", 10)
	choice_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(choice_row)

	var commander: Dictionary = _build_choice_card("COMMANDER")
	commander_card = commander.panel
	choice_row.add_child(commander.panel)
	commander_index_label = commander.index
	commander_name_label = commander.title
	commander_identity_label = commander.identity
	commander_strength_label = commander.primary
	commander_ability_label = commander.secondary
	commander_limitation_label = commander.risk
	commander_question_label = commander.fixed
	commander_previous_button = commander.previous
	commander_next_button = commander.next
	commander_previous_button.pressed.connect(func() -> void: commander_previous_requested.emit())
	commander_next_button.pressed.connect(func() -> void: commander_next_requested.emit())

	var scenario: Dictionary = _build_choice_card("DEFENSE")
	scenario_card = scenario.panel
	choice_row.add_child(scenario.panel)
	scenario_index_label = scenario.index
	scenario_name_label = scenario.title
	scenario_identity_label = scenario.identity
	scenario_objective_label = scenario.primary
	scenario_arc_label = scenario.secondary
	scenario_risk_label = scenario.risk
	scenario_fixed_label = scenario.fixed
	scenario_previous_button = scenario.previous
	scenario_next_button = scenario.next
	scenario_previous_button.pressed.connect(func() -> void: scenario_previous_requested.emit())
	scenario_next_button.pressed.connect(func() -> void: scenario_next_requested.emit())

func render(view_model: Dictionary) -> void:
	var commander: Dictionary = view_model.get("commander", {})
	var scenario: Dictionary = view_model.get("scenario", {})
	var locked: bool = bool(view_model.get("locked", false))
	summary_label.text = "%s\nPAIRING — %s\nSEED — %s\nFOCUS — %s" % [
		String(view_model.get("run_frame", "SKIRMISH · STANDARD · defender wipe is recoverable")),
		String(view_model.get("pairing", "Choose who leads which defense.")),
		String(view_model.get("seed_pressure", "Standard Bell: baseline stores and authored pressure.")),
		String(view_model.get("preparation_focus", "Read the first forecast before placing the defense.")),
	]
	lock_label.visible = locked
	lock_label.text = "FIRST WATCH LOCKED — This lesson uses The Castellan and Gatehouse Lock so every taught command matches the authored defense." if locked else ""

	commander_index_label.text = "COMMANDER %d / %d" % [int(commander.get("index", 0)), int(commander.get("count", 0))]
	commander_name_label.text = String(commander.get("name", "Commander"))
	commander_identity_label.text = String(commander.get("identity", "Choose a strategic lens."))
	commander_strength_label.text = "STRENGTH\n%s" % String(commander.get("strength", ""))
	commander_ability_label.text = "INTERVENTION\n%s — %s" % [String(commander.get("ability_name", "Ability")), String(commander.get("ability", ""))]
	commander_limitation_label.text = "LIMITATION\n%s" % String(commander.get("limitation", ""))
	commander_question_label.text = "FIRST QUESTION\n%s" % String(commander.get("question", ""))

	scenario_index_label.text = "DEFENSE %d / %d  •  %s" % [int(scenario.get("index", 0)), int(scenario.get("count", 0)), String(scenario.get("difficulty", "standard")).to_upper()]
	scenario_name_label.text = String(scenario.get("name", "Defense"))
	scenario_identity_label.text = "%s  •  %s\nGEOMETRY FIT — %s\nOPENING — %s\nFIRST QUESTION — %s" % [String(scenario.get("keep", "Keep")), String(scenario.get("identity", "Authored pressure")), String(scenario.get("geometry", "Read the keep geometry.")), String(scenario.get("geometry_opening", "Build one legible answer.")), String(scenario.get("question", "What must this defense preserve?"))]
	scenario_objective_label.text = "OBJECTIVE\n%s" % String(scenario.get("objective", ""))
	scenario_arc_label.text = "PRESSURE ARC\n%s" % String(scenario.get("arc", ""))
	scenario_risk_label.text = "RUN RULE\n%s" % String(scenario.get("risk", ""))
	scenario_fixed_label.text = "FIXED ON ENTRY\n%s" % String(scenario.get("fixed", ""))

	for button in [commander_previous_button, commander_next_button, scenario_previous_button, scenario_next_button]:
		button.disabled = locked
		button.tooltip_text = "First Watch fixes this choice." if locked else "Browse the authored catalogue through the existing selection command."

func set_compact_layout(compact: bool) -> void:
	set_responsive_layout(compact, 800.0)

func set_responsive_layout(compact: bool, available_width: float) -> void:
	choice_row.vertical = compact
	custom_minimum_size.x = minf(800.0, maxf(0.0, available_width))
	var card_width: float = 0.0 if compact else minf(380.0, maxf(300.0, (available_width - 34.0) * 0.5))
	if commander_card != null:
		commander_card.custom_minimum_size.x = card_width
	if scenario_card != null:
		scenario_card.custom_minimum_size.x = card_width

func focus_primary() -> void:
	if commander_next_button != null and commander_next_button.is_visible_in_tree() and not commander_next_button.disabled:
		commander_next_button.grab_focus()

func _build_choice_card(eyebrow_text: String) -> Dictionary:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 248)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#222934")
	style.border_color = Color("#516779")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 11
	style.content_margin_right = 11
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	panel.add_theme_stylebox_override("panel", style)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 5)
	panel.add_child(body)
	var index: Label = _label(eyebrow_text, Color("#8fc6d1"), 11)
	body.add_child(index)
	var title: Label = _label("", Color("#fff0c7"), 20)
	body.add_child(title)
	var identity: Label = _label("", Color("#c9bfd0"), 12)
	body.add_child(identity)
	var primary: Label = _label("", Color("#bfe8cf"), 11)
	body.add_child(primary)
	var secondary: Label = _label("", Color("#9fd6e2"), 11)
	body.add_child(secondary)
	var risk: Label = _label("", Color("#efb28f"), 11)
	body.add_child(risk)
	var fixed: Label = _label("", Color("#d8c389"), 11)
	fixed.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(fixed)
	var navigation: HBoxContainer = HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 6)
	body.add_child(navigation)
	var previous: Button = Button.new()
	previous.text = "← PREVIOUS"
	previous.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigation.add_child(previous)
	var next: Button = Button.new()
	next.text = "NEXT →"
	next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigation.add_child(next)
	body.move_child(navigation, 2)
	return {"panel": panel, "index": index, "title": title, "identity": identity, "primary": primary, "secondary": secondary, "risk": risk, "fixed": fixed, "previous": previous, "next": next}

func _label(value: String, color: Color, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
