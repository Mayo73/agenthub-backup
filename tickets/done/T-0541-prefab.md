---
id: T-0541
title: Prefab – wiederverwendbare Objektvorlage
project: hub-engine
priority: 4
---
## Ziel
Muss 4 „Grundbausteine“: wiederverwendbare Objektvorlagen. Eine Vorlage hat Typ und Grundeigenschaften; Instanzen übernehmen sie und dürfen einzelne Werte überschreiben.

## Dateien
- `core/prefab.gd` – neu, Klasse `Prefab`
- `tests/test_prefab.gd` – neu

## Akzeptanzkriterien
`class_name Prefab`, `extends RefCounted`.
- `var id := ""`, `var type := "Node2D"`, `var props: Dictionary = {}`
- `func _init(prefab_id: String = "", node_type: String = "Node2D", base_props: Dictionary = {}) -> void`: Werte setzen, `props = base_props.duplicate(true)`
- `func instantiate(object_id: String, overrides: Dictionary = {}) -> Dictionary`: `{"id": object_id, "type": type, "prefab": id, "props": …}`; `props` ist eine Kopie von `props` (`duplicate(true)`), danach jeder Schlüssel aus `overrides` gesetzt. Die Vorlage selbst ändert sich nicht.
- `func overrides_of(instance: Dictionary) -> Dictionary`: alle Schlüssel aus `instance["props"]`, deren Wert in `props` fehlt oder anders ist, mit dem Wert der Instanz
- `func to_dict() -> Dictionary` (`id`, `type`, `props`) und `static func from_dict(d: Dictionary) -> Prefab`

Hinweis Typen: Werte aus Dictionaries immer mit Typ lesen (`var p: Dictionary = instance.get("props", {})`), typisierte Arrays mit `var a: Array[String] = []` anlegen.

## Tests
`tests/test_prefab.gd`, Vorlage `Prefab.new("kiste", "RigidBody2D", {"mass": 2.0, "color": "braun"})`:
- `test_instanz`: `instantiate("k1")` → `id` „k1“, `type` „RigidBody2D“, `prefab` „kiste“, `props.mass` 2.0
- `test_ueberschreiben`: `instantiate("k2", {"mass": 5.0})` → `props.mass` 5.0, `props.color` „braun“; die Vorlage hat weiter `props.mass` 2.0
- `test_abweichungen`: `overrides_of(instantiate("k3", {"mass": 5.0}))` ist `{"mass": 5.0}`; `overrides_of(instantiate("k4"))` ist leer
- `test_speichern`: `Prefab.from_dict(p.to_dict())` hat gleiche `id`, `type` und `props.mass`

Review (21.10.2026): gemergt.
