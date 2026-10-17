---
id: T-0189
title: Maul der Spielerzelle kaut beim Fressen und Beißen
project: zellenphase
priority: 3
after: T-0188
---
## Ziel
Wenn die Spielerzelle frisst oder zubeißt, öffnet und schließt sich ihr Maul kurz (Lastenheft: „animierte Körperteile“, „Trefferreaktionen“). Hier nur die Spielerzelle; ausgelöst wird es später aus `main.gd`.

## Dateien
- `scripts/player_cell.gd`
- `tests/test_player_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/player_cell.gd`:
- Neue Konstante direkt unter `const MOUTH_COLOR := …`: `const CHEW_TIME := 0.3`
- Neue Variable direkt unter `var time := 0.0 …` (vor `var flash …`):
```gdscript
## Restzeit der Kaubewegung in Sekunden.
var chew_left := 0.0
```
- In `drive(delta, wish)` direkt nach `time += delta`: `chew_left = maxf(0.0, chew_left - delta)`
- Neue Funktionen am Ende:
```gdscript
## Startet eine Kaubewegung (beim Fressen oder Beißen).
func bite() -> void:
	chew_left = CHEW_TIME


## Öffnung des Mauls: 1 = normal, bis 1,5 mitten in der Kaubewegung.
func mouth_open() -> float:
	return 1.0 + 0.5 * sin(PI * chew_left / CHEW_TIME)


## Umriss des Mauls in Pixeln relativ zur Zellmitte, quer zur Blickrichtung um mouth_open() geweitet.
func mouth_points(part: Dictionary) -> PackedVector2Array:
	var open := mouth_open()
	var pts := PackedVector2Array()
	for p in PartLooks.shape(part["id"]):
		pts.append(Vector2(p.x, p.y * open))
	return PartLooks.place(pts, part, radius)
```
- In `_draw()` in der zweiten Schleife direkt vor der Zeile `elif category != "antrieb":` einfügen:
```gdscript
		elif category == "maul":
			draw_colored_polygon(mouth_points(part), PartLooks.color(part["id"]))
```
- Sonst nichts ändern.

## Tests
In `tests/test_player_cell.gd` anhängen:
- `test_maul_ruhig`: `cell.mouth_open()` ist 1.0
- `test_maul_kaut`: `cell.bite()`, `cell.drive(0.15, Vector2.ZERO)` → `cell.mouth_open()` ist 1.5; `cell.drive(1.0, Vector2.ZERO)` → `cell.mouth_open()` ist 1.0
- `test_maul_form`: `var part := {"id": "kiefer", "pos": Vector2(1, 0), "angle": 0.0}` → `cell.mouth_points(part)[1].is_equal_approx(Vector2(1.35 * cell.radius, 0.16 * cell.radius))` wahr; dann `cell.bite()`, `cell.drive(0.15, Vector2.ZERO)` → `cell.mouth_points(part)[1].is_equal_approx(Vector2(1.35 * cell.radius, 0.24 * cell.radius))` wahr

Review (17.10.2026): gemergt.
