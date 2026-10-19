class_name TimelineItem
extends Control
## Ein Eintrag im Zeitstrahl: Bild der Lebensform mit farbigem Rand, darunter Beschriftung und Zeit.

const BORDER_WIDTH := 4.0
const LABEL_FONT_SIZE := 14
const PICTURE_HEIGHT := 72.0

var entry: Dictionary
var name_label: Label
var time_label: Label


func _init() -> void:
	custom_minimum_size = Vector2(96, 120)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


static func create(timeline_entry: Dictionary) -> TimelineItem:
	var item := TimelineItem.new()
	item.entry = timeline_entry
	item.name_label = item._label(str(timeline_entry["label"]), PICTURE_HEIGHT)
	item.time_label = item._label(EvolutionTimeline.time_text(timeline_entry["time"]), PICTURE_HEIGHT + 22.0)
	return item


func _label(text: String, y: float) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(0, y)
	l.size = Vector2(custom_minimum_size.x, 20)
	l.clip_text = true
	l.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	add_child(l)
	return l


func _draw() -> void:
	var border_color: Color = EvolutionTimeline.diet_color(entry["diet"])
	var box := Rect2(Vector2.ZERO, Vector2(size.x, PICTURE_HEIGHT))
	draw_rect(box, Color(0, 0, 0, 0.35), true)
	draw_rect(box, border_color, false, BORDER_WIDTH)
	var center := box.get_center()
	var radius := PICTURE_HEIGHT * 0.3
	if entry["phase"] == "fisch":
		draw_colored_polygon(_ellipse(center, radius * 2.0, radius, 24), entry["color"])
	else:
		draw_circle(center, radius, entry["color"])


func _ellipse(center: Vector2, half_width: float, half_height: float, point_count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in point_count:
		var angle := TAU * i / point_count
		points.append(center + Vector2(cos(angle) * half_width, sin(angle) * half_height))
	return points
