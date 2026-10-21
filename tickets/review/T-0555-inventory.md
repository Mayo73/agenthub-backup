---
id: T-0555
title: Inventory – Gegenstände sammeln mit Stapelgrenzen
project: hub-engine
priority: 4
---
## Ziel
Muss 4 „Grundbausteine“ und Referenzspiele: ein Inventar für eingesammelte Gegenstände (Münzen, Tränke, Munition) mit Stapelgrenzen und begrenzten Plätzen.

## Dateien
- `core/inventory.gd` – neu, Klasse `Inventory`
- `tests/test_inventory.gd` – neu

## Akzeptanzkriterien
`class_name Inventory`, `extends RefCounted`.
- `var slots: Dictionary = {}` (Gegenstand → int), `var limits: Dictionary = {}` (Gegenstand → größte Stapelzahl; fehlt = unbegrenzt), `var capacity := 0` (höchstens so viele verschiedene Gegenstände; 0 = unbegrenzt)
- `func set_limit(item: String, max_count: int) -> void`
- `func count(item: String) -> int`: Anzahl, sonst 0
- `func add(item: String, amount: int = 1) -> int`: `amount <= 0` → 0; neuer Gegenstand, `capacity > 0` und schon `capacity` verschiedene → 0; mit Grenze nur bis zur Grenze auffüllen; neue Anzahl speichern und die tatsächlich hinzugefügte Menge zurückgeben
- `func remove(item: String, amount: int = 1) -> bool`: `amount <= 0` oder zu wenig vorhanden → `false`; sonst abziehen, bei 0 den Eintrag entfernen, `true`
- `func items() -> Array[String]`: Gegenstände sortiert
- `func is_empty() -> bool`
- `func to_dict() -> Dictionary` (`slots`, `limits`, `capacity`) und `static func from_dict(d: Dictionary) -> Inventory` (Zahlen mit `int(...)`)

Hinweis Typen: Werte aus Dictionaries immer mit Typ lesen (`var have: int = int(slots.get(item, 0))`).

## Tests
`tests/test_inventory.gd`, `setup()`: `inv = Inventory.new()`:
- `test_hinzufuegen`: `add("muenze", 5)` 5, `count("muenze")` 5, `add("muenze", 0)` 0
- `test_grenze`: `set_limit("trank", 3)`, `add("trank", 2)` 2, `add("trank", 5)` 1, `count("trank")` 3
- `test_entfernen`: `add("muenze", 5)`, `remove("muenze", 3)` wahr, `count` 2; `remove("muenze", 5)` falsch; `remove("muenze", 2)` wahr, `is_empty()` wahr
- `test_platz`: `capacity = 2`, `add("a")` 1, `add("b")` 1, `add("c")` 0, `add("a")` 1; `items()` ist `["a", "b"]`
- `test_speichern`: `add("muenze", 7)`, `set_limit("trank", 3)`; `var d: Dictionary = JSON.parse_string(JSON.stringify(inv.to_dict()))` → `Inventory.from_dict(d)` hat `count("muenze")` 7 und nimmt bei `add("trank", 5)` nur 3
