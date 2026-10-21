---
id: T-0444
title: ChunkView – eine Kachel des Meeresbodens zeichnen
project: zellenphase
priority: 4
after: T-0440, T-0442, T-0443
---
## Ziel
Auftrag „Fischphase – unendliche Welt“: Eine Kachel wird als 3D-Knoten gezeichnet: Bodenfläche mit Höhenprofil, Seegras (gebogen) und Felsen. Beim Wegschwimmen wird sie wieder entfernt.

## Dateien
- `scripts/chunk_view.gd` – neu, Klasse `ChunkView`
- `tests/test_chunk_view.gd` – neu

## Akzeptanzkriterien
`class_name ChunkView`, `extends Node3D`. Vorher `scripts/reef_view.gd` (bisherige Darstellung, Materialien) und `scripts/fish_textures.gd` lesen.
- `const GRID := 16` (Bodenraster je Kachel: 16 × 16 Felder)
- `var chunk: Vector2i`, `var layout: ChunkLayout`, `var floor_mesh: MeshInstance3D` (Name „Floor“), `var weeds: Array[MeshInstance3D] = []`, `var time := 0.0`
- `func _init(c: Vector2i, floor: SeafloorHeight) -> void`: `chunk = c`, `name = "Chunk_%d_%d" % [c.x, c.y]`, `position = WorldChunks.origin_of(c)`; Bodenfläche mit `SurfaceTool` als Raster von `(GRID + 1)²` Punkten, y = `floor.height_at(Weltx, Weltz)` (lokal ohne den Ursprung), UV = Weltx/8 und Weltz/8, `generate_normals()`, Material `FishTextures.floor_material()`; dann je Eintrag aus `ChunkLayout.new(c, floor)` Seegras mit `SeaweedShape.build_mesh(height, bend)` (Material wie in `ReefView`, `cull_mode = BaseMaterial3D.CULL_DISABLED` auf einer Kopie) bzw. Felsen wie in `ReefView`, jeweils an der lokalen Position (Weltposition minus `position`)
- Seegras wiegt sich wie in `ReefView` (`ReefView.sway` verwenden)

## Tests
`tests/test_chunk_view.gd` (Ansicht an `root` hängen, in `teardown()` freigeben):
- `test_name_und_lage`: `ChunkView.new(Vector2i(1, -1), SeafloorHeight.new())` → `name` „Chunk_1_-1“, `position` `Vector3(64, 0, -64)`
- `test_inhalt`: Anzahl Kinder = 1 (Boden) + Anzahl Einträge im Layout; `weeds.size()` gleich `layout.count("seegras")`
- `test_boden`: `floor_mesh.mesh` ist ein `ArrayMesh` mit `(GRID + 1) * (GRID + 1)` oder mehr Eckpunkten

Review (20.10.2026): fehlgeschlagen (Parse-Fehler im Test, Boden mit falschem Raster und ohne UV), von Claude selbst umgesetzt.
