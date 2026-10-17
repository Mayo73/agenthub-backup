---
id: T-0221
title: Blitze des Elektroorgans im Spiel anzeigen
project: zellenphase
priority: 2
after: T-0220, T-0218
---
## Ziel
Entlädt sich das Elektroorgan der Spielerzelle, sieht man Blitze zu jeder getroffenen Zelle.

## Dateien
- `scripts/main.gd`
- `tests/test_main_blitz.gd` – neu

## Akzeptanzkriterien
- In `scripts/main.gd` direkt unter `var poison_view: PoisonCloudView`:
```gdscript
var zap_view: ZapView
```
- In `_ready()` direkt nach der Zeile `world.add_child(poison_view)`:
```gdscript

	zap_view = ZapView.new()
	zap_view.name = "Zaps"
	world.add_child(zap_view)
```
- In `resolve_weapons(delta)`:
  - direkt nach `var zapped := false` die Zeile `var zap_targets: Array[Vector2] = []` einfügen;
  - im Block `if zap and ElectricOrgan.in_range(...)` nach `zapped = true` die Zeile `zap_targets.append(cell.motion.position)` einfügen;
  - der Schluss `if zapped:` ruft nach `electric.fire()` zusätzlich `zap_view.show_zaps(pos, zap_targets)` auf.
- Sonst nichts ändern.

## Tests
`tests/test_main_blitz.gd` mit `extends "res://tests/base_test.gd"`, `const P := "user://test_main_blitz.json"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`, dann `if FileAccess.file_exists(P): DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`:
- `test_knoten`: `main.world.get_node("Zaps") is ZapView` wahr
- `test_blitz_bei_entladung`: `main.start_scene("elektro")`, `main.ai_cells[0].motion.position = Vector2(40, 0)`, `main.resolve_weapons(0.016)` → `main.zap_view.is_zap_visible()` wahr; `main.zap_view.lines.size()` ist 1; `main.zap_view.lines[0][6]` ist `Vector2(40, 0)`
- `test_kein_ziel`: `main.start_scene("elektro")`, `main.ai_cells[0].motion.position = Vector2(500, 0)`, `main.resolve_weapons(0.016)` → `main.zap_view.is_zap_visible()` falsch

Review (17.10.2026): fehlgeschlagen (Agent hat sich in main.gd verrannt, Zeitlimit), von Claude selbst umgesetzt.
