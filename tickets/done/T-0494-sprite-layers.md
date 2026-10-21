---
id: T-0494
title: SpriteLayers – Ebenen für 2D-Szenen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Muss 3: „Sprites, Ebenen und Kamera in 2D“): Benannte Ebenen mit fester Reihenfolge (Hintergrund hinten, Oberfläche vorne), denen Objekte zugeordnet werden. Daraus ergibt sich der Zeichenindex (`z_index`).

## Dateien
- `core/sprite_layers.gd` – neu, Klasse `SpriteLayers`
- `tests/test_sprite_layers.gd` – neu

## Akzeptanzkriterien
`class_name SpriteLayers`, `extends RefCounted`.
- `const DEFAULT_LAYERS: Array[String] = ["hintergrund", "welt", "figuren", "vordergrund"]`, `const STEP := 100` (Abstand der z-Indizes zweier Ebenen)
- `var layers: Array[String] = []` (hinten → vorne), `var assignment: Dictionary = {}` (Objekt-ID → Ebene)
- `func _init() -> void`: `layers = DEFAULT_LAYERS.duplicate()`
- `func add_layer(name: String, index: int = -1) -> CommandResult`: leerer Name → `INVALID_ARGUMENT`; schon vorhanden → `CONFLICT`, `"Ebene %s gibt es schon"`; sonst an `index` einfügen (−1 = ganz vorne), `success({"layers": layers})`
- `func move_layer(name: String, index: int) -> CommandResult`: unbekannt → `NOT_FOUND`; Index auf `0 .. layers.size() - 1` begrenzen
- `func remove_layer(name: String) -> CommandResult`: unbekannt → `NOT_FOUND`; letzte verbleibende Ebene → `DEPENDENCY`, `"Die letzte Ebene kann nicht entfernt werden"`; zugeordnete Objekte wandern auf die erste Ebene
- `func assign(object_id: String, layer: String) -> CommandResult`: unbekannte Ebene → `NOT_FOUND`
- `func layer_of(object_id: String) -> String`: zugeordnete Ebene, sonst `"welt"`, falls es sie gibt, sonst die erste
- `func z_index_of(object_id: String) -> int`: `layers.find(layer_of(object_id)) * STEP`
- `func to_dict() -> Dictionary` und `static func from_dict(d: Dictionary) -> SpriteLayers`

## Tests
`tests/test_sprite_layers.gd`:
- `test_standard`: neue Ebenen sind `DEFAULT_LAYERS`; `z_index_of("o1")` ist 100 (Ebene „welt“)
- `test_zuordnen`: `assign("o1", "vordergrund")` → `z_index_of("o1")` 300; `assign("o1", "gibtsnicht")` → „not_found“
- `test_neue_ebene`: `add_layer("himmel", 0)` → `layers[0]` „himmel“; nochmal → „conflict“
- `test_verschieben`: `move_layer("hintergrund", 99)` → letzte Ebene ist „hintergrund“
- `test_entfernen`: `assign("o2", "figuren")`, `remove_layer("figuren")` → `layer_of("o2")` „hintergrund“
- `test_speichern`: `SpriteLayers.from_dict(l.to_dict())` liefert dieselben Ebenen und Zuordnungen

Review (2026-10-21): gemergt, nachgebessert: to_dict liefert Kopien, from_dict liest Ebenen aus JSON, add_layer begrenzt den Index (neuer Test test_speichern_json).
