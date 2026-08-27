extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _run_wave(keep: PackKeepState) -> Dictionary:
	var result: Dictionary = {"ok": false}
	while keep.wave_active:
		result = keep.advance_wave(1.0)
	return result

func _initialize() -> void:
	var keep: PackKeepState = PackKeepState.new(3307)
	_expect(bool(keep.select_scenario("gatehouse_lock").get("ok", false)), "Gatehouse Lock should be selectable")
	_expect(keep.authored_wave_count() == 3 and keep.has_next_wave(), "scenario should expose three waves before the first start")
	_expect(bool(keep.place_piece("pike_squad", Vector2i(0, 3), "ground").get("ok", false)), "starter Pike Squad should be placeable")
	var first: Dictionary = keep.start_wave("gate_assault")
	_expect(bool(first.get("ok", false)) and keep.wave_index == 1, "wave one should start")
	_expect(keep.enemy_doctrine == "gate_assault", "wave one should use Gate Assault")
	_run_wave(keep)
	_expect(not keep.wave_active and keep.repair_interval_active, "wave one should resolve into recovery")
	_expect(keep.has_next_wave(), "recovery after wave one should expose wave two")
	var recovery_snapshot: Dictionary = keep.serialize()
	var recovery_restored: PackKeepState = PackKeepState.new(0)
	var recovery_loaded: Dictionary = recovery_restored.load_serialized(recovery_snapshot)
	_expect(bool(recovery_loaded.get("ok", false)) and recovery_restored.repair_interval_active and recovery_restored.wave_index == 1, "save/load should preserve inter-wave recovery")
	_expect(recovery_restored.has_next_wave(), "loaded inter-wave recovery should preserve continuation")
	var restored_next: Dictionary = recovery_restored.finish_repair_interval()
	_expect(bool(restored_next.get("next_wave_started", false)) and recovery_restored.wave_index == 2, "loaded recovery should still start wave two automatically")
	var finished_one: Dictionary = keep.finish_repair_interval()
	_expect(bool(finished_one.get("next_wave_started", false)), "closing wave one recovery should start wave two automatically")
	_expect(keep.wave_active and keep.wave_index == 2, "wave two should be active after recovery closure")
	_expect(keep.enemy_doctrine == "distributed_sabotage", "wave two should escalate to Distributed Sabotage")
	_expect(keep.enemies.size() == 2 and String(keep.enemies[1].get("enemy_id", "")) == "sapper", "wave two should include a Sapper")
	var active_snapshot: Dictionary = keep.serialize()
	var active_restored: PackKeepState = PackKeepState.new(0)
	var active_loaded: Dictionary = active_restored.load_serialized(active_snapshot)
	_expect(bool(active_loaded.get("ok", false)) and active_restored.wave_active and active_restored.wave_index == 2, "save/load should preserve active wave two")
	_expect(active_restored.enemy_doctrine == "distributed_sabotage", "loaded active wave should preserve its doctrine")
	var blocked_manual: Dictionary = keep.start_wave("gate_assault")
	_expect(not bool(blocked_manual.get("ok", false)), "manual start should not duplicate an active automatic wave")
	_run_wave(keep)
	_expect(keep.repair_interval_active and keep.has_next_wave(), "wave two should open recovery with wave three available")
	var finished_two: Dictionary = keep.finish_repair_interval()
	_expect(bool(finished_two.get("next_wave_started", false)), "closing wave two recovery should start wave three automatically")
	_expect(keep.wave_active and keep.wave_index == 3, "wave three should be active after recovery closure")
	_expect(keep.enemy_doctrine == "feint_and_flank", "wave three should escalate to Feint and Flank")
	_expect(keep.enemies.size() == 3 and String(keep.enemies[1].get("enemy_id", "")) == "climber", "wave three should include a Climber")
	_run_wave(keep)
	_expect(keep.repair_interval_active and not keep.has_next_wave(), "final wave should open terminal recovery without another wave")
	var finished_three: Dictionary = keep.finish_repair_interval()
	_expect(bool(finished_three.get("ok", false)) and not bool(finished_three.get("next_wave_started", false)), "terminal recovery should close without a fourth wave")
	_expect(not bool(keep.start_wave("gate_assault").get("ok", false)), "authored scenario should reject a fourth wave")

	var collapsed: PackKeepState = PackKeepState.new(3307)
	collapsed.select_scenario("gatehouse_lock")
	collapsed.place_piece("pike_squad", Vector2i(0, 3), "ground")
	_expect(bool(collapsed.start_wave("gate_assault").get("ok", false)), "collapse regression wave should start")
	collapsed.morale = 0
	collapsed.advance_wave(6.0)
	_expect(collapsed.last_outcome == "collapse" and not collapsed.wave_active, "morale-zero resolution should collapse the scenario")
	_expect(not collapsed.has_next_wave(), "collapse should terminate authored wave continuation")
	_expect(not bool(collapsed.start_wave("gate_assault").get("ok", false)), "collapsed authored scenario should reject a follow-up wave")
	if failures.is_empty():
		print("Multi-wave simulation: PASS")
	else:
		for failure in failures:
			push_error(failure)
		printerr("Multi-wave simulation: FAIL (%d)" % failures.size())
	quit(0 if failures.is_empty() else 1)
