class_name PhaseHeaderSnapshot
extends RefCounted

static func build(keep: Object, screen: String, battle_paused: bool, assault_ready_reason: String) -> Dictionary:
	if keep == null:
		return {}
	var keep_name: String = String(keep.keep_definition().get("name", "The Keep"))
	var scenario_name: String = String(keep.scenario_preview().get("name", "Defense"))
	var forecast: Dictionary = keep.forecast()
	var doctrine_name: String = String(forecast.get("doctrine", "next pressure")).replace("_", " ").capitalize()
	var terminal: bool = screen == "results" and not keep.last_outcome.is_empty() and String(keep.scenario_report().get("status", "in_progress")) == "complete"
	var result: Dictionary = {
		"title": "%s — %s" % [keep_name.to_upper(), screen.to_upper()],
		"subtitle": "Choose the next deliberate defense decision.",
		"screen_label": "PACK THE KEEP / %s" % screen.capitalize(),
		"hint": "Read the current decision, then commit through the primary action.",
	}
	match screen:
		"title":
			result.title = "PACK THE KEEP"
			result.subtitle = "Pack the rooms. Read the pressure. Hold what matters."
			result.screen_label = "PACK THE KEEP / Main Menu"
			result.hint = "A compact two-floor defense about pressure and recovery."
		"setup":
			result.title = "WAR COUNCIL"
			result.subtitle = "Choose who leads, what pressure approaches, and what the keep must preserve."
			result.screen_label = "PACK THE KEEP / War Council"
			result.hint = "WAR COUNCIL  ›  FORTRESS  ›  ASSAULT  ›  AFTERMATH"
		"settings":
			result.title = "SETTINGS & ACCESSIBILITY"
			result.subtitle = "Tune readability and input without touching the simulation."
			result.screen_label = "PACK THE KEEP / Settings"
			result.hint = "Presentation settings are saved separately from the run."
		"preparation":
			var plan_title: String = String(keep.keep_definition().get("starter_plan", {}).get("title", "Build a readable defense"))
			result.title = "%s — FORTRESS" % keep_name.to_upper()
			result.subtitle = "%s. Shape the plan around %s before entering the assault." % [plan_title, doctrine_name]
			result.screen_label = "PACK THE KEEP / Fortress"
			result.hint = "Spend materials, place defenders, and read the forecast."
		"battle":
			result.title = "%s — ASSAULT" % keep_name.to_upper()
			result.screen_label = "PACK THE KEEP / Assault"
			if not assault_ready_reason.is_empty():
				result.subtitle = "%s is staged. Read first contact, then sound the bell." % doctrine_name
				result.hint = "The assault is waiting at tick zero for your commitment."
			elif battle_paused:
				result.subtitle = "%s is paused. Inspect targets, timing, and the next committed response." % scenario_name
				result.hint = "The assault is paused; inspection cannot advance simulation."
			else:
				result.subtitle = "%s is live. Watch target lines and health, then pause when the answer changes." % scenario_name
				result.hint = "The assault is live. Pause to inspect before spending command."
		"results":
			if terminal:
				result.title = "%s — FINAL DEBRIEF" % keep_name.to_upper()
				result.subtitle = "The fort remains beside the report: read the cost, the cause, and the next experiment."
				result.screen_label = "PACK THE KEEP / Final Debrief"
				result.hint = "The defense is complete. Review the evidence before choosing the next attempt."
			else:
				var recovery_advice: Dictionary = keep.recovery_advice()
				var next_doctrine: String = String(recovery_advice.get("next_doctrine", doctrine_name)).replace("_", " ").capitalize()
				result.title = "%s — RECOVERY" % keep_name.to_upper()
				result.subtitle = "%d recovery action%s remain. Repair one priority without hiding what must wait." % [keep.repair_actions_remaining, "" if keep.repair_actions_remaining == 1 else "s"]
				result.screen_label = "PACK THE KEEP / Recovery"
				result.hint = "Next pressure: %s. Commit recovery, then release the next phase." % next_doctrine
	return result
