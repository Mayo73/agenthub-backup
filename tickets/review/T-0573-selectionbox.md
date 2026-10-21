---
id: T-0573
title: SelectionBox – Rechteckauswahl im Editor
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Editor, Auswahl): Mit einem aufgezogenen Rechteck mehrere Objekte auswählen.

## Dateien
- `core/selection_box.gd` – neu, Klasse `SelectionBox`
- `tests/test_selection_box.gd` – neu

## Akzeptanzkriterien
`class_name SelectionBox`, `extends RefCounted`, nur statische Funktionen.
- `static func pick(rects: Dictionary, area: Rect2, mode: String = "touch") -> Array`: `rects` ordnet Kennungen (String) einem `Rect2` zu. Zuerst `area = area.abs()` (Rechteck darf rückwärts aufgezogen sein).
  - `"touch"`: alle Kennungen, deren Rechteck `area` schneidet (`area.intersects(rect)`)
  - `"inside"`: nur die, deren Rechteck ganz in `area` liegt (`area.encloses(rect)`)
  - Ergebnis alphabetisch sortiert (`sort()`)

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren (`var x: float = …`).

## Tests
`tests/test_selection_box.gd` mit `{"a": Rect2(0, 0, 10, 10), "b": Rect2(20, 0, 10, 10), "c": Rect2(5, 5, 2, 2)}`:
- `test_beruehren`: `pick(rects, Rect2(4, 4, 22, 4))` ist `["a", "b", "c"]`
- `test_innen`: `pick(rects, Rect2(4, 4, 22, 4), "inside")` ist `["c"]`
- `test_rueckwaerts`: `pick(rects, Rect2(15, 15, -15, -15))` ist `["a", "c"]`
- `test_leer`: `pick(rects, Rect2(100, 100, 5, 5))` ist `[]`
