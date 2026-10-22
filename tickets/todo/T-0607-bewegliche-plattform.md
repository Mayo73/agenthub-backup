---
id: T-0607
title: MovingPlatform2D – Plattform pendelt zwischen zwei Punkten
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“: Eine Plattform fährt gleichmäßig zwischen zwei Punkten hin und her und meldet ihre Verschiebung je Schritt, damit Figuren darauf mitfahren können.

## Dateien
- `core/moving_platform_2d.gd` – neu, Klasse `MovingPlatform2D`
- `tests/test_moving_platform_2d.gd` – neu

## Akzeptanzkriterien
`class_name MovingPlatform2D`, `extends RefCounted`. Alle lokalen Variablen mit Typ.
- `var a := Vector2.ZERO`, `var b := Vector2.ZERO`, `var speed := 2.0` (Einheiten pro Sekunde), `var t := 0.0` (0 bei `a`, 1 bei `b`), `var forward := true`
- `func _init(p_a: Vector2 = Vector2.ZERO, p_b: Vector2 = Vector2.ZERO, units_per_second: float = 2.0) -> void`
- `func position() -> Vector2`: `a.lerp(b, t)`
- `func step(dt: float) -> Vector2`: `var length: float = a.distance_to(b)`; `length <= 0` → `Vector2.ZERO`. Alte Position merken; `t += speed * dt / length` (vorwärts) bzw. `-=` (rückwärts); bei `t >= 1.0`: `t = 1.0`, `forward = false`; bei `t <= 0.0`: `t = 0.0`, `forward = true`. Rückgabe: neue minus alte Position

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Vektoren mit `is_equal_approx` vergleichen. Kein `assert`, kein `print`. Einrückung nur mit Tabs.

## Tests
`tests/test_moving_platform_2d.gd`, jeweils `MovingPlatform2D.new(Vector2(0, 0), Vector2(10, 0), 5.0)`:
- `test_hin`: `step(1.0)` ist `Vector2(5, 0)`, `position()` `Vector2(5, 0)`; `step(1.0)` → `position()` `Vector2(10, 0)`, `forward` falsch
- `test_zurueck`: zweimal `step(1.0)`, dann `step(1.0)` ist `Vector2(-5, 0)` und `position()` `Vector2(5, 0)`
- `test_anschlag`: zweimal `step(1.0)`, dann `step(4.0)` → `position()` `Vector2(0, 0)`, `forward` wahr
- `test_ohne_strecke`: `MovingPlatform2D.new(Vector2(3, 3), Vector2(3, 3), 5.0).step(1.0)` ist `Vector2.ZERO`
