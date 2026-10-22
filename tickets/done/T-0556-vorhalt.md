---
id: T-0556
title: LeadSolver – Vorhalt für ein bewegtes Ziel
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Zielhilfe): Für ein Ziel mit fester Geschwindigkeit den Treffpunkt berechnen, an dem ein geradeaus fliegendes Geschoss (ohne Schwerkraft) es erreicht.

## Dateien
- `core/lead_solver.gd` – neu, Klasse `LeadSolver`
- `tests/test_lead_solver.gd` – neu

## Akzeptanzkriterien
`class_name LeadSolver`, `extends RefCounted`, nur statische Funktionen. Alle lokalen Variablen mit Typ angeben (`var a: float = …`).
- `static func intercept_time(shooter: Vector3, target: Vector3, target_velocity: Vector3, speed: float) -> float`: kleinste Zeit `t > 0` mit `|target + target_velocity * t - shooter| == speed * t`. Rechnung: `r = target - shooter`, `a = target_velocity.dot(target_velocity) - speed * speed`, `b = 2.0 * r.dot(target_velocity)`, `c = r.dot(r)`. Ist `absf(a) < 0.000001`: `t = -c / b` (bei `b == 0` → `-1.0`). Sonst Diskriminante `b*b - 4*a*c`; negativ → `-1.0`; sonst beide Lösungen `(-b ± sqrt(D)) / (2a)` und die kleinste positive nehmen. Keine positive Lösung → `-1.0`. `speed <= 0` → `-1.0`
- `static func intercept_point(shooter: Vector3, target: Vector3, target_velocity: Vector3, speed: float) -> Vector3`: `target + target_velocity * t` mit `t` aus `intercept_time`; bei `t < 0` → `target` (ohne Vorhalt)
- `static func aim_direction(shooter: Vector3, target: Vector3, target_velocity: Vector3, speed: float) -> Vector3`: normierte Richtung von `shooter` zu `intercept_point(...)`; liegt der Punkt auf `shooter`, `Vector3.ZERO`

## Tests
`tests/test_lead_solver.gd` beginnt mit `extends "res://tests/base_test.gd"` (wie `tests/test_wind.gd`), Testfunktionen `func test_…() -> void`, Prüfungen mit `check(bedingung, "Text")` und `check_eq(ist, soll, "Text")`, kein `assert` und kein `print`.
- `test_ruhendes_ziel`: `intercept_time(Vector3.ZERO, Vector3(10, 0, 0), Vector3.ZERO, 5.0)` ist ungefähr `2.0` (Toleranz 0.001)
- `test_bewegtes_ziel`: Ziel `Vector3(10, 0, 0)` mit `Vector3(0, 0, 3)`, `speed = 5.0`: `t = intercept_time(...)` ist ungefähr `2.5`; `intercept_point(...)` ist ungefähr `Vector3(10, 0, 7.5)` (`distance_to` < 0.001)
- `test_zu_langsam`: Ziel `Vector3(10, 0, 0)` mit `Vector3(10, 0, 0)` und `speed = 5.0` → `intercept_time` ist `-1.0`, `intercept_point` ist `Vector3(10, 0, 0)`
- `test_richtung`: `aim_direction(Vector3.ZERO, Vector3(10, 0, 0), Vector3(0, 0, 3), 5.0)` hat Länge ungefähr 1 und `z > 0`

Review (21.10.2026): gemergt.
