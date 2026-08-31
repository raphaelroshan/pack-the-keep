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
	ui._set_screen("preparation")

	ui._select_option_metadata(ui.scenario_option, "the_unlit_stair")
	ui._on_select_scenario()
	ui._select_option_metadata(ui.pack_option, "lantern_watch")
	ui._refresh_pack_preview()
	_check(String(ui.scenario_preview_label.text).contains("The Unlit Stair"), "Preparation should expose the isolated concealment scenario")
	_check(String(ui.scenario_preview_label.text).contains("Lantern Watch + Road Wardens"), "scenario preview should expose both tested answers")
	_check(String(ui.pack_preview_label.text).contains("Lantern Watch") and String(ui.pack_preview_label.text).contains("Dusk Bow") and String(ui.pack_preview_label.text).contains("Lantern Post"), "Preparation should explain the complete Lantern Watch pack")

	ui._on_open_pack()
	_check(bool(ui.keep.place_piece("dusk_bow", Vector2i(1, 1), "upper").get("ok", false)), "UI fixture should place Dusk Bow")
	ui._refresh_ui()
	_check(String(ui.forecast_label.text).contains("Visibility: VEILED"), "forecast should warn that the route remains veiled")
	_check(bool(ui.keep.place_piece("lantern_post", Vector2i(7, 1), "upper").get("ok", false)), "UI fixture should place Lantern Post beside North Tower")
	ui._refresh_ui()
	_check(String(ui.forecast_label.text).contains("Visibility: REVEALED"), "forecast should confirm route visibility")
	_check(bool(ui.keep.start_wave("veiled_entry").get("ok", false)), "UI fixture should start Veiled Entry")
	ui._set_screen("battle")
	ui._refresh_ui()
	await process_frame

	_check(String(ui.forecast_label.text).contains("Veiled Entry") and String(ui.forecast_label.text).contains("Visibility: REVEALED"), "Battle forecast should preserve route visibility")
	_check(String(ui.enemy_label.text).contains("Gloam Knife") and String(ui.enemy_label.text).contains("visibility REVEALED"), "Battle roster should name Gloam Knife and its visibility state")
	var profile: Dictionary = ui.keep_canvas.actor_visual_snapshot("dusk_bow", "gloam_knife")
	_check(String(profile.get("piece", {}).get("family", "")) == "ranged" and String(profile.get("enemy", {}).get("initial", "")) == "K", "board registry should expose distinct Dusk Bow and Gloam Knife identities")
	var authoritative_before_inspection: String = JSON.stringify(ui.keep.serialize())
	ui._select_enemy_focus(0, "P51 Lantern Watch UI test")
	await process_frame
	_check(String(ui.inspector_label.text).contains("Gloam Knife") and String(ui.inspector_label.text).contains("visibility REVEALED"), "enemy inspection should expose effective concealment state")
	_check(String(ui.response_preview_label.text).contains("Dusk Bow"), "response preview should name the revealed ranged counter")
	ui.keep_canvas.queue_redraw()
	await process_frame
	_check(JSON.stringify(ui.keep.serialize()) == authoritative_before_inspection, "Gloam Knife inspection and redraw should not mutate authoritative state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P51 Lantern Watch UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
