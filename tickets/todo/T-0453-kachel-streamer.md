---
id: T-0453
title: ChunkStreamer – Kacheln beim Schwimmen nachladen und entfernen
project: zellenphase
priority: 4
after: T-0444
---
## Ziel
Auftrag „Fischphase – unendliche Welt“: Ein Knoten hält die 5 × 5 Kacheln um den Fisch als `ChunkView`-Kinder vor: neue werden angelegt, alte entfernt. Den Einbau in die Fischszene macht Claude.

## Dateien
- `scripts/chunk_streamer.gd` – neue Klasse
- `tests/test_chunk_streamer.gd` – Tests

## Akzeptanzkriterien
`class_name ChunkStreamer`, `extends Node3D`. Vorher `scripts/world_chunks.gd` und `scripts/chunk_view.gd` lesen.
- `var chunks := WorldChunks.new()`, `var floor: SeafloorHeight`, `var views: Dictionary = {}` (Kachel `Vector2i` → `ChunkView`)
- `func _init(p_floor: SeafloorHeight) -> void`: `floor = p_floor`, `name = "Chunks"`
- `func follow(center: Vector3) -> void`: ruft `chunks.update(center)` auf; je Kachel aus `"load"` ein `ChunkView.new(c, floor)` als Kind anlegen und in `views` eintragen; je Kachel aus `"unload"` den View entfernen (`remove_child`, `queue_free`) und aus `views` löschen
- `func view_count() -> int`: `views.size()`
- `func has_chunk(c: Vector2i) -> bool`

## Tests
`tests/test_chunk_streamer.gd` (Streamer an `(Engine.get_main_loop() as SceneTree).root` hängen, in `teardown()` mit `free()` freigeben; Boden `SeafloorHeight.new(7)`):
- `test_start`: `follow(Vector3(10, -20, 10))` → `view_count()` 25, `has_chunk(Vector2i(0, 0))` wahr
- `test_weiter`: danach `follow(Vector3(10 + 64, -20, 10))` → weiter 25, `has_chunk(Vector2i(3, 0))` wahr, `has_chunk(Vector2i(-2, 0))` falsch
- `test_gleich_bleiben`: zweimal `follow` an derselben Stelle → `get_child_count()` bleibt 25
