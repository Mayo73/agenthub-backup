class_name PlaceView
extends Control

## Zeichnet eine schematische Ortsskizze basierend auf PlaceSketch-Formen.
## Keine Karte, nur eine skizzierte Darstellung.

var kind: String = "Draußen"
var caption_label: Label


func _init() -> void:
	custom_minimum_size = Vector2(0, 220)

	# Caption-Label unten an der Fläche anlegen
	caption_label = UiStyle.label(
		PlaceSketch.caption("Draußen"),
		UiStyle.SIZE_SMALL,
		UiStyle.TEXT
	)
	add_child(caption_label)
	caption_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)


func set_place(place: String) -> void:
	kind = PlaceSketch.kind_for(place)
	caption_label.text = PlaceSketch.caption(kind)
	queue_redraw()


func shape_count() -> int:
	return PlaceSketch.shapes(kind).size()


func _draw() -> void:
	var shapes: Array[Dictionary] = PlaceSketch.shapes(kind)
	for shape in shapes:
		var color := shape["color"] as Color

		match shape["type"]:
			"rect":
				var pos: Vector2 = (shape["pos"] as Vector2) * size
				var s: Vector2 = shape["size"] as Vector2
				draw_rect(Rect2(pos, s * size), color)
			"circle":
				var pos: Vector2 = (shape["pos"] as Vector2) * size
				var radius: float = (shape["radius"] as float) * size.x
				draw_circle(pos, radius, color)
