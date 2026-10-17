---
id: T-0085
title: DNA und Wachstum (CellProgress)
project: zellenphase
priority: 4
---
## Ziel
Gefressene Nahrung bringt DNA (ausgebbar, z. B. im Editor) und Wachstum. Genug Wachstum hebt die Zelle in den nächsten von 5 Größenabschnitten.

## Dateien
- `scripts/cell_progress.gd`: neu
- `tests/test_cell_progress.gd`: neu

## Akzeptanzkriterien
`scripts/cell_progress.gd` genau so:
```gdscript
class_name CellProgress
extends RefCounted
## DNA (ausgebbar) und Wachstum (Fortschritt zum nächsten Größenabschnitt) der Spielerzelle.

const STAGE_COUNT := 5
## Wachstum, das vom Abschnitt i zum Abschnitt i + 1 nötig ist.
const GROWTH_NEEDED := [10, 15, 20, 25]
## Zellradius je Abschnitt in Pixeln.
const RADII := [12.0, 18.0, 27.0, 40.0, 60.0]

var dna := 0
var growth := 0
var stage := 0


## Rechnet gefressene Nahrung an. true, wenn die Zelle dabei mindestens einen Abschnitt aufsteigt.
func eat(value: int) -> bool:
	if value <= 0:
		return false
	dna += value
	growth += value
	var grew := false
	while stage < STAGE_COUNT - 1 and growth >= GROWTH_NEEDED[stage]:
		growth -= GROWTH_NEEDED[stage]
		stage += 1
		grew = true
	return grew


## Gibt DNA aus. false (und keine Änderung), wenn cost negativ ist oder die DNA nicht reicht.
func spend(cost: int) -> bool:
	if cost < 0 or cost > dna:
		return false
	dna -= cost
	return true


func is_final_stage() -> bool:
	return stage == STAGE_COUNT - 1


## Fortschritt zum nächsten Abschnitt von 0 bis 1; im letzten Abschnitt immer 1.
func growth_ratio() -> float:
	if is_final_stage():
		return 1.0
	return float(growth) / GROWTH_NEEDED[stage]


func radius() -> float:
	return radius_for_stage(stage)


static func radius_for_stage(s: int) -> float:
	return RADII[clampi(s, 0, STAGE_COUNT - 1)]
```

## Tests
`tests/test_cell_progress.gd` mit `extends "res://tests/base_test.gd"`, `var p: CellProgress`, `setup()`: `p = CellProgress.new()`.
- `test_fressen`: `p.eat(4)` ist falsch; `p.dna` ist 4, `p.growth` ist 4, `p.stage` ist 0, `p.growth_ratio()` ist 0.4
- `test_aufsteigen`: `p.eat(4)`, dann `p.eat(6)` ist wahr; `p.stage` ist 1, `p.growth` ist 0, `p.radius()` ist 18.0
- `test_nichts_fressen`: `p.eat(0)` ist falsch, `p.dna` ist 0
- `test_viele_abschnitte`: `p.eat(100)` ist wahr; `p.stage` ist 4, `p.growth` ist 30, `p.dna` ist 100, `p.is_final_stage()` wahr, `p.growth_ratio()` ist 1.0
- `test_ausgeben`: `p.eat(10)`; `p.spend(4)` wahr, `p.dna` 6; `p.spend(7)` falsch, `p.dna` 6; `p.spend(-5)` falsch, `p.dna` 6
- `test_radius`: `CellProgress.radius_for_stage(2)` ist 27.0, `(9)` ist 60.0, `(-1)` ist 12.0

Review (16.10.2026): gemergt.
