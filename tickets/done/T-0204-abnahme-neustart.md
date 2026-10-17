---
id: T-0204
title: Abnahmetest – Spielstand und Einstellungen nach einem Neustart
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 10: Nach Speichern, vollständigem Beenden und Neustart stimmen Zellaufbau, Freischaltungen, DNA, Gesundheit und Entwicklungsstand mit dem gespeicherten Zustand überein; Audio- und Anzeigeeinstellungen bleiben erhalten. Der Test gibt die Hauptszene frei und lädt sie neu. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_abnahme_neustart.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_abnahme_neustart.gd` anlegen. Keine Datei unter `scripts/` ändern.
- Kopf: `extends "res://tests/base_test.gd"`, `const P := "user://test_abnahme_neustart_"`, `const S := "user://test_abnahme_neustart.cfg"`, `var main: Node2D`.
- Hilfsfunktion (nicht `test_` benennen); sie setzt die Pfade **vor** `add_child`, damit `_ready()` sie schon nutzt:
```gdscript
func _start_game() -> Node2D:
	var m: Node2D = load("res://scenes/main.tscn").instantiate()
	m.slot_prefix = P
	m.settings_path = S
	(Engine.get_main_loop() as SceneTree).root.add_child(m)
	return m
```
- `teardown()`: `main.free()`, falls `main != null and is_instance_valid(main)`; danach für `slot` von 1 bis 3 die Datei `SaveSlots.path_for(slot, P)` und die Datei `S` löschen, falls vorhanden (`DirAccess.remove_absolute(ProjectSettings.globalize_path(...))`).

## Tests
- `test_spielstand`:
  - `main = _start_game()`, `main.ask_slot_new(Diet.FLEISCHFRESSER)`, `main.slot_menu.slot_buttons[0].pressed.emit()`
  - `main.progress.eat(30)` (danach Abschnitt 2, Wachstum 5), `main.progress.dna = 42`, `main.unlocks.unlock("stachel")`; `var b: CellBuild = main.player.build.copy()`, `b.add_part("stachel", Vector2(1, 0))`, `main.player.set_build(b)`, `main.player.set_stage(main.progress.stage)`, `main.player_health.hp = 55.0`; `var l := CellLook.new()`, `l.color = Color.RED`, `l.set_pattern("punkte")`, `main.player.set_look(l)`; `main.save_now()` → wahr
  - `main.free()`, `main = _start_game()` → `main.in_menu` wahr; `main.main_menu.continue_button.disabled` falsch
  - `main.ask_slot_continue()`, `main.slot_menu.slot_buttons[0].pressed.emit()` → `main.in_menu` falsch; `main.progress.dna` ist 42; `main.progress.stage` ist 2; `main.progress.growth` ist 5; `main.unlocks.is_unlocked("stachel")` wahr; `main.player.build.parts.size()` ist 3; `main.player.build.count("stachel")` ist 1; `main.player.diet` ist `Diet.FLEISCHFRESSER`; `main.player_health.hp` ist 55.0; `main.player.look.color.is_equal_approx(Color.RED)` wahr; `main.player.look.pattern` ist `"punkte"`; `main.player.radius` ist `CellProgress.radius_for_stage(2)`
- `test_einstellungen`:
  - `main = _start_game()`, `main.settings.set_music_volume(0.3)`, `main.settings.set_sfx_volume(0.6)`, `main.settings.fullscreen = true`, `main.settings.set_resolution_index(1)`, `main.close_settings()`
  - `main.free()`, `main = _start_game()` → `main.settings.music_volume` ist 0.3; `main.settings.sfx_volume` ist 0.6; `main.settings.fullscreen` wahr; `main.settings.resolution_index` ist 1; wenn `AudioServer.get_bus_index("Musik") >= 0`: `AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musik"))` ist `UserSettings.to_db(0.3)`
  - Am Ende die Lautstärken zurücksetzen, damit andere Tests nicht gestört werden: `main.settings = UserSettings.new()`, `main.apply_settings()`

Review (17.10.2026): gemergt.
