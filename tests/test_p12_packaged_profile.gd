extends SceneTree

const PackagedSmoke = preload("res://src/platform/packaged_smoke.gd")
const TEST_SAVE := "user://pack_the_keep_p12_profile_probe.save"
const TEST_SAVE_TEMP := "user://pack_the_keep_p12_profile_probe.save.tmp"
const TEST_SAVE_BACKUP := "user://pack_the_keep_p12_profile_probe.save.bak"
const TEST_SETTINGS := "user://pack_the_keep_p12_profile_probe.settings.json"
const TEST_SETTINGS_TEMP := "user://pack_the_keep_p12_profile_probe.settings.json.tmp"
const TEST_SETTINGS_BACKUP := "user://pack_the_keep_p12_profile_probe.settings.json.bak"

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _remove_test_files() -> void:
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		return
	for path in [TEST_SAVE, TEST_SAVE_TEMP, TEST_SAVE_BACKUP, TEST_SETTINGS, TEST_SETTINGS_TEMP, TEST_SETTINGS_BACKUP]:
		if FileAccess.file_exists(path):
			directory.remove(path.get_file())

func _write_test_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	_check(file != null, "profile probe fixture should be writable: %s" % path)
	if file != null:
		file.store_string("{}")
		file.close()

func _initialize() -> void:
	_remove_test_files()
	var harness: Node = PackagedSmoke.new()
	var save_paths: Array = [TEST_SAVE, TEST_SAVE_TEMP, TEST_SAVE_BACKUP]
	var settings_paths: Array = [TEST_SETTINGS, TEST_SETTINGS_TEMP, TEST_SETTINGS_BACKUP]
	var empty_status: Dictionary = harness._profile_file_status(save_paths, settings_paths)
	_check(not bool(empty_status.present) and not bool(empty_status.complete), "empty profile should be clean and incomplete")

	_write_test_file(TEST_SAVE_BACKUP)
	var stranded_status: Dictionary = harness._profile_file_status(save_paths, settings_paths)
	_check(bool(stranded_status.present) and not bool(stranded_status.complete), "one stranded backup should make the profile non-clean but incomplete")

	_write_test_file(TEST_SAVE)
	_write_test_file(TEST_SETTINGS)
	var complete_status: Dictionary = harness._profile_file_status(save_paths, settings_paths)
	_check(bool(complete_status.present) and bool(complete_status.complete), "both primary files should make the profile complete")

	harness.free()
	_remove_test_files()
	if failures.is_empty():
		print("P12 packaged profile detection: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
