extends SceneTree

const BoardVisuals = preload("res://src/ui/board_visual_registry.gd")

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
	ui._select_option_metadata(ui.scenario_option, "the_cut_standard")
	ui._on_select_scenario()
	ui._refresh_ui()
	await process_frame
	var preview: String = String(ui.scenario_preview_label.text)
	_check(preview.contains("The Cut Standard"), "Preparation should expose the K6 authored scenario")
	_check(preview.contains("Crossbow Watch") and preview.contains("Fallback Convoy"), "scenario briefing should expose both viable answers")
	ui.keep.open_pack("crossbow_watch")
	ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	ui.keep.place_piece("crossbow_patrol", Vector2i(1, 1), "upper")
	ui.keep.place_piece("watch_banner", Vector2i(4, 1), "upper")
	ui.keep.start_wave("cut_the_chain")
	ui._set_screen("battle")
	ui._refresh_ui()
	ui._select_enemy_focus(0, "K6 Standard Cutter UI test")
	await process_frame
	_check(String(ui.enemy_label.text).contains("Standard Cutter"), "Battle roster should name the new enemy family")
	_check(String(ui.enemy_label.text).contains("assigned HUNTER"), "Battle roster should state the Cutter's assigned-specialist priority")
	_check(String(ui.response_preview_label.text).contains("COUNTERS: Crossbow Patrol"), "focused Battle response should expose the direct counter")
	_check(String(ui.inspector_label.text).contains("hunts assigned specialists first"), "threat inspector should explain the Cutter's target rule")
	var profile: Dictionary = BoardVisuals.enemy_profile("standard_cutter", "melee")
	_check(String(profile.get("shape", "")) == "standard" and String(profile.get("initial", "")) == "T", "board grammar should give the Cutter a distinct standard silhouette")
	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	root.size = Vector2i(1280, 720)
	ui.ui_scale_index = 3
	ui._apply_ui_scale()
	ui._toggle_contrast()
	ui._toggle_reduced_motion()
	await process_frame
	await process_frame
	_check(ui.gameplay_columns.vertical and ui.pause_button.is_visible_in_tree(), "K6 Battle should retain its primary control in the large-text stacked layout")
	_check(String(ui.response_preview_label.text).contains("Standard Cutter"), "K6 focused threat explanation should survive accessibility changes")
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "K6 accessibility and responsive presentation must not mutate authoritative state")
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("K6 Standard Cutter UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
