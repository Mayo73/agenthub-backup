class_name TimelineItem
extends Control
## Ein Eintrag im Zeitstrahl: Bild der Lebensform mit farbigem Rand und zwei Labels.

var entry: Dictionary
const BORDER_WIDTH := 4
const LABEL_FONT_SIZE := 14


func _init() -> void:
	custom_minimum_size = Vector2(96, 120)


static func create(timeline_entry: Dictionary) -> TimelineItem:
	var item := TimelineItem.new()
	item.entry = timeline_entry
	return item


func _ready() -> void:
	# Labels unter dem Bild erstellen
	var lbl_label := Label.new()
	lbl_label.name = "LabelLabel"
	lbl_label.text = entry["label"]
	lbl_label.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	add_child(lbl_label)

	var lbl_time := Label.new()
	lbl_time.name = "LabelTime"
	lbl_time.text = EvolutionTimeline.time_text(entry["time"])
	lbl_time.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	add_child(lbl_time)

	# Labels positionieren
	_update_labels()


func _draw() -> void:
	var border_color: Color = EvolutionTimeline.diet_color(entry["diet"])
	var center: Vector2 = size / 2.0
	var min_edge: float = min(size.x, size.y)

	# Rahmen mit Farbe je Ernährung (Breite BORDER_WIDTH)
	draw_rect(Rect2(Vector2.ZERO, size), border_color, false, BORDER_WIDTH)

	# Inhalt in der Mitte zeichnen
	if entry["phase"] == "zelle":
		# Kreis für Zelle in entry["color"]
		var radius: float = min_edge / 2.0 * 0.6
		draw_circle(center, radius, entry["color"])
	elif entry["phase"] == "fisch":
		# Ellipse (Polygon aus 24 Punkten), doppelt so breit wie hoch
		var ellipse_width: float = min_edge * 0.75
		var ellipse_height: float = ellipse_width / 2.0
		var points: PackedVector2Array = _build_ellipse(center, ellipse_width, ellipse_height, 24)
		draw_colored_polygon(points, entry["color"])


func _build_ellipse(center: Vector2, width: float, height: float, point_count: int) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(point_count):
		var angle: float = (i / float(point_count)) * TAU
		var x: float = center.x + (width / 2.0) * cos(angle)
		var y: float = center.y + (height / 2.0) * sin(angle)
		points.append(Vector2(x, y))
	return points


func _update_labels() -> void:
	if get_child_count() < 2:
		return

	var lbl_label: Label = get_node_or_null("LabelLabel") as Label
	var lbl_time: Label = get_node_or_null("LabelTime") as Label
	if not lbl_label or not lbl_time:
		return

	# Labels untereinander zentrieren (unten im Control)
	var y_pos: float = size.y - lbl_label.size.y - lbl_time.size.y - 10
	lbl_label.position = Vector2((size.x - lbl_label.size.x) / 2.0, y_pos)
	lbl_time.position = Vector2((size.x - lbl_time.size.x) / 2.0, y_pos + lbl_label.size.y + 5)
