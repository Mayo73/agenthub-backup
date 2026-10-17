---
id: T-0145
title: Klänge und Musik im Spiel
project: zellenphase
priority: 3
after: T-0139, T-0144
---
## Ziel
Im Spiel laufen Musik und Wasserrauschen, Fressen, Wachsen, Treffer und Tod sind hörbar (Lastenheft „Audio“). Die Lautstärken aus den Einstellungen wirken, weil die Busse jetzt existieren.

## Dateien
- `scripts/main.gd`
- `tests/test_main_audio.gd`: neu

## Akzeptanzkriterien
- Neue Variable direkt unter `var settings_menu: SettingsMenu`: `var audio: GameAudio`
- Am Ende von `_ready()`:
```gdscript
	audio = GameAudio.new()
	audio.name = "Audio"
	add_child(audio)
	apply_settings()
```
- In `feed_player()` in der Schleife `for item in food.take_at(...)` als **erste** Zeile (vor `if progress.eat(item.value):`, gleiche Einrückung wie dieses `if`):
```gdscript
		audio.play("fressen_pflanze" if item.kind == Diet.PFLANZE else "fressen_fleisch")
```
  und im Block `if progress.eat(item.value):` als erste Zeile `audio.play("wachsen")`.
- In `resolve_combat()` direkt nach der Zeile `cell.motion.knockback(cell.motion.position - player.motion.position, 120.0)` eine Zeile `audio.play("treffer")` mit derselben Einrückung; ebenso direkt nach `player.motion.knockback(player.motion.position - cell.motion.position, 160.0)`.
- In `check_death()` direkt nach `deaths += 1` die Zeile `audio.play("tod")`.
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_audio.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`.
- `test_audio_da`: `main.audio != null` wahr; `AudioServer.get_bus_index("Musik") >= 0` wahr; `AudioServer.get_bus_index("Effekte") >= 0` wahr
- `test_fressen_klingt`: `main.food.items.clear()`, `main.food.add_item(Diet.PFLANZE, main.player.mouth_point())`, `main.feed_player()` → `main.audio.last_played` ist `"fressen_pflanze"`
- `test_wachsen_klingt`: `main.food.items.clear()`, `main.progress.eat(9)`, `main.food.add_item(Diet.PFLANZE, main.player.mouth_point())`, `main.feed_player()` → `main.audio.last_played` ist `"wachsen"`
- `test_tod_klingt`: `main.player_health.damage(1000.0)`, `main.check_death()` → `main.audio.last_played` ist `"tod"`

Review (16.10.2026): gemergt.
