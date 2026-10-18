---
id: T-0288
title: LightRays – Lichtstrahlen als 3D-Knoten
project: zellenphase
priority: 4
after: T-0287
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“, Teil „Lichtstrahlen“: Ein Knoten zeichnet die Strahlen aus `LightRayLayout` als lange, durchscheinende, nach unten breiter werdende Kegel, die von der Oberfläche (y = 0) nach unten reichen. Sie folgen der Kamera waagrecht und werden in der Tiefe schwächer. Eingebaut wird er in T-0289.

## Dateien
- `scripts/light_rays.gd` – neu
- `tests/test_light_rays.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/light_rays.gd`:
```gdscript
class_name LightRays
extends Node3D
## Lichtstrahlen von der Wasseroberfläche (LightRayLayout). Folgen der Kamera in x und z.

var rays: Array[MeshInstance3D] = []
var offsets: Array[Vector3] = []
var material: StandardMaterial3D
var time := 0.0


func _init() -> void:
	material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.75, 0.95, 1.0, LightRayLayout.MAX_ALPHA)
	offsets = LightRayLayout.offsets(LightRayLayout.COUNT, 5)
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.4
	mesh.bottom_radius = 1.8
	mesh.height = LightRayLayout.LENGTH
	for i in offsets.size():
		var m := MeshInstance3D.new()
		m.name = "Ray%d" % i
		m.mesh = mesh
		m.material_override = material
		m.position = offsets[i] + Vector3(0.0, -LightRayLayout.LENGTH * 0.5, 0.0)
		add_child(m)
		rays.append(m)
```
- Dazu die Funktion:
```gdscript
## Ein Schritt: der Kamera waagrecht folgen, Strahlen neigen, Deckkraft nach Tiefe der Kamera.
func update(camera_pos: Vector3, delta: float) -> void:
	time += delta
	position = Vector3(camera_pos.x, 0.0, camera_pos.z)
	for i in rays.size():
		rays[i].rotation.z = LightRayLayout.tilt(time, i)
	material.albedo_color.a = LightRayLayout.alpha_for_depth(FishWorld.depth_of(camera_pos))
```

## Tests
`tests/test_light_rays.gd` (neu, `extends "res://tests/base_test.gd"`; `setup()` legt `rays = LightRays.new()` an, `teardown()` ruft `rays.free()`):
- `test_aufbau`: `rays.rays.size()` ist `LightRayLayout.COUNT`; `rays.get_child_count()` ist `LightRayLayout.COUNT`; `rays.rays[0].position.y` ist `-LightRayLayout.LENGTH * 0.5`
- `test_folgt_kamera`: `rays.update(Vector3(10, -20, -5), 0.1)` → `rays.position` ist `Vector3(10, 0, -5)`
- `test_neigung`: `rays.update(Vector3.ZERO, 0.0)` → `rays.rays[0].rotation.z` ist `LightRayLayout.tilt(0.0, 0)`
- `test_tiefe_schwaecher`: `rays.update(Vector3(0, -5, 0), 0.1)`; `var oben := rays.material.albedo_color.a`; `rays.update(Vector3(0, -40, 0), 0.1)` → `rays.material.albedo_color.a < oben` wahr

Review (18.10.2026): gemergt.
