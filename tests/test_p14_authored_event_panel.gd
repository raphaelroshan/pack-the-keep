extends SceneTree

const AuthoredEventPanelView = preload("res://src/ui/authored_event_panel.gd")

var failures: Array[String] = []
var emitted_choice: String = ""

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var panel: VBoxContainer = AuthoredEventPanelView.new()
	panel.build(2)
	panel.choice_requested.connect(func(choice_id: String) -> void: emitted_choice = choice_id)
	root.add_child(panel)
	panel.render({
		"ok": true, "title": "Test Event", "phase": "recovery", "setup": "A bounded setup.",
		"choices": [
			{"id": "first_choice", "label": "First", "visible_result": "First result.", "available": true, "reason": ""},
			{"id": "second_choice", "label": "Second", "visible_result": "Second result.", "available": false, "reason": "needs_materials"}
		]
	})
	_check(panel.visible and panel.title_label.text == "RECOVERY DECISION — Test Event", "extracted panel should render a player-facing event heading")
	_check(not panel.choice_buttons[0].disabled and panel.choice_buttons[1].disabled and panel.choice_details[0].text.begins_with("RESULT —") and panel.choice_details[1].text.contains("BLOCKED — needs materials"), "extracted panel should preserve legal, result, and blocked choice states")
	panel.choice_buttons[0].pressed.emit()
	_check(emitted_choice == "first_choice", "extracted panel should emit the stable choice ID")
	panel.render({"ok": false})
	_check(not panel.visible, "extracted panel should hide when no event is active")
	panel.queue_free()
	await process_frame
	if failures.is_empty():
		print("P14 authored event panel: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
