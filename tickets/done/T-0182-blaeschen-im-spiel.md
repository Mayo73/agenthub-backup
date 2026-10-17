---
id: T-0182
title: Bläschen hinter der Spielerzelle im Spiel
project: zellenphase
priority: 3
after: T-0179, T-0181
---
## Ziel
Schwimmt die Spielerzelle schnell, steigen hinter ihr Bläschen auf (`BubbleTrail`, `BubbleView`).

## Dateien
- `scripts/main.gd`
- `tests/test_main_blaeschen.gd`: neu

## Akzeptanzkriterien
- Neue Variablen direkt unter `var auto_spawn := true`:
```gdscript
var bubbles := BubbleTrail.new()
var bubble_view: BubbleView
var bubble_timer := 0.0
```
- Am Ende von `_ready()` (vor dem Block, der `DemoScenes.requested(...)` prüft, damit die Reihenfolge egal bleibt, einfach direkt davor):
```gdscript
	bubble_view = BubbleView.new()
	bubble_view.name = "Bubbles"
	bubble_view.trail = bubbles
	world.add_child(bubble_view)
```
- In `_physics_process(delta)` direkt nach der Zeile `stats.tick(delta)`: `update_bubbles(delta)`
- Neue Funktion am Ende:
```gdscript
## Lässt hinter der schnell schwimmenden Spielerzelle Bläschen aufsteigen.
func update_bubbles(delta: float) -> void:
	bubbles.tick(delta)
	bubble_timer += delta
	if player.motion.speed() > 60.0 and bubble_timer >= 0.08:
		bubble_timer = 0.0
		var back := PartGeometry.world_point(player.motion.position, player.motion.heading, player.radius, Vector2(-1.1, 0))
		bubbles.emit(back, maxf(1.5, player.radius * 0.15))
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_blaeschen.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`.
- `test_view`: `main.bubble_view.get_parent() == main.world` wahr; `main.bubble_view.trail == main.bubbles` wahr
- `test_schnell`: `main.player.motion.velocity = Vector2(200, 0)`, `main.update_bubbles(0.1)` → `main.bubbles.bubbles.size()` ist 1; `(main.bubbles.bubbles[0]["pos"] as Vector2).x < main.player.motion.position.x` wahr
- `test_langsam`: `main.player.motion.velocity = Vector2.ZERO`, `main.update_bubbles(0.1)` → `main.bubbles.bubbles.size()` ist 0
- `test_takt`: `main.player.motion.velocity = Vector2(200, 0)`, `main.update_bubbles(0.1)`, `main.update_bubbles(0.01)` → `main.bubbles.bubbles.size()` ist 1

Review (17.10.2026): gemergt.
