---
id: T-0548
title: ContactLog – Kontaktinformationen sammeln und abfragen
project: hub-engine
priority: 4
---
## Ziel
Muss 5: „Treffer-/Kontaktinformationen … über Oberfläche und Agentenschnittstelle“. Ein Protokoll der Kontakte je Physikschritt, das Tests und Agenten abfragen können.

## Dateien
- `core/contact_log.gd` – neu, Klasse `ContactLog`
- `tests/test_contact_log.gd` – neu

## Akzeptanzkriterien
`class_name ContactLog`, `extends RefCounted`.
- `var contacts: Array[Dictionary] = []`, je `{"step": int, "a": String, "b": String, "point": [x, y], "normal": [x, y], "impulse": float}` (Vektoren als Arrays, JSON-fähig)
- `func add(step: int, a: String, b: String, point: Vector2, normal: Vector2, impulse: float = 0.0) -> void`: die Kennungen so speichern, dass `a < b` ist; werden sie dafür vertauscht, die Normale umdrehen (`-normal`)
- `func between(x: String, y: String) -> Array[Dictionary]`: alle Kontakte dieser beiden, Reihenfolge der Kennungen egal
- `func of(object_id: String) -> Array[Dictionary]`: alle Kontakte mit diesem Objekt
- `func at_step(step: int) -> Array[Dictionary]`
- `func strongest() -> Dictionary`: Kontakt mit dem größten `impulse`, ohne Kontakte `{}`
- `func clear_before(step: int) -> int`: entfernt alle Kontakte mit kleinerem `step`, gibt die Anzahl zurück

Hinweis Typen: Werte aus Dictionaries immer mit Typ lesen (`var s: int = c["step"]`), Ergebnisse in `var result: Array[Dictionary] = []` sammeln.

## Tests
`tests/test_contact_log.gd`:
- `test_reihenfolge`: `add(1, "z", "a", Vector2(1, 2), Vector2(0, -1))` → `contacts[0]["a"]` „a“, `contacts[0]["b"]` „z“, `contacts[0]["normal"][1]` 1.0, `contacts[0]["point"]` `[1.0, 2.0]`
- `test_zwischen`: `add(1, "a", "b", Vector2.ZERO, Vector2.UP)`, `add(2, "b", "a", Vector2.ZERO, Vector2.UP)`, `add(2, "a", "c", Vector2.ZERO, Vector2.UP)` → `between("b", "a").size()` 2, `of("a").size()` 3, `at_step(2).size()` 2
- `test_staerkster`: drei Kontakte mit Impuls 1.0, 5.0, 2.0 → `strongest()["impulse"]` 5.0; neues Protokoll → `strongest().is_empty()`
- `test_aufraeumen`: Kontakte in den Schritten 1, 2, 3 → `clear_before(3)` 2, `contacts.size()` 1

Review (21.10.2026): gemergt.
