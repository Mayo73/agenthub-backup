---
id: T-0532
title: TriggerZone3D – Auslösebereich im Raum
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Lastenheft: Auslöser auch in 3D): Ein quaderförmiger Bereich meldet, wann Objekte ihn betreten und verlassen, genau wie `TriggerZone` in 2D.

## Dateien
- `core/trigger_zone_3d.gd` – neu, Klasse `TriggerZone3D`
- `tests/test_trigger_zone_3d.gd` – neu

## Akzeptanzkriterien
`class_name TriggerZone3D`, `extends RefCounted`. Vorher `core/trigger_zone.gd` lesen und denselben Aufbau übernehmen, nur mit `AABB` und `Vector3` statt `Rect2` und `Vector2`.
- `var id := ""`, `var box: AABB = AABB()`, `var inside: Dictionary = {}`, `var events: Array[Dictionary] = []`
- `func _init(zone_id: String = "", zone_box: AABB = AABB()) -> void`
- `func update(step: int, positions: Dictionary) -> Array[Dictionary]`: `positions` ordnet Objektkennungen `Vector3` zu; IDs sortiert durchgehen; neu im Bereich (`box.has_point`) → Ereignis `{"zone": id, "object": oid, "type": "entered", "step": step}`, aus dem Bereich heraus → `"exited"`. Objekte, die in `positions` fehlen und vorher drin waren, gelten als verlassen (wie in `TriggerZone`). Neue Ereignisse auch an `events` anhängen und zurückgeben
- `func is_inside(object_id: String) -> bool`, `func clear() -> void` (leert `inside` und `events`)

## Tests
`tests/test_trigger_zone_3d.gd`, Bereich `AABB(Vector3(0, 0, 0), Vector3(2, 2, 2))`:
- `test_betreten`: `update(1, {"a": Vector3(1, 1, 1)})` → ein Ereignis `entered` für „a“ mit `step` 1; `is_inside("a")` wahr
- `test_verlassen`: danach `update(2, {"a": Vector3(5, 1, 1)})` → ein Ereignis `exited`
- `test_hoehe_zaehlt`: `update(1, {"b": Vector3(1, 5, 1)})` → kein Ereignis (über dem Bereich)
- `test_verschwunden`: „a“ drin, dann `update(2, {})` → ein Ereignis `exited`
- `test_sortiert`: `update(1, {"z": Vector3(1, 1, 1), "a": Vector3(1, 1, 1)})` → erstes Ereignis für „a“

Review (21.10.2026): gemergt.
