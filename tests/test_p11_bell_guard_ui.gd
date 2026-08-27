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

	ui._select_option_metadata(ui.scenario_option, "ash_at_the_bell")
	ui._on_select_scenario()
	ui._select_option_metadata(ui.pack_option, "bell_guard")
	ui._refresh_pack_preview()
	_check(String(ui.scenario_preview_label.text).contains("Ash at the Bell"), "Preparation should expose the Ash at the Bell scenario")
	_check(String(ui.pack_preview_label.text).contains("Bell Guard") and String(ui.pack_preview_label.text).contains("Bellkeepers") and String(ui.pack_preview_label.text).contains("Signal Beacon"), "Preparation should explain the complete Bell Guard pack")

	ui._on_open_pack()
	_check(String(ui.availability_label.text).contains("Bellkeepers") and String(ui.availability_label.text).contains("Signal Beacon"), "Opening Bell Guard should expose both signal pieces")
	ui.keep.place_piece("pike_squad", Vector2i(5, 3), "ground")
	ui.keep.place_piece("bellkeepers", Vector2i(1, 1), "upper")
	ui.keep.place_piece("signal_beacon", Vector2i(4, 1), "upper")
	ui._refresh_ui()
	_check(String(ui.forecast_label.text).contains("Signal: REDUNDANT"), "linked Bell Guard should expose redundant signal status before battle")
	_check(bool(ui.keep.start_wave("smoke_and_signal").get("ok", false)), "UI fixture should start Smoke and Signal")
	ui._set_screen("battle")
	ui._refresh_ui()
	await process_frame

	_check(String(ui.forecast_label.text).contains("smoke and signal") and String(ui.forecast_label.text).contains("Signal: REDUNDANT"), "Battle forecast should name Smoke and Signal and its countered state")
	_check(String(ui.enemy_label.text).contains("Ash Slinger") and String(ui.enemy_label.text).contains("signal RELAYED"), "Battle roster should show the Ash Slinger relay state")
	var authoritative_before_inspection: String = JSON.stringify(ui.keep.serialize())
	ui._select_enemy_focus(0, "P11 Bell Guard UI test")
	await process_frame
	_check(String(ui.inspector_label.text).contains("Ash Slinger") and String(ui.inspector_label.text).contains("signal RELAYED") and String(ui.inspector_label.text).contains("contact step 3"), "Enemy inspection should expose the preserved signal timing")
	_check(String(ui.response_preview_label.text).contains("Bellkeepers"), "Response preview should name Bellkeepers as the authored counter")
	_check(JSON.stringify(ui.keep.serialize()) == authoritative_before_inspection, "Bell Guard inspection and UI refresh should not mutate authoritative state")

	await _resolve_wave(ui)
	ui._set_screen("results")
	ui._refresh_ui()
	await process_frame
	_check(not ui.keep.wave_active and ui.keep.wave_history.size() == 1, "Ash at the Bell teaching wave should resolve through the UI")
	_check(String(ui.scorecard_label.text).contains("Ash at the Bell") and String(ui.scorecard_label.text).contains("W1"), "Results should identify the Bell Guard scenario and resolved wave")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P11 Bell Guard UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
