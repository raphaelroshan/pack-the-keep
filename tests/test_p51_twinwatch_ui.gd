extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _room_option_names(ui: Control) -> Array[String]:
	var names: Array[String] = []
	for index in range(ui.room_option.item_count):
		names.append(ui.room_option.get_item_text(index))
	return names

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._set_screen("preparation")
	ui._select_option_metadata(ui.scenario_option, "the_divided_bell")
	ui._on_select_scenario()
	await process_frame

	_check(String(ui.scenario_preview_label.text).contains("Twinwatch Bastion / The Divided Bell"), "scenario preview should name the Twinwatch identity")
	_check(String(ui.scenario_preview_label.text).contains("Shieldwall + Runner Network"), "scenario preview should expose both answer families")
	var room_names: Array[String] = _room_option_names(ui)
	_check(room_names.has("West Gatehouse") and room_names.has("East Arsenal") and room_names.has("Bell Court"), "room controls should use Twinwatch labels")
	_check(String(ui.status_label.text).contains("Twinwatch Bastion"), "status header should expose Twinwatch")
	_check(String(ui.layout_lens_label.text).contains("Spatial rule [INACTIVE]") and String(ui.layout_lens_label.text).contains("both marked bastions"), "Preparation should explain the inactive paired-watch rule")

	ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	ui.keep.open_pack("runner_network")
	ui.keep.place_piece("runner_pair", Vector2i(9, 3), "ground")
	ui._refresh_ui()
	await process_frame
	_check(String(ui.layout_lens_label.text).contains("Spatial rule [ACTIVE]"), "Preparation should show when both bastions are staffed")
	_check(String(ui.keep.keep_definition().get("visual", {}).get("terrain", "")) == "ridge", "Twinwatch board should select the ridge visual grammar")
	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	ui.keep_canvas.queue_redraw()
	await process_frame
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "Twinwatch board rendering should remain presentation-only")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P51 Twinwatch UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
