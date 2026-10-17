---
id: T-0195
title: Zellen platzen im Spiel, wenn sie sterben
project: zellenphase
priority: 3
after: T-0191, T-0194
---
## Ziel
Besiegte KI-Zellen und die Spielerzelle bei ihrem Tod platzen sichtbar in Bruchstücke.

## Dateien
- `scripts/main.gd`
- `tests/test_main_platzen.gd`: neu

## Akzeptanzkriterien
In `scripts/main.gd`:
- Neue Variable direkt unter `var bubble_timer := 0.0`: `var burst_view: DeathBurstView`
- In `_ready()` direkt nach der Zeile `world.add_child(bubble_view)`:
```gdscript
	burst_view = DeathBurstView.new()
	burst_view.name = "Bursts"
	world.add_child(burst_view)
```
- In `resolve_combat()` im Block `if cell.health.is_dead():` direkt nach der Zeile `stats.cells_defeated += 1`: `burst_view.bursts.add(cell.motion.position, cell.radius, cell.color)`
- In `check_death()` direkt nach der Zeile `stats.deaths += 1`: `burst_view.bursts.add(player.motion.position, player.radius, player.look.color)`
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_platzen.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`.
- `test_in_der_welt`: `main.burst_view.get_parent() == main.world` wahr
- `test_ki_platzt`: `var cell := AiCell.new()`, `cell.setup("blasenling", Vector2(300, 0))`, `main.world.add_child(cell)`, `main.ai_cells.append(cell)`, `cell.health.damage(1000.0)`, `main.resolve_combat()` → `main.burst_view.bursts.bursts.size()` ist 1; `(main.burst_view.bursts.bursts[0]["pos"] as Vector2).is_equal_approx(Vector2(300, 0))` wahr
- `test_spieler_platzt`: `main.player_health.damage(1000.0)`, `main.check_death()` → `main.burst_view.bursts.bursts.size()` ist 1

Review (17.10.2026): gemergt.
