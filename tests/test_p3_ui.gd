extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	for action in ["focus_cycle_forward", "focus_cycle_backward", "focus_enemy"]:
		if not InputMap.has_action(action):
			failures.append("missing P3 named input action: %s" % action)

	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	ui._on_reset_run()
	ui._on_place_piece()
	ui._on_start_wave()
	if not ui.keep.wave_active:
		failures.append("P3 setup could not start a valid invasion")

	var before_focus: Dictionary = ui.keep.summary()
	if ui.focused_enemy_index != 0:
		failures.append("battle start did not automatically focus the first priority enemy")
	if not ui.response_preview_label.text.contains("FOCUSED 1"):
		failures.append("response preview did not expose the automatically focused enemy")
	if ui.enemy_option.selected < 0 or int(ui.enemy_option.get_item_metadata(ui.enemy_option.selected)) != 0:
		failures.append("automatic focus did not synchronize the enemy fallback dropdown")

	var marker_position: Vector2 = ui.keep_canvas._enemy_origin(0)
	if ui.keep_canvas._enemy_hit(marker_position) != 0:
		failures.append("enemy marker hit-testing did not select the nearest stable index")
	var click_event: InputEventMouseButton = InputEventMouseButton.new()
	click_event.button_index = MOUSE_BUTTON_LEFT
	click_event.pressed = true
	click_event.position = marker_position
	ui.keep_canvas._gui_input(click_event)
	if ui.focused_enemy_index != 0:
		failures.append("map enemy click did not route into the focused-enemy handler")
	ui._cycle_enemy_focus(1)
	if ui.focused_enemy_index != 1:
		failures.append("forward focus did not cycle to the second active enemy")
	ui._cycle_enemy_focus(-1)
	if ui.focused_enemy_index != 0:
		failures.append("backward focus did not return to the first active enemy")
	if ui.keep.summary() != before_focus:
		failures.append("focus selection changed authoritative summary")

	var before_preview: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_response_preview()
	if JSON.stringify(ui.keep.serialize()) != before_preview:
		failures.append("response preview mutated authoritative serialized state")
	var command_before: int = ui.keep.command_points
	ui._on_use_ability()
	if ui.keep.command_points != command_before - 1:
		failures.append("paused intervention did not commit exactly one existing commander ability cost")
	if not ui.keep.lockdown_pending and ui.keep.commander_id == "castellan":
		failures.append("Castellan intervention was not armed through the authoritative core")

	ui.queue_free()
	# Let the SceneTree process queued UI cleanup before quitting. Without this
	# boundary, Windows Godot can occasionally segfault after a successful smoke test.
	await process_frame
	if failures.is_empty():
		print("P3 UI smoke: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("P3 UI smoke: FAIL (%d)" % failures.size())
		quit(1)
