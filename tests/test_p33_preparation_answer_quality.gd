extends SceneTree

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
	ui._on_start_custom_setup()
	ui._on_confirm_setup()
	await process_frame

	_check(ui.screen == "preparation" and ui.preparation_brief_panel.visible, "ordinary Preparation should expose the current-question summary")
	_check(String(ui.preparation_brief_panel.question_label.text).contains("CURRENT QUESTION") and String(ui.preparation_brief_panel.question_label.text).contains("Gate Assault"), "Preparation should name the active doctrine question")
	_check(String(ui.preparation_brief_panel.answer_label.text).contains("No defenders placed"), "empty Preparation should state that no answer has been built")
	_check(String(ui.preparation_brief_panel.weakness_label.text).contains("No ground-floor defender"), "empty Preparation should expose the first deterministic weakness")
	_check(String(ui.preparation_brief_panel.plan_label.text).contains("FIRST PLAN") and String(ui.preparation_brief_panel.plan_label.text).contains("LAYER THE GATE ROAD") and String(ui.preparation_brief_panel.plan_label.text).contains("ACCEPT"), "Preparation should expose a complete opening and its accepted weakness above the board")
	_check(not ui.guidance_label.visible and ui.keep_canvas.visible, "compact summary should replace redundant preparation guidance without hiding the keep")

	var state_before_summary: String = JSON.stringify(ui.keep.serialize())
	ui._refresh_preparation_brief()
	_check(JSON.stringify(ui.keep.serialize()) == state_before_summary, "answer-quality rendering should not mutate authoritative state")

	ui._on_recommended_layout()
	await process_frame
	_check(ui.keep.owned_packs.has("pike_line"), "Greywatch's authored first plan should open its named pack through normal rules")
	_check(String(ui.preparation_brief_panel.answer_label.text).contains("2 ground") and String(ui.preparation_brief_panel.answer_label.text).contains("visible coverage"), "placed defenders should produce a concrete visible-answer summary")
	_check(not String(ui.preparation_brief_panel.weakness_label.text).is_empty(), "populated Preparation should retain an explicit open question")
	_check(String(ui.preparation_brief_panel.plan_label.text).contains("[2/2 placed]") and String(ui.preparation_brief_panel.plan_label.text).contains("[done]"), "the first-plan summary should expose live completion")

	var distinct_plan_titles: Array[String] = []
	for scenario_id in ["ash_ford_crossing", "the_divided_bell"]:
		ui.keep.reset_run(3307)
		_check(bool(ui.keep.select_scenario(scenario_id).get("ok", false)), "%s should select for first-plan coverage" % scenario_id)
		ui._refresh_ui()
		await process_frame
		var plan_before: String = String(ui.preparation_brief_panel.plan_label.text)
		distinct_plan_titles.append(plan_before.get_slice("\n", 0))
		var state_before_plan_render: String = JSON.stringify(ui.keep.serialize())
		ui._refresh_preparation_brief()
		_check(JSON.stringify(ui.keep.serialize()) == state_before_plan_render, "%s plan rendering should remain read-only" % scenario_id)
		ui._on_recommended_layout()
		await process_frame
		_check(ui.keep.pieces.size() == 3 and ui.keep.owned_packs.has("runner_network"), "%s should apply its three-piece authored opening through normal rules (%s)" % [scenario_id, String(ui.event_label.text)])
		_check(String(ui.preparation_brief_panel.plan_label.text).contains("[3/3 placed]"), "%s should show a completed authored plan" % scenario_id)
		if scenario_id == "ash_ford_crossing":
			_check(bool(ui.keep.spatial_rule_state().get("active", false)), "Ash Ford's first plan should preserve the clear causeway")
		else:
			_check(bool(ui.keep.spatial_rule_state().get("active", false)), "Twinwatch's first plan should staff both bastions")
	_check(distinct_plan_titles[0] != distinct_plan_titles[1], "Ash Ford and Twinwatch should present distinct first-plan identities")

	ui._set_ui_scale(2)
	await process_frame
	_check(is_equal_approx(get_root().content_scale_factor, 1.25), "Preparation brief should retain supported 125 percent scaling")
	_check(ui.gameplay_columns.vertical and ui.preparation_brief_panel.visible, "125 percent scale should stack the command rail while retaining the Preparation brief")
	_check(ui.preparation_brief_panel.size.x >= 780.0, "scaled Preparation brief should retain three readable columns")

	ui._start_tutorial()
	ui._on_tutorial_continue()
	ui._on_tutorial_continue()
	ui._on_tutorial_continue()
	ui._on_confirm_setup()
	await process_frame
	_check(ui.screen == "preparation" and not ui.preparation_brief_panel.visible and ui.tutorial_panel.visible, "First Watch should keep its authored objective instead of duplicating the generic summary")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("P33 preparation answer quality: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
