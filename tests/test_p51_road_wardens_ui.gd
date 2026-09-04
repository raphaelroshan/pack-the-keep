extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _resolve_wave(ui: Control) -> void:
	var safety: int = 0
	while ui.keep.wave_active and safety < 12:
		ui.keep.advance_wave(1.0)
		ui._refresh_ui()
		await process_frame
		safety += 1

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._set_screen("preparation")

	ui._select_option_metadata(ui.scenario_option, "before_the_horn")
	ui._on_select_scenario()
	ui._select_option_metadata(ui.pack_option, "road_wardens")
	ui._refresh_pack_preview()
	_check(String(ui.scenario_preview_label.text).contains("Before the Horn"), "Preparation should expose the isolated Outrider scenario")
	_check(String(ui.scenario_preview_label.text).contains("Road Wardens + Crossbow Watch"), "scenario preview should expose both tested answers")
	_check(String(ui.preparation_pack_offer_panel.name_label.text) == "Road Wardens" and String(ui.pack_preview_label.text).contains("Hook Guard") and String(ui.pack_preview_label.text).contains("Stake Line"), "Preparation should explain the complete Road Wardens pack")

	ui._on_open_pack()
	_check(String(ui.availability_label.text).contains("Hook Guard") and String(ui.availability_label.text).contains("Stake Line"), "opening Road Wardens should expose both pieces")
	_check(bool(ui.keep.place_piece("hook_guard", Vector2i(4, 3), "ground").get("ok", false)), "UI fixture should place Hook Guard")
	ui._refresh_ui()
	_check(String(ui.forecast_label.text).contains("Charge: LIVE"), "forecast should warn that breakthrough momentum is live")
	_check(bool(ui.keep.place_piece("stake_line", Vector2i(1, 2), "ground").get("ok", false)), "UI fixture should place Stake Line beside Gate")
	ui._refresh_ui()
	_check(String(ui.forecast_label.text).contains("Charge: DELAYED"), "forecast should confirm the prepared route delay")
	_check(bool(ui.keep.start_wave("rapid_breakthrough").get("ok", false)), "UI fixture should start Rapid Breakthrough")
	ui._set_screen("battle")
	ui._refresh_ui()
	await process_frame

	_check(String(ui.forecast_label.text).contains("Rapid Breakthrough") and String(ui.forecast_label.text).contains("Charge: DELAYED"), "Battle forecast should preserve the delayed charge state")
	_check(String(ui.enemy_label.text).contains("Outrider") and String(ui.enemy_label.text).contains("charge DELAYED"), "Battle roster should name Outrider and its effective momentum state")
	var profile: Dictionary = ui.keep_canvas.actor_visual_snapshot("hook_guard", "outrider")
	_check(String(profile.get("piece", {}).get("family", "")) == "formation" and String(profile.get("enemy", {}).get("initial", "")) == "O", "board registry should expose distinct Hook Guard and Outrider identities")
	var authoritative_before_inspection: String = JSON.stringify(ui.keep.serialize())
	ui._select_enemy_focus(0, "P51 Road Wardens UI test")
	await process_frame
	_check(String(ui.inspector_label.text).contains("Outrider") and String(ui.inspector_label.text).contains("charge DELAYED") and String(ui.inspector_label.text).contains("contact step 3"), "enemy inspection should expose effective breakthrough timing")
	_check(String(ui.response_preview_label.text).contains("Hook Guard"), "response preview should name the authored interception counter")
	ui.keep_canvas.queue_redraw()
	await process_frame
	_check(JSON.stringify(ui.keep.serialize()) == authoritative_before_inspection, "Outrider inspection and redraw should not mutate authoritative state")

	await _resolve_wave(ui)
	ui._set_screen("results")
	ui._refresh_ui()
	await process_frame
	_check(not ui.keep.wave_active and ui.keep.wave_history.size() == 1, "Before the Horn teaching wave should resolve through the UI")
	_check(String(ui.scorecard_label.text).contains("Before the Horn") and String(ui.scorecard_label.text).contains("PHASE 1"), "Results should identify the Road Wardens scenario and resolved assault phase")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P51 Road Wardens UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
