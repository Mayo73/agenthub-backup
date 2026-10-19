---
id: T-0401
title: CollisionLayers – benannte Kollisionsebenen und Masken
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Lastenheft Muss 5, Kollisionsgruppen): Ebenen haben Namen statt Bitnummern; daraus entstehen die Godot-Werte `collision_layer` und `collision_mask`, und es lässt sich prüfen, ob zwei Körper kollidieren.

## Dateien
- `core/collision_layers.gd` – neu, Klasse `CollisionLayers`
- `tests/test_collision_layers.gd` – neu

## Akzeptanzkriterien
`class_name CollisionLayers`, `extends RefCounted`:
- `var names: Array[String] = ["Welt", "Spieler", "Gegner", "Projektile"]`; `func _init(layer_names: Array[String] = []) -> void`: ist die Liste nicht leer, `names = layer_names.duplicate()`
- `func bit(layer_name: String) -> int`: `1 << index` (erste Ebene = 1), unbekannt → 0
- `func mask(layer_list: Array[String]) -> int`: ODER aller `bit(...)`
- `func unknown(layer_list: Array[String]) -> Array[String]`: unbekannte Namen in Eingabereihenfolge
- `static func collides(layer_a: int, mask_a: int, layer_b: int, mask_b: int) -> bool`: wie Godot: `(layer_a & mask_b) != 0 or (layer_b & mask_a) != 0`
- `func names_of(value: int) -> Array[String]`: Namen aller gesetzten Bits in Ebenen-Reihenfolge

## Tests
`tests/test_collision_layers.gd`:
- `test_bits`: `bit("Welt")` 1, `bit("Projektile")` 8, `bit("Wasser")` 0
- `test_maske`: `mask(["Welt", "Gegner"])` 5
- `test_unbekannt`: `unknown(["Welt", "Wasser", "Luft"])` `["Wasser", "Luft"]`
- `test_kollision`: `collides(8, 4, 4, 1)` wahr (Projektil trifft Gegner); `collides(8, 4, 2, 1)` falsch (Projektil gegen Spieler)
- `test_namen`: `names_of(10)` `["Spieler", "Projektile"]`
- `test_eigene_namen`: `CollisionLayers.new(["A", "B"])` → `bit("B")` 2, `bit("Welt")` 0

Review (19.10.2026): gemergt, nachgebessert: names_of gibt ein typisiertes Array zurück.
