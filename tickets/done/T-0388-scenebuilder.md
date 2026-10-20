---
id: T-0388
title: SceneBuilder – Szenenmodell in echte Godot-Knoten übersetzen
project: hub-engine
priority: 4
after: T-0373
---
## Ziel
Meilenstein „Durchstich: Laufzeit, CLI, Editor, Export“: Das Szenenmodell (`SceneModel`, T-0373) wird zur Laufzeit in einen echten Godot-Knotenbaum übersetzt. Unbekannte Typen und Eigenschaften führen nicht zum Absturz, sondern werden gemeldet.

## Dateien
- `runtime/scene_builder.gd` – neu, Klasse `SceneBuilder`
- `tests/test_scene_builder.gd` – neu

## Akzeptanzkriterien
`class_name SceneBuilder`, `extends RefCounted` (der Ordner `runtime/` darf Knoten erzeugen, `core/` nicht):
- `var problems: Array[String] = []`
- `func build(model: SceneModel) -> Node`: `problems` leeren; Wurzel `Node.new()` mit `name = "Szene"`; dann die Objekte in der Reihenfolge von `model.order`:
  - Typ gültig, wenn `ClassDB.class_exists(type)`, `ClassDB.can_instantiate(type)` und `ClassDB.is_parent_class(type, "Node")`; dann `ClassDB.instantiate(type) as Node`. Sonst ein `Node.new()` und Problem `"%s: Typ %s gibt es nicht" % [id, type]`
  - `node.name = id`, `node.set_meta("hub_id", id)`, `node.set_meta("hub_type", type)`
  - je Eigenschaft aus `props`: nur setzen, wenn der Knoten sie hat (`key in node`, d. h. über `get_property_list()` prüfen); sonst Problem `"%s: Eigenschaft %s gibt es nicht" % [id, key]`
  - Elternknoten: bei `parent == ""` die Wurzel, sonst der zuvor erzeugte Knoten mit dieser Kennung (Kennung → Knoten in einem Dictionary merken)
  - Rückgabe die Wurzel (der Aufrufer gibt sie frei)
- `static func find(root: Node, id: String) -> Node`: Knoten mit Meta `hub_id == id` in der Wurzel und allen Nachkommen, sonst `null`

## Tests
`tests/test_scene_builder.gd`, jeder Test gibt die Wurzel am Ende mit `free()` frei.
- `test_baum`: Modell mit `Node2D` (o1) und darunter `Sprite2D` (o2) → Wurzel hat 1 Kind „o1“, das ein Kind „o2“ hat; `find(root, "o2") is Sprite2D`; `problems` leer
- `test_eigenschaften`: `Node2D` mit `{"visible": false, "z_index": 3}` → `find(root, "o1").visible` falsch, `z_index` 3
- `test_unbekannter_typ`: Typ „GibtEsNicht“ → Knoten vorhanden (`find` nicht `null`), `problems` `["o1: Typ GibtEsNicht gibt es nicht"]`
- `test_unbekannte_eigenschaft`: `Node2D` mit `{"fluegel": 2}` → `problems` `["o1: Eigenschaft fluegel gibt es nicht"]`
- `test_kein_node`: Typ „Resource“ (keine Node-Klasse) → als Problem gemeldet, Aufbau läuft weiter
- `test_reihenfolge`: drei Objekte auf oberster Ebene → Kinder der Wurzel heißen „o1“, „o2“, „o3“

Review (19.10.2026): gemergt.
