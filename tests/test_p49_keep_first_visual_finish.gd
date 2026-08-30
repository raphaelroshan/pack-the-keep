extends SceneTree

const BoardVisuals = preload("res://src/ui/board_visual_registry.gd")

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
	ui._on_start_quick_playtest()
	ui._on_confirm_setup()
	await process_frame
	await process_frame

	var serialized_before: String = JSON.stringify(ui.keep.serialize())
	var board: Dictionary = ui.keep_canvas.board_presentation_snapshot()
	var finish: Dictionary = board.get("surface_finish", {})
	var ground_finish: Dictionary = finish.get("ground", {})
	var upper_finish: Dictionary = finish.get("upper", {})
	_check(bool(finish.get("texture_assigned", false)), "P49 should assign the existing authored Greywatch texture to the keep canvas")
	_check(bool(ground_finish.get("authored", false)) and bool(upper_finish.get("authored", false)), "both Greywatch floors should use the authored surface treatment")
	_check(String(ground_finish.get("material", "")) == "stone_work_yard", "the Greywatch ground floor should identify its stone work-yard material")
	_check(String(upper_finish.get("material", "")) == "timber_wall_walk", "the Greywatch upper floor should identify its timber wall-walk material")
	_check(ground_finish.get("source_region", Rect2()) != upper_finish.get("source_region", Rect2()), "ground and upper floors should sample distinct authored source regions")
	_check(board.get("cell_size", Vector2.ZERO) == Vector2(28.0, 34.0) and board.get("canvas_size", Vector2.ZERO) == Vector2(800.0, 382.0), "P49 must preserve exact board geometry")

	ui._on_map_clicked("ground", Vector2i(1, 3))
	await process_frame
	var room_subject: Dictionary = ui.keep_canvas.selected_subject_snapshot()
	_check(String(room_subject.get("kind", "")) == "room" and String(room_subject.get("id", "")) == "gate", "clicking the Gate should project the selected room onto the board")
	_check(String(room_subject.get("name", "")) == "Gate" and String(room_subject.get("condition", "")).contains("100%"), "the selected room plate should expose identity and condition")
	_check(not String(room_subject.get("purpose", "")).is_empty() and not String(room_subject.get("next_action", "")).is_empty(), "the selected room plate should expose purpose and next action")

	ui._on_map_clicked("ground", Vector2i(4, 5))
	await process_frame
	var piece_subject: Dictionary = ui.keep_canvas.selected_subject_snapshot()
	_check(String(piece_subject.get("kind", "")) == "piece" and String(piece_subject.get("name", "")) == "Pike Squad", "clicking a defender should project that defender onto the board")
	_check(String(piece_subject.get("condition", "")).contains("READY") and not String(piece_subject.get("next_action", "")).is_empty(), "the selected defender plate should expose readiness and next action")

	var normal_opacity: float = float(ground_finish.get("texture_opacity", 0.0))
	var normal_selection_width: float = float(ground_finish.get("selection_width", 0.0))
	ui._toggle_contrast()
	var contrast_finish: Dictionary = ui.keep_canvas.board_presentation_snapshot().get("surface_finish", {}).get("ground", {})
	_check(float(contrast_finish.get("texture_opacity", 1.0)) < normal_opacity, "high contrast should reduce authored texture noise")
	_check(float(contrast_finish.get("selection_width", 0.0)) > normal_selection_width, "high contrast should strengthen selected-subject outlines")

	var ash_finish: Dictionary = BoardVisuals.surface_finish_profile("ash_ford_redoubt", "ground", false)
	_check(not bool(ash_finish.get("authored", true)) and String(ash_finish.get("material", "")) == "terrain_fallback", "Ash Ford should retain its existing river fallback until its own authored slice")

	ui.keep_canvas.queue_redraw()
	await process_frame
	_check(JSON.stringify(ui.keep.serialize()) == serialized_before, "authored surfaces, selection projection, and accessibility changes must not mutate authoritative state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P49 keep-first visual finish: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
