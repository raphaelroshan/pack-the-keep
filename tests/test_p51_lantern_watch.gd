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
	if answer == "route_reveal":
		if not bool(state.open_pack("lantern_watch").get("ok", false)):
			return false
		if not bool(state.place_piece("dusk_bow", Vector2i(1, 1), "upper").get("ok", false)):
			return false
		return bool(state.place_piece("lantern_post", Vector2i(7, 1), "upper").get("ok", false))
	if not bool(state.open_pack("road_wardens").get("ok", false)):
		return false
	return bool(state.place_piece("hook_guard", Vector2i(4, 3), "ground").get("ok", false))

func _run(seed: int, commander_id: String, answer: String, resume: bool = false) -> Dictionary:
	var state: RefCounted = PackKeepState.new(seed)
	state.select_commander(commander_id)
	state.select_scenario("the_unlit_stair")
	if not _place_answer(state, answer):
		return {}
	var restored: bool = false
	for _guard in range(100):
		if resume and not restored and state.wave_active and state.wave_index == 2 and state.battle_step == 1:
			var loaded: RefCounted = PackKeepState.new(1)
			_check(bool(loaded.load_serialized(state.serialize()).get("ok", false)), "Lantern Watch checkpoint should load")
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
	var malformed: Dictionary = catalog.enemy_definition("gloam_knife")
	malformed.concealment_profile.kind = "invisible_forever"
	malformed.concealment_profile.counter_modifier = "missing_light"
	malformed.concealment_profile.blocked_attack_styles = ["magic"]
	var malformed_errors: Array[String] = catalog.validate_enemy_definition(malformed, "gloam_knife", PackKeepState.ROOMS.keys(), catalog.doctrine_ids())
	var malformed_text: String = " ".join(malformed_errors)
	_check(malformed_text.contains("unsupported concealment kind") and malformed_text.contains("unknown support modifier") and malformed_text.contains("unsupported blocked attack style"), "concealment validation should reject malformed kind, counter, and attack style")

	var veiled: RefCounted = PackKeepState.new(5401)
	veiled.select_scenario("the_unlit_stair")
	veiled.open_pack("lantern_watch")
	_check(bool(veiled.place_piece("dusk_bow", Vector2i(1, 1), "upper").get("ok", false)), "veiled fixture should place Dusk Bow")
	_check(bool(veiled.forecast().get("concealment_threat", false)) and not bool(veiled.forecast().get("concealment_revealed", true)), "forecast should expose a veiled route without a Lantern Post")
	_check(bool(veiled.start_wave("veiled_entry").get("ok", false)), "veiled entry should start")
	veiled.advance_wave(1.0)
	_check(int(veiled.enemies[0].get("hp", 0)) == 8, "concealment should block ranged Dusk Bow damage")
	_check(" ".join(veiled.battle_report).contains("ranged response is blocked"), "battle report should explain blocked ranged response")

	var revealed: RefCounted = PackKeepState.new(5401)
	revealed.select_scenario("the_unlit_stair")
	revealed.open_pack("lantern_watch")
	_check(bool(revealed.place_piece("dusk_bow", Vector2i(1, 1), "upper").get("ok", false)), "revealed fixture should place Dusk Bow")
	var lantern_result: Dictionary = revealed.place_piece("lantern_post", Vector2i(7, 1), "upper")
	_check(bool(lantern_result.get("ok", false)), "Lantern Post should fit beside North Tower")
	_check(bool(revealed.forecast().get("concealment_revealed", false)), "forecast should expose route light before commitment")
	_check(bool(revealed.start_wave("veiled_entry").get("ok", false)), "revealed entry should start")
	_check(bool(revealed.enemies[0].get("concealment_revealed", false)), "Lantern Post should fix revealed state at wave start")
	revealed.advance_wave(1.0)
	_check(int(revealed.enemies[0].get("hp", 0)) == 4, "revealed Gloam Knife should take Dusk Bow damage")
	var active_snapshot: Dictionary = revealed.serialize()
	var restored_active: RefCounted = PackKeepState.new(1)
	_check(bool(restored_active.load_serialized(active_snapshot).get("ok", false)) and JSON.stringify(restored_active.serialize()) == JSON.stringify(active_snapshot), "active concealment state should round-trip without a schema change")
	var malformed_snapshot: Dictionary = active_snapshot.duplicate(true)
	malformed_snapshot.enemies[0].concealment_revealed = "yes"
	_check(not bool(PackKeepState.new(1).load_serialized(malformed_snapshot).get("ok", false)), "save validation should reject malformed reveal state before mutation")

	var disabled_light: RefCounted = PackKeepState.new(5401)
	disabled_light.select_scenario("the_unlit_stair")
	disabled_light.open_pack("lantern_watch")
	disabled_light.place_piece("dusk_bow", Vector2i(1, 1), "upper")
	var disabled_result: Dictionary = disabled_light.place_piece("lantern_post", Vector2i(7, 1), "upper")
	disabled_light._set_piece_health(String(disabled_result.get("piece_instance", "")), 0)
	disabled_light.start_wave("veiled_entry")
	_check(not bool(disabled_light.enemies[0].get("concealment_revealed", true)), "a disabled Lantern Post should not reveal the route")

	var melee: RefCounted = PackKeepState.new(5401)
	melee.select_scenario("the_unlit_stair")
	melee.open_pack("road_wardens")
	melee.place_piece("hook_guard", Vector2i(4, 3), "ground")
	melee.start_wave("veiled_entry")
	melee.advance_wave(1.0)
	_check(int(melee.enemies[0].get("hp", 0)) == 5, "Hook Guard melee should damage a veiled Gloam Knife")

	var mobile: RefCounted = PackKeepState.new(5401)
	mobile.select_scenario("the_unlit_stair")
	mobile.open_pack("runner_network")
	mobile.place_piece("runner_pair", Vector2i(4, 3), "ground")
	mobile.start_wave("veiled_entry")
	mobile.advance_wave(2.0)
	_check(bool(mobile.enemies[0].get("defeated", false)), "an open-lane Runner Pair should remain a viable concealed-threat answer")

	for answer in ["route_reveal", "melee_interception"]:
		for commander_id in ["castellan", "warden", "quartermaster"]:
			for seed in [5401, 5402, 5403]:
				var uninterrupted: Dictionary = _run(seed, commander_id, answer)
				var resumed: Dictionary = _run(seed, commander_id, answer, true)
				_check(not uninterrupted.is_empty() and uninterrupted.serialized == resumed.serialized, "The Unlit Stair replay should survive save/load for %s/%s/%d" % [answer, commander_id, seed])
				_check(bool(resumed.get("restored", false)), "The Unlit Stair replay should reach its checkpoint for %s/%s/%d" % [answer, commander_id, seed])
				_check(int(uninterrupted.get("waves", 0)) == 3 and String(uninterrupted.get("outcome", "")) != "collapse", "The Unlit Stair %s answer should remain viable for %s/%d" % [answer, commander_id, seed])

	if failures.is_empty():
		print("P51 Lantern Watch: PASS (18 two-answer runs plus save-resume parity)")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
