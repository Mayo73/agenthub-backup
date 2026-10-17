---
id: T-0244
title: Fischphase – Aussehen des Fischs aus Grundkörpern (FishModel)
project: zellenphase
priority: 3
after: T-0237
---
## Ziel
Der Fisch wird aus Godot-Grundkörpern gebaut: Körper, Schwanzflosse, Brustflossen, Augen, Kiefer und Rückenstacheln. Die Größen hängen von den Stufen in `FishBuild` ab, so ist jede Weiterentwicklung sofort sichtbar. Die Schwanzflosse schlägt beim Schwimmen.

## Dateien
- `scripts/fish_model.gd` – neu
- `tests/test_fish_model.gd` – neu

## Akzeptanzkriterien
`scripts/fish_model.gd` genau so:
```gdscript
class_name FishModel
extends Node3D
## Aussehen des Fischs aus Grundkörpern. Die Maße folgen den Stufen in FishBuild, so ist jede
## Entwicklung sichtbar. Vorne ist -z, oben ist +y.

var build := FishBuild.new()
var time := 0.0
var body: MeshInstance3D
var tail_pivot: Node3D
var tail: MeshInstance3D
var jaw: MeshInstance3D
var fins: Array[MeshInstance3D] = []
var eyes: Array[MeshInstance3D] = []
var spikes: Array[MeshInstance3D] = []


## Maße in Metern je Stufe: body = Breite, Höhe, Länge des Körpers; tail = Höhe der Schwanzflosse;
## fins = Länge der Brustflossen; jaw = Länge des Kiefers (0 = kein Kiefer); spikes = Anzahl; eyes = Augenradius.
static func shape(b: FishBuild) -> Dictionary:
	return {
		"body": Vector3(0.5, 0.6, 1.6),
		"tail": 0.5 + 0.25 * b.level("schwanz"),
		"fins": 0.3 + 0.2 * b.level("flossen"),
		"jaw": 0.15 * b.level("kiefer"),
		"spikes": 2 * b.level("stacheln"),
		"eyes": 0.08 + 0.04 * b.level("augen"),
	}


## Pendelwinkel der Schwanzflosse zum Zeitpunkt t; schneller bei höherem Tempo.
static func tail_angle(t: float, speed: float) -> float:
	return sin(t * (4.0 + speed)) * 0.35


static func material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.6
	return mat


static func sphere(radius: float) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	return m


static func box(size: Vector3) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = size
	return m


static func cone(radius: float, height: float) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = 0.0
	m.bottom_radius = radius
	m.height = height
	return m


func _init() -> void:
	rebuild(build)


## Baut alle Teile neu auf (nach dem Übergang oder einer Entwicklung).
func rebuild(b: FishBuild) -> void:
	build = b
	for child in get_children():
		remove_child(child)
		child.free()
	fins.clear()
	eyes.clear()
	spikes.clear()
	jaw = null
	var s := shape(b)
	var skin := material(b.color)
	var size: Vector3 = s["body"]
	body = add_part(self, "Body", sphere(0.5), skin, Vector3.ZERO)
	body.scale = size
	tail_pivot = Node3D.new()
	tail_pivot.name = "TailPivot"
	tail_pivot.position = Vector3(0.0, 0.0, size.z * 0.45)
	add_child(tail_pivot)
	var t: float = s["tail"]
	tail = add_part(tail_pivot, "Tail", box(Vector3(0.05, t, t * 0.8)), skin, Vector3(0.0, 0.0, t * 0.4))
	var f: float = s["fins"]
	fins.append(add_part(self, "FinL", box(Vector3(f, 0.04, f * 0.5)), skin, Vector3(-(size.x * 0.5 + f * 0.4), -0.05, -0.1)))
	fins.append(add_part(self, "FinR", box(Vector3(f, 0.04, f * 0.5)), skin, Vector3(size.x * 0.5 + f * 0.4, -0.05, -0.1)))
	var e: float = s["eyes"]
	var eye_mat := material(Color(0.05, 0.05, 0.08))
	eyes.append(add_part(self, "EyeL", sphere(e), eye_mat, Vector3(-size.x * 0.42, size.y * 0.15, -size.z * 0.32)))
	eyes.append(add_part(self, "EyeR", sphere(e), eye_mat, Vector3(size.x * 0.42, size.y * 0.15, -size.z * 0.32)))
	var j: float = s["jaw"]
	if j > 0.0:
		jaw = add_part(self, "Jaw", box(Vector3(0.3, 0.1, j)), material(b.color.darkened(0.3)), Vector3(0.0, -size.y * 0.25, -size.z * 0.5 - j * 0.3))
	var n: int = s["spikes"]
	var spike_mat := material(Color(0.9, 0.85, 0.7))
	for i in n:
		var z := -size.z * 0.3 + size.z * 0.6 * float(i) / maxf(1.0, float(n - 1))
		spikes.append(add_part(self, "Spike%d" % i, cone(0.06, 0.35), spike_mat, Vector3(0.0, size.y * 0.5, z)))


func add_part(parent: Node3D, part_name: String, mesh: Mesh, mat: Material, pos: Vector3) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.name = part_name
	m.mesh = mesh
	m.material_override = mat
	m.position = pos
	parent.add_child(m)
	return m


## Schwanzschlag weiterführen (speed = Tempo in m/s).
func animate(delta: float, speed: float) -> void:
	time += delta
	tail_pivot.rotation.y = tail_angle(time, speed)
```
- Keine andere Datei ändern.

## Tests
`tests/test_fish_model.gd` mit `extends "res://tests/base_test.gd"`, `var model: FishModel`; `setup()`: `model = FishModel.new()`; `teardown()`: `model.free()`:
- `test_grundform`: `model.get_child_count()` ist 6 (Body, TailPivot, FinL, FinR, EyeL, EyeR); `model.jaw == null` wahr; `model.spikes.size()` ist 0; `model.body.scale` ist `Vector3(0.5, 0.6, 1.6)`; `model.get_node("TailPivot/Tail") is MeshInstance3D` wahr
- `test_masse`: `var b := FishBuild.new()`; `b.upgrade("schwanz")`; `b.upgrade("flossen")`; `b.upgrade("flossen")`; `var s := FishModel.shape(b)` → `s["tail"]` ist 0.75; `s["fins"]` ist 0.7; `s["jaw"]` ist 0.0; `s["spikes"]` ist 0; `s["eyes"]` ist 0.08
- `test_kiefer_und_stacheln`: `var b := FishBuild.new()`; `b.upgrade("kiefer")`; `b.upgrade("stacheln")`; `b.upgrade("stacheln")`; `model.rebuild(b)` → `model.jaw != null` wahr; `model.spikes.size()` ist 4; `model.get_child_count()` ist 11; `model.build == b` wahr
- `test_flossen_wachsen`: `var b := FishBuild.new()`; `b.upgrade("flossen")`; `model.rebuild(b)` → `(model.fins[0].mesh as BoxMesh).size.x` ist 0.5
- `test_farbe`: `var b := FishBuild.new()`; `b.color = Color(0.9, 0.3, 0.2)`; `model.rebuild(b)` → `(model.body.material_override as StandardMaterial3D).albedo_color.is_equal_approx(Color(0.9, 0.3, 0.2))` wahr
- `test_schwanzschlag`: `FishModel.tail_angle(0.0, 3.0)` ist 0.0; `model.animate(0.1, 0.0)` → `model.tail_pivot.rotation.y` ist `sin(0.4) * 0.35`

Review (17.10.2026): gemergt.
