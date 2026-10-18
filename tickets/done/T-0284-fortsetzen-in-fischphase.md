---
id: T-0284
title: „Fortsetzen“ springt in die Fischphase, wenn der Spielstand dort war
project: zellenphase
priority: 4
after: T-0283
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“, Teil „Fortsetzen“: Wählt der Spieler im Hauptmenü „Fortsetzen“ und hat der gewählte Spielstand schon einen Fischteil (`FishSave.has_fish`), geht es direkt in die Fischszene mit dem gespeicherten Fisch weiter, statt in die Zellenphase.

## Dateien
- `scripts/main.gd`
- `tests/test_main_fisch.gd` – Tests anhängen (dort gibt es schon `main` mit `main.save_path = P` und `teardown()` mit `FishStart.clear()`)

## Akzeptanzkriterien
- `scripts/main.gd`: neue Funktion direkt unter `go_to_fish()`:
```gdscript
## Fortsetzen in der Fischphase: gespeicherten Fisch und Spielstand-Pfad für FishMain hinterlegen.
## false, wenn der Spielstand noch keinen Fischteil hat.
func prepare_fish_continue(data: Dictionary) -> bool:
	if not FishSave.has_fish(data):
		return false
	FishStart.clear()
	FishStart.pending_fish = data[FishSave.KEY]
	FishStart.pending_save_path = save_path
	return true
```
- `_on_continue()` sieht danach so aus:
```gdscript
func _on_continue() -> void:
	if prepare_fish_continue(SaveGame.read_file(save_path)):
		get_tree().change_scene_to_file(FISH_SCENE)
		return
	if load_saved():
		show_menu(false)
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_main_fisch.gd` anhängen:
- `test_fortsetzen_ohne_fischteil`: `main.prepare_fish_continue({"version": 1, "dna": 4})` ist falsch; `FishStart.pending_fish.is_empty()` wahr.
- `test_fortsetzen_mit_fischteil`: `var fisch := {"build": FishBuild.new().to_dict(), "dna": 9, "growth": 0, "stage": 1}`; `main.prepare_fish_continue({"version": 1, "fish": fisch})` ist wahr; `FishStart.pending_fish["dna"]` ist 9; `FishStart.pending_save_path` ist `P`.
Review (18.10.2026): gemergt, nachgebessert: Test leert FishStart nach dem Lauf
