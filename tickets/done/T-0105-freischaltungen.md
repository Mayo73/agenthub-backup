---
id: T-0105
title: Freigeschaltete Teile (PartUnlocks)
project: zellenphase
priority: 3
after: T-0102
---
## Ziel
Merkt sich, welche Teile der Spieler im Editor verwenden darf. Zu Beginn nur Filtermaul, Kiefer und Knopfauge, weitere kommen über Teilefunde in fester Reihenfolge dazu.

## Dateien
- `scripts/part_unlocks.gd`: neu
- `tests/test_part_unlocks.gd`: neu

## Akzeptanzkriterien
`scripts/part_unlocks.gd` genau so:
```gdscript
class_name PartUnlocks
extends RefCounted
## Welche Teile der Spieler schon im Zelleditor verwenden darf.

var unlocked: Array[String] = []


func _init() -> void:
	for id in PartCatalog.STARTER:
		unlocked.append(id)


func is_unlocked(id: String) -> bool:
	return unlocked.has(id)


## Schaltet ein Teil frei. false, wenn es unbekannt oder schon frei ist.
func unlock(id: String) -> bool:
	if not PartCatalog.exists(id) or unlocked.has(id):
		return false
	unlocked.append(id)
	return true


## Das nächste noch gesperrte Teil laut PartCatalog.UNLOCK_ORDER, "" wenn alle frei sind.
func next_locked() -> String:
	for id in PartCatalog.UNLOCK_ORDER:
		if not unlocked.has(id):
			return id
	return ""


func all_unlocked() -> bool:
	return next_locked() == ""
```

## Tests
`tests/test_part_unlocks.gd` mit `extends "res://tests/base_test.gd"`, `var u: PartUnlocks`, `setup()`: `u = PartUnlocks.new()`.
- `test_start`: `u.unlocked.size()` ist 3; `u.is_unlocked("filtermaul")` wahr; `u.is_unlocked("geissel")` falsch; `u.next_locked()` ist `"geissel"`
- `test_freischalten`: `u.unlock("geissel")` wahr; nochmals `u.unlock("geissel")` falsch; `u.unlock("gibtsnicht")` falsch; `u.next_locked()` ist `"stachel"`
- `test_ausser_der_reihe`: `u.unlock("wimpern")` wahr → `u.next_locked()` ist weiterhin `"geissel"`
- `test_alle_frei`: jede ID aus `PartCatalog.UNLOCK_ORDER` freischalten → `u.all_unlocked()` wahr, `u.next_locked()` ist `""`, `u.unlocked.size()` ist 11

Review (16.10.2026): gemergt.
