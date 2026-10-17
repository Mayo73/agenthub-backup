---
id: T-0211
title: Schwierigkeitsgrade Leicht, Normal, Schwer (Difficulty)
project: zellenphase
priority: 3
---
## Ziel
Das Lastenheft nennt unter „Kann“ auswählbare Schwierigkeitsgrade. `Difficulty` legt drei Stufen fest und wie stark Bisse anderer Zellen die Spielerzelle treffen. Eingebaut wird in Folgetickets.

## Dateien
- `scripts/difficulty.gd`: neu
- `tests/test_difficulty.gd`: neu

## Akzeptanzkriterien
`scripts/difficulty.gd` genau so:
```gdscript
class_name Difficulty
extends RefCounted
## Schwierigkeitsgrade (Lastenheft „Kann“): Faktor für den Schaden, den Bisse anderer Zellen der Spielerzelle zufügen.

const NAMES := ["Leicht", "Normal", "Schwer"]
const DAMAGE := [0.6, 1.0, 1.5]
const NORMAL := 1


## Begrenzt einen Index auf die gültigen Stufen.
static func clamp_index(i: int) -> int:
	return clampi(i, 0, NAMES.size() - 1)


static func name_of(i: int) -> String:
	return NAMES[clamp_index(i)]


static func damage_factor(i: int) -> float:
	return DAMAGE[clamp_index(i)]
```

## Tests
`tests/test_difficulty.gd` mit `extends "res://tests/base_test.gd"`:
- `test_namen`: `Difficulty.name_of(0)` ist `"Leicht"`, `Difficulty.name_of(1)` ist `"Normal"`, `Difficulty.name_of(2)` ist `"Schwer"`
- `test_faktoren`: `Difficulty.damage_factor(0)` ist 0.6, `Difficulty.damage_factor(Difficulty.NORMAL)` ist 1.0, `Difficulty.damage_factor(2)` ist 1.5
- `test_grenzen`: `Difficulty.clamp_index(-3)` ist 0; `Difficulty.clamp_index(7)` ist 2; `Difficulty.damage_factor(9)` ist 1.5; `Difficulty.name_of(-1)` ist `"Leicht"`

Review (17.10.2026): gemergt.
