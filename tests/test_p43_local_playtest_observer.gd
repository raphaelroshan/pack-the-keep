extends SceneTree

const Observer = preload("res://src/ui/local_playtest_observer.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var observer: LocalPlaytestObserver = Observer.new()
	observer.advance(5.0)
	observer.record_action("ignored")
	_check(not observer.started and observer.snapshot().screen_durations_seconds.is_empty(), "observation should collect nothing before explicit opt-in")
	observer.set_enabled(true, "title")
	observer.advance(1.25)
	observer.record_action("primary_action", {"primary_path": "title"})
	observer.record_action("pause_toggle")
	observer.record_action("focus_threat")
	observer.record_action("recovery_choice", {"recovery_choice": "repair_room"})
	observer.record_screen("battle")
	observer.advance(2.5)
	observer.record_result("held")
	var snapshot: Dictionary = observer.snapshot()
	_check(snapshot.local_only and not snapshot.human_evidence, "snapshot should explicitly declare local-only non-human evidence")
	_check(is_equal_approx(float(snapshot.screen_durations_seconds.title), 1.25) and is_equal_approx(float(snapshot.screen_durations_seconds.battle), 2.5), "screen duration should be driven only by supplied frame time")
	_check(String(snapshot.first_action) == "primary_action" and int(snapshot.pause_count) == 1 and int(snapshot.focus_count) == 1, "observer should retain first action and coarse battle counts")
	_check(int(snapshot.primary_action_paths.title) == 1 and int(snapshot.recovery_choices.repair_room) == 1 and String(snapshot.result_type) == "held", "observer should retain primary path, recovery choice, and result")
	snapshot.action_counts["primary_action"] = 99
	_check(int(observer.snapshot().action_counts.primary_action) == 1, "snapshot dictionaries should not mutate observer state")

	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui.local_metrics_path = "user://p43_local_observation_test.json"
	var before_toggle: String = JSON.stringify(ui.keep.serialize())
	_check(not ui.local_playtest_observer.enabled and ui.local_metrics_export_button.disabled, "runtime observation should begin off with export disabled")
	ui.local_metrics_button.pressed.emit()
	_check(ui.local_playtest_observer.enabled and String(ui.local_metrics_status_label.text).contains("NEVER UPLOADED"), "Settings should expose explicit local-only opt-in state")
	_check(JSON.stringify(ui.keep.serialize()) == before_toggle, "enabling observation should not mutate authoritative run state")
	ui._process(0.75)
	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	ui._on_start_wave()
	ui._on_playtest_primary_action()
	ui.battle_paused = true
	ui._select_enemy_focus(0, "test")
	ui.local_metrics_button.pressed.emit()
	ui._refresh_ui()
	_check(not ui.local_playtest_observer.enabled and not ui.local_metrics_export_button.disabled, "disabling should pause collection while preserving an exportable snapshot")
	ui.local_metrics_export_button.pressed.emit()
	_check(FileAccess.file_exists(ui.local_metrics_path), "explicit export should create one local JSON file")
	if FileAccess.file_exists(ui.local_metrics_path):
		var exported: Variant = JSON.parse_string(FileAccess.get_file_as_string(ui.local_metrics_path))
		_check(exported is Dictionary and bool(exported.get("local_only", false)) and not bool(exported.get("human_evidence", true)), "export should retain privacy and evidence-boundary markers")
		_check(String(exported.get("context", {}).get("build_version", "")).contains("local-playtest-observer"), "export should identify the exact build")
		DirAccess.open("user://").remove(ui.local_metrics_path.get_file())

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P43 local playtest observer: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
