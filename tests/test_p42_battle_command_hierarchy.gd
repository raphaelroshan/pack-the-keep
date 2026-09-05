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
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	ui._on_start_wave()
	await process_frame

	_check(ui.screen == "battle" and ui.keep.wave_active, "test setup should enter an active assault")
	_check(ui.battle_state_label.is_visible_in_tree() and String(ui.battle_state_label.text).contains("PAUSED"), "battle rail should lead with readable live state")
	_check(ui.pause_button.is_visible_in_tree() and ui.commander_ability_button.is_visible_in_tree(), "time control and commander intervention should remain primary")
	_check(ui.battle_focus_panel.is_visible_in_tree() and String(ui.battle_focus_panel.name_label.text).contains("Raider"), "board-first Assault should name the focused enemy in its compact dossier")
	_check(not ui.inspect_enemy_button.is_visible_in_tree() and not ui.battle_inspection_label.visible and not ui.response_preview_label.visible, "board-first Assault should remove duplicate inspection actions and prose")
	_check(not ui.battle_tactical_panel.visible and not ui.manual_step_button.is_visible_in_tree() and not ui.speed_button.is_visible_in_tree() and not ui.enemy_option.is_visible_in_tree(), "manual timing and fallback selection should begin collapsed")

	var before_disclosure: String = JSON.stringify(ui.keep.serialize())
	ui.battle_tactical_button.pressed.emit()
	await process_frame
	_check(ui.battle_tactical_panel.visible and ui.manual_step_button.is_visible_in_tree() and ui.speed_button.is_visible_in_tree() and ui.enemy_option.is_visible_in_tree(), "tactical disclosure should expose deterministic timing and fallback controls")
	_check(JSON.stringify(ui.keep.serialize()) == before_disclosure, "opening tactical controls should not mutate authoritative combat state")
	ui.battle_tactical_button.pressed.emit()
	_check(not ui.battle_tactical_panel.visible and JSON.stringify(ui.keep.serialize()) == before_disclosure, "closing tactical controls should remain presentation-only")

	ui.inspect_enemy_button.pressed.emit()
	await process_frame
	_check(String(ui.inspection_panel.kind_label.text).begins_with("THREAT") and String(ui.inspection_panel.name_label.text).contains("Raider"), "visible threat action should route into the shared inspection card")
	ui.tutorial.start()
	ui.tutorial.restore_progress({"tutorial_id": "first_watch", "version": 1, "active": true, "step_id": "inspect_raider", "failure_active": false, "failure_message": ""})
	ui._refresh_ui()
	ui._focus_tutorial_target("enemy_inspector")
	_check(ui.inspect_enemy_button.is_visible_in_tree() and root.gui_get_focus_owner() == ui.inspect_enemy_button, "tutorial threat inspection should restore and focus its explicit control: visible=%s tree=%s disabled=%s focus=%s" % [ui.inspect_enemy_button.visible, ui.inspect_enemy_button.is_visible_in_tree(), ui.inspect_enemy_button.disabled, root.gui_get_focus_owner().name if root.gui_get_focus_owner() != null else "none"])

	ui._set_ui_scale(2)
	await process_frame
	_check(ui.gameplay_columns.vertical and ui.battle_state_label.visible and ui.battle_tactical_button.visible, "125 percent scale should preserve the battle hierarchy in the stacked rail")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P42 battle command hierarchy: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
