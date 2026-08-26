extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _init() -> void:
	_test_commander_selection()
	_test_pack_opening()
	_test_grid_footprint_and_overlap()
	_test_material_cost()
	_test_wave_requires_defense()
	_test_wave_resolution_is_deterministic()
	_test_commander_ability()
	_test_save_round_trip()
	if failures.is_empty():
		print("PASS: Pack the Keep state tests")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _test_commander_selection() -> void:
	var keep := PackKeepState.new(3307)
	var result := keep.select_commander("warden")
	_expect(result.ok, "known commander should be selectable")
	_expect(keep.commander_id == "warden", "selected commander should be stored")

func _test_pack_opening() -> void:
	var keep := PackKeepState.new(3307)
	var result := keep.open_pack("pike_line")
	_expect(result.ok, "known pack should open")
	var duplicate := keep.open_pack("pike_line")
	_expect(not duplicate.ok, "opened pack should not be opened twice")

func _test_grid_footprint_and_overlap() -> void:
	var keep := PackKeepState.new(3307)
	_expect(keep.piece_fits("pike_squad", Vector2i(0, 0)), "pike squad should fit at origin")
	_expect(not keep.piece_fits("pike_squad", Vector2i(11, 7)), "piece should not fit outside the grid")
	var first := keep.place_piece("pike_squad", Vector2i(0, 0))
	_expect(first.ok, "first piece should place")
	var overlap := keep.place_piece("repair_station", Vector2i(1, 0))
	_expect(not overlap.ok, "overlapping piece should be rejected")

func _test_material_cost() -> void:
	var keep := PackKeepState.new(3307)
	var before := keep.materials
	var result := keep.place_piece("brace", Vector2i(0, 0))
	_expect(result.ok, "brace should place")
	_expect(keep.materials == before - 5, "piece placement should spend its material cost")

func _test_wave_requires_defense() -> void:
	var keep := PackKeepState.new(3307)
	var result := keep.start_wave("gate_assault")
	_expect(not result.ok, "wave should require at least one defense")

func _test_wave_resolution_is_deterministic() -> void:
	var first := PackKeepState.new(3307)
	var second := PackKeepState.new(3307)
	first.place_piece("pike_squad", Vector2i(0, 0))
	second.place_piece("pike_squad", Vector2i(0, 0))
	first.start_wave("gate_assault")
	second.start_wave("gate_assault")
	first.advance_wave(1.0)
	second.advance_wave(1.0)
	_expect(is_equal_approx(first.wave_progress, second.wave_progress), "same seed and inputs should produce same wave progress")
	_expect(first.enemy_doctrine == second.enemy_doctrine, "same seed should preserve the same doctrine")

func _test_commander_ability() -> void:
	var keep := PackKeepState.new(3307)
	keep.place_piece("brace", Vector2i(0, 0))
	var before := keep.command_points
	var result := keep.use_commander_ability()
	_expect(result.ok, "commander ability should work with command points")
	_expect(keep.command_points == before - 1, "commander ability should consume a command point")

func _test_save_round_trip() -> void:
	var keep := PackKeepState.new(17)
	keep.select_commander("warden")
	keep.open_pack("field_engineers")
	keep.place_piece("brace", Vector2i(0, 0))
	keep.start_wave("distributed_sabotage")
	keep.advance_wave(1.0)
	var restored := PackKeepState.new(0)
	restored.load_serialized(keep.serialize())
	_expect(restored.seed == 17, "save should preserve seed")
	_expect(restored.commander_id == "warden", "save should preserve commander")
	_expect(restored.owned_packs.size() == 1, "save should preserve opened packs")
	_expect(restored.pieces.size() == 1, "save should preserve placed pieces")
	_expect(restored.wave_active == keep.wave_active, "save should preserve wave state")
