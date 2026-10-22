---
id: T-0574
title: NameUniquifier – eindeutige Objektnamen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Szenen, Duplizieren): Beim Einfügen oder Duplizieren bekommt ein Objekt einen freien Namen („Gegner“, „Gegner2“, „Gegner3“ …).

## Dateien
- `core/name_uniquifier.gd` – neu, Klasse `NameUniquifier`
- `tests/test_name_uniquifier.gd` – neu

## Akzeptanzkriterien
`class_name NameUniquifier`, `extends RefCounted`, nur statische Funktionen.
- `static func base_name(name: String) -> String`: Ziffern am Ende entfernen („Gegner12“ → „Gegner“); bleibt nichts übrig → `"Knoten"`
- `static func unique(name: String, taken: Array) -> String`: leerer Name → `"Knoten"`. Ist der Name nicht in `taken`, ihn zurückgeben. Sonst `base_name(name)` mit angehängter Zahl ab 2 hochzählen (`basis + str(n)`), bis der Name frei ist.

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren (`var x: float = …`).

## Tests
`tests/test_name_uniquifier.gd`:
- `test_frei`: `unique("Gegner", [])` ist `"Gegner"`
- `test_hochzaehlen`: `unique("Gegner", ["Gegner"])` ist `"Gegner2"`; `unique("Gegner", ["Gegner", "Gegner2"])` ist `"Gegner3"`; `unique("Gegner2", ["Gegner2"])` ist `"Gegner3"`
- `test_basis`: `base_name("Kiste07")` ist `"Kiste"`; `base_name("42")` ist `"Knoten"`
- `test_leer`: `unique("", ["Knoten"])` ist `"Knoten2"`

Review (21.10.2026): gemergt.
