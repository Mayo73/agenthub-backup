---
id: T-0303
title: FishStats – Statistik der Fischphase
project: zellenphase
priority: 3
---
## Ziel
Wie `RunStats` in der Zellenphase zählt die Fischphase, was der Spieler erlebt: gefressene Fische je Art, Tode und die größte erreichte Tiefe. Diese Logik-Klasse kann speichern und laden; der Einbau folgt in T-0304.

## Dateien
- `scripts/fish_stats.gd` – neu
- `tests/test_fish_stats.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_stats.gd`, genau so:
```gdscript
class_name FishStats
extends RefCounted
## Statistik der Fischphase: gefressene Fische je Art, Tode und größte erreichte Tiefe.

## Art-ID → Anzahl gefressener Fische
var eaten := {}
var deaths := 0
var max_depth := 0.0


func record_eaten(species_id: String) -> void:
	eaten[species_id] = int(eaten.get(species_id, 0)) + 1


func record_death() -> void:
	deaths += 1


func record_depth(depth: float) -> void:
	max_depth = maxf(max_depth, depth)


func total_eaten() -> int:
	var n := 0
	for id: String in eaten:
		n += int(eaten[id])
	return n


func to_dict() -> Dictionary:
	return {"eaten": eaten.duplicate(), "deaths": deaths, "max_depth": max_depth}


static func from_dict(data: Dictionary) -> FishStats:
	var s := FishStats.new()
	var e: Variant = data.get("eaten", {})
	if e is Dictionary:
		for id: String in e:
			s.eaten[id] = maxi(0, int(e[id]))
	s.deaths = maxi(0, int(data.get("deaths", 0)))
	s.max_depth = maxf(0.0, float(data.get("max_depth", 0.0)))
	return s


## Eine Zeile für Anzeigen, z. B. "Gefressen: 3 · Tode: 1 · Tiefste Stelle: 42 m".
func summary() -> String:
	return "Gefressen: %d · Tode: %d · Tiefste Stelle: %d m" % [total_eaten(), deaths, roundi(max_depth)]
```

## Tests
Neue Datei `tests/test_fish_stats.gd` (`extends "res://tests/base_test.gd"`):
- `test_anfang`: neues `FishStats` → `total_eaten()` ist 0, `deaths` 0, `max_depth` 0.0
- `test_fressen`: `record_eaten("silberling")` zweimal, `record_eaten("grasfisch")` einmal → `eaten["silberling"]` ist 2, `total_eaten()` ist 3
- `test_tiefe`: `record_depth(20.0)`, `record_depth(42.4)`, `record_depth(10.0)` → `max_depth` ist 42.4
- `test_hin_und_zurueck`: Werte setzen (2 Silberlinge, 1 Tod, Tiefe 33.0), `FishStats.from_dict(s.to_dict())` → gleiche `total_eaten()`, `deaths`, `max_depth`
- `test_kaputte_daten`: `FishStats.from_dict({"eaten": 5, "deaths": -3, "max_depth": -1.0})` → `total_eaten()` 0, `deaths` 0, `max_depth` 0.0
- `test_zusammenfassung`: 3 gefressen, 1 Tod, `max_depth` 41.6 → `summary()` ist `"Gefressen: 3 · Tode: 1 · Tiefste Stelle: 42 m"`

Review (18.10.2026): gemergt.
