---
id: T-0090
title: Zelle wächst beim Größenwechsel
project: zellenphase
priority: 4
after: T-0089
---
## Ziel
Steigt die Spielerzelle in den nächsten Größenabschnitt auf, wird sie größer und etwas schneller. Die Kamera zoomt dadurch automatisch heraus (CameraZoom nutzt `player.radius`).

## Dateien
- `scripts/player_cell.gd`
- `scripts/main.gd`
- `tests/test_player_cell.gd`: neuen Test anhängen, bestehende nicht ändern
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/player_cell.gd`, neue Funktion direkt nach `mouth_point`:
```gdscript
## Passt Größe und Tempo an den Größenabschnitt an (0 bis 4).
func set_stage(stage: int) -> void:
	radius = CellProgress.radius_for_stage(stage)
	motion.max_speed = 220.0 + 30.0 * stage
	queue_redraw()
```
- `scripts/main.gd`, in `feed_player()` die Zeile `progress.eat(item.value)` ersetzen durch:
```gdscript
		if progress.eat(item.value):
			player.set_stage(progress.stage)
```

## Tests
- `tests/test_player_cell.gd`, neue Methode `test_wachsen`: `cell.set_stage(2)` → `cell.radius` ist 27.0, `cell.motion.max_speed` ist 280.0
- `tests/test_main_wiring.gd`, neue Methode `test_wachsen_beim_fressen`: `main.food.items.clear()`, `main.progress.eat(9)`, `main.food.add_item(Diet.PFLANZE, main.player.mouth_point())`, `main.feed_player()` → `main.progress.stage` ist 1, `main.player.radius` ist 18.0

Review (16.10.2026): gemergt, nachgebessert: fehlende Leerzeile vor set_stage
