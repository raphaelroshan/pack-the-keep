extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/Main.tscn")
	var ui: Control = scene.instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	var canvas: Control = ui.keep_canvas
	var before: String = JSON.stringify(ui.keep.serialize())
	for room_id in PackKeepState.ROOMS.keys():
		var room: Dictionary = PackKeepState.ROOMS[room_id]
		var origin: Vector2 = canvas.MAP_ORIGIN if String(room.get("floor", "ground")) == "ground" else canvas.UPPER_ORIGIN
		var box: Rect2 = canvas._placement_box_rect(String(room_id), origin)
		if box.size.x <= 0.0 or box.size.y <= 0.0:
			failures.append("placement box has no area: %s" % room_id)
		var map_rect := Rect2(origin, canvas.MAP_SIZE)
		if not map_rect.encloses(box):
			failures.append("placement box is outside its floor map: %s" % room_id)
		if canvas._placement_box_occupied(box, String(room.get("floor", "ground")), origin):
			failures.append("empty starting room is incorrectly marked occupied: %s" % room_id)
	if JSON.stringify(ui.keep.serialize()) != before:
		failures.append("placement-box inspection mutated authoritative state")
	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("Placement boxes smoke: PASS")
	else:
		for failure in failures:
			push_error(failure)
		printerr("Placement boxes smoke: FAIL (%d)" % failures.size())
	quit(0 if failures.is_empty() else 1)
