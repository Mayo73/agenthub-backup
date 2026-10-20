---
id: T-0411
title: TransformOps – Objekte verschieben, drehen und skalieren
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „Durchstich“ (Muss 3: verschieben, drehen, skalieren; numerische Eingaben und Werkzeuge bearbeiten dieselben Werte): Transformationen als Kernlogik auf dem Szenenmodell, mit Befehlen.

## Dateien
- `core/transform_ops.gd` – neu, Klasse `TransformOps`
- `tests/test_transform_ops.gd` – neu

## Akzeptanzkriterien
`class_name TransformOps`, `extends RefCounted`, nur statische Funktionen. Eigenschaften heißen wie in Godot: `position`, `rotation_degrees`, `scale`. Ein Objekt ist 3D, wenn sein Typ auf „3D“ endet, sonst 2D. 2D: `position` und `scale` sind `Vector2`, `rotation_degrees` ist `float`. 3D: alle drei sind `Vector3`.
- `static func is_3d(model: SceneModel, id: String) -> bool`
- `static func move(model: SceneModel, id: String, delta: Array) -> CommandResult`: Objekt fehlt → `NOT_FOUND`, `"Objekt %s gibt es nicht"`; `delta` braucht 2 (2D) bzw. 3 (3D) Werte, sonst `INVALID_ARGUMENT`, `"Erwartet %d Werte"`; neue Position = bisherige (Standard `Vector2.ZERO` bzw. `Vector3.ZERO`) + Delta (Werte mit `float(...)`); `success({"position": [x, y]})` bzw. `[x, y, z]`
- `static func rotate(model: SceneModel, id: String, degrees: Array) -> CommandResult`: 2D ein Wert, addiert zu `rotation_degrees` (Standard 0.0); 3D drei Werte, addiert zu `rotation_degrees` (Standard `Vector3.ZERO`); falsche Anzahl → wie bei `move`. Rückgabe `success({"rotation_degrees": wert})` (2D `float`, 3D `[x, y, z]`)
- `static func scale_by(model: SceneModel, id: String, factor: float) -> CommandResult`: `factor <= 0` → `INVALID_ARGUMENT`, `"Faktor muss größer als 0 sein"`; `scale` (Standard `Vector2.ONE` bzw. `Vector3.ONE`) mal Faktor; `success({"factor": factor})`
- `static func register_all(commands: CommandRegistry, model: SceneModel) -> void`: `"transform.move"` `{"id": "string", "delta": "array"}`, `"transform.rotate"` `{"id": "string", "degrees": "array"}`, `"transform.scale"` `{"id": "string", "factor": "number"}`, jeweils mit deutscher Beschreibung, Handler rufen die Funktionen oben

## Tests
`tests/test_transform_ops.gd`, `setup()`: `model = SceneModel.new()`, `model.add_object("Sprite2D", "", {"position": Vector2(1, 2)})` (o1), `model.add_object("MeshInstance3D")` (o2):
- `test_verschieben_2d`: `TransformOps.move(model, "o1", [3, 4])` ok, `model.get_property("o1", "position")` `Vector2(4, 6)`
- `test_verschieben_3d`: `move(model, "o2", [1, 2, 3])` → `Vector3(1, 2, 3)`; `move(model, "o2", [1, 2])` → „invalid_argument“
- `test_drehen`: zweimal `rotate(model, "o1", [90])` → `rotation_degrees` 180.0
- `test_skalieren`: `scale_by(model, "o2", 2.0)` → `scale` `Vector3(2, 2, 2)`; `scale_by(model, "o1", 0.0)` → „invalid_argument“
- `test_befehl`: Registry, `register_all`; `execute("transform.move", {"id": "o9", "delta": [1, 1]})` → „not_found“

Review (19.10.2026): nach 5 Fehlversuchen von Claude selbst umgesetzt und committet (verify grün, 303 Tests).
