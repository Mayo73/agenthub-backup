---
id: T-0610
title: EventBus – Spielereignisse veröffentlichen und abonnieren
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“: Ein einfacher Ereignisbus, über den Spielteile (Treffer, Punkte, Levelende) einander benachrichtigen, ohne sich zu kennen. Ereignisse werden zusätzlich protokolliert, damit Tests und KI-Agenten sie abfragen können.

## Dateien
- `core/event_bus.gd` – neu, Klasse `EventBus`
- `tests/test_event_bus.gd` – neu

## Akzeptanzkriterien
`class_name EventBus`, `extends RefCounted`.
- `var listeners := {}` (Name → `Array[Callable]`), `var history: Array[Dictionary] = []`, `var max_history := 100`
- `func subscribe(event_name: String, cb: Callable) -> void`: anhängen, doppelte (gleicher `Callable`) ignorieren
- `func unsubscribe(event_name: String, cb: Callable) -> bool`: entfernt, `true` wenn vorhanden
- `func publish(event_name: String, data: Dictionary = {}) -> int`: `{"name": event_name, "data": data}` an `history` anhängen (älteste entfernen, wenn mehr als `max_history`); alle Abonnenten mit `cb.call(data)` aufrufen; Rückgabe: Anzahl der aufgerufenen Abonnenten
- `func count(event_name: String) -> int`: Anzahl der Einträge in `history` mit diesem Namen
- `func clear_history() -> void`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren. Für Rückrufe im Test eine Mitgliedsvariable `var empfangen: Array = []` und eine Methode `func _merken(d: Dictionary) -> void: empfangen.append(d)` nutzen; in `setup()` zurücksetzen.

## Tests
`tests/test_event_bus.gd`:
- `test_abonnieren`: `subscribe("treffer", _merken)`, `publish("treffer", {"schaden": 5})` gibt 1 zurück, `empfangen[0]["schaden"]` 5
- `test_doppelt`: zweimal dasselbe abonnieren → `publish` gibt 1
- `test_abmelden`: abonnieren, `unsubscribe` wahr, nochmal falsch; `publish` gibt 0, `empfangen` leer
- `test_verlauf`: `publish("a")`, `publish("b")`, `publish("a")` → `count("a")` 2, `history.size()` 3; `clear_history()` → 0
- `test_verlauf_begrenzt`: `max_history = 3`, fünfmal `publish("x", {"i": i})` → `history.size()` 3, `history[0]["data"]["i"]` 2