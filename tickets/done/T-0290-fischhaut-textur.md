---
id: T-0290
title: Fischhaut mit Schuppen-Textur
project: zellenphase
priority: 4
after: A-0016
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“, Teil „schönere Fische“: Körper, Schwanzflosse und Brustflossen der Fische bekommen die Schuppen-Textur `res://assets/fish/scales.png` (hell, wird mit der Fischfarbe eingefärbt). Augen, Kiefer und Stacheln bleiben ohne Textur.

## Dateien
- `scripts/fish_model.gd`
- `tests/test_fish_model.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_model.gd`: Konstante unter `extends Node3D` und dem Klassenkommentar:
  `const SKIN_TEXTURE := preload("res://assets/fish/scales.png")`
- Neue statische Funktion direkt unter `material(color)`:
```gdscript
## Haut des Fischs: Schuppen-Textur, mit der Fischfarbe eingefärbt, über die ganze Form gelegt (triplanar).
static func skin_material(color: Color) -> StandardMaterial3D:
	var mat := material(color)
	mat.albedo_texture = SKIN_TEXTURE
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3.ONE * 2.5
	mat.roughness = 0.45
	return mat
```
- In `rebuild(b)` die Zeile `var skin := material(b.color)` ersetzen durch `var skin := skin_material(b.color)`.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_model.gd` anhängen (dort legt `setup()` schon `model = FishModel.new()` an und `teardown()` gibt es frei; in den Tests unten steht `m` für `model`):
- `test_haut_textur`: `FishModel.skin_material(Color.RED).albedo_texture` ist `FishModel.SKIN_TEXTURE`; `.uv1_triplanar` wahr; `.albedo_color` ist `Color.RED`
- `test_haut_am_koerper`: Modell neu bauen; `(m.body.material_override as StandardMaterial3D).albedo_texture != null` wahr; `(m.tail.material_override as StandardMaterial3D).albedo_texture != null` wahr; `(m.eyes[0].material_override as StandardMaterial3D).albedo_texture == null` wahr
- `test_textur_geladen`: `FishModel.SKIN_TEXTURE.get_width()` ist 256

Review (18.10.2026): gemergt.
