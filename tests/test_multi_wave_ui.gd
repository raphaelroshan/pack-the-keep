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

func _resolve_current_wave(ui: Control) -> void:
	var safety: int = 0
	while ui.keep.wave_active and safety < 12:
		ui._on_advance_wave()
		await process_frame
		safety += 1

func _continue_wave(ui: Control, wave_number: int) -> void:
	var button: Button = _find_button(ui, "CONTINUE — START WAVE %d/3" % wave_number)
	if button == null:
		failures.append("continue button for wave %d was missing" % wave_number)
	else:
		button.pressed.emit()
		await process_frame
	if not ui.keep.wave_active or ui.keep.wave_index != wave_number:
		failures.append("continue action did not start wave %d automatically" % wave_number)
	if ui.screen != "battle":
		failures.append("automatic wave %d did not return to Battle" % wave_number)

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui._on_start_quick_playtest()
	await process_frame
	ui._on_quick_test_action()
	await process_frame
	await _resolve_current_wave(ui)
	if ui.screen != "results" or not ui.keep.repair_interval_active:
		failures.append("wave one did not end in inter-wave recovery Results")
	if not ui.keep.has_next_wave():
		failures.append("wave one Results did not expose a next wave")
	await _continue_wave(ui, 2)
	if ui.keep.enemy_doctrine != "distributed_sabotage":
		failures.append("automatic wave two did not select Distributed Sabotage")
	await _resolve_current_wave(ui)
	await _continue_wave(ui, 3)
	if ui.keep.enemy_doctrine != "feint_and_flank":
		failures.append("automatic wave three did not select Feint and Flank")
	await _resolve_current_wave(ui)
	if ui.screen != "results" or ui.keep.has_next_wave() or not ui.keep.repair_interval_active:
		failures.append("final wave did not produce terminal Results recovery")
	if _find_button(ui, "RESTART QUICK PLAYTEST") == null:
		failures.append("terminal Results did not expose restart action")
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("Multi-wave UI smoke: PASS")
	else:
		for failure in failures:
			push_error(failure)
		printerr("Multi-wave UI smoke: FAIL (%d)" % failures.size())
	quit(0 if failures.is_empty() else 1)
