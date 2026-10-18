---
id: T-0301
title: FishThreat – Abstand zum nächsten Raubfisch und Warntext
project: zellenphase
priority: 2
---
## Ziel
Der Spieler soll merken, wenn ein Zackenbarsch näherkommt. Diese Logik-Klasse rechnet den Abstand zum nächsten Raubfisch aus und liefert den Warntext; der Einbau ins HUD folgt in T-0302.

## Dateien
- `scripts/fish_threat.gd` – neu
- `tests/test_fish_threat.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_threat.gd`, genau so:
```gdscript
class_name FishThreat
extends RefCounted
## Warnung vor Raubfischen in der Nähe des Spielerfischs.

## Bis zu diesem Abstand in Metern warnt die Anzeige.
const WARN_DIST := 15.0


## Abstand zum nächsten Raubfisch; INF, wenn keiner da ist. fishes: Knoten mit species_id und motion (AiFish).
static func nearest_predator(player_pos: Vector3, fishes: Array) -> float:
	var best := INF
	for f in fishes:
		if FishSpecies.is_predator(f.species_id):
			best = minf(best, player_pos.distance_to(f.motion.position))
	return best


static func is_warning(distance: float) -> bool:
	return distance <= WARN_DIST


## Leerer Text, wenn kein Raubfisch nah genug ist.
static func warning_text(distance: float) -> String:
	if not is_warning(distance):
		return ""
	return "Vorsicht: Raubfisch in %d m!" % roundi(distance)
```

## Tests
Neue Datei `tests/test_fish_threat.gd` (`extends "res://tests/base_test.gd"`). KI-Fische mit `AiFish.new()` anlegen, mit `setup(id, pos)` setzen und am Ende des Tests mit `free()` freigeben:
- `test_keiner`: `FishThreat.nearest_predator(Vector3(0, -20, 0), [])` ist `INF` (prüfen mit `check(is_inf(...), ...)`)
- `test_nur_beute`: ein `AiFish` mit `setup("silberling", Vector3(3, -20, 0))` → `nearest_predator(Vector3(0, -20, 0), [f])` ist `INF`
- `test_naechster`: zwei `AiFish` mit `setup("zackenbarsch", Vector3(10, -20, 0))` und `setup("zackenbarsch", Vector3(0, -20, 30))` → `nearest_predator(Vector3(0, -20, 0), [a, b])` ist `10.0`
- `test_warnung`: `FishThreat.is_warning(15.0)` ist wahr, `is_warning(15.1)` falsch, `is_warning(INF)` falsch
- `test_text`: `FishThreat.warning_text(9.6)` ist `"Vorsicht: Raubfisch in 10 m!"`; `warning_text(20.0)` ist `""`; `warning_text(INF)` ist `""`

Review (18.10.2026): gemergt.
