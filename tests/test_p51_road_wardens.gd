extends SceneTree

const ContentCatalog = preload("res://src/core/content_catalog.gd")
const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _place_answer(state: RefCounted, answer: String) -> bool:
	if not bool(state.place_piece("pike_squad", Vector2i(0, 3), "ground").get("ok", false)):
		return false
	if answer == "prepared_delay":
		if not bool(state.open_pack("road_wardens").get("ok", false)):
			return false
		if not bool(state.place_piece("stake_line", Vector2i(1, 2), "ground").get("ok", false)):
			return false
		return bool(state.place_piece("hook_guard", Vector2i(4, 3), "ground").get("ok", false))
	if not bool(state.open_pack("crossbow_watch").get("ok", false)):
		return false
	if not bool(state.place_piece("crossbow_patrol", Vector2i(1, 1), "upper").get("ok", false)):
		return false
	return bool(state.place_piece("watch_banner", Vector2i(4, 1), "upper").get("ok", false))

func _run(seed: int, commander_id: String, answer: String, resume: bool = false) -> Dictionary:
	var state: RefCounted = PackKeepState.new(seed)
	state.select_commander(commander_id)
	state.select_scenario("before_the_horn")
	if not _place_answer(state, answer):
		return {}
	var restored: bool = false
	for _guard in range(100):
		if resume and not restored and state.wave_active and state.wave_index == 2 and state.battle_step == 1:
			var loaded: RefCounted = PackKeepState.new(1)
			_check(bool(loaded.load_serialized(state.serialize()).get("ok", false)), "Road Wardens checkpoint should load")
			state = loaded
			restored = true
		if state.wave_active:
			state.advance_wave(1.0)
			continue
		if state.last_outcome == "collapse" or (state.wave_index >= state.authored_wave_count() and not state.has_next_wave()):
			break
		if state.repair_interval_active:
			state.finish_repair_interval()
		else:
			state.start_wave(state.enemy_doctrine)
	return {"serialized": JSON.stringify(state.serialize()), "waves": state.wave_history.size(), "outcome": state.last_outcome, "restored": restored}

