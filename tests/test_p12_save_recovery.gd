extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")
const TEST_SAVE := "user://pack_the_keep_p12_recovery.save"
const TEST_TEMP := "user://pack_the_keep_p12_recovery.save.tmp"
const TEST_BACKUP := "user://pack_the_keep_p12_recovery.save.bak"

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

func _write(path: String, value: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value)
	file.close()

func _saved_state(seed: int) -> Dictionary:
	var state: PackKeepState = PackKeepState.new(seed)
	state.place_piece("pike_squad", Vector2i(0, 3), "ground")
	return state.serialize()

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

	_write(TEST_SAVE, "{truncated")
	_write(TEST_BACKUP, JSON.stringify(_saved_state(4401)))
	ui._on_load()
	_check(ui.keep.seed == 4401 and ui.keep.pieces.has("pike_squad_0"), "malformed primary should recover the valid backup")
	_check(String(ui.event_label.text).contains("from backup"), "backup recovery should be explicit")

	_remove_test_files()
	_write(TEST_BACKUP, JSON.stringify(_saved_state(4402)))
	ui.keep.reset_run(99)
	ui._on_load()
	_check(ui.keep.seed == 4402, "missing primary should recover a crash-stranded backup")

	var before_rejection: String = JSON.stringify(ui.keep.serialize())
	_write(TEST_SAVE, "[]")
	_write(TEST_BACKUP, "{bad")
	ui._on_load()
	_check(JSON.stringify(ui.keep.serialize()) == before_rejection, "two invalid save candidates should not mutate the live run")
	_check(String(ui.event_label.text).contains("current run is unchanged"), "double rejection should explain state preservation")

	var legacy: Dictionary = _saved_state(4403)
	legacy.schema_version = 3
	legacy.erase("unlocked_modifier_ids")
	legacy.erase("equipped_modifier_id")
	_write(TEST_SAVE, JSON.stringify(legacy))
	_remove_backup_only()
	ui._on_load()
	_check(ui.keep.seed == 4403 and String(ui.event_label.text).contains("legacy migration"), "legacy primary should retain migration reporting")

	ui.queue_free()
	await process_frame
	_remove_test_files()
	if failures.is_empty():
		print("P12 malformed save recovery: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _remove_backup_only() -> void:
	var directory: DirAccess = DirAccess.open("user://")
	if directory != null and FileAccess.file_exists(TEST_BACKUP):
		directory.remove(TEST_BACKUP.get_file())
