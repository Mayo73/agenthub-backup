---
id: T-0287
title: LightRayLayout – Lage und Stärke der Lichtstrahlen unter Wasser
project: zellenphase
priority: 4
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“, Teil „Lichtstrahlen“: Von der Wasseroberfläche fallen schräge, schwach leuchtende Lichtstrahlen ins Wasser. Diese Logik-Klasse bestimmt, wo die Strahlen stehen, wie sie schwanken und wie stark sie in welcher Tiefe leuchten. Gezeichnet werden sie in T-0288.

## Dateien
- `scripts/light_ray_layout.gd` – neu
- `tests/test_light_ray_layout.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/light_ray_layout.gd`, genau so:
```gdscript
class_name LightRayLayout
extends RefCounted
## Lichtstrahlen der Fischphase: feste Lage um die Kamera, leichtes Schwanken, schwächer in der Tiefe.

## Anzahl der Strahlen.
const COUNT := 14
## Die Strahlen stehen in x und z höchstens so weit (Meter) von der Kamera entfernt.
const SPREAD := 40.0
## Länge eines Strahls von der Oberfläche nach unten (Meter).
const LENGTH := 32.0
## Größte Deckkraft (nahe der Oberfläche).
const MAX_ALPHA := 0.22
## Ab dieser Tiefe (Meter) sind die Strahlen nicht mehr zu sehen.
const FADE_DEPTH := 45.0


## Waagrechte Versätze der Strahlen (y = 0), immer gleich für denselben seed_value.
static func offsets(count: int, seed_value: int) -> Array[Vector3]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var out: Array[Vector3] = []
	for i in count:
		out.append(Vector3(rng.randf_range(-SPREAD, SPREAD), 0.0, rng.randf_range(-SPREAD, SPREAD)))
	return out


## Neigung (Bogenmaß) des Strahls index zur Zeit t: schwankt langsam um 0,25 rad.
static func tilt(t: float, index: int) -> float:
	return 0.25 + sin(t * 0.3 + float(index) * 1.7) * 0.06


## Deckkraft der Strahlen, wenn die Kamera in depth Metern Tiefe ist.
static func alpha_for_depth(depth: float) -> float:
	return clampf(MAX_ALPHA * (1.0 - depth / FADE_DEPTH), 0.0, MAX_ALPHA)
```

## Tests
`tests/test_light_ray_layout.gd` (neu, `extends "res://tests/base_test.gd"`):
- `test_anzahl`: `LightRayLayout.offsets(5, 1).size()` ist 5
- `test_gleich_bei_gleichem_seed`: `LightRayLayout.offsets(6, 7)` gleich `LightRayLayout.offsets(6, 7)`; ungleich `LightRayLayout.offsets(6, 8)`
- `test_im_bereich`: für jeden Punkt aus `offsets(LightRayLayout.COUNT, 3)`: `absf(p.x) <= SPREAD`, `absf(p.z) <= SPREAD`, `p.y == 0.0`
- `test_neigung`: `tilt(0.0, 0)` ist 0.25; für t in 0, 1, …, 30 und index 0 bis 3 liegt `tilt` zwischen 0.19 und 0.31
- `test_tiefe`: `alpha_for_depth(0.0)` ist 0.22; `alpha_for_depth(45.0)` ist 0.0; `alpha_for_depth(60.0)` ist 0.0; `alpha_for_depth(10.0) > alpha_for_depth(30.0)` wahr

Review (18.10.2026): gemergt.
