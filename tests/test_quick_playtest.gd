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
	var start_button: Button = _find_button(ui, "New Game")
	if start_button == null:
		failures.append("New Game button is missing")
	else:
		ui._on_start_quick_playtest()
		await process_frame
	if ui.screen != "setup":
		failures.append("New Game did not open the briefing screen after tutorial completion")
	if not ui.keep.scenario_active:
		failures.append("quick-playtest preset did not activate Gatehouse Lock")
	if not ui.setup_overview_panel.visible or ui.keep_canvas.visible:
		failures.append("briefing did not separate setup choices from the keep board")
	if ui.keep.pieces.size() != 0:
		failures.append("briefing placed pieces before setup confirmation")
	var enter_button: Button = _find_button(ui, "Enter Keep — Recommended Layout")
	if enter_button == null:
		failures.append("guided briefing did not expose its enter-keep action")
	else:
		enter_button.pressed.emit()
		await process_frame
	if ui.screen != "preparation":
		failures.append("confirming the briefing did not open preparation")
	if ui.keep.pieces.size() != 2:
		failures.append("confirmed guided setup did not place exactly two starter pieces")
	if not ui.keep.pieces.has("pike_squad_0") or not ui.keep.pieces.has("narrow_gate_1"):
		failures.append("quick-playtest preset is missing Pike Squad or Narrow Gate")
	var quick_action: Button = _find_button(ui, "READY DEFENSE — ENTER ASSAULT")
	if quick_action == null:
		failures.append("preparation start action is missing")
	else:
		quick_action.pressed.emit()
		await process_frame
	if ui.screen != "battle":
		failures.append("preparation action did not open battle")
	if not ui.keep.wave_active:
		failures.append("preparation action did not start an invasion")
	if ui.keep.battle_step != 0 or not ui.battle_paused or ui.assault_ready_reason.is_empty():
		failures.append("battle did not open in the tick-zero readiness beat")
	var ready_action: Button = _find_button(ui, "SOUND THE BELL — BEGIN PHASE 1")
	if ready_action == null:
		failures.append("first assault did not expose the sound-the-bell action")
	else:
		ready_action.pressed.emit()
		await process_frame
	if ui.battle_paused:
		failures.append("sounding the bell did not begin real-time playback")
	var battle_step_before: int = ui.keep.battle_step
	var pause_button: Button = _find_button(ui, "PAUSE — INSPECT")
	if pause_button == null:
		failures.append("battle primary action did not change to pause state")
	else:
		pause_button.pressed.emit()
		await process_frame
	if not ui.battle_paused:
		failures.append("primary battle action did not pause real-time motion")
	ui._on_advance_wave()
	await process_frame
	if ui.keep.battle_step != battle_step_before + 1:
		failures.append("secondary manual step did not advance exactly one deterministic tick")
	var safety: int = 0
	while ui.keep.wave_active and safety < 20:
		ui._on_advance_wave()
		await process_frame
		safety += 1
	if ui.screen != "results":
		failures.append("quick-playtest did not reach inter-wave Results after wave one")
	var continue_two: Button = _find_button(ui, "END LULL — RELEASE PHASE 2/3")
	if continue_two == null:
		failures.append("inter-wave Results did not offer Continue for wave two")
	else:
		continue_two.pressed.emit()
		await process_frame
	if ui.screen != "battle" or not ui.keep.wave_active or ui.keep.wave_index != 2 or not ui.battle_paused or ui.assault_ready_reason.is_empty():
		failures.append("changed pressure did not open phase two in readiness")
	ui._on_playtest_primary_action()
	if ui.battle_paused:
		failures.append("phase two readiness did not release continuous combat")
	safety = 0
	while ui.keep.wave_active and safety < 20:
		ui._on_advance_wave()
		await process_frame
		safety += 1
	var continue_three: Button = _find_button(ui, "END LULL — RELEASE PHASE 3/3")
	if continue_three == null:
		failures.append("inter-wave Results did not offer Continue for wave three")
	else:
		continue_three.pressed.emit()
		await process_frame
	if ui.screen != "battle" or not ui.keep.wave_active or ui.keep.wave_index != 3 or not ui.battle_paused or ui.assault_ready_reason.is_empty():
		failures.append("changed pressure did not open phase three in readiness")
	ui._on_playtest_primary_action()
	if ui.battle_paused:
		failures.append("phase three readiness did not release continuous combat")
	safety = 0
	while ui.keep.wave_active and safety < 20:
		ui._on_advance_wave()
		await process_frame
		safety += 1
	if ui.screen != "results":
		failures.append("quick-playtest did not reach terminal Results after wave three")
	var restart_button: Button = _find_button(ui, "REVIEW SETUP — PLAY AGAIN")
	if restart_button == null:
		failures.append("terminal Results primary action did not return to setup")
	else:
		restart_button.pressed.emit()
		await process_frame
	if ui.screen != "setup" or ui.keep.pieces.size() != 0:
		failures.append("replay action did not return to a clean guided briefing")
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("Quick playtest smoke: PASS")
	else:
		for failure in failures:
			push_error(failure)
		printerr("Quick playtest smoke: FAIL (%d)" % failures.size())
	quit(0 if failures.is_empty() else 1)
