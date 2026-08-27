extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/Main.tscn")
	var ui: Control = scene.instantiate()
	root.add_child(ui)
	await process_frame
	ui._set_screen("preparation")

	if not ui.guidance_label.text.contains("FIRST BATTLE GUIDE"):
		failures.append("preparation did not show the first-battle guide")
	if not ui.guidance_label.text.contains("recommended starter layout"):
		failures.append("empty preparation guide did not recommend the starter layout")

	var before_recommendation: String = JSON.stringify(ui.keep.serialize())
	ui._on_recommended_layout()
	if ui.keep.pieces.size() != 2:
		failures.append("recommended layout did not place both starter pieces")
	if not ui.event_label.text.contains("Recommended layout placed"):
		failures.append("recommended layout did not report the applied placement")
	if JSON.stringify(ui.keep.serialize()) == before_recommendation:
		failures.append("recommended layout did not commit its authoritative placement command")

	var after_recommendation: String = JSON.stringify(ui.keep.serialize())
	ui._first_battle_guidance()
	ui._refresh_result_explanation()
	if JSON.stringify(ui.keep.serialize()) != after_recommendation:
		failures.append("guidance/result refresh mutated authoritative state")

	ui._on_start_wave()
	if not ui.keep.wave_active:
		failures.append("recommended layout could not start the first invasion")
	if not ui.guidance_label.text.contains("fort stays visible"):
		failures.append("battle guide did not explain the persistent fort board")
	if not ui.log_label.text.contains("COMBAT EVENT FEED") or not ui.log_label.text.contains("Forecast"):
		failures.append("combat event feed did not expose the deterministic forecast")

	var event_before_step: String = ui.log_label.text
	ui._on_advance_wave()
	if ui.log_label.text == event_before_step:
		failures.append("combat event feed did not update after a manual step")

	var steps: int = 1
	while ui.keep.wave_active and steps < 8:
		ui._on_advance_wave()
		steps += 1
	if ui.keep.wave_active:
		failures.append("first invasion did not resolve within the bounded test steps")
	if not ui.result_explain_label.text.contains("CAUSAL RESULT"):
		failures.append("resolved invasion did not show the causal result panel")
	if not ui.guidance_label.text.contains("Read the causal result"):
		failures.append("results guide did not direct the tester to the causal explanation")
	if not ui.result_explain_label.text.contains("Breach") or not ui.result_explain_label.text.contains("Morale"):
		failures.append("causal result panel omitted core outcome metrics")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P8.2 UI smoke: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("P8.2 UI smoke: FAIL (%d)" % failures.size())
		quit(1)
