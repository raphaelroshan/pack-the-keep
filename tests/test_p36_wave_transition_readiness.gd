extends SceneTree

const TEST_SAVE := "user://pack_the_keep_p36_readiness_test.json"
const TEST_TEMP := "user://pack_the_keep_p36_readiness_test.json.tmp"
const TEST_BACKUP := "user://pack_the_keep_p36_readiness_test.json.bak"

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _configure_paths(ui: Control) -> void:
	ui.save_path = TEST_SAVE
	ui.save_temp_path = TEST_TEMP
	ui.save_backup_path = TEST_BACKUP
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false

func _remove_test_files() -> void:
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		return
	for path in [TEST_SAVE, TEST_TEMP, TEST_BACKUP]:
		if FileAccess.file_exists(path):
			directory.remove(path.get_file())

func _wave_fingerprint(ui: Control) -> Dictionary:
	return {
		"scenario_id": ui.keep.scenario_id,
		"wave_index": ui.keep.wave_index,
		"battle_step": ui.keep.battle_step,
		"battle_clock": ui.keep.battle_clock,
		"enemy_doctrine": ui.keep.enemy_doctrine,
		"enemies": ui.keep.enemies.duplicate(true),
		"pieces": ui.keep.pieces.duplicate(true),
		"rooms": ui.keep.rooms.duplicate(true),
		"materials": ui.keep.materials,
		"morale": ui.keep.morale
	}

func _normalized(value: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(value))

func _resolve_active_wave(ui: Control) -> void:
	if not ui.assault_ready_reason.is_empty():
		ui._on_playtest_primary_action()
	if not ui.battle_paused:
		ui._toggle_battle_pause()
	var guard: int = 0
	while ui.keep.wave_active and guard < 12:
		ui._on_advance_wave()
		guard += 1
	_check(guard < 12, "authored phase should resolve inside the deterministic guard")

func _initialize() -> void:
	_remove_test_files()
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	_configure_paths(ui)
	ui._on_start_custom_setup()
	ui._on_confirm_setup()
	ui._on_recommended_layout()
	ui._on_start_wave()
	await process_frame

	_check(ui.screen == "battle" and ui.keep.wave_active and ui.keep.battle_step == 0, "entering the assault should create the authoritative first phase at tick zero")
	_check(ui.battle_paused and String(ui.assault_ready_reason).contains("READY") and String(ui.playtest_button.text).contains("SOUND THE BELL"), "phase one should expose an explicit focused ready beat")
	_check(ui.manual_step_button.disabled, "manual stepping should remain blocked until readiness is acknowledged")
	var ready_state: String = JSON.stringify(ui.keep.serialize())
	var ready_fingerprint: Variant = _normalized(_wave_fingerprint(ui))
	ui._process(3.0)
	ui._on_advance_wave()
	_check(JSON.stringify(ui.keep.serialize()) == ready_state and ui.keep.battle_step == 0 and is_zero_approx(ui.keep.battle_clock), "waiting and blocked manual input in readiness should not advance simulation")

	ui._set_battle_speed(0)
	ui._set_battle_speed(2)
	_check(JSON.stringify(ui.keep.serialize()) == ready_state, "changing presentation speed during readiness should not mutate the run")
	ui._on_save()
	var restored: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(restored)
	await process_frame
	await process_frame
	_configure_paths(restored)
	restored._on_continue_saved_run()
	await process_frame
	_check(restored.screen == "battle" and restored.battle_paused and not restored.assault_ready_reason.is_empty(), "loading an active tick-zero save should reconstruct readiness")
	_check(_normalized(_wave_fingerprint(restored)) == ready_fingerprint, "readiness save/load should restore the exact authoritative wave without new save fields")

	var same_pressure: Dictionary = ui._pressure_readiness_context("gate_assault", "gate_assault", ["raider"], ["raider", "raider"])
	_check(not bool(same_pressure.get("required", true)), "an unchanged doctrine and enemy family should be allowed to continue live")
	var new_family: Dictionary = ui._pressure_readiness_context("gate_assault", "gate_assault", ["raider"], ["raider", "sapper"])
	_check(bool(new_family.get("required", false)) and new_family.get("new_enemy_ids", []).has("sapper"), "a newly introduced enemy family should require a readable warning")
	var doctrine_shift: Dictionary = ui._pressure_readiness_context("gate_assault", "distributed_sabotage", ["raider"], ["raider"])
	_check(bool(doctrine_shift.get("required", false)) and bool(doctrine_shift.get("doctrine_changed", false)), "a doctrine change should require readiness even with a familiar roster")

	ui._on_playtest_primary_action()
	_check(not ui.battle_paused and ui.assault_ready_reason.is_empty(), "sounding the bell should release continuous combat through the existing pause path")
	_resolve_active_wave(ui)
	_check(ui.screen == "results" and ui.keep.repair_interval_active, "phase one should still resolve into the authored recovery lull")
	ui._on_finish_interval()
	await process_frame
	_check(ui.keep.wave_index == 2 and ui.keep.wave_active and ui.battle_paused and String(ui.assault_ready_reason).contains("NEW PRESSURE"), "Gatehouse phase two should pause for its changed doctrine and new Sapper family")
	_check(ui.keep.battle_step == 0 and int(ui.keep.combat_metrics.get("enemy_attacks", 0)) == 0 and int(ui.keep.combat_metrics.get("unit_attacks", 0)) == 0, "phase-two readiness should occur before any authoritative combat exchange")

	ui.queue_free()
	restored.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P36 wave transition readiness: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
