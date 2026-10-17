---
id: T-0248
title: Fischphase – Anzeige (FishHud) und Schwebeteilchen (MarineSnow)
project: zellenphase
priority: 3
after: T-0247
---
## Ziel
Die Fischphase zeigt Tiefe, DNA und Wachstum, eine Steuerungshilfe und kurze Meldungen. Schwebeteilchen rund um die Kamera lassen Bewegung und Tiefe im 3D-Raum spüren (wie Wasserpartikel in der Zellenphase).

## Dateien
- `scripts/fish_hud.gd` – neu
- `scripts/marine_snow.gd` – neu
- `tests/test_fish_hud.gd` – neu

## Akzeptanzkriterien
`scripts/fish_hud.gd` genau so:
```gdscript
class_name FishHud
extends CanvasLayer
## Anzeige der Fischphase: Tiefe, DNA, Wachstum, Steuerungshilfe und kurze Meldungen.

const HELP := "W / linke Maustaste: schwimmen · A/D: drehen · Leertaste: auftauchen · Umschalt: abtauchen"

var depth_label: Label
var dna_label: Label
var growth_label: Label
var help_label: Label
var message_label: Label
var message_left := 0.0


func _init() -> void:
	layer = 5
	depth_label = make_label("Depth", Vector2(40, 30), 32)
	dna_label = make_label("Dna", Vector2(40, 76), 28)
	growth_label = make_label("Growth", Vector2(40, 116), 28)
	help_label = make_label("Help", Vector2(40, 1010), 22)
	help_label.text = HELP
	message_label = make_label("Message", Vector2(560, 140), 30)
	message_label.visible = false
	show_depth(FishWorld.depth_of(FishWorld.START))
	show_progress(FishProgress.new())


func make_label(label_name: String, pos: Vector2, font_size: int) -> Label:
	var l := Label.new()
	l.name = label_name
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	add_child(l)
	return l


static func depth_text(depth: float) -> String:
	return "Tiefe: %d m" % roundi(depth)


static func growth_text(progress: FishProgress) -> String:
	if progress.is_final_stage():
		return "Wachstum: ausgewachsen"
	return "Wachstum: %d / %d" % [progress.growth, FishProgress.GROWTH_NEEDED[progress.stage]]


func show_depth(depth: float) -> void:
	depth_label.text = depth_text(depth)


func show_progress(progress: FishProgress) -> void:
	dna_label.text = "DNA: %d" % progress.dna
	growth_label.text = growth_text(progress)


func show_message(text: String, seconds: float = 4.0) -> void:
	message_label.text = text
	message_label.visible = true
	message_left = seconds


func tick(delta: float) -> void:
	if message_left <= 0.0:
		return
	message_left -= delta
	if message_left <= 0.0:
		message_label.visible = false


func _process(delta: float) -> void:
	tick(delta)
```
`scripts/marine_snow.gd` genau so:
```gdscript
class_name MarineSnow
extends CPUParticles3D
## Schwebeteilchen im Wasser rund um die Kamera (FishMain setzt die Lage jedes Bild auf die Kamera).

## Größe des Bereichs, in dem Teilchen entstehen, in Metern.
const BOX := Vector3(30, 20, 30)


func _init() -> void:
	amount = 400
	lifetime = 8.0
	preprocess = 8.0
	local_coords = false
	emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	emission_box_extents = BOX * 0.5
	direction = Vector3(0, 1, 0)
	spread = 180.0
	gravity = Vector3(0, -0.05, 0)
	initial_velocity_min = 0.0
	initial_velocity_max = 0.15
	var quad := QuadMesh.new()
	quad.size = Vector2(0.06, 0.06)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.95, 1.0, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	quad.material = mat
	mesh = quad
```
- Keine andere Datei ändern.

## Tests
`tests/test_fish_hud.gd` mit `extends "res://tests/base_test.gd"`, `var hud: FishHud`; `setup()`: `hud = FishHud.new()`; `teardown()`: `hud.free()`:
- `test_start`: `hud.depth_label.text` ist `"Tiefe: 20 m"`; `hud.dna_label.text` ist `"DNA: 0"`; `hud.growth_label.text` ist `"Wachstum: 0 / 20"`; `hud.help_label.text` ist `FishHud.HELP`; `hud.message_label.visible` falsch
- `test_tiefe`: `FishHud.depth_text(12.4)` ist `"Tiefe: 12 m"`; `hud.show_depth(41.6)` → `hud.depth_label.text` ist `"Tiefe: 42 m"`
- `test_fortschritt`: `var p := FishProgress.new()`; `p.eat(25)`; `hud.show_progress(p)` → `hud.dna_label.text` ist `"DNA: 25"`; `hud.growth_label.text` ist `"Wachstum: 5 / 30"`
- `test_ausgewachsen`: `var p := FishProgress.new()`; `p.eat(500)` → `FishHud.growth_text(p)` ist `"Wachstum: ausgewachsen"`
- `test_meldung`: `hud.show_message("Hallo", 2.0)` → `hud.message_label.visible` wahr; `hud.message_label.text` ist `"Hallo"`; `hud.tick(1.0)` → noch sichtbar; `hud.tick(1.5)` → `hud.message_label.visible` falsch
- `test_schnee`: `var s := MarineSnow.new()` → `s.amount` ist 400; `s.emission_box_extents` ist `Vector3(15, 10, 15)`; `s.local_coords` falsch; `s.mesh is QuadMesh` wahr; am Ende `s.free()`
