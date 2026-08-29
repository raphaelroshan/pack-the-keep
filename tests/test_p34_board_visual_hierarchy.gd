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
	ui.preferences_persistence_enabled = false
	ui.display_application_enabled = false
	ui._on_start_custom_setup()
	ui._on_confirm_setup()
	ui._on_recommended_layout()
	await process_frame

	var before: String = JSON.stringify(ui.keep.serialize())
	var board: Dictionary = ui.keep_canvas.board_presentation_snapshot()
	var layers: Array = board.get("layers", [])
	_check(layers == ["background_atmosphere", "structural_board", "room_surfaces", "placement_zones", "defender_actors", "enemy_routes_and_actors", "damage_and_status", "focus_and_selection", "tactical_labels"], "board should expose the intended structural-to-tactical layer order")
	_check(not bool(board.get("grid_visible", true)), "board hierarchy should preserve the gridless normal presentation")
	_check(String(board.get("ground", {}).get("pattern", "")) == "stone", "Greywatch ground floor should use the stone fortress treatment")
	_check(String(board.get("upper", {}).get("pattern", "")) == "wall_walk", "upper floor should use the distinct wall-walk treatment")
	_check(board.get("ground", {}).get("surface", Color.BLACK) != board.get("upper", {}).get("surface", Color.BLACK), "ground and upper surfaces should not collapse into one treatment")

	var pike: Dictionary = ui.keep_canvas.actor_visual_snapshot("pike_squad", "raider")
	var repair: Dictionary = ui.keep_canvas.actor_visual_snapshot("repair_station", "sapper")
	var gate: Dictionary = ui.keep_canvas.actor_visual_snapshot("narrow_gate", "climber")
	_check(String(pike.piece.get("shape", "")) == "shield", "formation defenders should use a shield silhouette family")
	_check(String(repair.piece.get("shape", "")) == "cross", "support defenders should use a support-cross silhouette family")
	_check(String(gate.piece.get("shape", "")) == "barrier", "fortification pieces should use a barrier silhouette family")

	var enemy_shapes: Dictionary = board.get("enemy_shapes", {})
	var unique_shapes: Dictionary = {}
	for shape in enemy_shapes.values():
		unique_shapes[String(shape)] = true
	_check(unique_shapes.size() == 4, "Raider, Sapper, Climber, and Siege Beast should have distinct silhouettes")
	var beast: Dictionary = ui.keep_canvas.actor_visual_snapshot("pike_squad", "siege_beast")
	_check(String(beast.enemy.get("shape", "")) == "hex" and float(beast.enemy.get("scale", 1.0)) > 1.0, "Siege Beast should reserve the largest heavy silhouette")

	ui.keep_canvas.queue_redraw()
	await process_frame
	_check(JSON.stringify(ui.keep.serialize()) == before, "board profile inspection and rendering should not mutate authoritative state")
	ui._toggle_contrast()
	var contrast_board: Dictionary = ui.keep_canvas.board_presentation_snapshot()
	_check(contrast_board.get("ground", {}).get("frame", Color.BLACK) != board.get("ground", {}).get("frame", Color.BLACK), "high contrast should strengthen the board frame without changing geometry")
	_check(contrast_board.get("cell_size", Vector2.ZERO) == board.get("cell_size", Vector2.ONE), "accessibility treatment should preserve board geometry")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P34 board visual hierarchy: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
