---
id: T-0104
title: Werte aus dem Zellaufbau (CellStats)
project: zellenphase
priority: 3
after: T-0103
---
## Ziel
Tempo, Wendigkeit und Ernährung einer Zelle ergeben sich aus ihren Teilen und ihrem Größenabschnitt. Mehrere gleiche Teile wirken mit abnehmendem Nutzen, damit sich Stapeln nicht beliebig lohnt.

## Dateien
- `scripts/cell_stats.gd`: neu
- `tests/test_cell_stats.gd`: neu

## Akzeptanzkriterien
`scripts/cell_stats.gd` genau so:
```gdscript
class_name CellStats
extends RefCounted
## Werte einer Zelle aus Aufbau (CellBuild) und Größenabschnitt.

const BASE_SPEED := 220.0
const SPEED_PER_STAGE := 30.0
const BASE_TURN := 6.0
const MIN_TURN := 2.0


static func max_speed(build: CellBuild, stage: int) -> float:
	return BASE_SPEED + SPEED_PER_STAGE * stage + bonus(build, "speed")


static func turn_rate(build: CellBuild) -> float:
	return maxf(MIN_TURN, BASE_TURN + bonus(build, "turn"))


## Ernährung aus den Mundwerkzeugen; "" ohne Maul.
static func diet(build: CellBuild) -> String:
	return Diet.from_mouths(build.mouths())


## Summe eines Werts (Schlüssel aus PartCatalog.PARTS) über alle Teile.
## Jedes weitere Teil derselben Art wirkt nur halb so stark wie das vorige.
static func bonus(build: CellBuild, key: String) -> float:
	var total := 0.0
	var seen := {}
	for p in build.parts:
		var id: String = p["id"]
		var n: int = seen.get(id, 0)
		total += float(PartCatalog.data(id)[key]) * pow(0.5, n)
		seen[id] = n + 1
	return total
```

## Tests
`tests/test_cell_stats.gd` mit `extends "res://tests/base_test.gd"`, `var b: CellBuild`, `setup()`: `b = CellBuild.starter(Diet.PFLANZENFRESSER)`.
- `test_startwerte`: `CellStats.max_speed(b, 0)` ist 220.0; `max_speed(b, 2)` ist 280.0; `turn_rate(b)` ist 6.0; `diet(b)` ist `Diet.PFLANZENFRESSER`
- `test_geisseln_abnehmend`: eine `"geissel"` bei (-1, 0) einbauen → `max_speed(b, 0)` ist 280.0; zweite Geißel → 310.0; dritte → 325.0
- `test_wimpern`: eine `"wimpern"` einbauen → `max_speed(b, 0)` ist 240.0, `turn_rate(b)` ist 9.0
- `test_duesen`: zwei `"duese"` einbauen → `max_speed(b, 0)` ist 370.0, `turn_rate(b)` ist 4.5
- `test_ernaehrung`: `CellStats.diet(CellBuild.starter(Diet.FLEISCHFRESSER))` ist `Diet.FLEISCHFRESSER`; nach `b.add_part("kiefer", Vector2(0.9, 0.3))` ist `diet(b)` gleich `Diet.ALLESFRESSER`; `CellStats.diet(CellBuild.new())` ist `""`

Review (16.10.2026): gemergt.
