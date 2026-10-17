---
id: T-0237
title: Fischphase – Ausbau des Fischs (FishBuild)
project: zellenphase
priority: 3
---
## Ziel
Wunsch des Nutzers: Nach der Zellenphase folgt eine Fischphase in 3D, in der sich der Fisch sichtbar und spielerisch wirksam weiterentwickelt. `FishBuild` hält den Ausbau des Fischs: je Bauteil eine Stufe, dazu Farbe und Ernährung. Grundlage für Übergang, Aussehen und Fähigkeiten in späteren Tickets. Siehe Abschnitt „Fischphase (3D)“ in `CLAUDE.md`.

## Dateien
- `scripts/fish_build.gd` – neu
- `tests/test_fish_build.gd` – neu

## Akzeptanzkriterien
`scripts/fish_build.gd` genau so:
```gdscript
class_name FishBuild
extends RefCounted
## Ausbau des Spielerfischs: je Bauteil eine Stufe von 0 bis MAX_LEVEL, dazu Farbe und Ernährung.

const SLOTS := ["schwanz", "flossen", "kiefer", "stacheln", "augen"]
const NAMES := {"schwanz": "Schwanzflosse", "flossen": "Brustflossen", "kiefer": "Kiefer", "stacheln": "Stacheln", "augen": "Augen"}
const MAX_LEVEL := 3

var levels := {"schwanz": 0, "flossen": 0, "kiefer": 0, "stacheln": 0, "augen": 0}
var color := Color(0.5, 0.88, 0.82)
var diet := Diet.PFLANZENFRESSER


## Stufe eines Bauteils; 0 bei unbekanntem Bauteil.
func level(slot: String) -> int:
	return int(levels.get(slot, 0))


## Erhöht ein Bauteil um eine Stufe. false bei unbekanntem Bauteil oder schon höchster Stufe.
func upgrade(slot: String) -> bool:
	if not levels.has(slot) or level(slot) >= MAX_LEVEL:
		return false
	levels[slot] = level(slot) + 1
	return true


## Summe aller Stufen.
func total_levels() -> int:
	var n := 0
	for slot: String in SLOTS:
		n += level(slot)
	return n


func copy() -> FishBuild:
	var b := FishBuild.new()
	b.levels = levels.duplicate()
	b.color = color
	b.diet = diet
	return b


func to_dict() -> Dictionary:
	return {"levels": levels.duplicate(), "color": color.to_html(), "diet": diet}


static func from_dict(d: Dictionary) -> FishBuild:
	var b := FishBuild.new()
	var stored: Dictionary = d.get("levels", {})
	for slot: String in SLOTS:
		b.levels[slot] = clampi(int(stored.get(slot, 0)), 0, MAX_LEVEL)
	b.color = Color.from_string(str(d.get("color", "")), b.color)
	b.diet = str(d.get("diet", Diet.PFLANZENFRESSER))
	return b
```
- Keine andere Datei ändern.

## Tests
`tests/test_fish_build.gd` mit `extends "res://tests/base_test.gd"`:
- `test_neu`: `var b := FishBuild.new()` → `b.level("schwanz")` ist 0; `b.total_levels()` ist 0; `b.level("unbekannt")` ist 0; `b.diet` ist `Diet.PFLANZENFRESSER`
- `test_ausbauen`: `var b := FishBuild.new()`; `b.upgrade("flossen")` wahr; `b.upgrade("flossen")` wahr → `b.level("flossen")` ist 2; `b.total_levels()` ist 2
- `test_hoechste_stufe`: `var b := FishBuild.new()`; dreimal `b.upgrade("kiefer")` → viertes `b.upgrade("kiefer")` falsch; `b.level("kiefer")` ist 3
- `test_unbekannt`: `FishBuild.new().upgrade("fluegel")` falsch
- `test_kopie`: `var b := FishBuild.new()`, `b.upgrade("augen")`, `var c := b.copy()`, `c.upgrade("augen")` → `b.level("augen")` ist 1; `c.level("augen")` ist 2
- `test_speichern`: `var b := FishBuild.new()`, `b.upgrade("schwanz")`, `b.color = Color(1, 0, 0)`, `b.diet = Diet.FLEISCHFRESSER`; `var c := FishBuild.from_dict(b.to_dict())` → `c.level("schwanz")` ist 1; `c.color.is_equal_approx(Color(1, 0, 0))` wahr; `c.diet` ist `Diet.FLEISCHFRESSER`
- `test_laden_begrenzt`: `FishBuild.from_dict({"levels": {"stacheln": 9}}).level("stacheln")` ist 3; `FishBuild.from_dict({}).total_levels()` ist 0
