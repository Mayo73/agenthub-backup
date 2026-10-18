---
id: T-0283
title: Fischszene übernimmt einen gespeicherten Fischstand
project: zellenphase
priority: 4
after: T-0282
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“, Teil „Fortsetzen“: Wird ein Spielstand fortgesetzt, der schon in der Fischphase war, soll die Fischszene Ausbau, DNA, Wachstum und Größe daraus übernehmen. Dafür bekommt `FishStart` eine weitere Übergabe `pending_fish` (das Dictionary unter dem Schlüssel `"fish"` im Spielstand). Den Aufruf aus dem Hauptmenü baut T-0284 ein.

## Dateien
- `scripts/fish_start.gd`
- `scripts/fish_main.gd`
- `tests/test_fish_start.gd` – Test anhängen
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_start.gd`: unter `static var pending_save_path := ""` die Zeile
  `static var pending_fish: Dictionary = {}` mit dem Kommentar `## Gespeicherter Stand der Fischphase (FishSave.to_dict), leer = neuer Fisch.`
  In `clear()` zusätzlich `pending_fish = {}`.
- `scripts/fish_main.gd`, `_ready()`: direkt vor der Zeile `progress.dna = FishStart.pending_dna` nichts ändern; aber direkt **nach** dieser Zeile einfügen:
```gdscript
	if not FishStart.pending_fish.is_empty():
		player.set_build(FishSave.apply(FishStart.pending_fish, progress))
		player.set_size(progress.size())
```
  (Die Zeile `save_path = FishStart.pending_save_path` und `FishStart.clear()` bleiben, wo sie sind; `clear()` muss danach kommen.)
- Sonst nichts ändern.

## Tests
- `tests/test_fish_start.gd` anhängen: `test_fischstand_leeren`: `FishStart.pending_fish = {"dna": 3}`; `FishStart.clear()` → `FishStart.pending_fish.is_empty()` wahr.
- `tests/test_fish_main.gd` anhängen:
  - `test_fortsetzen_uebernimmt_stand`: `var b := FishBuild.new()`; `b.upgrade("schwanz")`; `b.upgrade("schwanz")`; `var p := FishProgress.new()`; `p.dna = 17`; `p.stage = 2`; `p.growth = 5`; `FishStart.pending_fish = FishSave.to_dict(b, p)`; neue Fischszene laden und an die Wurzel hängen (wie in `test_uebergabe`) → ihr `progress.dna` ist 17, `progress.stage` ist 2, `progress.growth` ist 5, `player.build.level("schwanz")` ist 2, `player.size` ist `FishProgress.SIZES[2]`, `player.motion.max_speed` ist 12.0; `FishStart.pending_fish.is_empty()` wahr; Szene freigeben.
  - `test_ohne_fischstand`: `FishStart.clear()`; neue Fischszene laden → `progress.stage` ist 0, `player.size` ist 1.0; Szene freigeben.

Review (18.10.2026): gemergt.
