---
id: T-0096
title: KI-Zellen in der Hauptszene
project: zellenphase
priority: 3
after: T-0090, T-0094, T-0095
---
## Ziel
In der Hauptszene leben 30 KI-Zellen um den Spieler. Sie entscheiden jeden Schritt (fliehen, jagen, Nahrung suchen), fressen passende Nahrung mit dem Maul und verschwinden, wenn sie zu weit weg sind.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variablen unter `var hud: Hud`: `var spawner := EcoSpawner.new(11)` und `var ai_cells: Array[AiCell] = []`
- In `_physics_process` nach `refill_food()` anhängen: `spawn_ai()`, `despawn_far_ai()`, `think_ai()`, `feed_ai()`
- Neue Funktionen am Ende:
```gdscript
## Füllt die KI-Zellen auf EcoSpawner.TARGET_COUNT auf.
func spawn_ai() -> void:
	var spread := EcoSpawner.view_scale(player.radius)
	for i in EcoSpawner.missing(ai_cells.size()):
		var cell := AiCell.new()
		cell.setup(spawner.pick_species(progress.stage), spawner.spawn_position(player.position, spread))
		world.add_child(cell)
		ai_cells.append(cell)


func remove_ai(cell: AiCell) -> void:
	ai_cells.erase(cell)
	world.remove_child(cell)
	cell.queue_free()


func despawn_far_ai() -> void:
	var spread := EcoSpawner.view_scale(player.radius)
	for cell in ai_cells.duplicate():
		if EcoSpawner.is_too_far(player.position, cell.position, spread):
			remove_ai(cell)


## Jede KI-Zelle entscheidet anhand aller Zellen (Spieler eingeschlossen) und der nächsten Nahrung.
func think_ai() -> void:
	var infos: Array = [{"position": player.position, "radius": player.radius, "diet": player.diet}]
	for cell in ai_cells:
		infos.append(cell.info())
	for cell in ai_cells:
		var kind := Diet.FLEISCH if cell.diet == Diet.FLEISCHFRESSER else Diet.PFLANZE
		var item := food.nearest(cell.position, kind, cell.brain.sight)
		cell.think(infos, item.position if item != null else null)


func feed_ai() -> void:
	for cell in ai_cells:
		food.take_at(cell.mouth_point(), MOUTH_REACH, cell.diet)
```

## Tests
In `tests/test_main_wiring.gd` anhängen:
- `test_ki_zellen`: `main.spawn_ai()` → `main.ai_cells.size()` ist 30, `main.ai_cells[0].get_parent() == main.world` ist wahr; nochmals `main.spawn_ai()` → weiterhin 30
- `test_ki_entfernen`: `main.spawn_ai()`, dann `main.ai_cells[0].position = Vector2(99999, 0)` und `main.despawn_far_ai()` → `main.ai_cells.size()` ist 29
- `test_ki_entscheidet`: `main.spawn_ai()`, `main.think_ai()` → für jede Zelle ist `cell.brain.state` eins von `AiBrain.SUCHEN`, `AiBrain.JAGEN`, `AiBrain.FLIEHEN`, `AiBrain.TREIBEN`
- `test_ki_frisst`: `main.food.items.clear()`, eine `AiCell` mit `setup("blasenling", Vector2(300, 0))` in `main.world` einhängen und an `main.ai_cells` anhängen, `main.food.add_item(Diet.PFLANZE, cell.mouth_point())`, `main.feed_ai()` → `main.food.items.size()` ist 0

Review (16.10.2026): gemergt, nachgebessert: Konstante AiBrain im Test entfernt (verdeckte die globale Klasse).
