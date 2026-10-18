---
id: T-0263
title: FishUpgrades – Bauteile mit DNA verbessern
project: zellenphase
priority: 4
---
## Ziel
Meilenstein „Fischphase – Weiterentwicklung“: Gesammelte DNA verbessert Bauteile. `FishUpgrades` kennt die Preise (je Stufe teurer) und führt eine Verbesserung aus, wenn die DNA reicht.

## Dateien
- `scripts/fish_upgrades.gd` – neu
- `tests/test_fish_upgrades.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_upgrades.gd`, genau so:
```gdscript
class_name FishUpgrades
extends RefCounted
## Verbessern der Bauteile mit DNA. Preis für die nächste Stufe: COSTS[aktuelle Stufe].

const COSTS := [10, 20, 35]


## DNA für die nächste Stufe; -1, wenn das Bauteil schon die höchste Stufe hat oder unbekannt ist.
static func cost(b: FishBuild, slot: String) -> int:
	if not slot in FishBuild.SLOTS or b.level(slot) >= FishBuild.MAX_LEVEL:
		return -1
	return COSTS[b.level(slot)]


static func can_upgrade(b: FishBuild, progress: FishProgress, slot: String) -> bool:
	var c := cost(b, slot)
	return c >= 0 and progress.dna >= c


## Gibt die DNA aus und erhöht das Bauteil um eine Stufe. false (ohne Änderung), wenn es nicht geht.
static func upgrade(b: FishBuild, progress: FishProgress, slot: String) -> bool:
	if not can_upgrade(b, progress, slot):
		return false
	progress.spend(cost(b, slot))
	b.upgrade(slot)
	return true
```

## Tests
Neue Datei `tests/test_fish_upgrades.gd` (`extends "res://tests/base_test.gd"`), in `setup()` je ein neues `FishBuild` und `FishProgress`:
- `test_preise`: `cost(b, "schwanz")` ist 10; nach `b.upgrade("schwanz")` 20; nach noch einem 35; nach dem dritten -1; `cost(b, "fluegel")` ist -1
- `test_zu_wenig_dna`: `p.dna = 9` → `can_upgrade(b, p, "augen")` falsch; `upgrade(b, p, "augen")` falsch; `p.dna` bleibt 9; `b.level("augen")` bleibt 0
- `test_verbessern`: `p.dna = 35` → `upgrade(b, p, "kiefer")` wahr; `p.dna` ist 25; `b.level("kiefer")` ist 1; noch einmal → wahr, `p.dna` 5, Stufe 2; noch einmal → falsch (35 > 5)
- `test_hoechste_stufe`: dreimal `b.upgrade("flossen")`; `p.dna = 100` → `upgrade(b, p, "flossen")` falsch, `p.dna` bleibt 100

Review (17.10.2026): gemergt.
