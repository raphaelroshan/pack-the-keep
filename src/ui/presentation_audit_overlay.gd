class_name PresentationAuditOverlay
extends Control

const REGION_COLORS := [
	Color("#65d6c1"),
	Color("#f2c572"),
	Color("#e88378"),
	Color("#8fc6d1"),
	Color("#c9a7e8"),
	Color("#bfe8cf"),
]

var tracked_regions: Dictionary = {}
var screen_name: String = "unknown"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	z_index = 1000
	set_process(true)

func configure(regions: Dictionary, current_screen: String) -> void:
	tracked_regions = regions.duplicate()
	screen_name = current_screen
	queue_redraw()

func set_screen_name(value: String) -> void:
	screen_name = value
	queue_redraw()

func audit_snapshot(viewport_rect: Rect2 = Rect2()) -> Dictionary:
	var bounds: Rect2 = viewport_rect
	if bounds.size == Vector2.ZERO:
		bounds = Rect2(Vector2.ZERO, size)
	var regions: Array[Dictionary] = []
	var clipped_count: int = 0
	for region_name_value in tracked_regions.keys():
		var region_name: String = String(region_name_value)
		var control: Control = tracked_regions[region_name]
		if control == null or not is_instance_valid(control) or not control.is_visible_in_tree():
			continue
		var rect: Rect2 = control.get_global_rect()
		var clipped: bool = not bounds.encloses(rect)
		if clipped:
			clipped_count += 1
		regions.append({"name": region_name, "rect": rect, "clipped": clipped})
	var focus_owner: Control = get_viewport().gui_get_focus_owner() if get_viewport() != null else null
	var focus_text: String = "none"
	if focus_owner != null:
		focus_text = focus_owner.name
		if focus_owner is Button and not String(focus_owner.text).is_empty():
			focus_text = "%s: %s" % [focus_owner.name, String(focus_owner.text)]
	return {
		"screen": screen_name,
		"viewport": {"width": int(bounds.size.x), "height": int(bounds.size.y)},
		"focus": focus_text,
		"visible_region_count": regions.size(),
		"clipped_region_count": clipped_count,
		"regions": regions,
	}

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var snapshot: Dictionary = audit_snapshot()
	var regions: Array = snapshot.get("regions", [])
	for index in range(regions.size()):
		var region: Dictionary = regions[index]
		var color: Color = REGION_COLORS[index % REGION_COLORS.size()]
		var rect: Rect2 = region.get("rect", Rect2())
		rect.position -= global_position
		draw_rect(rect, color, false, 2.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(5, 14), String(region.get("name", "region")).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, color)
	var status: String = "PRESENTATION AUDIT • %s • %dx%d • FOCUS %s • REGIONS %d • CLIPPED %d" % [String(snapshot.screen).to_upper(), int(snapshot.viewport.width), int(snapshot.viewport.height), String(snapshot.focus), int(snapshot.visible_region_count), int(snapshot.clipped_region_count)]
	var status_rect: Rect2 = Rect2(8, size.y - 34, minf(size.x - 16.0, 920.0), 26)
	draw_rect(status_rect, Color(0.04, 0.03, 0.06, 0.9), true)
	draw_rect(status_rect, Color("#f2c572"), false, 1.0)
	draw_string(ThemeDB.fallback_font, status_rect.position + Vector2(8, 18), status, HORIZONTAL_ALIGNMENT_LEFT, status_rect.size.x - 16.0, 12, Color("#fff4df"))
