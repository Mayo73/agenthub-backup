---
id: T-0137
title: Neue Partie, Spielstand laden und automatisch speichern
project: zellenphase
priority: 3
after: T-0136, T-0118
---
## Ziel
Eine neue Partie beginnt als Pflanzen- oder Fleischfresser. Der Spielstand (mit Aussehen und Ernährung) lässt sich speichern und laden und wird nach jedem Editorbesuch und Größenwechsel automatisch gespeichert (Lastenheft „Bedienung und Speicherung“). Automatisch gespeichert wird erst, wenn eine Partie gestartet oder geladen wurde, damit Testläufe keinen echten Spielstand überschreiben.

## Dateien
- `scripts/main.gd`
- `tests/test_main_save.gd`: neu

## Akzeptanzkriterien
- Neue Variablen direkt unter `var editor: CellEditor`:
```gdscript
var save_path := SaveGame.DEFAULT_PATH
## Erst nach start_new() oder load_saved() wird automatisch gespeichert.
var autosave := false
```
- In `feed_player()` im Block `if progress.eat(item.value):` als letzte Zeile (gleiche Einrückung) `autosave_now()` anhängen.
- In `close_editor()` als letzte Zeile `autosave_now()` anhängen.
- Neue Funktionen am Ende:
```gdscript
## Neue Partie mit Startaufbau passend zur Ernährung (Pflanzen- oder Fleischfresser).
func start_new(diet: String) -> void:
	progress = CellProgress.new()
	player_health.reset()
	unlocks = PartUnlocks.new()
	mate = MateCall.new()
	player.diet = diet
	player.set_build(CellBuild.starter(diet))
	player.set_stage(0)
	player.set_look(CellLook.new())
	hud.show_progress(progress)
	autosave = true


func save_now() -> bool:
	var data := SaveGame.to_dict(progress, player_health, player.build, unlocks)
	data["look"] = player.look.to_dict()
	data["diet"] = player.diet
	return SaveGame.write_file(save_path, data)


func autosave_now() -> void:
	if autosave:
		save_now()


## Lädt den Spielstand; false, wenn keiner da ist oder er nicht passt.
func load_saved() -> bool:
	var data := SaveGame.read_file(save_path)
	if data.is_empty() or not SaveGame.apply(data, progress, player_health, unlocks):
		return false
	player.diet = str(data.get("diet", Diet.PFLANZENFRESSER))
	player.set_build(SaveGame.read_build(data))
	player.set_stage(progress.stage)
	var look_data: Variant = data.get("look")
	if look_data is Dictionary:
		player.set_look(CellLook.from_dict(look_data))
	hud.show_progress(progress)
	autosave = true
	return true
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_save.gd` mit `extends "res://tests/base_test.gd"`, `const PATH := "user://test_spielstand.json"`, `var main: Node2D`;
`setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, `main.save_path = PATH`;
`teardown()`: `main.free()` und `if FileAccess.file_exists(PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))`.
- `test_neue_partie_fleisch`: `main.start_new(Diet.FLEISCHFRESSER)` → `main.player.diet` ist `Diet.FLEISCHFRESSER`; `main.player.build.mouths()[0]` ist `"kiefer"`; `main.progress.dna` ist 0; `main.autosave` wahr
- `test_speichern_laden`: `main.start_new(Diet.PFLANZENFRESSER)`, `main.progress.dna = 17`, `main.unlocks.unlock("geissel")`, `main.player.build.add_part("geissel", Vector2(-1, 0))`, `var l := CellLook.new()`, `l.set_pattern("punkte")`, `main.player.set_look(l)`; `main.save_now()` wahr; dann `main.progress.dna = 0`, `main.unlocks.unlocked.clear()`, `main.player.set_build(CellBuild.new())`, `main.player.set_look(CellLook.new())`; `main.load_saved()` wahr → `main.progress.dna` ist 17; `main.unlocks.is_unlocked("geissel")` wahr; `main.player.build.parts.size()` ist 3; `main.player.look.pattern` ist `"punkte"`
- `test_ohne_spielstand`: `main.load_saved()` falsch; `main.autosave` falsch
- `test_autospeichern_nach_editor`: `main.start_new(Diet.PFLANZENFRESSER)`, `main.open_editor()`, `main.editor.cancel()` → `FileAccess.file_exists(PATH)` wahr
- `test_kein_autospeichern_ohne_partie`: `main.open_editor()`, `main.editor.cancel()` → `FileAccess.file_exists(PATH)` falsch
- `test_autospeichern_beim_wachsen`: `main.start_new(Diet.PFLANZENFRESSER)`, `main.food.items.clear()`, `main.progress.eat(9)`, `main.food.add_item(Diet.PFLANZE, main.player.mouth_point())`, `main.feed_player()` → `FileAccess.file_exists(PATH)` wahr

Review (16.10.2026): gemergt.
