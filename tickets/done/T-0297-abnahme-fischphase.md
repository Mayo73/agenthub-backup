---
id: T-0297
title: Abnahmetests der Fischphase
project: zellenphase
priority: 4
after: T-0284, T-0291, T-0295
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“: Eine Testdatei prüft die Fischphase als Ganzes, so wie sie abgenommen werden soll: Der erste Fisch übernimmt die Teile der Zelle, jede Verbesserung ist am Modell sichtbar und in den Werten spürbar, Fressen lässt den Fisch wachsen, und der Fortschritt landet im Spielstand.

## Dateien
- `tests/test_abnahme_fischphase.gd` – neu

## Akzeptanzkriterien
Neue Datei `tests/test_abnahme_fischphase.gd` (`extends "res://tests/base_test.gd"`). Hilfsfunktion in der Datei:
```gdscript
## Lädt die Fischszene und hängt sie an die Wurzel (wie in tests/test_fish_main.gd).
func load_fish() -> FishMain:
	var f: FishMain = load("res://scenes/fish.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(f)
	return f
```
`teardown()` ruft `FishStart.clear()` und löscht die Testdatei `const SAVE := "user://test_abnahme_fisch.json"`, falls vorhanden. Jeder Test gibt seine Szene am Ende mit `free()` frei.

## Tests
- `test_uebergang_traegt_teile`: `var cell := CellBuild.new()`; `cell.add_part("geissel", Vector2(-1, 0))`; `cell.add_part("kiefer", Vector2(1, 0))`; `cell.add_part("stachel", Vector2(0, 1))`; `FishStart.pending_build = FishStart.from_cell(cell, CellLook.new(), Diet.FLEISCHFRESSER)`; `var f := load_fish()` → `f.player.build.level("schwanz")` ist 1, `level("kiefer")` ist 1, `level("stacheln")` ist 1, `f.player.build.diet` ist `Diet.FLEISCHFRESSER`, `f.player.model.jaw != null` wahr, `f.player.model.spikes.size()` ist 2
- `test_jede_verbesserung_sichtbar`: `var f := load_fish()`; `f.progress.dna = 200`; für jedes `slot` in `FishBuild.SLOTS`: vorher `var vorher := FishModel.shape(f.player.build)`; `f.evolve.open(f.player.build, f.progress)`; `f.evolve.try_upgrade(slot)`; danach `FishModel.shape(f.player.build) != vorher` wahr (Meldung: `"%s sichtbar" % slot`)
- `test_verbesserungen_spuerbar`: `var f := load_fish()`; `f.progress.dna = 200`; `var tempo: float = f.player.motion.max_speed`; `var wende: float = f.player.motion.turn_rate`; `var nebel: float = f.water.environment.fog_density`; `f.evolve.open(f.player.build, f.progress)`; `try_upgrade` für `"schwanz"`, `"flossen"` und `"augen"` → `max_speed > tempo`, `turn_rate > wende`, `fog_density < nebel`
- `test_wachsen`: `var f := load_fish()`; `f.eat_value(FishProgress.GROWTH_NEEDED[0])` → `f.progress.stage` ist 1, `f.player.size` ist `FishProgress.SIZES[1]`
- `test_spielstand_und_fortsetzen`: `SaveGame.write_file(SAVE, {"version": 1})`; `var f := load_fish()`; `f.save_path = SAVE`; `f.progress.dna = 33`; `f.save_now()` wahr; `f.free()`; `var d := SaveGame.read_file(SAVE)`; `FishStart.pending_fish = d["fish"]`; `var g := load_fish()` → `g.progress.dna` ist 33; `g.free()`

Review (18.10.2026): gemergt.
