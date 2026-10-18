---
id: T-0309
title: Sandboden und Felsen mit Textur in der Fischszene
project: zellenphase
priority: 3
after: T-0308, T-0306
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Der Meeresboden zeigt Sand, die Felsen des Riffs Stein mit Algen (Materialien aus `FishTextures`, T-0308).

## Dateien
- `scripts/fish_main.gd`
- `scripts/reef_view.gd`
- `tests/test_fish_main.gd` – Test anhängen
- `tests/test_reef_view.gd` – Test anhängen (neu anlegen, falls es die Datei nicht gibt: `extends "res://tests/base_test.gd"`)

## Akzeptanzkriterien
- `scripts/fish_main.gd`, `_ready()`: direkt nach der Zeile `floor_mesh = make_plane("Floor", -FishWorld.DEPTH, FishWorld.FLOOR_COLOR)` die Zeile
  `(floor_mesh.mesh as PlaneMesh).material = FishTextures.floor_material()` einfügen. `make_plane()` selbst nicht ändern.
- `scripts/reef_view.gd`, `_init()`: die Zeile `var rock_mat := FishModel.material(Color(0.42, 0.4, 0.38))` ersetzen durch `var rock_mat := FishTextures.rock_material()`.
- Sonst nichts ändern.

## Tests
- `tests/test_fish_main.gd` anhängen: `test_sandboden`: `((fish.floor_mesh.mesh as PlaneMesh).material as StandardMaterial3D).albedo_texture == FishTextures.SAND` wahr; die Oberfläche (`fish.surface_mesh`, gleiche Schreibweise) hat **keine** Textur (`albedo_texture == null`).
- `tests/test_reef_view.gd` anhängen: `test_felsen_textur`: `var r := ReefView.new()`; unter `r.get_children()` gibt es mindestens ein `MeshInstance3D`, dessen `material_override` ein `StandardMaterial3D` mit `albedo_texture == FishTextures.ROCK` ist; am Ende `r.free()`.

Review (18.10.2026): gemergt.
