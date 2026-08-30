extends SceneTree

const Snapshot = preload("res://src/ui/preparation_presentation_snapshot.gd")

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
	await process_frame

	var pack_id: String = String(ui.pack_option.get_item_metadata(ui.pack_option.selected))
	var before: String = JSON.stringify(ui.keep.serialize())
	var first: Dictionary = Snapshot.build(ui.keep, pack_id, ui.pack_option.selected, ui.pack_option.item_count, false, "")
	var second: Dictionary = Snapshot.build(ui.keep, pack_id, ui.pack_option.selected, ui.pack_option.item_count, false, "")
	_check(JSON.stringify(first) == JSON.stringify(second), "same Preparation state should produce the same presentation snapshot")
	_check(JSON.stringify(ui.keep.serialize()) == before, "Preparation snapshot construction should not mutate authoritative state")

	var offer: Dictionary = first.get("pack_offer", {})
	_check(bool(offer.get("ok", false)) and String(offer.get("name", "")) == "Pike Line", "snapshot should expose the selected doctrine pack identity")
	_check(String(offer.get("state", "")) == "AVAILABLE" and bool(offer.get("can_open", false)), "initial Pike Line offer should expose its authoritative available action")
	_check(String(offer.get("pieces", "")).contains("Pike Squad") and String(offer.get("strength", "")).contains("Gate pressure"), "pack snapshot should retain contents and strategic strength")

	var brief: Dictionary = first.get("brief", {})
	_check(String(brief.get("question", "")).contains("Gate Assault"), "Preparation snapshot should expose the current doctrine question")
	_check(String(brief.get("answer", "")).contains("visible coverage") and not String(brief.get("weakness", "")).is_empty(), "Preparation snapshot should expose answer quality and one open weakness")
	_check(String(first.get("layout_lens_text", "")).contains("LAYOUT SUMMARY") and String(first.get("layout_lens_text", "")).contains("Greywatch Keep"), "snapshot should retain the advanced layout lens")

	ui._refresh_preparation_presentation()
	_check(JSON.stringify(ui.preparation_presentation_snapshot) == JSON.stringify(first), "Preparation UI should retain the exact snapshot it renders")
	_check(String(ui.preparation_pack_offer_panel.name_label.text) == String(offer.get("name", "")), "pack offer panel should render directly from the snapshot")
	_check(String(ui.preparation_brief_panel.question_label.text).contains(String(brief.get("question", ""))), "Preparation brief should render directly from the snapshot")
	_check(String(ui.layout_lens_label.text) == String(first.get("layout_lens_text", "")), "advanced layout lens should render directly from the snapshot")

	var tutorial_locked: Dictionary = Snapshot.build(ui.keep, pack_id, ui.pack_option.selected, ui.pack_option.item_count, true, "inspect_room:gate")
	var locked_offer: Dictionary = tutorial_locked.get("pack_offer", {})
	_check(bool(locked_offer.get("selection_locked", false)) and not bool(locked_offer.get("can_open", true)), "tutorial context should lock browsing and opening until the authored step")
	_check(JSON.stringify(ui.keep.serialize()) == before, "alternate tutorial projection should remain read-only")

	ui.queue_free()
	await process_frame
	if failures.is_empty():
		print("K3 Preparation presentation snapshot: PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
