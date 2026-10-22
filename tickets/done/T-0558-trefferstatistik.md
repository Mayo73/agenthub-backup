---
id: T-0558
title: HitStats – Schüsse, Treffer und Genauigkeit zählen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Auswertung für Referenzspiel und Abnahmetests): Schüsse und Treffer je Waffe zählen, Genauigkeit berechnen und speichern.

## Dateien
- `core/hit_stats.gd` – neu, Klasse `HitStats`
- `tests/test_hit_stats.gd` – neu

## Akzeptanzkriterien
`class_name HitStats`, `extends RefCounted`. Intern `var _shots: Dictionary = {}` und `var _hits: Dictionary = {}` (Schlüssel: Waffenname als `String`, Wert `int`). Alle lokalen Variablen mit Typ angeben.
- `func shot(weapon: String) -> void`, `func hit(weapon: String) -> void` (zählt jeweils um 1 hoch; ein Treffer zählt nicht als Schuss)
- `func shots(weapon: String = "") -> int`, `func hits(weapon: String = "") -> int`: leerer Name = Summe über alle Waffen
- `func accuracy(weapon: String = "") -> float`: `hits / shots`, bei 0 Schüssen `0.0`
- `func weapons() -> Array[String]`: alle Waffen mit mindestens einem Schuss oder Treffer, alphabetisch sortiert
- `func reset() -> void`
- `func to_dict() -> Dictionary` → `{"shots": {...}, "hits": {...}}` (Kopien) und `static func from_dict(data: Dictionary) -> HitStats` (Zahlen mit `int(...)` übernehmen, fehlende Schlüssel = leer)

## Tests
`tests/test_hit_stats.gd` beginnt mit `extends "res://tests/base_test.gd"` (wie `tests/test_wind.gd`), Testfunktionen `func test_…() -> void`, Prüfungen mit `check(...)` und `check_eq(...)`, kein `assert` und kein `print`.
- `test_zaehlen`: 4× `shot("gewehr")`, 3× `hit("gewehr")`, 2× `shot("bogen")` → `shots()` ist 6, `hits()` ist 3, `accuracy("gewehr")` ist 0.75, `accuracy()` ist 0.5
- `test_leer`: neue Statistik: `accuracy()` ist 0.0, `weapons()` ist leer
- `test_waffen`: nach `shot("zange")` und `shot("axt")` ist `weapons()` gleich `["axt", "zange"]`
- `test_speichern`: Werte aus `test_zaehlen`, `HitStats.from_dict(s.to_dict())` liefert dieselben `shots()`, `hits()` und `accuracy("gewehr")`; nach `reset()` ist `shots()` 0

Review (21.10.2026): gemergt.
