class_name PoisonCloudView
extends Node2D
## Zeichnet die Giftwolken aller Quellen (PoisonClouds) als grüne Kreise, die wachsen und verblassen.

const COLOR := Color(0.55, 0.85, 0.3)

## Quellen vom Typ PoisonClouds (Spielerzelle und KI-Zellen).
var sources: Array = []


## Deckkraft einer Wolke mit dem Alter age (Sekunden).
static func cloud_alpha(age: float) -> float:
	return 0.45 * (1.0 - clampf(age / PoisonClouds.LIFETIME, 0.0, 1.0))


## Radius einer Wolke mit dem Alter age: wächst von 60 % auf 100 % von PoisonClouds.RADIUS.
static func cloud_radius(age: float) -> float:
	return PoisonClouds.RADIUS * (0.6 + 0.4 * clampf(age / PoisonClouds.LIFETIME, 0.0, 1.0))


## Anzahl aller Wolken aus allen Quellen.
func cloud_count() -> int:
	var n := 0
	for src: PoisonClouds in sources:
		n += src.clouds.size()
	return n


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for src: PoisonClouds in sources:
		for c: Dictionary in src.clouds:
			var col := COLOR
			col.a = cloud_alpha(c["age"])
			draw_circle(c["pos"], cloud_radius(c["age"]), col)
