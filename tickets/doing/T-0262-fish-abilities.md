---
id: T-0262
title: FishAbilities – Bauteile bestimmen die Fähigkeiten des Fischs
project: zellenphase
priority: 4
---
## Ziel
Meilenstein „Fischphase – Weiterentwicklung“: Jede Stufe eines Bauteils soll spielerisch wirken. `FishAbilities` rechnet aus dem Ausbau (`FishBuild`) die Werte aus: Schwanzflosse → Tempo und Beschleunigung, Brustflossen → Drehen und Neigen, Kiefer → Bissschaden, Stacheln → Abwehr, Augen → Sichtweite. Siehe Abschnitt „Fischphase (3D)“ in `CLAUDE.md`.

## Dateien
- `scripts/fish_abilities.gd` – neu
- `tests/test_fish_abilities.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_abilities.gd`, genau so:
```gdscript
class_name FishAbilities
extends RefCounted
## Fähigkeiten des Fischs aus seinem Ausbau (FishBuild). Jede Stufe eines Bauteils wirkt spürbar.

## Höchsttempo in m/s: 8 + 2 je Stufe der Schwanzflosse.
static func max_speed(b: FishBuild) -> float:
	return 8.0 + 2.0 * b.level("schwanz")


## Beschleunigung in m/s²: 10 + 2,5 je Stufe der Schwanzflosse.
static func accel(b: FishBuild) -> float:
	return 10.0 + 2.5 * b.level("schwanz")


## Drehgeschwindigkeit in rad/s: 1,8 + 0,4 je Stufe der Brustflossen.
static func turn_rate(b: FishBuild) -> float:
	return 1.8 + 0.4 * b.level("flossen")


## Neigegeschwindigkeit in rad/s: 1,4 + 0,35 je Stufe der Brustflossen.
static func pitch_rate(b: FishBuild) -> float:
	return 1.4 + 0.35 * b.level("flossen")


## Bissschaden: 10 ohne Kiefer, +8 je Stufe.
static func bite_damage(b: FishBuild) -> float:
	return 10.0 + 8.0 * b.level("kiefer")


## Anteil des erlittenen Schadens, den die Stacheln abwehren: 0,15 je Stufe.
static func defense(b: FishBuild) -> float:
	return 0.15 * b.level("stacheln")


## Sichtweite im trüben Wasser in Metern: 25 + 10 je Stufe der Augen.
static func sight(b: FishBuild) -> float:
	return 25.0 + 10.0 * b.level("augen")


## Überträgt Tempo, Beschleunigung, Drehen und Neigen auf die Bewegung.
static func apply(b: FishBuild, motion: FishMotion) -> void:
	motion.max_speed = max_speed(b)
	motion.accel = accel(b)
	motion.turn_rate = turn_rate(b)
	motion.pitch_rate = pitch_rate(b)
```

## Tests
Neue Datei `tests/test_fish_abilities.gd` (`extends "res://tests/base_test.gd"`):
- `test_anfang`: `var b := FishBuild.new()` → `max_speed(b)` 8.0, `accel(b)` 10.0, `turn_rate(b)` 1.8, `pitch_rate(b)` 1.4, `bite_damage(b)` 10.0, `defense(b)` 0.0, `sight(b)` 25.0 (Toleranz 0,001 mit `absf(...) < 0.001`)
- `test_schwanz`: zweimal `b.upgrade("schwanz")` → `max_speed` 12.0, `accel` 15.0
- `test_flossen`: dreimal `b.upgrade("flossen")` → `turn_rate` 3.0, `pitch_rate` 2.45
- `test_kiefer_stacheln_augen`: je einmal `upgrade` für `"kiefer"`, `"stacheln"`, `"augen"` → `bite_damage` 18.0, `defense` 0.15, `sight` 35.0
- `test_anwenden`: `b.upgrade("schwanz")`, `b.upgrade("flossen")`; `var m := FishMotion.new()`; `FishAbilities.apply(b, m)` → `m.max_speed` 10.0, `m.accel` 12.5, `m.turn_rate` 2.2, `m.pitch_rate` 1.75
- `test_jede_stufe_schneller`: für Stufe 0 bis 3 der Schwanzflosse ist `max_speed` streng steigend
