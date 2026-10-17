---
id: T-0231
title: Riesen in der Tiefe – Bewegung und Lage (DeepGiants)
project: zellenphase
priority: 3
---
## Ziel
Wie in Spore sollen tief unter der Spielwelt riesige Zellen als Schatten vorbeiziehen (Lastenheft: „mehrere Tiefenebenen“). Diese Klasse verwaltet die Riesen, bewegt sie und berechnet ihre Lage auf dem Bildschirm; sie zeichnet nichts.

## Dateien
- `scripts/deep_giants.gd` – neu
- `tests/test_deep_giants.gd` – neu

## Akzeptanzkriterien
`scripts/deep_giants.gd` genau so:
```gdscript
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
```
- Keine andere Datei ändern.

## Tests
`tests/test_deep_giants.gd` mit `extends "res://tests/base_test.gd"`:
- `test_anzahl`: `var d := DeepGiants.new()` → `d.giants.size()` ist 3; für jeden Riesen `g["radius"] >= 180.0 and g["radius"] <= 320.0` wahr und `g["pos"].x >= 0.0 and g["pos"].x < DeepGiants.AREA` wahr
- `test_gleicher_seed`: `DeepGiants.new(9).giants == DeepGiants.new(9).giants` wahr
- `test_schritt`: `var d := DeepGiants.new()`, `d.giants = [{"pos": Vector2(100, 50), "radius": 200.0, "vel": Vector2(10, -5), "stretch": 1.5}]`, `d.step(2.0)` → `d.giants[0]["pos"]` ist `Vector2(120, 40)`
- `test_umfalten`: wie oben, aber `"pos": Vector2(2390, 5)` und `"vel": Vector2(20, 0)`, `d.step(1.0)` → `d.giants[0]["pos"]` ist `Vector2(10, 5)`
- `test_bildschirm`: `DeepGiants.screen_pos(Vector2(100, 0), Vector2.ZERO, Vector2(1920, 1080))` ist `Vector2(1060, 540)`; `DeepGiants.screen_pos(Vector2(2300, 0), Vector2.ZERO, Vector2(1920, 1080))` ist `Vector2(860, 540)`; `DeepGiants.screen_pos(Vector2(100, 0), Vector2(1000, 0), Vector2(1920, 1080))` ist `Vector2(980, 540)`
- `test_richtung`: `is_equal_approx(DeepGiants.heading({"vel": Vector2(0, 10)}), PI / 2.0)` wahr

Review (17.10.2026): gemergt.
