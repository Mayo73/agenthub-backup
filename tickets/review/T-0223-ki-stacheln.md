---
id: T-0223
title: Stacheln der KI-Zellen verletzen die Spielerzelle
project: zellenphase
priority: 2
after: T-0222, T-0221
---
## Ziel
Wie in Spore tut es weh, eine Stachelkugel oder einen Hornjäger an den Stachelspitzen zu berühren. Dafür bekommt die Hauptszene eine Funktion für die Waffen der KI-Zellen.

## Dateien
- `scripts/main.gd`
- `tests/test_main_ki_waffen.gd` – neu

## Akzeptanzkriterien
- In `scripts/main.gd` direkt nach der Funktion `resolve_weapons(delta)` eine neue Funktion:
```gdscript


## Stacheln, Gift und Elektroorgane der KI-Zellen gegen die Spielerzelle.
func resolve_ai_weapons(delta: float) -> void:
	var factor := Difficulty.damage_factor(settings.difficulty)
	for cell in ai_cells:
		var tips := SpeciesWeapons.spike_tips(cell.species_id, cell.motion.position, cell.motion.heading, cell.radius)
		if WeaponRules.spike_hits(tips, player.motion.position, player.radius) > 0:
			if player_health.damage(WeaponRules.SPIKE_DAMAGE * factor):
				player.motion.knockback(player.motion.position - cell.motion.position, 140.0)
				player.flash.trigger()
				audio.play("treffer")
```
- In `_physics_process(delta)` direkt nach `resolve_weapons(delta)` die Zeile `resolve_ai_weapons(delta)` einfügen.
- Sonst nichts ändern.

## Tests
`tests/test_main_ki_waffen.gd` mit `extends "res://tests/base_test.gd"`, `const P := "user://test_main_ki_waffen.json"`, `var main: Node2D`. `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, `main.start_new(Diet.PFLANZENFRESSER)`, alle KI-Zellen mit `for cell in main.ai_cells.duplicate(): main.remove_ai(cell)` entfernen, `main.settings.difficulty = Difficulty.NORMAL`, `main.player_health.invulnerable = 0.0`. `teardown()`: `main.free()`, dann `if FileAccess.file_exists(P): DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`.

Hilfsfunktion (nicht `test_` benennen):
```gdscript
func _add(id: String, offset: Vector2) -> AiCell:
	var cell := AiCell.new()
	var pos: Vector2 = main.player.motion.position + offset
	cell.setup(id, pos)
	cell.motion.heading = 0.0
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	return cell
```
- `test_stachelkugel_sticht`: `_add("stachelkugel", Vector2(-30, 0))`, `var vorher: float = main.player_health.hp`, `main.resolve_ai_weapons(0.016)` → `vorher - main.player_health.hp` ist `WeaponRules.SPIKE_DAMAGE`
- `test_schwer`: `main.settings.difficulty = 2`, `_add("stachelkugel", Vector2(-30, 0))`, `var vorher: float = main.player_health.hp`, `main.resolve_ai_weapons(0.016)` → `vorher - main.player_health.hp` ist `WeaponRules.SPIKE_DAMAGE * 1.5`
- `test_ohne_stacheln`: `_add("blasenling", Vector2(-30, 0))`, `var vorher: float = main.player_health.hp`, `main.resolve_ai_weapons(0.016)` → `main.player_health.hp` ist `vorher`
- `test_weit_weg`: `_add("stachelkugel", Vector2(-200, 0))`, `var vorher: float = main.player_health.hp`, `main.resolve_ai_weapons(0.016)` → `main.player_health.hp` ist `vorher`
- `test_im_ablauf`: `FileAccess.get_file_as_string("res://scripts/main.gd").contains("resolve_ai_weapons(delta)")` wahr
