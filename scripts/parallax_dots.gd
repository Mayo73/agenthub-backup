class_name ParallaxDots
extends RefCounted
## Schwebeteilchen in mehreren Tiefenebenen. Hintere Ebenen folgen der Kamera langsamer.

const LAYER_FACTORS := [0.2, 0.45, 0.75]
const TILE := 1024.0

## Je Ebene ein PackedVector2Array mit Punkten in [0, TILE)
var layers: Array = []


func _init(points_per_layer: int = 60, seed_value: int = 3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for factor in LAYER_FACTORS:
		var points := PackedVector2Array()
		for i in points_per_layer:
			points.append(Vector2(rng.randf() * TILE, rng.randf() * TILE))
		layers.append(points)


## Verschiebung einer Ebene bei Kameraposition camera_pos, auf die Kachel gefaltet (0 bis unter TILE).
static func layer_offset(camera_pos: Vector2, factor: float) -> Vector2:
	var offset := -camera_pos * factor
	return Vector2(fposmod(offset.x, TILE), fposmod(offset.y, TILE))
