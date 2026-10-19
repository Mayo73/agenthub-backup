---
id: T-0402
title: TriggerZone – Betreten und Verlassen von Triggerbereichen als Ereignisse
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Lastenheft Muss 5, Triggerbereiche; Abnahmekriterium 6): ein testbarer Triggerbereich, der aus Positionen je Schritt die Ereignisse „betreten“ und „verlassen“ erzeugt, die Agenten abfragen können.

## Dateien
- `core/trigger_zone.gd` – neu, Klasse `TriggerZone`
- `tests/test_trigger_zone.gd` – neu

## Akzeptanzkriterien
`class_name TriggerZone`, `extends RefCounted`:
- `var id := ""`, `var rect := Rect2()`, `var inside: Dictionary = {}` (Objekt-ID → true), `var events: Array[Dictionary] = []`
- `func _init(zone_id: String = "", zone_rect: Rect2 = Rect2()) -> void`
- `func update(step: int, positions: Dictionary) -> Array[Dictionary]`: `positions` ist Objekt-ID → `Vector2`. Für jedes Objekt (IDs sortiert): liegt es in `rect` (`rect.has_point`) und war nicht drin → Ereignis `{"zone": id, "object": oid, "type": "entered", "step": step}`; liegt es nicht drin und war drin → `"exited"`. Danach Objekte, die in `inside` stehen, aber in `positions` fehlen (IDs sortiert) → `"exited"`. `inside` nachführen. Neue Ereignisse an `events` anhängen und zurückgeben.
- `func is_inside(object_id: String) -> bool`
- `func clear() -> void`: `inside` und `events` leeren

## Tests
`tests/test_trigger_zone.gd`, Zone `TriggerZone.new("ziel", Rect2(0, 0, 10, 10))`:
- `test_betreten`: `update(1, {"a": Vector2(5, 5)})` → ein Ereignis, Typ „entered“, `step` 1; `is_inside("a")` wahr
- `test_kein_doppeltes`: zweimal derselbe Punkt → zweiter Aufruf liefert leere Liste
- `test_verlassen`: rein, dann `update(2, {"a": Vector2(20, 5)})` → Typ „exited“, `is_inside("a")` falsch
- `test_verschwunden`: rein, dann `update(2, {})` → „exited“
- `test_reihenfolge`: `update(1, {"b": Vector2(1, 1), "a": Vector2(2, 2)})` → Objekte „a“, „b“ in dieser Reihenfolge; `events.size()` 2

Review (19.10.2026): gemergt, nachgebessert: Nach dem Verlassen wurde erneutes Betreten nicht gemeldet (inside behielt false-Einträge); Test test_wieder_betreten ergänzt.
