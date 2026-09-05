extends SceneTree

const Snapshot = preload("res://src/ui/battle_presentation_snapshot.gd")

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

	var before: String = JSON.stringify(ui.keep.serialize())
	var first: Dictionary = Snapshot.build(ui.keep, ui.battle_paused, ui.assault_ready_reason, ui.focused_enemy_index, ui._battle_speed())
	var second: Dictionary = Snapshot.build(ui.keep, ui.battle_paused, ui.assault_ready_reason, ui.focused_enemy_index, ui._battle_speed())
	_check(JSON.stringify(first) == JSON.stringify(second), "same battle state should produce the same presentation snapshot")
	_check(JSON.stringify(ui.keep.serialize()) == before, "snapshot construction should not mutate authoritative battle state")
	_check(first.ready and first.paused and not first.manual_step_enabled, "tick-zero readiness should project a paused state with manual step blocked")
	_check(String(first.pause_text).contains("Sound the bell") and String(first.state_text).contains("PHASE 1/3"), "snapshot should expose the current primary action and phase")
	_check(bool(first.focus.active) and String(first.focus.name).contains("Raider"), "snapshot should expose the focused threat identity")
	_check(String(first.response_text).contains("TARGET") and String(first.response_text).contains("Pike Squad"), "snapshot should include target and counter response evidence")
	_check(String(first.focus_card.target_route).contains("TARGET —") and String(first.focus_card.timing).contains("STRIKE —") and String(first.focus_card.response).contains("DEFENSE —"), "snapshot should expose compact target, timing, and committed-response fields")
	_check(String(first.focus_card.counter).contains("COUNTER — Pike Squad") and String(first.focus_card.action).begins_with("FORECAST —"), "snapshot should expose the visible counter and readiness action")
	_check(bool(first.ability.ready) and String(first.ability.status) == "READY", "snapshot should expose commander intervention availability")

	ui._refresh_battle_presentation()
	_check(String(ui.battle_state_label.text) == String(first.compact_state_text), "board-first battle state should render the compact snapshot projection")
	_check(String(ui.response_preview_label.text) == String(first.response_text), "response control should render directly from the snapshot")
	_check(String(ui.commander_ability_button.text).contains(String(first.ability.status)), "commander control should render snapshot availability")

	var no_focus: Dictionary = Snapshot.build(ui.keep, true, ui.assault_ready_reason, -1, 1.0)
	_check(not bool(no_focus.focus.active) and String(no_focus.response_text).contains("fallback list"), "no-focus state should provide a clear map-first fallback instruction")
	ui._toggle_battle_pause()
	var live: Dictionary = Snapshot.build(ui.keep, ui.battle_paused, ui.assault_ready_reason, ui.focused_enemy_index, ui._battle_speed())
	_check(not live.paused and not live.ready and String(live.state_text).contains("LIVE 1.0x"), "sounding the bell should project live state without advancing a combat tick")
	_check(JSON.stringify(ui.keep.serialize()) == before, "presentation pause/readiness changes should not alter serialized keep state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P44 battle presentation snapshot: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
