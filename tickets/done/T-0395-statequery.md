---
id: T-0395
title: StateQuery – Zustand laufender Objekte strukturiert abfragen
project: hub-engine
priority: 4
after: T-0388
---
## Ziel
Meilenstein „Durchstich: Laufzeit, CLI, Editor, Export“ (Lastenheft Muss 10 „Objektzustände, Positionen, Geschwindigkeiten, Szenenstruktur strukturiert abfragen“, Abnahmekriterium 4 „Zustand abrufen“): Aus dem Knotenbaum, den `SceneBuilder` (T-0388, `runtime/scene_builder.gd`) baut, liest dieses Ticket den Zustand eines Objekts als JSON-fähiges Dictionary.

## Dateien
- `runtime/state_query.gd` – neu, Klasse `StateQuery`
- `tests/test_state_query.gd` – neu

## Akzeptanzkriterien
`class_name StateQuery`, `extends RefCounted`, nur statische Funktionen. Nutzt `SceneBuilder.find(root, id)`.
- `static func vec(v: Variant) -> Array`: `Vector2` → `[x, y]`, `Vector3` → `[x, y, z]`, sonst `[]`
- `static func object_state(node: Node) -> Dictionary`: immer `{"id": str(node.get_meta("hub_id", "")), "type": node.get_class(), "name": str(node.name)}`, dazu, soweit zutreffend:
  - `Node2D`: `"position"` (`vec(position)`), `"rotation"` (`rotation_degrees`)
  - `Node3D`: `"position"` (`vec(position)`), `"rotation"` (`vec(rotation_degrees)`)
  - `RigidBody2D` und `RigidBody3D`: `"velocity"` (`vec(linear_velocity)`); `CharacterBody2D` und `CharacterBody3D`: `"velocity"` (`vec(velocity)`)
  - `CanvasItem` und `Node3D`: `"visible"` (`visible`)
- `static func query(root: Node, id: String) -> CommandResult`: Knoten fehlt → `NOT_FOUND`, `"Objekt %s gibt es nicht"`; sonst `success(object_state(node))`
- `static func tree(root: Node) -> Array[Dictionary]`: alle Nachkommen mit Meta `hub_id`, in Baumreihenfolge (Tiefensuche, Kinder in ihrer Reihenfolge), je `{"id", "type", "parent"}`; `type` ist die Meta `hub_type`, `parent` die `hub_id` des Elternknotens oder „“, wenn der Elternknoten keine hat

## Tests
`tests/test_state_query.gd`, Szene jeweils mit `SceneBuilder.new().build(model)` bauen und am Ende mit `free()` freigeben:
- `test_position_2d`: `Node2D` mit `{"position": Vector2(3, 4)}` → `query(root, "o1")` ok, `data["position"]` `[3.0, 4.0]`, `data["type"]` „Node2D“, `data["visible"]` wahr
- `test_geschwindigkeit`: `RigidBody2D` mit `{"linear_velocity": Vector2(1, -2)}` → `data["velocity"]` `[1.0, -2.0]`
- `test_3d`: `Node3D` mit `{"position": Vector3(1, 2, 3)}` → `data["position"]` `[1.0, 2.0, 3.0]`
- `test_fehlt`: `query(root, "o9")` → Code „not_found“, Meldung „Objekt o9 gibt es nicht“
- `test_baum`: `Node2D` (o1) mit Kind `Sprite2D` (o2) → `tree(root)` gleich `[{"id": "o1", "type": "Node2D", "parent": ""}, {"id": "o2", "type": "Sprite2D", "parent": "o1"}]`
- `test_vec`: `vec(Vector2(1, 2))` `[1.0, 2.0]`; `vec("x")` `[]`

Review (19.10.2026): gemergt.
