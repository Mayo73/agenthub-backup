---
id: T-0412
title: Body2D – dynamischer Körper mit Schwerkraft, Impuls, Reibung und Rückprall am Boden
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Muss 5, Abnahmekriterium 6): Ein einfacher dynamischer 2D-Körper als prüfbare Kernlogik: fällt unter Schwerkraft, landet auf einem Boden, reagiert auf Impulse, wird durch Reibung gebremst und prallt ab.

## Dateien
- `core/body_2d.gd` – neu, Klasse `Body2D`
- `tests/test_body_2d.gd` – neu

## Akzeptanzkriterien
`class_name Body2D`, `extends RefCounted`. 1 Einheit = 1 Meter, Schwerkraft nach **+y**, der Boden ist `y = floor_y`, „über dem Boden“ heißt `y < floor_y`.
- `var position := Vector2.ZERO`, `var velocity := Vector2.ZERO`, `var mass := 1.0`, `var friction := 0.5`, `var bounce := 0.0`, `var on_floor := false`
- `const GRAVITY := 9.81`
- `func apply_impulse(impulse: Vector2) -> void`: `velocity += impulse / mass` (bei `mass <= 0` nichts tun)
- `func step(dt: float, floor_y: float, gravity: float = GRAVITY) -> void`:
  1. `velocity.y += gravity * dt`, dann `position += velocity * dt`
  2. ist `position.y >= floor_y`: `position.y = floor_y`; ist `velocity.y > 0`: `velocity.y = -velocity.y * bounce`, und ist danach `absf(velocity.y) < 0.05`, `velocity.y = 0.0`; `on_floor = true`. Sonst `on_floor = false`
  3. ist `on_floor`: `velocity.x` um `friction * gravity * dt` Richtung 0 verringern (nicht über 0 hinaus, `move_toward`)
- `func run(seconds: float, floor_y: float, hz: int = 120) -> void`: `roundi(seconds * hz)` Mal `step(1.0 / hz, floor_y)`

## Tests
`tests/test_body_2d.gd`:
- `test_faellt`: Körper bei `(0, 0)`, `run(0.5, 100.0)` → `position.y` ungefähr 1.226 (Toleranz 0.05), `on_floor` falsch
- `test_landet`: Körper bei `(0, 0)`, `run(3.0, 10.0)` → `position.y` 10.0, `on_floor` wahr, `velocity.y` 0.0
- `test_impuls`: `mass = 2.0`, `apply_impulse(Vector2(4, 0))` → `velocity.x` 2.0
- `test_reibung`: auf dem Boden (`position = Vector2(0, 10)`), `velocity = Vector2(3, 0)`, `friction = 0.5`, `run(2.0, 10.0)` → `velocity.x` 0.0; mit `friction = 0.0` bleibt `velocity.x` 3.0
- `test_rueckprall`: `bounce = 0.5`, Start `(0, 0)`, so lange `step(1.0 / 120, 10.0)`, bis `on_floor` wahr ist (höchstens 1000 Schritte) → danach `velocity.y < 0` (prallt nach oben ab); mit `bounce = 0.0` ist `velocity.y` dann 0.0

Review (19.10.2026): gemergt.
