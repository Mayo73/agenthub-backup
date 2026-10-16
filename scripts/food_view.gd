class_name FoodView
extends Node2D
## Zeichnet alle Nahrungsstücke eines FoodField (Platzhalter: Kreise).

const PLANT_COLOR := Color(0.42, 0.8, 0.37)
const MEAT_COLOR := Color(0.85, 0.33, 0.31)

## Die Bild-Dateien für Nahrung (Platzhalter werden ersetzt).
const PLANT_TEXTURE: Texture2D = preload("res://assets/food/pflanze.png")
const MEAT_TEXTURE: Texture2D = preload("res://assets/food/fleisch.png")
## Das Bild ist etwas größer als der Berührungsradius, weil es einen weichen Rand hat.
const SPRITE_SCALE := 1.4

var field: FoodField
var time := 0.0


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _draw() -> void:
	if field == null:
		return
	for item in field.items:
		var texture := texture_for(item.kind)
		var rect := sprite_rect(item)
		rect.position += bob(item.position, time)
		draw_texture_rect(texture, rect, false)

## Liefert die Textur für eine Nahrungsart.
static func texture_for(kind: String) -> Texture2D:
	return PLANT_TEXTURE if kind == Diet.PFLANZE else MEAT_TEXTURE


## Rechteck, in das das Bild eines Nahrungsstücks gezeichnet wird (Mitte = Lage des Stücks).
static func sprite_rect(item: FoodItem) -> Rect2:
	var half := item.radius * SPRITE_SCALE
	return Rect2(item.position - Vector2(half, half), Vector2(half, half) * 2.0)

## Verschiebung der Zeichnung beim Schweben; jedes Stück ist nach seiner x-Lage versetzt.
static func bob(pos: Vector2, t: float) -> Vector2:
	return Vector2(0, 1.5 * sin(t * 2.0 + pos.x * 0.05))
