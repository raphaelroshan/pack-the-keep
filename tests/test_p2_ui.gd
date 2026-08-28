extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	var required_actions: Array[String] = [
		"battle_pause", "battle_advance", "battle_speed_half", "battle_speed_normal", "battle_speed_double",
		"battle_manual_step", "commander_ability", "placement_arm", "placement_cancel", "report_focus", "feedback_mute", "contrast_toggle", "reduced_motion_toggle"
	]
	for action in required_actions:
		if not InputMap.has_action(action):
			failures.append("missing named input action: %s" % action)

	var scene: PackedScene = load("res://scenes/Main.tscn")
	var ui: Control = scene.instantiate()
	root.add_child(ui)
	await process_frame
	var initial_summary: Dictionary = ui.keep.summary()

	ui._on_place_piece()
	if ui.keep.pieces.is_empty():
		failures.append("starter placement did not create a defensive piece")
	ui._on_start_wave()
	if not ui.keep.wave_active:
		failures.append("start wave did not activate the invasion")
	if ui.battle_paused:
		failures.append("new invasion should begin in real-time playback")
	var moving_origin: Vector2 = ui.keep_canvas._enemy_origin(0)
	ui._process(0.25)
	if ui.keep.battle_step != 0 or ui.keep_canvas._enemy_origin(0) == moving_origin:
		failures.append("fractional real-time presentation did not move the enemy before the next deterministic tick")
	var space_event: InputEventKey = InputEventKey.new()
	space_event.physical_keycode = 32
	space_event.pressed = true
	ui._unhandled_key_input(space_event)
	if not ui.battle_paused:
		failures.append("named Space action did not pause the live battle")
	var paused_step: int = ui.keep.battle_step
	var enter_event: InputEventKey = InputEventKey.new()
	enter_event.physical_keycode = 4194309
	enter_event.pressed = true
	ui._unhandled_key_input(enter_event)
	if ui.keep.battle_step != paused_step + 1:
		failures.append("named Enter action did not resolve one manual step")
	if ui.keep_canvas.engagement_traces.is_empty() or ui.keep_canvas.engagement_ttl <= 0.0:
		failures.append("resolved combat tick did not produce a bounded engagement trace")
	ui._process(1.0)
	if ui.keep.battle_step != paused_step + 1:
		failures.append("paused automatic presentation advanced the simulation")
	ui._unhandled_key_input(space_event)
	if ui.battle_paused:
		failures.append("named Space action did not resume the paused battle")
	ui._unhandled_key_input(space_event)
	if not ui.battle_paused:
		failures.append("second named Space action did not pause the battle again")
	ui.keep_canvas.set_reduced_motion(true)
	var reduced_motion_traces: Array[Dictionary] = [{"attacker_id": "pike_squad_0", "enemy_index": 0, "damage": 1}]
	ui.keep_canvas.show_engagements(reduced_motion_traces)
	if not ui.keep_canvas.engagement_traces.is_empty():
		failures.append("reduced motion did not suppress transient engagement traces")

	ui._set_battle_speed(2)
	if ui.battle_speed_index != 2 or ui.keep.battle_step != paused_step + 1:
		failures.append("speed selection changed simulation state")
	ui._on_advance_wave()
	if ui.keep.battle_step != paused_step + 2:
		failures.append("manual step did not resolve exactly one deterministic step")

	# Named Space dispatch above already verifies both resume and pause without assuming the wave remains active.
	ui._on_reset_run()
	ui._arm_selected_piece()
	if not ui.placement_mode:
		failures.append("keyboard-equivalent placement arm did not enter placement mode")
	ui._on_cancel_placement()
	if ui.placement_mode:
		failures.append("placement cancel did not exit placement mode")

	ui._toggle_contrast()
	ui._toggle_reduced_motion()
	ui._toggle_mute()
	if ui.keep.summary() != initial_summary:
		failures.append("presentation-only accessibility/audio toggles changed authoritative summary")
	ui.queue_free()

	if failures.is_empty():
		print("P2 UI smoke: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("P2 UI smoke: FAIL (%d)" % failures.size())
		quit(1)
