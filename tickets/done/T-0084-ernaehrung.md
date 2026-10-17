---
id: T-0084
title: Ernährungsarten und Mundwerkzeuge (Diet)
project: zellenphase
priority: 4
---
## Ziel
Wie bei Spore bestimmen die Mundwerkzeuge, was eine Zelle fressen kann: Filtermaul → Pflanzen, Kiefer → Fleisch, Rüssel → beides.

## Dateien
- `scripts/diet.gd`: neu
- `tests/test_diet.gd`: neu

## Akzeptanzkriterien
`scripts/diet.gd` genau so:
```gdscript
class_name Diet
extends RefCounted
## Nahrungsarten, Ernährungsarten und die Mundwerkzeuge, die sie bestimmen.

const PFLANZE := "pflanze"
const FLEISCH := "fleisch"

const PFLANZENFRESSER := "pflanzenfresser"
const FLEISCHFRESSER := "fleischfresser"
const ALLESFRESSER := "allesfresser"

## IDs der Mundwerkzeuge (Teile)
const FILTERMAUL := "filtermaul"
const KIEFER := "kiefer"
const RUESSEL := "ruessel"


static func can_eat(diet: String, food_kind: String) -> bool:
	if diet == PFLANZENFRESSER:
		return food_kind == PFLANZE
	if diet == FLEISCHFRESSER:
		return food_kind == FLEISCH
	if diet == ALLESFRESSER:
		return food_kind == PFLANZE or food_kind == FLEISCH
	return false


## Ernährungsart aus den eingebauten Mundwerkzeugen. Leer, wenn keins dabei ist.
static func from_mouths(mouths: Array[String]) -> String:
	var plant := mouths.has(FILTERMAUL) or mouths.has(RUESSEL)
	var meat := mouths.has(KIEFER) or mouths.has(RUESSEL)
	if plant and meat:
		return ALLESFRESSER
	if plant:
		return PFLANZENFRESSER
	if meat:
		return FLEISCHFRESSER
	return ""
```

## Tests
`tests/test_diet.gd` mit `extends "res://tests/base_test.gd"`:
- `test_pflanzenfresser`: `Diet.can_eat(Diet.PFLANZENFRESSER, Diet.PFLANZE)` wahr, `(Diet.PFLANZENFRESSER, Diet.FLEISCH)` falsch
- `test_fleischfresser`: `(Diet.FLEISCHFRESSER, Diet.FLEISCH)` wahr, `(Diet.FLEISCHFRESSER, Diet.PFLANZE)` falsch
- `test_allesfresser`: beide wahr; `Diet.can_eat("", Diet.PFLANZE)` falsch; `Diet.can_eat(Diet.ALLESFRESSER, "stein")` falsch
- `test_aus_mundwerkzeugen`: mit typisierten Arrays (`var m: Array[String] = [...]`): `["filtermaul"]` → `Diet.PFLANZENFRESSER`; `["kiefer"]` → `Diet.FLEISCHFRESSER`; `["ruessel"]` → `Diet.ALLESFRESSER`; `["filtermaul", "kiefer"]` → `Diet.ALLESFRESSER`; `[]` → `""`

Review (16.10.2026): gemergt.
