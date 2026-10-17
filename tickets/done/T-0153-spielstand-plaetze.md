---
id: T-0153
title: Drei Spielstandplätze (SaveSlots)
project: zellenphase
priority: 3
after: T-0118, T-0148
---
## Ziel
Mehrere lokale Spielstände (Lastenheft Soll): drei Plätze mit festen Dateinamen und einer Kurzbeschreibung für das Auswahlmenü.

## Dateien
- `scripts/save_slots.gd`: neu
- `tests/test_save_slots.gd`: neu

## Akzeptanzkriterien
`scripts/save_slots.gd` genau so:
```gdscript
class_name SaveSlots
extends RefCounted
## Drei lokale Spielstände: Dateipfade und Kurzbeschreibung für das Auswahlmenü.

const COUNT := 3
const PREFIX := "user://spielstand_"


## Pfad des Platzes slot (1 bis COUNT, wird begrenzt).
static func path_for(slot: int, prefix: String = PREFIX) -> String:
	return "%s%d.json" % [prefix, clampi(slot, 1, COUNT)]


## Kurzbeschreibung, z. B. "Größe 3 · 42 DNA · Pflanzenfresser"; "Leer", wenn kein Spielstand da ist.
static func summary(path: String) -> String:
	var data := SaveGame.read_file(path)
	if data.is_empty():
		return "Leer"
	return "Größe %d · %d DNA · %s" % [int(data.get("stage", 0)) + 1, int(data.get("dna", 0)), EndScreen.diet_name(str(data.get("diet", "")))]


## Nummer des ersten belegten Platzes (1 bis COUNT), 0 wenn alle leer sind.
static func first_used(prefix: String = PREFIX) -> int:
	for slot in range(1, COUNT + 1):
		if FileAccess.file_exists(path_for(slot, prefix)):
			return slot
	return 0
```

## Tests
`tests/test_save_slots.gd` mit `extends "res://tests/base_test.gd"`, `const P := "user://test_platz_"`; `teardown()`: für `slot` von 1 bis 3: `var path := SaveSlots.path_for(slot, P)`, wenn `FileAccess.file_exists(path)`: `DirAccess.remove_absolute(ProjectSettings.globalize_path(path))`.
- `test_pfade`: `SaveSlots.path_for(2)` ist `"user://spielstand_2.json"`; `SaveSlots.path_for(9, P)` ist `"user://test_platz_3.json"`; `SaveSlots.path_for(0, P)` ist `"user://test_platz_1.json"`
- `test_leer`: `SaveSlots.summary(SaveSlots.path_for(1, P))` ist `"Leer"`; `SaveSlots.first_used(P)` ist 0
- `test_beschreibung`: `SaveGame.write_file(SaveSlots.path_for(2, P), {"stage": 2, "dna": 42, "diet": Diet.PFLANZENFRESSER})` → `SaveSlots.summary(SaveSlots.path_for(2, P))` ist `"Größe 3 · 42 DNA · Pflanzenfresser"`; `SaveSlots.first_used(P)` ist 2

Review (16.10.2026): gemergt.
