---
id: T-0578
title: Knockback2D – Zurückstoßen bei Treffern
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Spielverhalten, Projektile): Getroffene Figuren werden vom Treffpunkt weggestoßen, der Stoß klingt gleichmäßig ab.

## Dateien
- `core/knockback_2d.gd` – neu, Klasse `Knockback2D`
- `tests/test_knockback_2d.gd` – neu

## Akzeptanzkriterien
`class_name Knockback2D`, `extends RefCounted`.
- `var velocity := Vector2.ZERO`, `var decay := 8.0` (Abbau in Einheiten pro Sekunde²)
- `func _init(decay_rate: float = 8.0) -> void`: `decay = decay_rate`
- `func hit(source: Vector2, target: Vector2, strength: float) -> void`: Richtung `(target - source).normalized()`; ist sie `Vector2.ZERO` (gleiche Position), `Vector2(0, -1)` nehmen; `velocity += richtung * strength`
- `func step(dt: float) -> Vector2`: zuerst `var offset: Vector2 = velocity * dt`, dann `velocity = velocity.move_toward(Vector2.ZERO, decay * dt)`, `offset` zurückgeben
- `func active() -> bool`: `velocity.length() > 0.001`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Vektoren mit `is_equal_approx` vergleichen (`check(a.is_equal_approx(b), "…")`). Einrückung nur mit Tabs.

## Tests
`tests/test_knockback_2d.gd`, jeweils `Knockback2D.new(10.0)`:
- `test_richtung`: `hit(Vector2(0, 0), Vector2(3, 4), 10.0)` → `velocity` ist `Vector2(6, 8)`
- `test_abklingen`: nach diesem Treffer ist `step(0.5)` `Vector2(3, 4)` und `velocity` danach `Vector2(3, 4)`; `step(1.0)` ist `Vector2(3, 4)`, danach ist `active()` falsch
- `test_gleiche_position`: `hit(Vector2(1, 1), Vector2(1, 1), 5.0)` → `velocity` ist `Vector2(0, -5)`
