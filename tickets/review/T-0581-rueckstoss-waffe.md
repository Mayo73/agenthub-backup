---
id: T-0581
title: Recoil – Waffenrückstoß in 3D
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Ballistik, 3D-Referenzspiel): Jeder Schuss hebt die Waffe an, danach kehrt sie gleichmäßig zurück.

## Dateien
- `core/recoil.gd` – neu, Klasse `Recoil`
- `tests/test_recoil.gd` – neu

## Akzeptanzkriterien
`class_name Recoil`, `extends RefCounted`.
- `var kick := 2.0` (Grad pro Schuss), `var recovery := 10.0` (Grad pro Sekunde), `var max_pitch := 10.0`, `var pitch := 0.0`
- `func _init(kick_deg: float = 2.0, recovery_deg: float = 10.0, max_deg: float = 10.0) -> void`
- `func fire() -> void`: `pitch = minf(pitch + kick, max_pitch)`
- `func step(dt: float) -> float`: `pitch = maxf(pitch - recovery * dt, 0.0)`, `pitch` zurückgeben
- `func reset() -> void`: `pitch = 0.0`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs.

## Tests
`tests/test_recoil.gd`, jeweils `Recoil.new()`:
- `test_schuesse`: dreimal `fire()` → `pitch` ist 6.0; danach `step(0.1)` ist 5.0
- `test_grenze`: zehnmal `fire()` → `pitch` ist 10.0
- `test_erholung`: nach `fire()` ist `step(2.0)` 0.0; nach `fire()` und `reset()` ist `pitch` 0.0
