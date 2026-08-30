class_name BattleBeatPresentation
extends RefCounted

const BEAT_ORDER := {
	"forecast": 1,
	"approach": 2,
	"target_lock": 3,
	"wind_up": 4,
	"defender_response": 5,
	"hostile_impact": 6,
	"consequence": 7,
	"settle": 8,
}

static func ambient(keep: Object, assault_ready_reason: String, focused_enemy_index: int) -> Dictionary:
	if keep == null or not keep.wave_active:
		return _beat("settle", "SETTLE", "No active assault. Read the result or prepare the next defense.")
	if not assault_ready_reason.is_empty():
		return _beat("forecast", "FORECAST", assault_ready_reason)
	var focus_index: int = focused_enemy_index
	if focus_index < 0 or focus_index >= keep.enemies.size() or bool(keep.enemies[focus_index].get("defeated", false)):
		focus_index = _first_active_enemy(keep)
	if focus_index < 0:
		return _beat("settle", "SETTLE", "The current pressure has been answered.")
	var enemy: Dictionary = keep.enemies[focus_index]
	var enemy_id: String = String(enemy.get("enemy_id", ""))
	var enemy_name: String = String(keep.enemy_definition(enemy_id).get("name", enemy_id.replace("_", " ").capitalize()))
	var arrival_step: int = int(enemy.get("arrival_step", 1))
	var continuous_time: float = float(keep.battle_step) + keep.battle_clock
	if continuous_time < float(arrival_step):
		return _beat("approach", "APPROACH", "%s closes on contact at T%d." % [enemy_name, arrival_step])
	var timing: Dictionary = keep.enemy_attack_timing(focus_index)
	var target: String = String(keep.enemy_target_readout(focus_index).get("summary", "the keep"))
	if not bool(timing.get("in_contact", false)) or not bool(timing.get("has_target", false)):
		return _beat("approach", "APPROACH", "%s is seeking a line into the keep." % enemy_name)
	if float(timing.get("cadence_progress", 0.0)) >= 0.55 and bool(timing.get("within_wave", false)):
		return _beat("wind_up", "WIND-UP", "%s is preparing its next strike on %s." % [enemy_name, target])
	return _beat("target_lock", "TARGET LOCK", "%s has committed to %s." % [enemy_name, target])

static func exchange_stage(progress: float, has_defender_response: bool, has_hostile_impact: bool, reduced_motion: bool = false) -> Dictionary:
	var value: float = clampf(progress, 0.0, 1.0)
	if reduced_motion:
		if has_hostile_impact:
			return _beat("consequence", "CONSEQUENCE", "Damage and remaining health are shown without travel animation.")
		if has_defender_response:
			return _beat("defender_response", "DEFENDER RESPONSE", "Committed defenders resolve their attacks without travel animation.")
		return _beat("settle", "SETTLE", "The authoritative combat tick is complete.")
	if value < 0.10:
		return _beat("target_lock", "TARGET LOCK", "Targets are committed for this deterministic tick.")
	if has_defender_response and (value < 0.48 or not has_hostile_impact and value < 0.82):
		return _beat("defender_response", "DEFENDER RESPONSE", "Ready defenders answer their committed threats.")
	if has_hostile_impact and value < 0.82:
		return _beat("hostile_impact", "HOSTILE IMPACT", "Surviving attackers deliver their committed strikes.")
	if has_hostile_impact and value < 0.94:
		return _beat("consequence", "CONSEQUENCE", "Health, structure, and disabled states reflect the resolved damage.")
	return _beat("settle", "SETTLE", "The board returns to its live tactical state.")

static func scaled_exchange_duration(battle_speed: float, reduced_motion: bool) -> float:
	if reduced_motion:
		return 0.18
	return clampf(0.82 / maxf(0.5, battle_speed), 0.38, 1.64)

static func _first_active_enemy(keep: Object) -> int:
	for index in range(keep.enemies.size()):
		if not bool(keep.enemies[index].get("defeated", false)):
			return index
	return -1

static func _beat(id: String, label: String, detail: String) -> Dictionary:
	return {"id": id, "index": int(BEAT_ORDER.get(id, 8)), "count": 8, "label": label, "detail": detail}
