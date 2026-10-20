---
id: T-0403
title: SceneDiff – Unterschiede zwischen zwei Szenenständen als Vorschau
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „Kern“ (Lastenheft Muss 8: Vorschau/Differenz vor Übernahme): Zwei Schnappschüsse des Szenenmodells (`SceneModel.to_dict()`) vergleichen und die Änderungen als Liste liefern, damit Mensch und Agenten sehen, was eine Änderung bewirkt.

## Dateien
- `core/scene_diff.gd` – neu, Klasse `SceneDiff`
- `tests/test_scene_diff.gd` – neu

## Akzeptanzkriterien
`class_name SceneDiff`, `extends RefCounted`, nur statische Funktionen. Ein Schnappschuss hat die Form von `SceneModel.to_dict()`; vorher `core/scene_model.gd` lesen (Objekte unter `"objects"`, je `{"id", "type", "parent", "props"}`).
- `static func diff(before: Dictionary, after: Dictionary) -> Array[Dictionary]`:
  - Kennungen beider Stände sammeln und **sortiert** durchgehen.
  - nur in `after` → `{"op": "added", "id": id, "type": typ}`
  - nur in `before` → `{"op": "removed", "id": id, "type": typ}`
  - in beiden: geändertes `parent` → `{"op": "moved", "id": id, "old": alt, "new": neu}`; danach jede Eigenschaft (Schlüssel beider `props` zusammen, sortiert), deren Wert sich unterscheidet oder die nur auf einer Seite existiert → `{"op": "changed", "id": id, "key": key, "old": alt oder null, "new": neu oder null}`
- `static func summary(changes: Array[Dictionary]) -> String`: `"%d neu, %d entfernt, %d verschoben, %d geändert"`
- Werte aus Dictionaries mit ausdrücklichem Typ lesen (`var objs: Dictionary = before.get("objects", {})`).

## Tests
`tests/test_scene_diff.gd`, in `setup()` `model = SceneModel.new()`:
- `test_gleich`: `SceneDiff.diff(model.to_dict(), model.to_dict())` leer
- `test_neu`: `var a: Dictionary = model.to_dict().duplicate(true)`, dann `model.add_object("Node2D")`, `diff(a, model.to_dict())` → ein Eintrag, `op` „added“, `id` „o1“
- `test_entfernt`: Objekt anlegen, Schnappschuss, `model.remove_object("o1")` → ein Eintrag, `op` „removed“
- `test_geaendert`: Objekt mit `{"mass": 1.0}`, Schnappschuss, `model.set_property("o1", "mass", 2.0)` → ein Eintrag `op` „changed“, `key` „mass“, `old` 1.0, `new` 2.0
- `test_zusammenfassung`: `summary([{"op": "added"}, {"op": "changed"}])` ist „1 neu, 0 entfernt, 0 verschoben, 1 geändert“

Review (19.10.2026): gemergt.
