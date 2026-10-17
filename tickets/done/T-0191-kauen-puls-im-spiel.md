---
id: T-0191
title: Kauen und Wachstumspuls im Spiel auslösen
project: zellenphase
priority: 3
after: T-0182, T-0190
---
## Ziel
Die Spielerzelle kaut, wenn sie frisst oder eine andere Zelle beißt, und pulsiert, wenn sie in den nächsten Größenabschnitt wächst.

## Dateien
- `scripts/main.gd`
- `tests/test_main_kauen.gd`: neu

## Akzeptanzkriterien
In `scripts/main.gd`:
- In `feed_player()` direkt nach der Zeile `stats.food_eaten += 1`: `player.bite()`
- In `feed_player()` direkt nach der Zeile `player.set_stage(progress.stage)`: `player.pulse()`
- In `resolve_combat()` im Block, der mit `if cell.health.damage(CombatRules.bite_damage(CombatRules.PLAYER_BITE, …)):` beginnt, als letzte Zeile des Blocks (nach `audio.play("treffer")`, gleiche Einrückung): `player.bite()`
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_kauen.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`.
- `test_kauen_beim_fressen`: `main.start_new(Diet.PFLANZENFRESSER)`, `main.food.items.clear()`, `main.food.add_item(Diet.PFLANZE, main.player.mouth_point())`, `main.feed_player()` → `main.player.chew_left > 0.0` wahr
- `test_kauen_beim_biss`: `main.player.diet = Diet.FLEISCHFRESSER`; `var cell := AiCell.new()`, `cell.setup("schnapper", Vector2(30, 0))`, `cell.motion.heading = 0.0`, `main.world.add_child(cell)`, `main.ai_cells.append(cell)`; `main.resolve_combat()` → `main.player.chew_left > 0.0` wahr
- `test_ruhig`: `main.player.chew_left` ist 0.0; `main.player.pulse_left` ist 0.0

Review (17.10.2026): gemergt.
