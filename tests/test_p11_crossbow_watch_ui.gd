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

	ui._select_option_metadata(ui.scenario_option, "red_banner_road")
	ui._on_select_scenario()
	ui._select_option_metadata(ui.pack_option, "crossbow_watch")
	ui._refresh_pack_preview()
	_check(String(ui.scenario_preview_label.text).contains("Red Banner Road"), "Preparation should expose the Red Banner Road scenario")
	_check(String(ui.pack_preview_label.text).contains("Crossbow Watch") and String(ui.pack_preview_label.text).contains("Crossbow Patrol") and String(ui.pack_preview_label.text).contains("Watch Banner"), "Preparation should explain the complete Crossbow Watch pack")

	ui._on_open_pack()
	_check(String(ui.availability_label.text).contains("Crossbow Patrol") and String(ui.availability_label.text).contains("Watch Banner"), "Opening Crossbow Watch should expose both pieces")
	_check(bool(ui.keep.place_piece("crossbow_patrol", Vector2i(1, 1), "upper").get("ok", false)), "UI fixture should place Crossbow Patrol on the upper wall")
	_check(bool(ui.keep.place_piece("watch_banner", Vector2i(4, 1), "upper").get("ok", false)), "UI fixture should place Watch Banner near the patrol")
	_check(bool(ui.keep.start_wave("shielded_advance").get("ok", false)), "UI fixture should start Shielded Advance")
	ui._set_screen("battle")
	ui._refresh_ui()
	await process_frame

	_check(String(ui.forecast_label.text).contains("Shielded Advance"), "Battle forecast should name Shielded Advance")
	_check(String(ui.enemy_label.text).contains("Shield Guard") and String(ui.enemy_label.text).contains("armor 2"), "Battle roster should show Shield Guard and its armor")
	var ranged_traces: Array[Dictionary] = ui._next_engagement_traces()
	_check(not ranged_traces.is_empty() and String(ranged_traces[0].get("style", "")) == "ranged" and String(ranged_traces[0].get("piece_id", "")) == "crossbow_patrol", "Crossbow Patrol response should expose ranged projectile presentation metadata")
	var authoritative_before_inspection: String = JSON.stringify(ui.keep.serialize())
	ui._select_enemy_focus(0, "P11 UI test")
	await process_frame
	_check(String(ui.inspector_label.text).contains("Shield Guard") and String(ui.inspector_label.text).contains("armor 2"), "Enemy inspection should expose Shield Guard armor")
	_check(String(ui.inspector_label.text).contains("Crossbow Patrol") and not String(ui.inspector_label.text).contains("crossbow_patrol") and String(ui.response_preview_label.text).contains("Crossbow Patrol"), "Enemy inspection and response preview should name the authored precision counter without exposing its internal ID")
	_check(JSON.stringify(ui.keep.serialize()) == authoritative_before_inspection, "Enemy focus and P11 UI refresh should not mutate authoritative state")

	await _resolve_wave(ui)
	ui._set_screen("results")
	ui._refresh_ui()
	await process_frame
	_check(not ui.keep.wave_active and ui.keep.wave_history.size() == 1, "Red Banner Road teaching wave should resolve through the UI")
	_check(String(ui.scorecard_label.text).contains("Red Banner Road") and String(ui.scorecard_label.text).contains("PHASE 1"), "Results should identify the P11 scenario and resolved assault phase")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P11 Crossbow Watch UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
