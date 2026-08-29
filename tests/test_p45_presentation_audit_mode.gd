extends SceneTree

const AuditOverlay = preload("res://src/ui/presentation_audit_overlay.gd")

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
	_check(not ui.developer_ui_enabled and ui.presentation_audit_overlay == null, "normal launch should not instantiate presentation audit chrome")
	var before: String = JSON.stringify(ui.keep.serialize())

	var in_bounds: Button = Button.new()
	in_bounds.name = "PrimaryAction"
	in_bounds.text = "Begin"
	in_bounds.position = Vector2(10, 10)
	in_bounds.size = Vector2(80, 30)
	ui.add_child(in_bounds)
	var clipped: Control = Control.new()
	clipped.position = Vector2(190, 80)
	clipped.size = Vector2(30, 30)
	ui.add_child(clipped)
	var overlay: PresentationAuditOverlay = AuditOverlay.new()
	ui.add_child(overlay)
	overlay.configure({"primary_action": in_bounds, "clipped_region": clipped}, "battle")
	in_bounds.grab_focus()
	await process_frame
	var snapshot: Dictionary = overlay.audit_snapshot(Rect2(0, 0, 200, 100))
	_check(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE and overlay.focus_mode == Control.FOCUS_NONE, "audit overlay should never intercept mouse or keyboard focus")
	_check(String(snapshot.screen) == "battle" and int(snapshot.visible_region_count) == 2, "audit snapshot should identify screen and visible tracked regions")
	_check(int(snapshot.clipped_region_count) == 1, "audit snapshot should report regions outside the supplied viewport")
	_check(String(snapshot.focus).contains("PrimaryAction") and String(snapshot.focus).contains("Begin"), "audit snapshot should name the active focus control and button text")
	_check(JSON.stringify(ui.keep.serialize()) == before, "audit inspection should not mutate authoritative keep state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P45 presentation audit mode: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
