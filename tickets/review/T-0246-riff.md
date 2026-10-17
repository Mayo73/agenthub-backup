---
id: T-0246
title: Fischphase – Seegras und Felsen am Meeresboden (ReefLayout, ReefView)
project: zellenphase
priority: 3
after: T-0244
---
## Ziel
Der Meeresboden der Fischphase bekommt Seegras und Felsen, damit man Tiefe und Bewegung im 3D-Raum sieht. Die Lage wird mit festem Seed berechnet (testbar), die Darstellung baut daraus Grundkörper; das Seegras wiegt sich leicht.

## Dateien
- `scripts/reef_layout.gd` – neu
- `scripts/reef_view.gd` – neu
- `tests/test_reef.gd` – neu

## Akzeptanzkriterien
`scripts/reef_layout.gd` genau so:
```gdscript
class_name ReefLayout
extends RefCounted
## Lage von Seegras und Felsen am Meeresboden der Fischphase, mit festem Seed reproduzierbar.

const WEED_COUNT := 160
const ROCK_COUNT := 40

## Je Eintrag: {"kind": "seegras" oder "fels", "position": Vector3 auf dem Boden, "height": float in Metern}
var items: Array[Dictionary] = []


func _init(seed_value: int = 7) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in WEED_COUNT:
		items.append({"kind": "seegras", "position": random_floor_point(rng), "height": rng.randf_range(3.0, 12.0)})
	for i in ROCK_COUNT:
		items.append({"kind": "fels", "position": random_floor_point(rng), "height": rng.randf_range(1.5, 6.0)})


## Zufälliger Punkt auf dem Meeresboden, mindestens 5 m vom Rand.
static func random_floor_point(rng: RandomNumberGenerator) -> Vector3:
	var r := FishWorld.HALF_SIZE - 5.0
	return Vector3(rng.randf_range(-r, r), -FishWorld.DEPTH, rng.randf_range(-r, r))


func count(kind: String) -> int:
	var n := 0
	for item in items:
		if item["kind"] == kind:
			n += 1
	return n
```
`scripts/reef_view.gd` genau so:
```gdscript
class_name ReefView
extends Node3D
## Zeichnet Seegras und Felsen aus ReefLayout. Das Seegras wiegt sich leicht.

var layout := ReefLayout.new()
var weeds: Array[MeshInstance3D] = []
var time := 0.0


func _init() -> void:
	var weed_mat := FishModel.material(Color(0.25, 0.55, 0.3))
	var rock_mat := FishModel.material(Color(0.42, 0.4, 0.38))
	for item: Dictionary in layout.items:
		var m := MeshInstance3D.new()
		var h: float = item["height"]
		var p: Vector3 = item["position"]
		if item["kind"] == "seegras":
			var c := CylinderMesh.new()
			c.top_radius = 0.05
			c.bottom_radius = 0.18
			c.height = h
			m.mesh = c
			m.material_override = weed_mat
			m.position = p + Vector3(0.0, h * 0.5, 0.0)
			weeds.append(m)
		else:
			m.mesh = FishModel.sphere(1.0)
			m.material_override = rock_mat
			m.position = p
			m.scale = Vector3(h, h * 0.6, h * 0.8)
		add_child(m)


## Neigung eines Seegrashalms zum Zeitpunkt t; phase verschiebt jeden Halm etwas.
static func sway(t: float, phase: float) -> float:
	return sin(t * 0.8 + phase) * 0.12


func _process(delta: float) -> void:
	time += delta
	for i in weeds.size():
		weeds[i].rotation.z = sway(time, i * 0.7)
```
- Keine andere Datei ändern.

## Tests
`tests/test_reef.gd` mit `extends "res://tests/base_test.gd"`:
- `test_anzahl`: `var l := ReefLayout.new()` → `l.items.size()` ist 200; `l.count("seegras")` ist 160; `l.count("fels")` ist 40
- `test_am_boden`: für jeden Eintrag von `ReefLayout.new().items`: `item["position"].y` ist `-FishWorld.DEPTH` und `absf(item["position"].x) <= FishWorld.HALF_SIZE - 5.0` wahr
- `test_gleicher_seed`: `ReefLayout.new(3).items == ReefLayout.new(3).items` wahr; `ReefLayout.new(3).items == ReefLayout.new(4).items` falsch
- `test_ansicht`: `var v := ReefView.new()` → `v.get_child_count()` ist 200; `v.weeds.size()` ist 160; `var first: Dictionary = v.layout.items[0]`; `(v.get_child(0) as MeshInstance3D).position.is_equal_approx(first["position"] + Vector3(0, first["height"] * 0.5, 0))` wahr; am Ende `v.free()`
- `test_wiegen`: `ReefView.sway(0.0, 0.0)` ist 0.0; `var v := ReefView.new()`; `v._process(1.0)` → `v.weeds[0].rotation.z` ist `sin(0.8) * 0.12`; am Ende `v.free()`
