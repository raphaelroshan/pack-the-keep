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
	var labels_before: String = JSON.stringify(ui.keep.serialize())
	var board_presentation: Dictionary = ui.keep_canvas.board_presentation_snapshot()
	if bool(board_presentation.get("grid_visible", true)) or Vector2(board_presentation.get("cell_size", Vector2.ZERO)).x < 24.0 or Vector2(board_presentation.get("cell_size", Vector2.ZERO)).y < 32.0:
		failures.append("battle board did not expose the enlarged grid-free presentation")
	if not is_equal_approx(ui.keep_canvas._health_ratio(5, 10), 0.5) or not is_equal_approx(ui.keep_canvas._health_ratio(0, 10), 0.0):
		failures.append("health bar projection did not reflect authoritative current and maximum health")
	var gate_room: Dictionary = ui.keep.room_definition("gate")
	var gate_board: Vector2 = ui.keep_canvas.MAP_ORIGIN + Vector2(gate_room.origin.x * ui.keep_canvas.CELL_X, gate_room.origin.y * ui.keep_canvas.CELL_Y) + Vector2(gate_room.size.x * ui.keep_canvas.CELL_X, gate_room.size.y * ui.keep_canvas.CELL_Y) * 0.5
	var gate_view: Vector2 = ui.keep_canvas._board_offset() + gate_board * ui.keep_canvas._board_scale()
	var gate_tooltip: String = ui.keep_canvas._get_tooltip(gate_view)
	if not gate_tooltip.contains("Gate") or not gate_tooltip.contains("condition") or not gate_tooltip.contains("Critical room"):
		failures.append("room hover did not expose full room identity, condition, and role")
	var compact_piece_label: String = ui.keep_canvas._compact_board_label("Crossbow Patrol", 24.0, 8)
	if compact_piece_label.is_empty() or ThemeDB.fallback_font.get_string_size(compact_piece_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x > 24.0:
		failures.append("compact board label did not fit its requested width")
	var first_piece_id: String = String(ui.keep.pieces.keys()[0])
	var original_piece: Dictionary = ui.keep.pieces[first_piece_id].duplicate(true)
	var overlapping_piece: Dictionary = original_piece.duplicate(true)
	overlapping_piece.origin = gate_room.origin
	overlapping_piece.floor = gate_room.floor
	ui.keep.pieces[first_piece_id] = overlapping_piece
	if ui.keep_canvas._room_label_visible("gate", "ground", ui.keep_canvas.MAP_ORIGIN):
		failures.append("placed defender did not suppress the competing room label")
	ui.keep.pieces[first_piece_id] = original_piece
	if JSON.stringify(ui.keep.serialize()) != labels_before:
		failures.append("board label projection mutated authoritative state")
	ui._set_screen("preparation")
	if not bool(ui.keep_canvas.board_presentation_snapshot().get("placement_guides_visible", false)):
		failures.append("preparation board did not retain placement guides")
	ui._on_start_wave()
	if not ui.keep.wave_active:
		failures.append("start wave did not activate the invasion")
	if bool(ui.keep_canvas.board_presentation_snapshot().get("placement_guides_visible", true)):
		failures.append("battle board kept preparation placement guides visible during combat")
	if ui.battle_paused:
		failures.append("new invasion should begin in real-time playback")
	if ui.focused_enemy_index != ui._priority_enemy_index() or ui.focused_enemy_index < 0 or not String(ui.response_preview_label.text).contains("FOCUSED"):
		failures.append("live battle did not begin with the highest-priority threat and a populated response preview")
	if ui.enemy_option.selected < 0 or int(ui.enemy_option.get_item_metadata(ui.enemy_option.selected)) != ui.focused_enemy_index:
		failures.append("automatic threat focus did not synchronize the enemy dropdown")
	var watch_state_before: String = JSON.stringify(ui.keep.serialize())
	if ui.keep_canvas.defender_watch_snapshot().is_empty():
		failures.append("ready defenders did not face a projected attacker while idle")
	if JSON.stringify(ui.keep.serialize()) != watch_state_before:
		failures.append("defender readiness projection mutated authoritative state")
	var serialized_before_timeline: String = JSON.stringify(ui.keep.serialize())
	var timeline_before: Dictionary = ui.keep_canvas.assault_timeline_snapshot()
	var spacing_before: Dictionary = ui.keep_canvas.assault_lane_spacing_snapshot()
	var arrival_marker_count: int = 0
	for arrival_rows in timeline_before.get("arrivals", {}).values():
		arrival_marker_count += arrival_rows.size()
	if int(timeline_before.get("tick_count", 0)) != 6 or arrival_marker_count != ui.keep.enemies.size() or int(timeline_before.get("next_arrival_step", -1)) < 1:
		failures.append("assault timeline did not expose six ticks, stable active-enemy arrivals, and the next contact")
	if float(spacing_before.get("clearance", 0.0)) < 12.0 or float(spacing_before.get("summary_bottom", INF)) > float(spacing_before.get("canvas_bottom", 0.0)):
		failures.append("gate approach labels and the complete assault timeline did not retain a readable vertical separation")
	if JSON.stringify(ui.keep.serialize()) != serialized_before_timeline:
		failures.append("assault timeline inspection mutated authoritative state")
	var first_arrival_key: String = str(int(timeline_before.get("next_arrival_step", 1)))
	var first_arrival_rows: Array = timeline_before.get("arrivals", {}).get(first_arrival_key, [])
	if not first_arrival_rows.is_empty():
		var marker_board: Vector2 = ui.keep_canvas._timeline_marker_origin(int(first_arrival_key), 0, first_arrival_rows.size())
		var marker_view: Vector2 = ui.keep_canvas._board_offset() + marker_board * ui.keep_canvas._board_scale()
		var marker_enemy_index: int = int(first_arrival_rows[0].get("index", -1))
		var enemy_board: Vector2 = ui.keep_canvas._enemy_origin(marker_enemy_index)
		var enemy_view: Vector2 = ui.keep_canvas._board_offset() + enemy_board * ui.keep_canvas._board_scale()
		var map_tooltip: String = ui.keep_canvas._get_tooltip(enemy_view)
		var timeline_tooltip: String = ui.keep_canvas._get_tooltip(marker_view)
		var marker_inspection: Dictionary = ui.keep.inspect_enemy(marker_enemy_index)
		if map_tooltip != timeline_tooltip:
			failures.append("map and timeline markers did not expose the same enemy tooltip")
		if not map_tooltip.contains(String(marker_inspection.get("name", ""))) or not map_tooltip.contains("Route:") or not map_tooltip.contains("HP ") or not map_tooltip.contains("Contact T") or not map_tooltip.contains("Strike every") or not map_tooltip.contains("Counter:"):
			failures.append("enemy tooltip did not expose name, route, health, contact tick, strike cadence, and counter")
		if ui.keep_canvas._timeline_enemy_hit(marker_view) != marker_enemy_index:
			failures.append("timeline arrival marker hit testing did not resolve the matching enemy")
		var timeline_click: InputEventMouseButton = InputEventMouseButton.new()
		timeline_click.button_index = MOUSE_BUTTON_LEFT
		timeline_click.pressed = true
		timeline_click.position = marker_view
		ui.keep_canvas._gui_input(timeline_click)
		if ui.focused_enemy_index != marker_enemy_index or not String(ui.event_label.text).contains("timeline marker"):
			failures.append("timeline arrival click did not route through the dedicated focus source")
	var focus_state_before: String = JSON.stringify(ui.keep.serialize())
	if focus_state_before != serialized_before_timeline:
		failures.append("timeline or enemy tooltip inspection mutated authoritative state")
	if ui.keep.enemies.size() > 1:
		ui._on_enemy_clicked(1)
		ui._ensure_enemy_focus()
		if ui.focused_enemy_index != 1:
			failures.append("automatic focus replaced a living player-selected threat")
		ui.keep.enemies[1].defeated = true
		ui._ensure_enemy_focus()
		if ui.focused_enemy_index != 0:
			failures.append("defeated threat did not hand focus to the next deterministic priority")
		ui.keep.enemies[1].defeated = false
	if not String(ui.response_preview_label.text).contains("STRIKE:"):
		failures.append("focused response preview did not expose enemy strike cadence")
	if JSON.stringify(ui.keep.serialize()) != focus_state_before:
		failures.append("threat focus selection or handoff mutated authoritative state")
	var moving_origin: Vector2 = ui.keep_canvas._enemy_origin(0)
	ui._process(0.25)
	if ui.keep.battle_step != 0 or ui.keep_canvas._enemy_origin(0) == moving_origin:
		failures.append("fractional real-time presentation did not move the enemy before the next deterministic tick")
	if float(ui.keep_canvas.assault_timeline_snapshot().get("progress", 0.0)) <= float(timeline_before.get("progress", 0.0)):
		failures.append("assault timeline did not advance fractionally with live presentation time")
	var original_step: int = ui.keep.battle_step
	var original_clock: float = ui.keep.battle_clock
	var arrival_step: int = int(ui.keep.enemies[0].get("arrival_step", 1))
	ui.keep.battle_step = maxi(0, arrival_step - 1)
	ui.keep.battle_clock = 0.25
	if not ui.keep_canvas._enemy_contact_is_imminent(0):
		failures.append("enemy in the final approach second did not expose a contact telegraph")
	ui.keep.battle_step = original_step
	ui.keep.battle_clock = original_clock
	var preview_traces: Array[Dictionary] = ui._next_engagement_traces()
	if preview_traces.is_empty() or String(preview_traces[0].get("style", "")) != "melee":
		failures.append("engagement traces did not retain the defender's data-driven combat style")
	ui._process(0.8)
	if ui.keep.battle_step != 1 or not String(ui.status_label.text).contains("Tick 1"):
		failures.append("live UI did not refresh status after an automatic deterministic tick")
	var space_event: InputEventKey = InputEventKey.new()
	space_event.physical_keycode = 32
	space_event.pressed = true
	ui._unhandled_key_input(space_event)
	if not ui.battle_paused:
		failures.append("named Space action did not pause the live battle")
	var paused_timeline: Dictionary = ui.keep_canvas.assault_timeline_snapshot()
	ui._process(0.4)
	if ui.keep_canvas.assault_timeline_snapshot() != paused_timeline:
		failures.append("paused battle changed the assault timeline")
	var paused_step: int = ui.keep.battle_step
	var enter_event: InputEventKey = InputEventKey.new()
	enter_event.physical_keycode = 4194309
	enter_event.pressed = true
	ui._unhandled_key_input(enter_event)
	if ui.keep.battle_step != paused_step + 1:
		failures.append("named Enter action did not resolve one manual step")
	if ui.keep_canvas.engagement_traces.is_empty() or ui.keep_canvas.engagement_ttl <= 0.0:
		failures.append("resolved combat tick did not produce a bounded engagement trace")
	var effect_progress_before: float = ui.keep_canvas._combat_effect_progress()
	ui.keep_canvas._process(0.08)
	if ui.keep_canvas._combat_effect_progress() <= effect_progress_before:
		failures.append("combat exchange presentation did not advance independently after the authoritative tick")
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
	var reduced_motion_traces: Array[Dictionary] = [{"attacker_id": "pike_squad_0", "enemy_index": 0, "damage": 1, "style": "melee"}]
	ui.keep_canvas.show_engagements(reduced_motion_traces)
	if ui.keep_canvas.engagement_traces.is_empty() or ui.keep_canvas.engagement_ttl > 0.22 or ui.keep_canvas._enemy_reaction_offset(0) != Vector2.ZERO:
		failures.append("reduced motion did not retain a static bounded impact while suppressing travel and hit reaction")
	var target_snapshot: Dictionary = ui._combat_target_snapshot()
	var original_gate_condition: int = ui.keep.room_condition("gate")
	var original_target: String = String(ui.keep.enemies[0].get("target", ""))
	ui.keep.enemies[0].target = "gate"
	ui.keep.rooms.gate.condition = original_gate_condition - 7
	var detected_impacts: Array[Dictionary] = ui._resolved_target_impacts(target_snapshot)
	if detected_impacts.is_empty() or int(detected_impacts[0].get("damage", 0)) != 7 or String(detected_impacts[0].get("target_kind", "")) != "room":
		failures.append("authoritative before/after room state did not produce an exact target impact")
	ui.keep.rooms.gate.condition = original_gate_condition
	ui.keep.enemies[0].target = original_target

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
