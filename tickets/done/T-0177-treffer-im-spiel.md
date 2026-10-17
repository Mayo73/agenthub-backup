---
id: T-0177
title: Getroffene Zellen blitzen im Spiel auf
project: zellenphase
priority: 2
after: T-0176, T-0173, T-0169, T-0174
---
## Ziel
Wird die Spielerzelle oder eine KI-Zelle gebissen oder von Stacheln getroffen, blitzt sie kurz rot auf (`HitFlash`).

## Dateien
- `scripts/player_cell.gd`
- `scripts/ai_cell.gd`
- `scripts/main.gd`
- `tests/test_main_treffer.gd`: neu

## Akzeptanzkriterien
- `scripts/player_cell.gd`:
  - Neue Variable direkt unter `var time := 0.0`: `var flash := HitFlash.new()`
  - In `drive(delta, wish)` direkt nach `time += delta`: `flash.tick(delta)`
  - In `_draw()` direkt nach der Zeile `CellPainter.draw_cell(self, Vector2.ZERO, look, radius, time)`:
```gdscript
	if flash.is_active():
		draw_circle(Vector2.ZERO, radius * 1.05, flash.overlay_color())
```
- `scripts/ai_cell.gd`: genau dieselben drei Änderungen (Variable unter `var time := 0.0`, `flash.tick(delta)` direkt nach `time += delta` in `drive(delta)`, Überlagerung direkt nach der Zeile mit `CellPainter.draw_cell(...)` in `_draw()`).
- `scripts/main.gd`:
  - In `resolve_combat()` direkt nach der Zeile `cell.motion.knockback(cell.motion.position - player.motion.position, 120.0)` die Zeile `cell.flash.trigger()` (gleiche Einrückung); direkt nach der Zeile `player.motion.knockback(player.motion.position - cell.motion.position, 160.0)` die Zeile `player.flash.trigger()`.
  - In `resolve_weapons(delta)` direkt nach der Zeile `cell.motion.knockback(cell.motion.position - pos, 100.0)` die Zeile `cell.flash.trigger()`.
- Sonst nichts an den drei Dateien ändern.

## Tests
`tests/test_main_treffer.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`. Hilfsfunktion (nicht `test_` benennen):
```gdscript
func _add_ai(id: String, pos: Vector2, heading: float) -> AiCell:
	var cell := AiCell.new()
	cell.setup(id, pos)
	cell.motion.heading = heading
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	return cell
```
Die Spielerzelle steht bei (0, 0), Blick nach rechts, Radius 12.
- `test_ki_blitzt`: `main.player.diet = Diet.FLEISCHFRESSER`; `var cell := _add_ai("schnapper", Vector2(30, 0), 0.0)`; `main.resolve_combat()` → `cell.flash.is_active()` wahr
- `test_spieler_blitzt`: `_add_ai("schnapper", Vector2(30, 0), PI)`; `main.resolve_combat()` → `main.player.flash.is_active()` wahr
- `test_klingt_ab`: `main.player.flash.trigger()`, `main.player.drive(1.0, Vector2.ZERO)` → `main.player.flash.is_active()` falsch
- `test_ki_ruhig`: `var cell := _add_ai("weidezelle", Vector2(300, 0), 0.0)`; `main.resolve_combat()` → `cell.flash.is_active()` falsch

Review (17.10.2026): gemergt.
