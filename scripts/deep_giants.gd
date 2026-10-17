class_name DeepGiants
extends RefCounted
## Riesige Zellen, die in einer tiefen Ebene langsam unter der Spielwelt vorbeiziehen (wie in Spore).

## So stark folgt die Ebene der Kamera (kleiner als bei den Schwebeteilchen, also weiter hinten).
const FACTOR := 0.08
## Kantenlänge des Bereichs in Bildschirmpixeln, in dem die Riesen kreisen.
const AREA := 2400.0
const COUNT := 3

## Je Riese: {"pos": Vector2 in [0, AREA), "radius": float, "vel": Vector2, "stretch": float}
var giants: Array = []


func _init(seed_value: int = 5) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in COUNT:
		giants.append({
			"pos": Vector2(rng.randf() * AREA, rng.randf() * AREA),
			"radius": rng.randf_range(180.0, 320.0),
			"vel": Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(8.0, 20.0),
			"stretch": rng.randf_range(1.2, 1.8),
		})


## Bewegt alle Riesen um vel * delta; sie bleiben im Bereich [0, AREA) (an den Rändern umgefaltet).
func step(delta: float) -> void:
	for g: Dictionary in giants:
		var p: Vector2 = g["pos"] + g["vel"] * delta
		g["pos"] = Vector2(fposmod(p.x, AREA), fposmod(p.y, AREA))


## Lage eines Riesen auf dem Bildschirm (Pixel ab der linken oberen Ecke) bei Kameraposition camera_pos.
## Die Ebene folgt der Kamera mit FACTOR; gefaltet auf [-AREA/2, AREA/2) um die Bildschirmmitte.
static func screen_pos(pos: Vector2, camera_pos: Vector2, screen: Vector2) -> Vector2:
	var p := pos - camera_pos * FACTOR
	var half := AREA * 0.5
	return screen * 0.5 + Vector2(fposmod(p.x + half, AREA) - half, fposmod(p.y + half, AREA) - half)


## Schwimmrichtung eines Riesen (Winkel von vel).
static func heading(g: Dictionary) -> float:
	return (g["vel"] as Vector2).angle()
