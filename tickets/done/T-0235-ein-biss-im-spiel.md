---
id: T-0235
title: Ein-Biss-Regel im Spiel – kleine Beute wird ganz verschluckt
project: zellenphase
priority: 2
after: T-0234, T-0233
---
## Ziel
Beißt die Spielerzelle (Fleisch- oder Allesfresser) eine deutlich kleinere KI-Zelle (`CombatRules.can_swallow`), verschluckt sie sie sofort ganz: keine Fleischbrocken, sondern direkt Nahrung, DNA und Wachstum wie beim Fressen. Gleich große Zellen werden wie bisher nur verletzt.

## Dateien
- `scripts/main.gd`
- `tests/test_main_verschlingen.gd` – neu

## Akzeptanzkriterien
- In `scripts/main.gd` die Funktion `feed_player()` so aufteilen, dass ihr Schleifenrumpf eine neue Funktion `eat_value()` ist. Danach sieht es genau so aus (der Inhalt von `eat_value` ist der bisherige Schleifenrumpf, nur mit `kind`/`value` statt `item.kind`/`item.value`):
```gdscript
## Frisst alles, was das Maul der Spielerzelle berührt und zur Ernährung passt.
func feed_player() -> void:
	for item in food.take_at(player.mouth_point(), MOUTH_REACH, player.diet):
		eat_value(item.kind, item.value)


## Wirkung eines Bissens Nahrung: Klang, Statistik, Kauen, DNA und Wachstum (mit Aufstieg in den nächsten Abschnitt).
func eat_value(kind: String, value: int) -> void:
	audio.play("fressen_pflanze" if kind == Diet.PFLANZE else "fressen_fleisch")
	stats.food_eaten += 1
	player.bite()
	hint("fressen")
	if progress.eat(value):
		player.set_stage(progress.stage)
		player.pulse()
		mate.add_charge()
		hud.show_message("Neuer Ruf bereit: Taste C oder rechte Maustaste")
		autosave_now()
		audio.play("wachsen")
		stats.record_stage(player.diet)
		hint("partner")
```
- Neue Funktion in `scripts/main.gd` direkt vor `## Nach dem Tod schlüpft eine neue Zelle …` (also vor `check_death()`):
```gdscript
## Ein-Biss-Regel: Die Spielerzelle verschluckt eine deutlich kleinere Zelle ganz.
func swallow(cell: AiCell) -> void:
	stats.cells_defeated += 1
	burst_view.bursts.add(cell.motion.position, cell.radius, cell.color)
	var part := PartDrops.drop_for(cell.species_id, unlocks)
	if part != "" and unlocks.unlock(part):
		hud.show_message("Teil erbeutet: %s" % PartCatalog.name_of(part))
	remove_ai(cell)
	eat_value(Diet.FLEISCH, CombatRules.swallow_value())
```
- In `resolve_combat()` im Block `if CombatRules.can_bite(player.diet) and CombatRules.bite_hits(...):` als **erste** Zeilen einfügen (vor `if cell.health.damage(...)`):
```gdscript
			if CombatRules.can_swallow(player.radius, cell.radius):
				swallow(cell)
				continue
```
- Sonst nichts ändern.

## Tests
`tests/test_main_verschlingen.gd` mit `extends "res://tests/base_test.gd"`, `const P := "user://test_main_verschlingen.json"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`, dann `if FileAccess.file_exists(P): DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`.

Die Szene „flucht“ setzt die Spielerzelle (Fleischfresser, Abschnitt 3, Radius 40) bei (0, 0) mit Blick nach rechts; ihr Maul liegt bei (40, 0). Darin schwimmt ein Blasenling (Radius 12).
- `test_kleine_beute_ganz`: `main.start_scene("flucht")`; `var dna: int = main.progress.dna`; `main.ai_cells[0].motion.position = Vector2(50, 0)`; `main.resolve_combat()` → `main.ai_cells.size()` ist 0; `main.food.count_kind(Diet.FLEISCH)` ist 0 (keine Fleischbrocken); `main.progress.dna` ist `dna + 6`; `main.stats.cells_defeated` ist 1
- `test_gleich_gross_nur_verletzt`: `main.start_scene("flucht")`; `main.remove_ai(main.ai_cells[0])`; `var c := AiCell.new()`, `c.setup("weidezelle", Vector2(70, 0))`, `main.world.add_child(c)`, `main.ai_cells.append(c)`; `c.motion.position = Vector2(70, 0)`; `main.resolve_combat()` → `main.ai_cells.size()` ist 1; `c.health.hp < c.health.max_hp` wahr
- `test_pflanzenfresser_verschluckt_nicht`: `main.start_scene("flucht")`; `main.player.diet = Diet.PFLANZENFRESSER`; `main.ai_cells[0].motion.position = Vector2(50, 0)`; `main.resolve_combat()` → `main.ai_cells.size()` ist 1
- `test_fressen_wie_bisher`: `main.start_scene("flucht")`; `var dna: int = main.progress.dna`; `main.eat_value(Diet.FLEISCH, 2)` → `main.progress.dna` ist `dna + 2`; `main.stats.food_eaten` ist 1

Review (17.10.2026): gemergt.
