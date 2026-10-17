---
id: T-0238
title: Fischphase – Übergang aus der Zelle berechnen (FishStart)
project: zellenphase
priority: 3
after: T-0237
---
## Ziel
Der Übergang von der Zellenphase in die Fischphase soll nachvollziehbar sein: Was die Zelle zuletzt eingebaut hatte, bestimmt den ersten Fisch (Geißel wird zur Schwanzflosse, Wimpern zu Brustflossen usw.), Farbe und Ernährung bleiben. `FishStart` rechnet das aus und übergibt es beim Szenenwechsel.

## Dateien
- `scripts/fish_start.gd` – neu
- `tests/test_fish_start.gd` – neu

## Akzeptanzkriterien
`scripts/fish_start.gd` genau so:
```gdscript
class_name FishStart
extends RefCounted
## Übergang von der Zellenphase in die Fischphase: Die Teile der Zelle bestimmen den ersten Fisch.

## Welches Teil der Zelle zu welchem Bauteil des Fischs wird.
const PART_MAP := {
	"geissel": "schwanz",
	"duese": "schwanz",
	"wimpern": "flossen",
	"kiefer": "kiefer",
	"stachel": "stacheln",
	"knopfauge": "augen",
	"stielauge": "augen",
}
## Höchste Stufe, die ein Bauteil aus der Zelle mitbringt.
const MAX_START_LEVEL := 2

## Übergabe zwischen den Szenen: main.gd setzt beides vor dem Szenenwechsel, FishMain liest es.
static var pending_build: FishBuild = null
static var pending_dna := 0


## Erster Fisch aus Aufbau, Aussehen und Ernährung der Zelle. Je passendem Teil eine Stufe, höchstens MAX_START_LEVEL.
static func from_cell(build: CellBuild, look: CellLook, diet: String) -> FishBuild:
	var fish := FishBuild.new()
	fish.color = look.color
	fish.diet = diet
	for part: Dictionary in build.parts:
		var slot: String = PART_MAP.get(part["id"], "")
		if slot != "" and fish.level(slot) < MAX_START_LEVEL:
			fish.levels[slot] = fish.level(slot) + 1
	return fish


## Zeilen für den Übergangsbildschirm: Ernährung, dann jedes Bauteil mit Stufe über 0 (z. B. "Schwanzflosse: Stufe 2").
static func summary_lines(fish: FishBuild) -> Array[String]:
	var lines: Array[String] = ["Ernährung: " + EndScreen.diet_name(fish.diet)]
	for slot: String in FishBuild.SLOTS:
		if fish.level(slot) > 0:
			lines.append("%s: Stufe %d" % [FishBuild.NAMES[slot], fish.level(slot)])
	return lines


## Soll das Spiel direkt in der Fischphase starten? (Startargument "--fisch", zum Ausprobieren.)
static func requested(args: PackedStringArray) -> bool:
	return args.has("--fisch")


## Setzt die Übergabe zurück (nach dem Lesen und in Tests).
static func clear() -> void:
	pending_build = null
	pending_dna = 0
```
- Keine andere Datei ändern.

## Tests
`tests/test_fish_start.gd` mit `extends "res://tests/base_test.gd"`; `teardown()`: `FishStart.clear()`:
- `test_teile`: `var b := CellBuild.new()`; `b.add_part("geissel", Vector2(-1, 0))`; `b.add_part("geissel", Vector2(-1, 0.3))`; `b.add_part("wimpern", Vector2(0, 1))`; `b.add_part("kiefer", Vector2(1, 0))`; `var f := FishStart.from_cell(b, CellLook.new(), Diet.FLEISCHFRESSER)` → `f.level("schwanz")` ist 2; `f.level("flossen")` ist 1; `f.level("kiefer")` ist 1; `f.level("stacheln")` ist 0; `f.diet` ist `Diet.FLEISCHFRESSER`
- `test_hoechstens_zwei`: `var b := CellBuild.new()`; viermal `b.add_part("stachel", Vector2(1, 0))`; `FishStart.from_cell(b, CellLook.new(), Diet.PFLANZENFRESSER).level("stacheln")` ist 2
- `test_farbe`: `var look := CellLook.new()`, `look.color = Color(0.9, 0.2, 0.3)` → `FishStart.from_cell(CellBuild.new(), look, Diet.PFLANZENFRESSER).color.is_equal_approx(Color(0.9, 0.2, 0.3))` wahr
- `test_unbekannte_teile`: `var b := CellBuild.new()`; `b.add_part("gift", Vector2(-1, 0))`; `b.add_part("filtermaul", Vector2(1, 0))` → `FishStart.from_cell(b, CellLook.new(), Diet.PFLANZENFRESSER).total_levels()` ist 0
- `test_zeilen`: `var f := FishBuild.new()`, `f.diet = Diet.PFLANZENFRESSER`, `f.upgrade("schwanz")`, `f.upgrade("schwanz")`, `f.upgrade("augen")`; `var lines := FishStart.summary_lines(f)` → `lines.size()` ist 3; `lines[0]` ist `"Ernährung: Pflanzenfresser"`; `lines[1]` ist `"Schwanzflosse: Stufe 2"`; `lines[2]` ist `"Augen: Stufe 1"`
- `test_argument`: `FishStart.requested(PackedStringArray(["--fisch"]))` wahr; `FishStart.requested(PackedStringArray(["--szene=jagd"]))` falsch
- `test_uebergabe`: `FishStart.pending_build = FishBuild.new()`, `FishStart.pending_dna = 40`; `FishStart.clear()` → `FishStart.pending_build == null` wahr; `FishStart.pending_dna` ist 0

Review (17.10.2026): gemergt.
