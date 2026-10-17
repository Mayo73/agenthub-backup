---
id: T-0251
title: Fischphase – Nahrung zeichnen (FishFoodView)
project: zellenphase
priority: 3
after: T-0250, T-0244
---
## Ziel
Die Nahrung der Fischphase wird sichtbar: grüne Algenbüschel (Kugeln) und rote Krebschen (kleine Quader). Die Ansicht hält je Stück einen Knoten und gleicht Anzahl und Lage jedes Bild mit `FishFood` ab.

## Dateien
- `scripts/fish_food_view.gd` – neu
- `tests/test_fish_food_view.gd` – neu

## Akzeptanzkriterien
`scripts/fish_food_view.gd` genau so:
```gdscript
class_name FishFoodView
extends Node3D
## Zeichnet die Nahrung aus FishFood: grüne Algenbüschel und rote Krebschen, ein Knoten je Stück.

var field: FishFood
var plant_mesh := FishModel.sphere(0.3)
var meat_mesh := FishModel.box(Vector3(0.35, 0.2, 0.25))
var plant_mat := FishModel.material(Color(0.42, 0.8, 0.37))
var meat_mat := FishModel.material(Color(0.85, 0.33, 0.31))


## Gleicht Anzahl, Form und Lage der Knoten mit field.items ab.
func refresh() -> void:
	if field == null:
		return
	while get_child_count() < field.items.size():
		add_child(MeshInstance3D.new())
	while get_child_count() > field.items.size():
		var last := get_child(get_child_count() - 1)
		remove_child(last)
		last.free()
	for i in field.items.size():
		var item: Dictionary = field.items[i]
		var m := get_child(i) as MeshInstance3D
		var plant: bool = item["kind"] == Diet.PFLANZE
		m.mesh = plant_mesh if plant else meat_mesh
		m.material_override = plant_mat if plant else meat_mat
		m.position = item["position"]


func _process(_delta: float) -> void:
	refresh()
```
- Keine andere Datei ändern.

## Tests
`tests/test_fish_food_view.gd` mit `extends "res://tests/base_test.gd"`, `var view: FishFoodView`; `setup()`: `view = FishFoodView.new()`, `view.field = FishFood.new()`; `teardown()`: `view.free()`:
- `test_leer`: `view.refresh()` → `view.get_child_count()` ist 0
- `test_stuecke`: `view.field.add_item(Diet.PFLANZE, Vector3(1, -55, 2))`; `view.field.add_item(Diet.FLEISCH, Vector3(0, -10, 0))`; `view.refresh()` → `view.get_child_count()` ist 2; `(view.get_child(0) as MeshInstance3D).position` ist `Vector3(1, -55, 2)`; `(view.get_child(0) as MeshInstance3D).mesh is SphereMesh` wahr; `(view.get_child(1) as MeshInstance3D).mesh is BoxMesh` wahr
- `test_gefressen`: zwei Stücke hinzufügen, `view.refresh()`; `view.field.items.remove_at(0)`; `view.refresh()` → `view.get_child_count()` ist 1
- `test_ohne_feld`: `var v := FishFoodView.new()`; `v.refresh()` → `v.get_child_count()` ist 0; am Ende `v.free()`

Review (17.10.2026): gemergt.
