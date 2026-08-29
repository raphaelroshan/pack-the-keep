extends SceneTree

const TEST_TUTORIAL := "user://pack_the_keep_p31_tutorial_test.save"
const TEST_TEMP := "user://pack_the_keep_p31_tutorial_test.save.tmp"
const TEST_BACKUP := "user://pack_the_keep_p31_tutorial_test.save.bak"

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _remove_test_files() -> void:
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		return
	for path in [TEST_TUTORIAL, TEST_TEMP, TEST_BACKUP]:
		if FileAccess.file_exists(path):
			directory.remove(path.get_file())

func _configure_test_paths(ui: Control) -> void:
	ui.tutorial_path = TEST_TUTORIAL
	ui.tutorial_temp_path = TEST_TEMP
	ui.tutorial_backup_path = TEST_BACKUP
	ui.preferences_persistence_enabled = true
	ui.display_application_enabled = false

func _advance_to_first_assault(ui: Control) -> void:
	ui._start_tutorial()
	ui._on_tutorial_continue()
	ui._on_tutorial_continue()
	ui._on_tutorial_continue()
	ui._on_confirm_setup()
	var gate: Dictionary = ui.keep.room_definition("gate")
	ui._on_map_clicked(String(gate.get("floor", "ground")), gate.get("origin", Vector2i.ZERO))
	ui._on_open_pack()
	ui._on_map_clicked("ground", Vector2i(0, 3))
	ui._on_map_clicked("ground", Vector2i(2, 5))
	ui._on_map_clicked("ground", Vector2i(0, 3))
	ui._on_tutorial_continue()
	ui._on_playtest_primary_action()
	for index in range(ui.keep.enemies.size()):
		if String(ui.keep.enemies[index].get("enemy_id", "")) == "raider":
			ui._select_enemy_focus(index, "tutorial resilience test")
			break
	ui._on_playtest_primary_action()

func _initialize() -> void:
	_remove_test_files()
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	_configure_test_paths(ui)

	ui._start_tutorial()
	var state_before_blocked_command: String = JSON.stringify(ui.keep.serialize())
	ui._on_confirm_setup()
	_check(ui.tutorial.current_id() == "intro_keep", "strict tutorial should reject commands outside the current objective")
	_check(JSON.stringify(ui.keep.serialize()) == state_before_blocked_command, "a rejected tutorial command should not mutate the keep")
	ui._on_tutorial_continue()
	_check(FileAccess.file_exists(TEST_TUTORIAL), "tutorial progress should persist independently from run saves")

	var resumed: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(resumed)
	await process_frame
	await process_frame
	_configure_test_paths(resumed)
	resumed._continue_tutorial()
	_check(resumed.tutorial.active and resumed.tutorial.current_id() == "intro_resources", "Continue Tutorial should restore the latest valid lesson")
	resumed.queue_free()
	await process_frame

	_advance_to_first_assault(ui)
	_check(ui.tutorial.current_id() == "observe_first" and String(ui.tutorial_checkpoint.get("step_id", "")) == "inspect_raider", "first assault should retain its analysis checkpoint while combat runs")
	var checkpoint_state: String = JSON.stringify(ui.tutorial_checkpoint.get("keep_state", {}))
	ui.keep.morale = 0
	ui.tutorial.sync_wave_result(1, "collapse")
	ui._prepare_tutorial_step(false)
	_check(ui.tutorial.failure_active and String(ui.tutorial_continue_button.text) == "Retry Phase", "collapse should expose a clear checkpoint retry")
	ui._on_tutorial_continue()
	_check(not ui.tutorial.failure_active and ui.tutorial.current_id() == "inspect_raider", "retry should restore the failed phase lesson")
	_check(JSON.stringify(ui.keep.serialize()) == checkpoint_state, "retry should restore the authoritative keep checkpoint exactly")

	ui._skip_tutorial()
	_check(not ui.tutorial.active and ui.tutorial_dismissed and not ui.tutorial_completed, "skip should dismiss without falsely completing First Watch")
	_check(ui.screen == "setup" and not FileAccess.file_exists(TEST_TUTORIAL), "skip should enter Skirmish and remove resumable tutorial progress")

	ui.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P31 tutorial resilience: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
