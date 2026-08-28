extends SceneTree

const PackKeepState = preload("res://src/core/keep_state.gd")

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _workshop_fixture(commander_id: String) -> RefCounted:
	var state: RefCounted = PackKeepState.new(3307)
	state.select_commander(commander_id)
	state.select_scenario("gatehouse_lock")
	state.wave_index = 2
	state.last_outcome = "partial_breach"
	state.repair_interval_active = true
	state.repair_actions_remaining = 2
	state.rooms.workshop.condition = 55
	state._update_room_state("workshop")
	state._refresh_active_event()
	return state

func _open_future_event(state: RefCounted) -> void:
	state.wave_index = 3
	state.last_outcome = "held"
	state.repair_interval_active = true
	state._refresh_active_event()

func _initialize() -> void:
	var absent: RefCounted = PackKeepState.new(3307)
	absent.select_scenario("gatehouse_lock")
	absent.wave_index = 3
	absent.last_outcome = "held"
	absent.repair_interval_active = true
	absent._refresh_active_event()
	_check(absent.active_event_id.is_empty(), "Mara's future event should remain absent without an earlier arc flag")

	var castellan: RefCounted = _workshop_fixture("castellan")
	castellan.choose_event_option("repair_workshop")
	_check(bool(castellan.event_flags.get("mara_workshop_repaired", false)) and not castellan.event_flags.has("mara_station_trusted"), "Workshop repair should set exactly its Mara arc flag")
	_open_future_event(castellan)
	_check(castellan.active_event_id == "mara_second_door", "a resolved Workshop path should unlock Mara's future event")
	var castellan_event: Dictionary = castellan.current_event()
	_check(String(castellan_event.get("setup", "")).contains("Castellan") and String(castellan_event.get("choices", [])[0].get("label", "")).contains("controlled"), "Castellan should receive the compact-structure variant")
	castellan.choose_event_option("open_second_door")
	_check(bool(castellan.event_flags.get("mara_second_door_open", false)), "opening the route should set Mara's third flag true")
	var saved: Dictionary = castellan.serialize()
	var restored: RefCounted = PackKeepState.new(1)
	_check(bool(restored.load_serialized(saved).get("ok", false)) and restored.event_flags == castellan.event_flags, "Mara's bounded flags should survive save/load")

	var warden: RefCounted = _workshop_fixture("warden")
	warden.choose_event_option("repair_workshop")
	_open_future_event(warden)
	var warden_event: Dictionary = warden.current_event()
	_check(String(warden_event.get("setup", "")).contains("Warden") and String(warden_event.get("choices", [])[0].get("label", "")).contains("response lane"), "Warden should receive the open-lane variant")
	warden.choose_event_option("keep_single_entry")
	_check(warden.event_flags.has("mara_second_door_open") and not bool(warden.event_flags.get("mara_second_door_open", true)), "refusing the route should persist Mara's third flag as false")
	var ledger: Dictionary = warden.event_ledger_snapshot(5)
	_check(ledger.get("flags", []).size() == 2, "the Ledger should expose only the two Mara flags reached by this path")

	if failures.is_empty():
		print("P13 Mara Venn arc: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