func _initialize() -> void:
	var catalog: RefCounted = ContentCatalog.new()
	catalog.load_default(PackKeepState.ROOMS.keys())
	var malformed: Dictionary = catalog.enemy_definition("outrider")
	malformed.momentum_profile.delay_steps = 3
	malformed.momentum_profile.counter_modifier = "missing_control"
	var malformed_errors: Array[String] = catalog.validate_enemy_definition(malformed, "outrider", PackKeepState.ROOMS.keys(), catalog.doctrine_ids())
	_check(" ".join(malformed_errors).contains("delay_steps") and " ".join(malformed_errors).contains("unknown support modifier"), "momentum validation should reject out-of-bounds delay and unknown route control")

	var live_charge: RefCounted = PackKeepState.new(5301)
	live_charge.select_scenario("before_the_horn")
	live_charge.open_pack("road_wardens")
	_check(bool(live_charge.place_piece("hook_guard", Vector2i(4, 3), "ground").get("ok", false)), "unopposed fixture should place Hook Guard")
	_check(bool(live_charge.forecast().get("momentum_threat", false)) and not bool(live_charge.forecast().get("momentum_delayed", true)), "forecast should expose live momentum without a route obstacle")
	_check(bool(live_charge.start_wave("rapid_breakthrough").get("ok", false)), "unopposed breakthrough should start")
	_check(int(live_charge.enemies[0].get("arrival_step", 0)) == 2 and not bool(live_charge.enemies[0].get("momentum_delayed", true)), "unopposed Outrider should keep second-tick contact")
	live_charge.advance_wave(2.0)
	_check(int(live_charge.pieces["hook_guard_0"].get("health", 0)) == 8, "a surviving live charge should damage its unit target on tick two")

	var delayed_charge: RefCounted = PackKeepState.new(5301)
	delayed_charge.select_scenario("before_the_horn")
	delayed_charge.open_pack("road_wardens")
	var stake_result: Dictionary = delayed_charge.place_piece("stake_line", Vector2i(1, 2), "ground")
	_check(bool(stake_result.get("ok", false)), "Stake Line should fit beside Gate")
	_check(bool(delayed_charge.place_piece("hook_guard", Vector2i(4, 3), "ground").get("ok", false)), "delayed fixture should place Hook Guard")
	_check(bool(delayed_charge.forecast().get("momentum_delayed", false)), "forecast should expose prepared delay before commitment")
	_check(bool(delayed_charge.start_wave("rapid_breakthrough").get("ok", false)), "delayed breakthrough should start")
	_check(int(delayed_charge.enemies[0].get("arrival_step", 0)) == 3 and bool(delayed_charge.enemies[0].get("momentum_delayed", false)), "Stake Line should delay Outrider contact by exactly one tick")
	delayed_charge.advance_wave(2.0)
	_check(int(delayed_charge.pieces["hook_guard_1"].get("health", 0)) == 11 and int(delayed_charge.enemies[0].get("hp", 0)) == 2, "the delayed charge should remain in approach after two Hook Guard responses")
	var active_snapshot: Dictionary = delayed_charge.serialize()
	var restored_active: RefCounted = PackKeepState.new(1)
	_check(bool(restored_active.load_serialized(active_snapshot).get("ok", false)) and JSON.stringify(restored_active.serialize()) == JSON.stringify(active_snapshot), "active momentum timing should round-trip without a schema change")
	var malformed_snapshot: Dictionary = active_snapshot.duplicate(true)
	malformed_snapshot.enemies[0].momentum_delayed = "yes"
	_check(not bool(PackKeepState.new(1).load_serialized(malformed_snapshot).get("ok", false)), "save validation should reject malformed momentum state before mutation")
	delayed_charge.advance_wave(1.0)
	_check(bool(delayed_charge.enemies[0].get("defeated", false)) and int(delayed_charge.pieces["hook_guard_1"].get("health", 0)) == 11, "Hook Guard should finish the delayed Outrider before contact")
	_check(" ".join(delayed_charge.battle_report).contains("contact is delayed from step 2 to step 3"), "battle report should explain the route-control timing change")

	var disabled_stakes: RefCounted = PackKeepState.new(5301)
	disabled_stakes.select_scenario("before_the_horn")
	disabled_stakes.open_pack("road_wardens")
	var disabled_result: Dictionary = disabled_stakes.place_piece("stake_line", Vector2i(1, 2), "ground")
	disabled_stakes.place_piece("hook_guard", Vector2i(4, 3), "ground")
	disabled_stakes._set_piece_health(String(disabled_result.get("piece_instance", "")), 0)
	disabled_stakes.start_wave("rapid_breakthrough")
	_check(int(disabled_stakes.enemies[0].get("arrival_step", 0)) == 2 and not bool(disabled_stakes.enemies[0].get("momentum_delayed", true)), "a disabled Stake Line should not delay momentum")

	var mobile: RefCounted = PackKeepState.new(5301)
	mobile.select_scenario("before_the_horn")
	mobile.open_pack("runner_network")
	mobile.place_piece("runner_pair", Vector2i(4, 3), "ground")
	mobile.start_wave("rapid_breakthrough")
	mobile.advance_wave(2.0)
	_check(bool(mobile.enemies[0].get("defeated", false)), "an open-lane Runner Pair should remain a viable direct interception answer")

	for answer in ["prepared_delay", "precision_stop"]:
		for commander_id in ["castellan", "warden", "quartermaster"]:
			for seed in [5301, 5302, 5303]:
				var uninterrupted: Dictionary = _run(seed, commander_id, answer)
				var resumed: Dictionary = _run(seed, commander_id, answer, true)
				_check(not uninterrupted.is_empty() and uninterrupted.serialized == resumed.serialized, "Before the Horn replay should survive save/load for %s/%s/%d" % [answer, commander_id, seed])
				_check(bool(resumed.get("restored", false)), "Before the Horn replay should reach its checkpoint for %s/%s/%d" % [answer, commander_id, seed])
				_check(int(uninterrupted.get("waves", 0)) == 3 and String(uninterrupted.get("outcome", "")) != "collapse", "Before the Horn %s answer should remain viable for %s/%d" % [answer, commander_id, seed])

	if failures.is_empty():
		print("P51 Road Wardens: PASS (18 two-answer runs plus save-resume parity)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
