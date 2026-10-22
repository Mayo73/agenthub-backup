---
id: T-0602
title: Explosion3D – Impulse einer Explosion auf Körper verteilen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“: Eine Explosion stößt Körper in ihrem Radius nach außen, nahe Körper stärker als ferne.

## Dateien
- `core/explosion_3d.gd` – neu, Klasse `Explosion3D`
- `tests/test_explosion_3d.gd` – neu

## Akzeptanzkriterien
`class_name Explosion3D`, `extends RefCounted`, nur statische Funktionen. Vorher `core/body_3d.gd` lesen. Alle lokalen Variablen mit Typ.
- `static func impulses(center: Vector3, radius: float, strength: float, positions: Dictionary) -> Dictionary`: `positions` ordnet Kennungen (String) einem `Vector3` zu. `radius <= 0` → `{}`. Für jede Position: `var d: float = center.distance_to(p)`; ist `d >= radius`, kommt sie nicht ins Ergebnis. Richtung `(p - center).normalized()`, bei `d < 0.0001` stattdessen `Vector3.UP`. Impuls `richtung * strength * (1.0 - d / radius)`. Ergebnis: Kennung → Impuls
- `static func apply(bodies: Dictionary, center: Vector3, radius: float, strength: float) -> int`: `bodies` ordnet Kennungen einem `Body3D` zu; Positionen aus `body.position` sammeln, `impulses(...)` berechnen, für jeden Treffer `apply_impulse` aufrufen; Rückgabe: Anzahl getroffener Körper

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Vektoren mit `is_equal_approx` vergleichen. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Werte aus Dictionaries mit Typ lesen (`var p: Vector3 = positions[id]`).

## Tests
`tests/test_explosion_3d.gd`:
- `test_verteilung`: `impulses(Vector3.ZERO, 10.0, 100.0, {"a": Vector3(5, 0, 0), "b": Vector3(0, 0, 20), "c": Vector3.ZERO})` → `a` ist `Vector3(50, 0, 0)`, `b` fehlt, `c` ist `Vector3(0, 100, 0)`
- `test_ohne_radius`: `impulses(Vector3.ZERO, 0.0, 100.0, {"a": Vector3(1, 0, 0)})` ist leer
- `test_anwenden`: `Body3D` mit `mass = 2.0` bei `Vector3(0, 0, 4)` und einer bei `Vector3(0, 0, 50)`; `apply({"nah": nah, "fern": fern}, Vector3.ZERO, 8.0, 40.0)` ist 1; `nah.velocity` ist `Vector3(0, 0, 10)`, `fern.velocity` ist `Vector3.ZERO`
