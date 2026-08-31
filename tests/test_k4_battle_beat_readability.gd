extends SceneTree

const Beat = preload("res://src/ui/battle_beat_presentation.gd")

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
	ui._on_start_wave()
	await process_frame

	var forecast: Dictionary = Beat.ambient(ui.keep, ui.assault_ready_reason, ui.focused_enemy_index)
	_check(String(forecast.get("id", "")) == "forecast" and int(forecast.get("index", 0)) == 1, "tick-zero readiness should begin the eight-beat grammar at Forecast")
	ui._refresh_battle_presentation()
	_check(String(ui.battle_state_label.text).contains("PRESSURE READ — FORECAST"), "Battle rail should expose the ambient pressure read from its snapshot")

	var enemy_index: int = ui.focused_enemy_index
	var enemy: Dictionary = ui.keep.enemies[enemy_index]
	var arrival_step: int = int(enemy.get("arrival_step", 1))
	ui.keep.battle_step = maxi(0, arrival_step - 1)
	ui.keep.battle_clock = 0.25
	var approach: Dictionary = Beat.ambient(ui.keep, "", enemy_index)
	_check(String(approach.get("id", "")) == "approach" and String(approach.get("detail", "")).contains("T%d" % arrival_step), "pre-contact threat should expose Approach and its contact tick")

	ui.keep.enemies[enemy_index].target = "pike_squad_0"
	ui.keep.battle_step = arrival_step
	ui.keep.battle_clock = 0.20
	_check(String(Beat.ambient(ui.keep, "", enemy_index).get("id", "")) == "target_lock", "early contact cadence should expose Target Lock")
	ui.keep.battle_clock = 0.75
	var before_projection: String = JSON.stringify(ui.keep.serialize())
	_check(String(Beat.ambient(ui.keep, "", enemy_index).get("id", "")) == "wind_up", "late contact cadence should expose Wind-up")

	var traces: Array[Dictionary] = [{"attacker_id": "pike_squad_0", "enemy_index": enemy_index, "damage": 2, "style": "melee"}]
	var impacts: Array[Dictionary] = [{"target_kind": "piece", "target_id": "pike_squad_0", "enemy_index": enemy_index, "attack_style": "melee", "damage": 3, "before_value": 14, "after_value": 11}]
	ui.keep_canvas.set_reduced_motion(false)
	ui.keep_canvas.show_combat_exchange(traces, impacts, 1.0)
	_check(is_equal_approx(ui.keep_canvas.engagement_duration, 0.82), "1x exchange should reserve a readable sub-tick presentation window")
	_check(String(ui.keep_canvas.battle_beat_snapshot().get("id", "")) == "target_lock", "resolved exchange should begin with a short Target Lock beat")
	ui.keep_canvas.engagement_ttl = ui.keep_canvas.engagement_duration * 0.72
	_check(String(ui.keep_canvas.battle_beat_snapshot().get("id", "")) == "defender_response", "exchange should stage defender response before hostile damage")
	ui.keep_canvas.engagement_ttl = ui.keep_canvas.engagement_duration * 0.36
	_check(String(ui.keep_canvas.battle_beat_snapshot().get("id", "")) == "hostile_impact", "exchange should stage hostile impact after defender response")
	ui.keep_canvas.engagement_ttl = ui.keep_canvas.engagement_duration * 0.10
	_check(String(ui.keep_canvas.battle_beat_snapshot().get("id", "")) == "consequence", "exchange should expose the damage consequence before settling")
	var defender_melee_effect: Dictionary = ui.keep_canvas.combat_effect_snapshot("defender", "melee")
	var defender_ranged_effect: Dictionary = ui.keep_canvas.combat_effect_snapshot("defender", "ranged")
	var hostile_melee_effect: Dictionary = ui.keep_canvas.combat_effect_snapshot("hostile", "melee")
	var hostile_ranged_effect: Dictionary = ui.keep_canvas.combat_effect_snapshot("hostile", "ranged")
	var demolition_effect: Dictionary = ui.keep_canvas.combat_effect_snapshot("hostile", "demolition")
	for effect in [defender_melee_effect, defender_ranged_effect, hostile_melee_effect, hostile_ranged_effect, demolition_effect]:
		_check(bool(effect.get("texture_loaded", false)) and String(effect.get("asset_status", "")) == "temporary_cc0", "combat effects should resolve loadable temporary CC0 textures")
	_check(String(defender_melee_effect.get("texture_path", "")) != String(defender_ranged_effect.get("texture_path", "")), "defender melee and ranged impacts should remain visually distinct")
	_check(String(hostile_melee_effect.get("texture_path", "")) != String(hostile_ranged_effect.get("texture_path", "")) and String(hostile_ranged_effect.get("texture_path", "")) != String(demolition_effect.get("texture_path", "")), "hostile melee, ranged, and demolition impacts should remain visually distinct")
	ui.keep_canvas.engagement_ttl = ui.keep_canvas.engagement_duration * 0.03
	_check(String(ui.keep_canvas.battle_beat_snapshot().get("id", "")) == "settle", "exchange should finish on a settle beat")

	_check(is_equal_approx(Beat.scaled_exchange_duration(0.5, false), 1.64), "0.5x exchange should fit its two-second simulation interval")
	_check(is_equal_approx(Beat.scaled_exchange_duration(2.0, false), 0.41), "2x exchange should fit its half-second simulation interval")
	ui.keep_canvas.set_reduced_motion(true)
	ui.keep_canvas.show_combat_exchange(traces, impacts, 2.0)
	_check(ui.keep_canvas.engagement_duration <= 0.18 and String(ui.keep_canvas.battle_beat_snapshot().get("id", "")) == "consequence", "reduced motion should use a short static consequence instead of travel animation")
	_check(ui.keep_canvas._enemy_reaction_offset(enemy_index) == Vector2.ZERO and ui.keep_canvas._target_reaction_offset("piece", "pike_squad_0", ui.keep_canvas._piece_board_origin("pike_squad_0"), 14) == Vector2.ZERO, "reduced motion should suppress attacker and defender recoil")
	_check(JSON.stringify(ui.keep.serialize()) == before_projection, "beat projection should not mutate authoritative state")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("K4 battle beat readability: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
