extends SceneTree

const CAPTURE_SIZE := Vector2i(1600, 900)

var output_dir: String = ""
var captured_files: Array[String] = []

func _initialize() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Vertical-slice capture requires a graphical renderer; remove --headless.")
		quit(2)
		return
	output_dir = _argument_value("--output-dir=")
	if output_dir.is_empty():
		output_dir = ProjectSettings.globalize_path("user://visual-captures")
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(output_dir)
	if directory_error != OK:
		push_error("Could not create capture directory: %s" % output_dir)
		quit(2)
		return
	call_deferred("_run_capture")

func _run_capture() -> void:
	root.size = CAPTURE_SIZE
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	await _capture("01_title", ui)
	ui._on_start_quick_playtest()
	await _capture("02_war_council", ui)
	ui._on_confirm_setup()
	await _capture("03_preparation", ui)
	ui._on_start_wave()
	await _capture("04_assault_phase_1", ui)
	await _resolve_phase(ui)
	await _capture("05_recovery_phase_1", ui)
	ui._on_finish_interval()
	await _capture("06_assault_phase_2", ui)
	await _resolve_phase(ui)
	await _capture("07_recovery_phase_2", ui)
	ui._on_finish_interval()
	await _capture("08_assault_phase_3", ui)
	await _resolve_phase(ui)
	await _capture("09_terminal_results", ui)
	_write_manifest()
	ui.queue_free()
	await process_frame
	print("Vertical-slice capture: PASS (%d screens at %s)" % [captured_files.size(), output_dir])
	quit(0)

func _resolve_phase(ui: Control) -> void:
	if not ui.assault_ready_reason.is_empty():
		ui._toggle_battle_pause()
	ui.battle_paused = true
	while ui.keep.wave_active:
		ui._on_advance_wave()
		await process_frame

func _capture(stem: String, ui: Control) -> void:
	await process_frame
	await process_frame
	var image: Image = root.get_texture().get_image()
	if image == null:
		push_error("No framebuffer available for %s" % stem)
		quit(2)
		return
	var filename: String = "%s.png" % stem
	var path: String = output_dir.path_join(filename)
	var save_error: Error = image.save_png(path)
	if save_error != OK:
		push_error("Could not save capture: %s" % path)
		quit(2)
		return
	captured_files.append(filename)
	print("Captured %s (%s)" % [filename, ui.screen])

func _write_manifest() -> void:
	var payload: Dictionary = {
		"schema_version": 1,
		"build_version": String(ProjectSettings.get_setting("application/config/version", "unknown")),
		"resolution": {"width": CAPTURE_SIZE.x, "height": CAPTURE_SIZE.y},
		"files": captured_files,
		"debug_ui": OS.get_cmdline_user_args().has("--debug-ui"),
		"human_evidence": false,
	}
	var file: FileAccess = FileAccess.open(output_dir.path_join("capture-manifest.json"), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload, "  "))
		file.close()

func _argument_value(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
