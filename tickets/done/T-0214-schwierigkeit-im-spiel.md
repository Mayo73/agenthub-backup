---
id: T-0214
title: Schwierigkeitsgrad bestimmt den Bissschaden im Spiel
project: zellenphase
priority: 3
after: T-0212, T-0195
---
## Ziel
Bisse anderer Zellen treffen die Spielerzelle je nach Schwierigkeitsgrad schwächer (Leicht) oder stärker (Schwer).

## Dateien
- `scripts/main.gd`
- `tests/test_main_schwierigkeit.gd`: neu

## Akzeptanzkriterien
In `scripts/main.gd`:
- Neue Funktion direkt über `func resolve_combat() -> void:`:
```gdscript
## Schaden, den der Biss einer KI-Zelle der Spielerzelle zufügt, mit dem Faktor des Schwierigkeitsgrads.
func enemy_bite_damage(cell: AiCell) -> float:
	return CombatRules.bite_damage(cell.damage, cell.radius, player.radius) * Difficulty.damage_factor(settings.difficulty)


```
- In `resolve_combat()` die Zeile `if player_health.damage(CombatRules.bite_damage(cell.damage, cell.radius, player.radius)):` ersetzen durch `if player_health.damage(enemy_bite_damage(cell)):` (gleiche Einrückung).
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_schwierigkeit.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`, `var cell: AiCell`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, `cell = AiCell.new()`, `cell.setup("schnapper", Vector2(300, 0))`; `teardown()`: `cell.free()`, `main.free()`. Kein Test speichert Einstellungen.
- `test_normal`: `main.settings.set_difficulty(1)` → `main.enemy_bite_damage(cell)` gleich `CombatRules.bite_damage(cell.damage, cell.radius, main.player.radius)` (mit `check_eq`)
- `test_leicht`: `main.settings.set_difficulty(0)` → `main.enemy_bite_damage(cell)` gleich `0.6 * CombatRules.bite_damage(cell.damage, cell.radius, main.player.radius)`
- `test_schwer`: `main.settings.set_difficulty(2)` → `main.enemy_bite_damage(cell)` gleich `1.5 * CombatRules.bite_damage(cell.damage, cell.radius, main.player.radius)`
- `test_aufruf`: `FileAccess.get_file_as_string("res://scripts/main.gd").contains("player_health.damage(enemy_bite_damage(cell))")` wahr

Review (17.10.2026): gemergt.
