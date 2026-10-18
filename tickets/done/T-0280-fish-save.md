---
id: T-0280
title: FishSave – Spielstand der Fischphase als Dictionary
project: zellenphase
priority: 4
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“: Der Fortschritt in der Fischphase (Ausbau, DNA, Wachstum, Größe) soll im Spielstand landen. `FishSave` wandelt ihn in ein Dictionary um und zurück. Geschrieben wird er in T-0282.

## Dateien
- `scripts/fish_save.gd` – neu
- `tests/test_fish_save.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_save.gd`, genau so:
```gdscript
class_name FishSave
extends RefCounted
## Spielstand der Fischphase: Ausbau und Fortschritt als Dictionary (Schlüssel "fish" im Spielstand).

const KEY := "fish"


static func to_dict(build: FishBuild, progress: FishProgress) -> Dictionary:
	return {"build": build.to_dict(), "dna": progress.dna, "growth": progress.growth, "stage": progress.stage}


## Überträgt DNA, Wachstum und Größe auf progress und gibt den gespeicherten Ausbau zurück.
static func apply(data: Dictionary, progress: FishProgress) -> FishBuild:
	progress.dna = maxi(0, int(data.get("dna", 0)))
	progress.growth = maxi(0, int(data.get("growth", 0)))
	progress.stage = clampi(int(data.get("stage", 0)), 0, FishProgress.SIZES.size() - 1)
	var b: Variant = data.get("build", {})
	return FishBuild.from_dict(b if b is Dictionary else {})


## Hat ein Spielstand schon einen Teil für die Fischphase?
static func has_fish(save_data: Dictionary) -> bool:
	return save_data.get(KEY) is Dictionary
```

## Tests
Neue Datei `tests/test_fish_save.gd` (`extends "res://tests/base_test.gd"`):
- `test_hin_und_zurueck`: `var b := FishBuild.new()`; `b.upgrade("kiefer")`; `b.diet = Diet.FLEISCHFRESSER`; `var p := FishProgress.new()`; `p.dna = 42`; `p.growth = 7`; `p.stage = 2`; `var d := FishSave.to_dict(b, p)`; `var p2 := FishProgress.new()`; `var b2 := FishSave.apply(d, p2)` → `p2.dna` 42, `p2.growth` 7, `p2.stage` 2, `b2.level("kiefer")` 1, `b2.diet` `Diet.FLEISCHFRESSER`
- `test_leer`: `var p := FishProgress.new()`; `var b := FishSave.apply({}, p)` → `p.dna` 0, `p.stage` 0, `b.total_levels()` 0
- `test_begrenzt`: `FishSave.apply({"stage": 9, "dna": -5}, p)` → `p.stage` ist 3, `p.dna` ist 0
- `test_hat_fisch`: `FishSave.has_fish({"fish": {}})` wahr; `FishSave.has_fish({})` falsch; `FishSave.has_fish({"fish": 3})` falsch

Review (18.10.2026): gemergt.
