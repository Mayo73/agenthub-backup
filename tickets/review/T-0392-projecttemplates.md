---
id: T-0392
title: ProjectTemplates – Vorlagen für ein neues 2D- und 3D-Projekt
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich: Laufzeit, CLI, Editor, Export“ (Lastenheft Muss 1 „aus einer Vorlage starten“, Muss 3 „Kameras, einfache Beleuchtung“): Neue Projekte starten aus einer Vorlage mit einer Grundszene. Reine Logik auf dem `SceneModel` (`core/scene_model.gd`).

## Dateien
- `core/project_templates.gd` – neu, Klasse `ProjectTemplates`
- `tests/test_project_templates.gd` – neu

## Akzeptanzkriterien
`class_name ProjectTemplates`, `extends RefCounted`, nur statische Funktionen. Alle Typen sind echte Godot-Klassennamen, alle Eigenschaften echte Eigenschaften dieser Klassen.
- `static func names() -> Array[String]`: `["leer_2d", "leer_3d"]`
- `static func title(name: String) -> String`: „Leeres 2D-Projekt“, „Leeres 3D-Projekt“, sonst „“
- `static func create(name: String) -> SceneModel`: unbekannter Name → `null`. Sonst ein neues `SceneModel` mit genau diesen Objekten in dieser Reihenfolge (über `add_object`):
  - `leer_2d`:
    1. `Node2D`, oberste Ebene, `{"name": "Welt"}`
    2. `Camera2D` unter 1, `{"name": "Kamera", "position": Vector2(0, 0)}`
    3. `StaticBody2D` unter 1, `{"name": "Boden", "position": Vector2(0, 300)}`
  - `leer_3d`:
    1. `Node3D`, oberste Ebene, `{"name": "Welt"}`
    2. `Camera3D` unter 1, `{"name": "Kamera", "position": Vector3(0, 2, 6)}`
    3. `DirectionalLight3D` unter 1, `{"name": "Sonne", "rotation_degrees": Vector3(-45, 30, 0)}`
    4. `StaticBody3D` unter 1, `{"name": "Boden", "position": Vector3(0, 0, 0)}`
- `static func describe(name: String) -> Dictionary`: `{"name": name, "title": title(name), "objects": create(name).order.size()}`, bei unbekanntem Namen `{}`

## Tests
`tests/test_project_templates.gd`:
- `test_namen`: `names()` gleich `["leer_2d", "leer_3d"]`; `title("leer_3d")` „Leeres 3D-Projekt“; `title("x")` „“
- `test_2d`: `create("leer_2d")` → `order.size()` 3; `get_object("o1")["type"]` „Node2D“; `children("o1")` `["o2", "o3"]`; `get_property("o2", "name")` „Kamera“; `get_property("o3", "position")` `Vector2(0, 300)`
- `test_3d`: `create("leer_3d")` → `order.size()` 4; Typen der Objekte o2–o4 „Camera3D“, „DirectionalLight3D“, „StaticBody3D“; `children("o1").size()` 3
- `test_unbekannt`: `create("gibts_nicht") == null`; `describe("gibts_nicht")` leer
- `test_beschreibung`: `describe("leer_2d")` → `objects` 3, `title` „Leeres 2D-Projekt“
- `test_echte_klassen`: für jede Vorlage und jedes Objekt `ClassDB.class_exists(type)` wahr, und für jede Eigenschaft enthält `ClassDB.class_get_property_list(type)` einen Eintrag, dessen `"name"` gleich dem Schlüssel ist (über die Liste laufen und vergleichen)
- `test_unabhaengig`: zweimal `create("leer_2d")`, im ersten `set_property("o1", "name", "X")` → im zweiten weiter „Welt“
