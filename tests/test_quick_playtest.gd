extends SceneTree

var failures: Array[String] = []

func _find_button(node: Node, target_text: String) -> Button:
	for child in node.get_children():
		if child is Button and String(child.text) == target_text:
			return child
		var nested: Button = _find_button(child, target_text)
		if nested != null:
			return nested
	return null

func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/Main.tscn")
	var ui: Control = scene.instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	if ui.screen != "title":
		failures.append("fresh scene did not begin on the title screen")
	var start_button: Button = _find_button(ui, "Start Game — Quick Playtest")
	if start_button == null:
		failures.append("Start Game quick-playtest button is missing")
	else:
		start_button.pressed.emit()
		await process_frame
	if ui.screen != "preparation":
		failures.append("Start Game did not open preparation")
	if not ui.keep.scenario_active:
		failures.append("quick-playtest preset did not activate Gatehouse Lock")
	if ui.keep.pieces.size() != 2:
		failures.append("quick-playtest preset did not place exactly two starter pieces")
	if not ui.keep.pieces.has("pike_squad_0") or not ui.keep.pieces.has("narrow_gate_1"):
		failures.append("quick-playtest preset is missing Pike Squad or Narrow Gate")
	var quick_action: Button = _find_button(ui, "RUN QUICK TEST — ONE BATTLE STEP")
	if quick_action == null:
		failures.append("quick test action button is missing")
	else:
		quick_action.pressed.emit()
		await process_frame
	if ui.screen != "battle":
		failures.append("quick test action did not open battle")
	if not ui.keep.wave_active:
		failures.append("quick test action did not start an invasion")
	if ui.keep.battle_step < 1:
		failures.append("quick test action did not advance one readable step")
	if not String(ui.event_label.text).contains("Battle step"):
		failures.append("quick test action did not leave a battle-step event")
	var battle_step_before: int = ui.keep.battle_step
	var advance_button: Button = _find_button(ui, "ADVANCE ONE STEP — INSPECT")
	if advance_button == null:
		failures.append("battle primary action did not change to advance-step state")
	else:
		advance_button.pressed.emit()
		await process_frame
	if ui.keep.battle_step != battle_step_before + 1:
		failures.append("battle primary action did not advance exactly one additional step")
	if not ui.battle_paused:
		failures.append("primary battle action unexpectedly started real-time motion")
	var safety: int = 0
	while ui.keep.wave_active and safety < 20:
		ui._on_advance_wave()
		await process_frame
		safety += 1
	if ui.screen != "results":
		failures.append("quick-playtest did not reach Results after deterministic completion")
	var restart_button: Button = _find_button(ui, "RESTART QUICK PLAYTEST")
	if restart_button == null:
		failures.append("Results primary action did not change to restart")
	else:
		restart_button.pressed.emit()
		await process_frame
	if ui.screen != "preparation" or ui.keep.pieces.size() != 2:
		failures.append("restart quick-playtest did not restore the preset preparation state")
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("Quick playtest smoke: PASS")
	else:
		for failure in failures:
			push_error(failure)
		printerr("Quick playtest smoke: FAIL (%d)" % failures.size())
	quit(0 if failures.is_empty() else 1)
