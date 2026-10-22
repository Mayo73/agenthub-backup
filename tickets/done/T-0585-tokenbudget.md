---
id: T-0585
title: TokenBudget – KI-Kontext auf ein Budget kürzen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“: Der Kontext für lokale Modelle passt ins Budget; die Systemanweisung bleibt, ältere Einträge fallen zuerst weg.

## Dateien
- `core/token_budget.gd` – neu, Klasse `TokenBudget`
- `tests/test_token_budget.gd` – neu

## Akzeptanzkriterien
`class_name TokenBudget`, `extends RefCounted`, nur statische Funktionen.
- `static func estimate(text: String) -> int`: `ceili(text.length() / 4.0)`
- `static func trim(entries: Array, budget: int) -> Array`: Einträge sind Strings. Leere Liste → `[]`. Eintrag 0 (Systemanweisung) bleibt immer. Danach von hinten (neueste zuerst) Einträge dazunehmen, solange die Summe aller `estimate` höchstens `budget` bleibt; beim ersten, der nicht mehr passt, aufhören. Ergebnis in der ursprünglichen Reihenfolge.

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren.

## Tests
`tests/test_token_budget.gd`, Einträge `["SSSS", "aaaaaaaa", "bbbbbbbb", "cccccccc"]` (Schätzungen 1, 2, 2, 2):
- `test_schaetzen`: `estimate("")` ist 0; `estimate("abcde")` ist 2
- `test_kuerzen`: Budget 5 → `["SSSS", "bbbbbbbb", "cccccccc"]`; Budget 3 → `["SSSS", "cccccccc"]`
- `test_nur_system`: Budget 0 → `["SSSS"]`; `trim([], 10)` ist `[]`
- `test_alles`: Budget 100 → alle vier Einträge in der ursprünglichen Reihenfolge

Review (21.10.2026): gemergt.
