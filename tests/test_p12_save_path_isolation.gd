extends SceneTree

const TEST_SAVE := "user://pack_the_keep_p12_isolation.save"
const TEST_TEMP := "user://pack_the_keep_p12_isolation.save.tmp"
const TEST_BACKUP := "user://pack_the_keep_p12_isolation.save.bak"

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _remove_test_files() -> void:
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		return
	for path in [TEST_SAVE, TEST_TEMP, TEST_BACKUP]:
		if FileAccess.file_exists(path):
			directory.remove(path.get_file())

func _initialize() -> void:
	_remove_test_files()
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui.save_path = TEST_SAVE
	ui.save_temp_path = TEST_TEMP
	ui.save_backup_path = TEST_BACKUP
	ui.keep.place_piece("pike_squad", Vector2i(0, 3), "ground")
	ui._on_save()
	_check(FileAccess.file_exists(TEST_SAVE), "custom save path should receive the atomic run save")
	_check(not FileAccess.file_exists(TEST_TEMP) and not FileAccess.file_exists(TEST_BACKUP), "successful custom save should leave no temporary or backup file")
	var payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE))
	_check(payload is Dictionary and String(payload.get("game_id", "")) == "pack-the-keep", "custom save path should contain a valid Pack the Keep payload")

	ui.keep.reset_run(99)
	ui._on_load()
	_check(ui.keep.seed == 3307 and ui.keep.pieces.has("pike_squad_0"), "custom load path should restore the saved authoritative run")
	ui._on_save()
	_check(not FileAccess.file_exists(TEST_BACKUP), "atomic replacement at a custom path should remove its recovery backup")

	ui.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P12 save path isolation: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
