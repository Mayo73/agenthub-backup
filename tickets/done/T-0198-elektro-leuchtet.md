---
id: T-0198
title: Elektroorgan der Spielerzelle leuchtet und flackert
project: zellenphase
priority: 3
after: T-0190
---
## Ziel
Das Elektroorgan der Spielerzelle bekommt einen flackernden blauen Schein (Stil: „sanfte Biolumineszenz“), damit man es auf einen Blick erkennt.

## Dateien
- `scripts/player_cell.gd`
- `tests/test_player_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/player_cell.gd`:
- Neue Funktion am Ende:
```gdscript
## Deckkraft des Scheins um das Elektroorgan; flackert leicht.
func glow_alpha() -> float:
	return 0.3 + 0.15 * sin(time * 9.0)
```
- In `_draw()` in der zweiten Schleife im Zweig `elif category != "antrieb":` direkt vor der Zeile `draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))` (gleiche Einrückung wie diese Zeile):
```gdscript
			if part["id"] == "elektro":
				draw_circle((part["pos"] as Vector2) * radius, radius * 0.35, Color(0.5, 0.85, 1.0, glow_alpha()))
```
- Sonst nichts ändern.

## Tests
In `tests/test_player_cell.gd` anhängen:
- `test_schein_start`: `cell.glow_alpha()` ist 0.3
- `test_schein_flackert`: `cell.drive(PI / 18.0, Vector2.ZERO)` → `cell.glow_alpha()` ist 0.45

Review (17.10.2026): gemergt.
