extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	var before: String = JSON.stringify(ui.keep.serialize())
	var build_version: String = String(ProjectSettings.get_setting("application/config/version", ""))
	_check(ui.screen == "title", "playtest build should open on the title screen")
	_check(ui.build_identity_label != null and ui.build_identity_label.visible, "title should expose a visible build identity")
	_check(String(ui.build_identity_label.text).contains(build_version), "title build identity should match project metadata")
	_check(String(ui.build_identity_label.text).contains("PRE-ALPHA"), "title should preserve the pre-alpha release boundary")
	_check(String(ui.build_identity_label.text).contains("HUMAN PLAYTEST PENDING"), "title should not imply completed human playtesting")
	_check(JSON.stringify(ui.keep.serialize()) == before, "reading build identity should not mutate authoritative state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P16 playtest readiness UI: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
