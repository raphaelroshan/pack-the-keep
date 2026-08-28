extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _fixture(run_seed: int) -> RefCounted:
	var state: RefCounted = PackKeepState.new(run_seed)
	state.select_scenario("open_yard_net")
	state.wave_index = 2
	state.last_outcome = "held"
	state.repair_interval_active = true
	state.repair_actions_remaining = 2
	state._refresh_active_event()
	return state

func _initialize() -> void:
	var eligible_seeds: Array[int] = []
	for run_seed in [3307, 3308, 3309]:
		var state: RefCounted = _fixture(run_seed)
		if state.active_event_id == "old_drain_opens":
			eligible_seeds.append(run_seed)
	_check(eligible_seeds.size() == 1, "the one-in-three rare slot should select exactly one consecutive test seed")
	var selected_seed: int = eligible_seeds[0] if not eligible_seeds.is_empty() else 3307
	var first: RefCounted = _fixture(selected_seed)
	var second: RefCounted = _fixture(selected_seed)
	_check(first.active_event_id == second.active_event_id and first.active_event_id == "old_drain_opens", "rare occurrence selection should replay for the same seed")
	_check(first.current_event().get("choices", []).size() == 2, "Old Drain should expose two counter-preserving choices")
	var snapshot: Dictionary = first.serialize()
	var restored: RefCounted = PackKeepState.new(1)
	_check(bool(restored.load_serialized(snapshot).get("ok", false)) and restored.active_event_id == "old_drain_opens", "an active rare occurrence should survive save/load")
	restored.choose_event_option("mark_escape_route")
	_check(bool(restored.event_flags.get("old_drain_escape_open", false)) and restored.repair_actions_remaining == 2, "marking the escape route should preserve recovery actions and all existing counters")
	second.choose_event_option("seal_old_drain")
	_check(bool(second.event_flags.get("old_drain_sealed", false)), "sealing the drain should record the alternate visible consequence")

	if failures.is_empty():
		print("P13 Old Drain rare occurrence: PASS (seed %d selected)" % selected_seed)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
