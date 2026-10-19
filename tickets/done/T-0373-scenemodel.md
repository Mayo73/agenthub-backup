---
id: T-0373
title: SceneModel – Objekte mit stabiler Kennung, Eltern und Eigenschaften
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Kern: Befehle, Szenen, Revisionen“ (Lastenheft Muss 4 „stabile Objektkennungen“, Muss 7): das Szenenmodell der Engine als reine Logik. GUI, CLI und Agenten bearbeiten später alle dieses Modell.

## Dateien
- `core/scene_model.gd` – neu, Klasse `SceneModel`
- `tests/test_scene_model.gd` – neu

## Akzeptanzkriterien
`class_name SceneModel`, `extends RefCounted`:
- `var objects: Dictionary = {}` – Kennung → `{"id": String, "type": String, "parent": String, "props": Dictionary}`
- `var order: Array[String] = []` – Kennungen in Einfügereihenfolge
- `var next_id := 1`
- `func add_object(type: String, parent_id: String = "", props: Dictionary = {}) -> String`: neue Kennung `"o%d" % next_id`, danach `next_id += 1` (Kennungen werden nie wiederverwendet). Gibt es `parent_id` nicht (und ist es nicht leer), passiert nichts und es kommt `""` zurück. `props` wird kopiert (`duplicate(true)`).
- `func has_object(id: String) -> bool`
- `func get_object(id: String) -> Dictionary`: tiefe Kopie oder `{}`
- `func children(parent_id: String) -> Array[String]`: direkte Kinder in Einfügereihenfolge (`""` = oberste Ebene)
- `func remove_object(id: String) -> bool`: entfernt das Objekt und rekursiv alle Nachkommen aus `objects` und `order`; `false`, wenn es fehlt
- `func set_property(id: String, key: String, value: Variant) -> bool` und `func get_property(id: String, key: String, default: Variant = null) -> Variant`
- `func duplicate_object(id: String) -> String`: Kopie mit neuer Kennung, gleichem Typ, gleichem Elternobjekt und kopierten Eigenschaften (ohne Kinder); `""`, wenn es `id` nicht gibt
- `func to_dict() -> Dictionary`: `{"next_id": next_id, "objects": [Objekte in Reihenfolge von order]}`
- `func load_from(d: Dictionary) -> void`: ersetzt den gesamten Inhalt (für Rückgängig und Laden); `next_id` mit `int(...)` lesen
- `static func from_dict(d: Dictionary) -> SceneModel`: neues Modell, dann `load_from(d)`

## Tests
`tests/test_scene_model.gd`, in `setup()` `model = SceneModel.new()`:
- `test_kennungen`: zwei Objekte anlegen → „o1“, „o2“; „o1“ entfernen, neues anlegen → „o3“
- `test_eltern`: `var a := model.add_object("Node2D")`, `model.add_object("Sprite2D", a)` zweimal → `children(a).size()` 2, `children("")` `["o1"]`; `add_object("Sprite2D", "o99")` → „“
- `test_eigenschaften`: `add_object("RigidBody2D", "", {"mass": 2.0})` → `get_property(id, "mass")` 2.0; `set_property(id, "mass", 5.0)` wahr → 5.0; `get_property(id, "fehlt", 7)` 7; `set_property("o99", "mass", 1.0)` falsch
- `test_entfernen_mit_kindern`: Elternobjekt mit zwei Kindern entfernen → `objects.size()` 0, `order.size()` 0
- `test_kopie_unabhaengig`: `get_object(id)["props"]["mass"] = 9.0` ändert `get_property(id, "mass")` nicht
- `test_duplizieren`: Objekt mit `{"mass": 2.0}` unter einem Elternobjekt duplizieren → neue Kennung, gleicher Typ und Elternteil, `mass` 2.0
- `test_speichern_laden`: drei Objekte, `SceneModel.from_dict(JSON.parse_string(JSON.stringify(model.to_dict())))` → gleiche `order`, `next_id` 4 und `typeof(next_id)` `TYPE_INT`, Eigenschaften gleich

Review (19.10.2026): selbst umgesetzt (5. Versuch des Agents übernommen, load_from() repariert), Commit in main.
