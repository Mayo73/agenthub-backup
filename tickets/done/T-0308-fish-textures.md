---
id: T-0308
title: FishTextures – Materialien für Sandboden und Felsen
project: zellenphase
priority: 3
after: A-0017, A-0018
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Boden und Felsen der Fischphase bekommen echte Texturen statt einfarbiger Flächen. Diese Klasse liefert die beiden Materialien, der Einbau folgt in T-0309.

## Dateien
- `scripts/fish_textures.gd` – neu
- `tests/test_fish_textures.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_textures.gd`, genau so:
```gdscript
class_name FishTextures
extends RefCounted
## Texturen der Fischphase: Sandboden und Felsen (Higgsfield, A-0017 und A-0018).

const SAND := preload("res://assets/fish/sand.png")
const ROCK := preload("res://assets/fish/fels.png")
## So oft wiederholt sich die Sandtextur über die ganze Bodenfläche (300 m).
const SAND_REPEAT := 60.0


## Boden: Sand, oft wiederholt, von beiden Seiten sichtbar.
static func floor_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = SAND
	mat.uv1_scale = Vector3(SAND_REPEAT, SAND_REPEAT, 1.0)
	mat.texture_repeat = true
	mat.roughness = 0.95
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


## Felsen: Steintextur, triplanar über die ganze Form gelegt.
static func rock_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = ROCK
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3.ONE * 0.5
	mat.roughness = 0.9
	return mat
```

## Tests
`tests/test_fish_textures.gd` (neu, `extends "res://tests/base_test.gd"`):
- `test_texturen_geladen`: `FishTextures.SAND.get_width()` ist 512; `FishTextures.ROCK.get_width()` ist 512
- `test_boden`: `var m := FishTextures.floor_material()` → `m.albedo_texture == FishTextures.SAND` wahr; `m.uv1_scale.x` ist 60.0; `m.cull_mode` ist `BaseMaterial3D.CULL_DISABLED`
- `test_fels`: `var m := FishTextures.rock_material()` → `m.albedo_texture == FishTextures.ROCK` wahr; `m.uv1_triplanar` wahr

Review (18.10.2026): gemergt.
