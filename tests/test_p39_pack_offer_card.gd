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
	await process_frame
	await process_frame

	var panel: PackOfferPanel = ui.preparation_pack_offer_panel
	_check(panel.visible and String(panel.name_label.text) == "Pike Line", "Preparation should lead with the selected pack offer")
	_check(String(panel.detail_label.text).contains("ADDS — Pike Squad") and String(panel.detail_label.text).contains("Narrow Gate"), "pack card should expose every granted piece")
	_check(String(panel.detail_label.text).contains("SOLVES") and String(panel.detail_label.text).contains("LIMITATION") and String(panel.detail_label.text).contains("SPACE"), "pack card should expose strength, weakness, and spatial demand")
	_check(String(panel.role_label.text).contains("QUESTION"), "pack card should expose its strategic question")
	_check(ui.pack_option.is_inside_tree() and not ui.preparation_advanced_panel.visible, "advanced pack dropdown should remain available but collapsed by default")
	ui._toggle_preparation_advanced()
	_check(ui.pack_option.is_visible_in_tree() and not ui.pack_option.disabled, "advanced pack dropdown should be reachable outside First Watch")
	ui._toggle_preparation_advanced()
	var before_refresh: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_pack_preview()
	_check(JSON.stringify(ui.keep.serialize()) == before_refresh, "rendering the pack offer should not mutate authoritative state")

	panel.next_button.pressed.emit()
	_check(ui._selected_id(ui.pack_option) != "pike_line" and JSON.stringify(ui.keep.serialize()) == before_refresh, "browsing pack cards should change only presentation selection")
	var selected_pack: String = ui._selected_id(ui.pack_option)
	panel.reserve_button.pressed.emit()
	_check(ui.keep.reserved_pack_id == selected_pack and String(panel.status_label.text).contains("RESERVED"), "reserve card action should use the existing authoritative reserve command")
	panel.reserve_button.pressed.emit()
	_check(ui.keep.reserved_pack_id.is_empty(), "reserved pack action should clear through the existing toggle behavior")
	var material_before: int = ui.keep.materials
	var pack_cost: int = int(ui.keep.pack_preview(selected_pack).get("cost", 0))
	panel.open_button.pressed.emit()
	_check(ui.keep.owned_packs.has(selected_pack) and ui.keep.materials == material_before - pack_cost, "open card action should preserve authoritative pack cost and ownership")
	_check(String(panel.status_label.text).contains("OPENED") and panel.open_button.disabled, "opened pack should have a clear disabled state")
	panel.next_button.pressed.emit()
	panel.open_button.pressed.emit()
	panel.next_button.pressed.emit()
	_check(String(panel.status_label.text).contains("NO OPENINGS") and panel.open_button.disabled, "pack card should expose an exhausted opening budget")
	ui._set_ui_scale(2)
	ui._set_screen("preparation")
	await process_frame
	_check(ui.gameplay_columns.vertical and panel.visible, "125 percent scale should retain the pack card in the stacked command rail")

	var tutorial_ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(tutorial_ui)
	await process_frame
	await process_frame
	tutorial_ui.preferences_persistence_enabled = false
	tutorial_ui.display_application_enabled = false
	tutorial_ui._start_tutorial()
	tutorial_ui._on_tutorial_continue()
	tutorial_ui._on_tutorial_continue()
	tutorial_ui._on_tutorial_continue()
	tutorial_ui._on_confirm_setup()
	await process_frame
	_check(tutorial_ui.pack_option.disabled and tutorial_ui.preparation_pack_offer_panel.next_button.disabled, "First Watch should lock card and fallback browsing")
	_check(tutorial_ui.preparation_pack_offer_panel.open_button.disabled, "First Watch should not open the pack before the Gate inspection lesson")
	var gate: Dictionary = tutorial_ui.keep.room_definition("gate")
	tutorial_ui._on_map_clicked(String(gate.get("floor", "ground")), gate.get("origin", Vector2i.ZERO))
	_check(not tutorial_ui.preparation_pack_offer_panel.open_button.disabled and tutorial_ui.preparation_pack_offer_panel.reserve_button.disabled, "First Watch should enable only its authored Pike Line opening")
	await process_frame
	_check(root.gui_get_focus_owner() == tutorial_ui.pack_button, "First Watch should focus the pack card's authoritative Open action")

	ui.queue_free()
	tutorial_ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P39 pack offer card: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
