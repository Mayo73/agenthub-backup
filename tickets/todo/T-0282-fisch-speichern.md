---
id: T-0282
title: Fischphase speichert in den Spielstand
project: zellenphase
priority: 4
after: T-0280, T-0281
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“: Die Fischphase schreibt ihren Fortschritt in denselben Spielstand-Platz wie die Zellenphase (Schlüssel `"fish"`): beim Wachsen, nach jeder Verbesserung und beim Wechsel ins Hauptmenü. Den Pfad übergibt die Zellenphase beim Szenenwechsel über `FishStart`.

## Dateien
- `scripts/fish_start.gd`
- `scripts/main.gd`
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_start.gd`: unter `static var pending_dna := 0` die Zeile `static var pending_save_path := ""` mit Kommentar `## Spielstand-Datei des aktuellen Platzes (leer = nicht speichern).`; in `clear()` zusätzlich `pending_save_path = ""`.
- `scripts/main.gd`, `prepare_fish()`: als letzte Zeile `FishStart.pending_save_path = save_path`.
- `scripts/fish_main.gd`:
  - Variable `var save_path := ""` unter `var paused := false`.
  - In `_ready()` direkt vor der Zeile `FishStart.clear()` die Zeile `save_path = FishStart.pending_save_path`.
  - Neue Funktion am Ende:
```gdscript
## Schreibt den Fortschritt der Fischphase in den Spielstand (Schlüssel FishSave.KEY). false ohne Pfad.
func save_now() -> bool:
	if save_path == "":
		return false
	var data := SaveGame.read_file(save_path)
	data[FishSave.KEY] = FishSave.to_dict(player.build, progress)
	return SaveGame.write_file(save_path, data)
```
  - `save_now()` aufrufen: in `eat_value(value)` direkt nach `player.set_size(progress.size())`; in `_on_upgraded(slot)` als letzte Zeile; in `back_to_menu()` als erste Zeile.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen; Testdatei `const FISH_SAVE := "user://test_fisch_speichern.json"`, am Ende jedes Tests löschen (`DirAccess.remove_absolute(ProjectSettings.globalize_path(FISH_SAVE))`, nur wenn sie existiert):
- `test_ohne_pfad`: `fish.save_now()` ist falsch
- `test_speichern`: `SaveGame.write_file(FISH_SAVE, {"version": 1, "dna": 5})`; `fish.save_path = FISH_SAVE`; `fish.progress.dna = 12`; `fish.save_now()` wahr → `var d := SaveGame.read_file(FISH_SAVE)`; `d["dna"]` ist 5 (Zellenphase bleibt erhalten); `FishSave.has_fish(d)` wahr; `d["fish"]["dna"]` ist 12
- `test_pfad_uebergabe`: `FishStart.pending_save_path = FISH_SAVE`; neue Fischszene laden und an die Wurzel hängen (wie in `test_uebergabe`) → ihr `save_path` ist `FISH_SAVE`; `FishStart.pending_save_path` ist `""`; Szene freigeben
- `test_speichern_nach_verbessern`: `fish.save_path = FISH_SAVE`; `fish.progress.dna = 20`; `fish.toggle_evolve()`; `fish.evolve.try_upgrade("augen")` → `SaveGame.read_file(FISH_SAVE)["fish"]["build"]["levels"]["augen"]` ist 1
