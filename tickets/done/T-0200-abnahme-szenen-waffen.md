---
id: T-0200
title: Abnahmetest – Stachel, Gift und Elektroorgan in den Vorführszenen
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 6: Stachelkontakt, Giftwirkung und elektrische Abwehr werden in den Vorführszenen „stachel“, „gift“ und „elektro“ geprüft. Weil sich im Test nichts von selbst bewegt, setzt der Test die Gegnerzelle jeweils an die Stelle, an der die Waffe wirkt. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_abnahme_waffen.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_abnahme_waffen.gd` anlegen. Keine Datei unter `scripts/` ändern.
- Kopf: `extends "res://tests/base_test.gd"`, `const P := "user://test_abnahme_waffen.json"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, danach `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()` und die Datei `P` löschen, falls vorhanden (`DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`). So wird nie der echte Spielstand überschrieben.
- Hilfsfunktion (nicht `test_` benennen): `func _put(cell: AiCell, pos: Vector2) -> void:` setzt `cell.motion.position = pos` und `cell.position = pos`.

## Tests
- `test_stachel`: `main.start_scene("stachel")`; `var cell: AiCell = main.ai_cells[0]`; `var tips := WeaponRules.spike_tips(main.player.motion.position, main.player.motion.heading, main.player.radius, main.player.build)` → `tips.size()` ist 1; `_put(cell, tips[0] + Vector2(cell.radius * 0.5, 0))`, `var vorher: float = cell.health.hp`, `main.resolve_weapons(0.016)` → `cell.health.hp < vorher` wahr
- `test_stachel_nur_vorn`: `main.start_scene("stachel")`; `var cell: AiCell = main.ai_cells[0]`; `_put(cell, Vector2(-main.player.radius - cell.radius * 0.9, 0))` (hinter der Zelle), `var vorher: float = cell.health.hp`, `main.resolve_weapons(0.016)` → `cell.health.hp` ist `vorher`
- `test_gift`: `main.start_scene("gift")`; `main.player.motion.velocity = Vector2(100, 0)`; `main.resolve_weapons(0.016)` → `main.poison.clouds.size()` ist 1; dann `var cell: AiCell = main.ai_cells[0]`, `_put(cell, main.poison.clouds[0]["pos"])`, `var vorher: float = cell.health.hp`, `main.resolve_weapons(0.5)` → `cell.health.hp < vorher` wahr
- `test_elektro`: `main.start_scene("elektro")`; `var cell: AiCell = main.ai_cells[0]`; `_put(cell, Vector2(main.player.radius + cell.radius, 0))`, `var vorher: float = cell.health.hp`, `main.resolve_weapons(0.016)` → `cell.health.hp` ist `vorher - ElectricOrgan.DAMAGE`; `main.electric.is_ready()` falsch
- `test_elektro_zu_weit`: `main.start_scene("elektro")`; `var cell: AiCell = main.ai_cells[0]`; `_put(cell, Vector2(main.player.radius * 3.0 + cell.radius, 0))`, `var vorher: float = cell.health.hp`, `main.resolve_weapons(0.016)` → `cell.health.hp` ist `vorher`; `main.electric.is_ready()` wahr

Review (17.10.2026): gemergt.
