---
id: T-0098
title: Kampf in der Hauptszene
project: zellenphase
priority: 3
after: T-0096, T-0097
---
## Ziel
Fleisch- und Allesfresser beißen mit dem Maul: Die Spielerzelle kann KI-Zellen verletzen und besiegen (sie hinterlassen Fleisch), bissige KI-Zellen verletzen den Spieler. Treffer stoßen zurück.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variable unter `var ai_cells: Array[AiCell] = []`: `var player_health := CellHealth.new()`
- `_physics_process`: Parameter `_delta` in `delta` umbenennen; als **erste** Zeile `player_health.tick(delta)`, als **letzte** Zeile `resolve_combat()`
- Neue Funktion am Ende:
```gdscript
## Bisse zwischen Spieler und KI-Zellen; besiegte KI-Zellen werden zu Fleisch.
func resolve_combat() -> void:
	for cell in ai_cells.duplicate():
		if CombatRules.can_bite(player.diet) and CombatRules.bite_hits(player.motion.position, player.motion.heading, player.radius, cell.motion.position, cell.radius):
			if cell.health.damage(CombatRules.bite_damage(CombatRules.PLAYER_BITE, player.radius, cell.radius)):
				cell.motion.knockback(cell.motion.position - player.motion.position, 120.0)
		if cell.damage > 0.0 and CombatRules.can_bite(cell.diet) and CombatRules.bite_hits(cell.motion.position, cell.motion.heading, cell.radius, player.motion.position, player.radius):
			if player_health.damage(CombatRules.bite_damage(cell.damage, cell.radius, player.radius)):
				player.motion.knockback(player.motion.position - cell.motion.position, 160.0)
		if cell.health.is_dead():
			for pos in CombatRules.meat_positions(cell.motion.position, cell.radius):
				food.add_item(Diet.FLEISCH, pos)
			remove_ai(cell)
```

## Tests
In `tests/test_main_wiring.gd` anhängen. Hilfsfunktion in der Testdatei (nicht `test_` benennen):
```gdscript
func _add_ai(id: String, pos: Vector2, heading: float) -> AiCell:
	var cell := AiCell.new()
	cell.setup(id, pos)
	cell.motion.heading = heading
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	return cell
```
Die Spielerzelle steht nach dem Start bei (0, 0), Blick nach rechts, Radius 12.
- `test_spieler_beisst`: `main.player.diet = Diet.FLEISCHFRESSER`; `var meat_before := main.food.count_kind(Diet.FLEISCH)`; `_add_ai("blasenling", Vector2(20, 0), 0.0)`; `main.resolve_combat()` → `main.ai_cells.size()` ist 0; `main.food.count_kind(Diet.FLEISCH)` ist `meat_before + 3`
- `test_pflanzenfresser_beisst_nicht`: wie oben ohne Änderung von `diet` → `cell.health.hp` ist 20.0, `main.ai_cells.size()` ist 1
- `test_ki_beisst`: `_add_ai("schnapper", Vector2(30, 0), PI)`; `main.resolve_combat()` → `main.player_health.hp` ist 77.5
- `test_ki_von_hinten_harmlos`: `_add_ai("schnapper", Vector2(30, 0), 0.0)` (Körper berühren sich, Maul zeigt weg); `main.resolve_combat()` → `main.player_health.hp` ist 100.0

Review (16.10.2026): gemergt.
