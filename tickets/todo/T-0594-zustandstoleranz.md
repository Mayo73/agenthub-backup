---
id: T-0594
title: StateTolerance – Zustände mit Toleranz vergleichen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Abnahmekriterium 13: Wiederholungen erfüllen Zustandstoleranzen): Zwei Zustands-Dictionaries vergleichen und Abweichungen benennen, Zahlen und Vektoren mit Toleranz.

## Dateien
- `core/state_tolerance.gd` – neu, Klasse `StateTolerance`
- `tests/test_state_tolerance.gd` – neu

## Akzeptanzkriterien
`class_name StateTolerance`, `extends RefCounted`, nur statische Funktionen.
- `static func compare(expected: Dictionary, actual: Dictionary, tolerance: float) -> Array[String]`: Schlüssel von `expected` alphabetisch sortiert durchgehen:
  - fehlt in `actual` → `"fehlt: <schlüssel>"`
  - beide Werte Zahlen (`TYPE_INT` oder `TYPE_FLOAT`): Betrag der Differenz größer als `tolerance` → `"abweichung: <schlüssel>"`
  - beide `Vector2` oder beide `Vector3`: `distance_to` größer als `tolerance` → `"abweichung: <schlüssel>"`
  - sonst: ungleich (`!=`) → `"abweichung: <schlüssel>"`
  - Schlüssel, die nur in `actual` vorkommen, zählen nicht
- `static func within(expected: Dictionary, actual: Dictionary, tolerance: float) -> bool`: `compare(...)` ist leer

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren, Typprüfung mit `typeof(...)`.

## Tests
`tests/test_state_tolerance.gd`:
- `test_innerhalb`: `compare({"x": 1.0, "y": 2.0}, {"x": 1.05, "y": 2.0, "z": 9}, 0.1)` ist leer; `within(...)` mit denselben Werten wahr
- `test_abweichung`: dieselben Werte mit Toleranz 0.01 → `["abweichung: x"]`
- `test_fehlt`: `compare({"x": 1.0, "y": 2}, {"x": 1.0}, 0.1)` ist `["fehlt: y"]`
- `test_vektor`: `compare({"pos": Vector2(1, 1)}, {"pos": Vector2(1.0, 1.2)}, 0.1)` ist `["abweichung: pos"]`; mit Toleranz 0.5 leer; `compare({"p": Vector3(0, 1, 0)}, {"p": Vector3(0, 1.05, 0)}, 0.1)` leer
- `test_andere_typen`: `compare({"zustand": "laeuft"}, {"zustand": "pausiert"}, 1.0)` ist `["abweichung: zustand"]`; `compare({"n": 3}, {"n": 3.0}, 0.0)` ist leer
