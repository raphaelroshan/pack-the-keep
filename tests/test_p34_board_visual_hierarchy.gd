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
	_check(String(board.get("placement_guide_style", "")) == "outline_only", "placement guides should not compete with room-function labels")
	_check(String(board.get("ground", {}).get("pattern", "")) == "stone", "Greywatch ground floor should use the stone fortress treatment")
	_check(String(board.get("upper", {}).get("pattern", "")) == "wall_walk", "upper floor should use the distinct wall-walk treatment")
	_check(board.get("ground", {}).get("surface", Color.BLACK) != board.get("upper", {}).get("surface", Color.BLACK), "ground and upper surfaces should not collapse into one treatment")
	for room_id_value in ui.keep.room_definitions().keys():
		var room_id: String = String(room_id_value)
		var room_label: Dictionary = ui.keep_canvas.room_label_snapshot(room_id)
		_check(bool(room_label.get("fits", false)), "%s should fit its stable board label without accidental truncation" % room_id)
	_check(String(ui.keep_canvas.room_label_snapshot("supply_room").get("text", "")) == "Supply", "Supply Room should use a purposeful compact board label")
	_check(String(ui.keep_canvas.room_label_snapshot("north_tower").get("text", "")) == "Tower", "North Tower should use a purposeful compact board label")
	_check(String(ui.keep_canvas.room_label_snapshot("workshop").get("text", "")) == "Workshop", "Workshop should remain unabridged through font fitting")
	_check(String(ui.keep_canvas.room_label_snapshot("barracks").get("text", "")) == "Barracks", "Barracks should remain unabridged through font fitting")
	_check(BoardVisualRegistry.room_display_label("ash_ford_redoubt", "supply_room", "Grain Store") == "Grain", "Ash Ford should retain a keep-specific Grain label")
	_check(BoardVisualRegistry.room_display_label("ash_ford_redoubt", "north_tower", "Signal Mast") == "Signal", "Ash Ford should retain a keep-specific Signal label")
	_check(BoardVisualRegistry.room_display_label("twinwatch_bastion", "supply_room", "Central Magazine") == "Magazine", "Twinwatch should retain a keep-specific Magazine label")
	_check(BoardVisualRegistry.room_display_label("twinwatch_bastion", "armory", "East Arsenal") == "East Post", "Twinwatch should retain a keep-specific eastern-post label")
	var label_ui: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(label_ui)
	await process_frame
	label_ui.preferences_persistence_enabled = false
	label_ui.display_application_enabled = false
	for scenario_id in ["gatehouse_lock", "ash_ford_crossing", "the_divided_bell"]:
		_check(bool(label_ui.keep.select_scenario(scenario_id).get("ok", false)), "%s should be available for cross-keep label validation" % scenario_id)
		for room_id_value in label_ui.keep.room_definitions().keys():
			var room_id: String = String(room_id_value)
			var room_label: Dictionary = label_ui.keep_canvas.room_label_snapshot(room_id)
			_check(bool(room_label.get("fits", false)), "%s/%s should fit its stable board label" % [label_ui.keep.keep_id, room_id])
	label_ui.queue_free()
	await process_frame

	var pike: Dictionary = ui.keep_canvas.actor_visual_snapshot("pike_squad", "raider")
	var repair: Dictionary = ui.keep_canvas.actor_visual_snapshot("repair_station", "sapper")
	var gate: Dictionary = ui.keep_canvas.actor_visual_snapshot("narrow_gate", "climber")
	_check(String(pike.piece.get("shape", "")) == "shield", "formation defenders should use a shield silhouette family")
	_check(String(repair.piece.get("shape", "")) == "cross", "support defenders should use a support-cross silhouette family")
	_check(String(gate.piece.get("shape", "")) == "barrier", "fortification pieces should use a barrier silhouette family")
	_check(String(pike.piece.get("sprite_path", "")).ends_with("defender_formation.svg") and String(pike.piece.get("asset_status", "")) == "authored_original" and bool(pike.get("piece_texture_loaded", false)), "formation defenders should resolve the authored small-scale silhouette")
	var ranged: Dictionary = ui.keep_canvas.actor_visual_snapshot("fire_team", "ash_slinger")
	_check(String(ranged.piece.get("sprite_path", "")).ends_with("defender_ranged.svg") and bool(ranged.get("piece_texture_loaded", false)), "ranged defenders should resolve a distinct authored silhouette")
	var authored_defender_paths: Dictionary = {}
	for piece_id in ["pike_squad", "fire_team", "runner_pair", "bellkeepers"]:
		var actor: Dictionary = ui.keep_canvas.actor_visual_snapshot(piece_id, "raider")
		_check(String(actor.piece.get("asset_status", "")) == "authored_original" and bool(actor.get("piece_texture_loaded", false)), "%s should resolve an authored defender-role silhouette" % piece_id)
		authored_defender_paths[String(actor.piece.get("sprite_path", ""))] = true
	_check(authored_defender_paths.size() == 4, "combat defenders should retain four distinct authored role silhouettes")
	_check(String(ranged.enemy.get("sprite_path", "")).ends_with("enemy_ash_slinger.svg") and String(ranged.enemy.get("asset_status", "")) == "authored_original" and bool(ranged.get("enemy_texture_loaded", false)), "extended ranged enemies should resolve an authored hostile silhouette")
	_check(bool(board.get("authored_actor_assets", false)) and int(board.get("authored_enemy_count", 0)) == 10 and String(board.get("authored_actor_source", "")).contains("32px"), "the board snapshot should identify complete authored actor provenance")
	_check(not bool(board.get("temporary_actor_assets", true)), "the board should no longer depend on temporary actor tiles")
	var authored_enemy_paths: Dictionary = {}
	for enemy_id in ["raider", "sapper", "climber", "siege_beast", "shield_guard", "ash_slinger", "shieldbreaker", "standard_cutter", "outrider", "gloam_knife"]:
		var actor: Dictionary = ui.keep_canvas.actor_visual_snapshot("pike_squad", enemy_id)
		_check(String(actor.enemy.get("asset_status", "")) == "authored_original" and bool(actor.get("enemy_texture_loaded", false)), "%s should resolve an authored small-scale silhouette" % enemy_id)
		authored_enemy_paths[String(actor.enemy.get("sprite_path", ""))] = true
	_check(authored_enemy_paths.size() == 10, "all enemy families should retain distinct authored silhouettes")
	var unknown_actor: Dictionary = BoardVisualRegistry.enemy_profile("unknown_enemy")
	_check(String(unknown_actor.get("asset_status", "")) == "procedural_fallback" and String(unknown_actor.get("sprite_path", "")).is_empty(), "unknown enemies should retain procedural fallback without borrowed art")
	var accented_rooms: Array[String] = ["gate", "armory", "workshop", "barracks", "supply_room", "north_tower", "old_chapel"]
	var accent_paths: Dictionary = {}
	for room_id in accented_rooms:
		var accent: Dictionary = ui.keep_canvas.room_function_accent_snapshot(room_id)
		_check(bool(accent.get("active", false)) and bool(accent.get("texture_loaded", false)), "%s should resolve a loadable temporary room-function accent" % room_id)
		_check(String(accent.get("asset_status", "")) == "temporary_cc0" and String(accent.get("source", "")).contains("Tiny Dungeon"), "%s should expose temporary Tiny Dungeon provenance" % room_id)
		accent_paths[String(accent.get("texture_path", ""))] = true
	_check(accent_paths.size() >= 6, "Greywatch room accents should preserve distinct functional silhouettes")
	_check(not bool(ui.keep_canvas.room_function_accent_snapshot("inner_yard").get("active", true)), "the open response yard should remain free of decorative room accents")
	_check(not bool(ui.keep_canvas.room_function_accent_snapshot("outer_wall").get("active", true)), "the structural outer wall should remain free of decorative room accents")
	_check(not bool(BoardVisualRegistry.room_function_accent_profile("ash_ford", "workshop").get("active", true)), "temporary room accents should remain scoped to Greywatch")
	_check(bool(board.get("temporary_room_accents", false)) and String(board.get("temporary_room_accent_source", "")).contains("CC0"), "the board snapshot should identify temporary room-accent provenance")
	var stable_effect: Dictionary = BoardVisualRegistry.room_damage_effect_profile("stable")
	var damaged_effect: Dictionary = BoardVisualRegistry.room_damage_effect_profile("damaged")
	var breached_effect: Dictionary = BoardVisualRegistry.room_damage_effect_profile("breached")
	_check(not bool(stable_effect.get("active", true)) and String(stable_effect.get("texture_path", "")).is_empty(), "stable rooms should remain visually quiet")
	_check(bool(damaged_effect.get("active", false)) and ResourceLoader.exists(String(damaged_effect.get("texture_path", ""))), "damaged rooms should resolve a loadable temporary atmosphere texture")
	_check(bool(breached_effect.get("active", false)) and ResourceLoader.exists(String(breached_effect.get("texture_path", ""))) and damaged_effect.get("texture_path") != breached_effect.get("texture_path"), "breached rooms should resolve a distinct stronger atmosphere texture")
	var repair_effect: Dictionary = BoardVisualRegistry.repair_effect_profile()
	_check(ResourceLoader.exists(String(repair_effect.get("texture_path", ""))) and String(repair_effect.get("asset_status", "")) == "temporary_cc0", "repair feedback should resolve a loadable temporary CC0 effect")

	var enemy_shapes: Dictionary = board.get("enemy_shapes", {})
	var unique_shapes: Dictionary = {}
	for shape in enemy_shapes.values():
		unique_shapes[String(shape)] = true
	_check(unique_shapes.size() == 5, "Raider, Sapper, Climber, Siege Beast, and Standard Cutter should have distinct silhouettes")
	var beast: Dictionary = ui.keep_canvas.actor_visual_snapshot("pike_squad", "siege_beast")
	_check(String(beast.enemy.get("shape", "")) == "hex" and float(beast.enemy.get("scale", 1.0)) > 1.0, "Siege Beast should reserve the largest heavy silhouette")
	_check(String(beast.enemy.get("sprite_path", "")).ends_with("enemy_siege_beast.svg") and bool(beast.get("enemy_texture_loaded", false)), "Siege Beast should resolve a distinct authored siege silhouette")

	ui.keep_canvas.queue_redraw()
	await process_frame
	_check(JSON.stringify(ui.keep.serialize()) == before, "board profile inspection and rendering should not mutate authoritative state")
	ui._toggle_contrast()
	var contrast_board: Dictionary = ui.keep_canvas.board_presentation_snapshot()
	_check(contrast_board.get("ground", {}).get("frame", Color.BLACK) != board.get("ground", {}).get("frame", Color.BLACK), "high contrast should strengthen the board frame without changing geometry")
	_check(contrast_board.get("cell_size", Vector2.ZERO) == board.get("cell_size", Vector2.ONE), "accessibility treatment should preserve board geometry")
	var contrast_accent: Dictionary = ui.keep_canvas.room_function_accent_snapshot("workshop")
	_check(bool(contrast_accent.get("high_contrast", false)) and float(contrast_accent.get("opacity", 1.0)) < 0.30, "high contrast should subordinate temporary room accents to tactical information")
	_check(JSON.stringify(ui.keep.serialize()) == before, "accessibility-only room accent changes should not mutate authoritative state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P34 board visual hierarchy: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
