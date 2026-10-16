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


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if field == null:
		return
	for item in field.items:
		var texture := texture_for(item.kind)
		draw_texture_rect(texture, sprite_rect(item), false)

## Liefert die Textur für eine Nahrungsart.
static func texture_for(kind: String) -> Texture2D:
	return PLANT_TEXTURE if kind == Diet.PFLANZE else MEAT_TEXTURE


## Rechteck, in das das Bild eines Nahrungsstücks gezeichnet wird (Mitte = Lage des Stücks).
static func sprite_rect(item: FoodItem) -> Rect2:
	var half := item.radius * SPRITE_SCALE
	return Rect2(item.position - Vector2(half, half), Vector2(half, half) * 2.0)
