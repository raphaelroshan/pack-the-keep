extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame

	# Controlled recovery fixture: use commands for placement, then set damage and
	# interval state directly so every card can be inspected without combat noise.
	ui.keep.reset_run(3307)
	var placed: Dictionary = ui.keep.place_piece("pike_squad", Vector2i(3, 3), "ground")
	_check(bool(placed.get("ok", false)), "recovery-card fixture could not place Pike Squad")
	ui.keep.rooms["gate"].condition = 40
	ui.keep._update_room_state("gate")
	ui.keep._set_piece_health("pike_squad_0", 7)
	ui.keep.repair_interval_active = true
	ui.keep.repair_actions_remaining = 2
	ui.keep.repair_interval_reason = "Choose what Greywatch restores before the next warning."
	ui._set_screen("results")
	ui._on_map_clicked("ground", Vector2i(3, 3))
	ui._on_map_clicked("ground", Vector2i(1, 3))
	ui._refresh_ui()
	await process_frame

	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_recovery_action_cards()
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "refreshing recovery cards mutated authoritative state")
	_check(ui.recovery_actions_panel.visible, "recovery action cards were not visible during recovery")
	_check(ui.selected_instance_id == "pike_squad_0" and ui._selected_id(ui.room_option) == "gate", "map-first recovery targeting did not preserve the selected piece and room")
	var scroll_rect: Rect2 = Rect2(ui.command_scroll.global_position, ui.command_scroll.size)
	_check(scroll_rect.has_point(ui.recovery_stage_label.global_position + Vector2.ONE), "Results did not scroll the command table to the recovery choices")
	_check(String(ui.recovery_stage_label.text).contains("CHOICE 1 OF 2"), "recovery header did not expose the first action slot")
	_check(not ui.recovery_room_button.disabled, "damaged selected room was not a legal repair card")
	_check(not ui.recovery_piece_button.disabled, "damaged selected piece was not a legal repair card")
	_check(not ui.recovery_assign_button.disabled, "adjacent specialist assignment was not a legal action card")
	_check(ui.recovery_clear_button.disabled, "unassigned piece incorrectly exposed a legal clear action")
	_check(String(ui.recovery_clear_card_detail.text).contains("piece has no room assignment"), "blocked clear card did not show the authoritative reason")
	_check(ui.recovery_room_card_panel.get_index() == 2 and ui.recovery_piece_card_panel.get_index() == 3 and ui.recovery_assign_card_panel.get_index() == 4, "ready recovery cards should preserve their authored relative order")
	_check(ui.recovery_clear_card_panel.get_index() > ui.recovery_assign_card_panel.get_index(), "blocked recovery cards should follow every legal action")
	_check(ui.finish_interval_button.get_index() == ui.recovery_actions_panel.get_child_count() - 1, "Finish Recovery should remain the final command-rail control")

	var materials_before: int = ui.keep.materials
	ui.recovery_room_button.pressed.emit()
	await process_frame
	_check(ui.keep.materials == materials_before - 8, "room repair card did not spend the authoritative material cost")
	_check(ui.keep.repair_actions_remaining == 1, "room repair card did not consume exactly one action")
	_check(String(ui.recovery_stage_label.text).contains("CHOICE 2 OF 2"), "recovery header did not advance to the second action slot")

	ui.recovery_assign_button.pressed.emit()
	await process_frame
	_check(ui.keep.assigned_rooms.get("gate", "") == "pike_squad_0", "assignment card did not invoke the authoritative assignment command")
	_check(ui.keep.repair_actions_remaining == 0, "two recovery cards did not exhaust the action budget")
	_check(ui.recovery_room_button.disabled and ui.recovery_piece_button.disabled and ui.recovery_assign_button.disabled and ui.recovery_clear_button.disabled, "action cards remained enabled after the budget was exhausted")
	_check(String(ui.recovery_room_card_detail.text).contains("no recovery actions remain"), "exhausted cards did not explain the action-budget block")
	_check(ui.finish_interval_button.text == "FINISH RECOVERY", "terminal recovery did not expose an explicit finish action")

	ui.finish_interval_button.pressed.emit()
	await process_frame
	_check(not ui.keep.repair_interval_active, "explicit finish action did not close recovery")
	_check(ui.screen == "preparation", "terminal recovery did not return to Preparation")

	# A second fixture proves that the clear card becomes legal after an
	# authoritative assignment, rather than merely existing as a disabled button.
	ui.keep.reset_run(3307)
	ui.keep.place_piece("pike_squad", Vector2i(3, 3), "ground")
	ui.keep.repair_interval_active = true
	ui.keep.repair_actions_remaining = 2
	ui.keep.repair_interval_reason = "Reconsider the current specialist post."
	ui.keep.assign_piece_to_room("pike_squad_0", "gate")
	ui.selected_instance_id = "pike_squad_0"
	ui._set_screen("results")
	ui._refresh_ui()
	await process_frame
	_check(not ui.recovery_clear_button.disabled, "assigned piece did not expose a legal clear-assignment card")
	_check(ui.recovery_clear_card_panel.get_index() == 2, "the sole legal clear-assignment card should move ahead of blocked repair and assignment diagnostics")
	ui.recovery_clear_button.pressed.emit()
	await process_frame
	_check(String(ui.keep.pieces["pike_squad_0"].get("assignment", "")).is_empty(), "clear-assignment card did not invoke the authoritative command")
	_check(ui.keep.repair_actions_remaining == 0, "assignment plus clearing did not consume the two-action budget")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P5 recovery action cards: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		printerr("P5 recovery action cards: FAIL (%d)" % failures.size())
		quit(1)
