---
id: T-0425
title: Body3D – dynamischer 3D-Körper mit Schwerkraft, Impuls, Reibung und Rückprall
project: hub-engine
priority: 3
after: T-0412
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Muss 5, Abnahmekriterium 6 für 3D): Das Gegenstück zu `Body2D` in 3D: fällt nach −y, landet auf dem Boden, reagiert auf Impulse, Reibung und Rückprall.

## Dateien
- `core/body_3d.gd` – neu, Klasse `Body3D`
- `tests/test_body_3d.gd` – neu

## Akzeptanzkriterien
`class_name Body3D`, `extends RefCounted`. Aufbau wie `Body2D` (`core/body_2d.gd`, vorher lesen), aber 3D: Schwerkraft nach **−y**, Boden ist `y = floor_y`, „über dem Boden“ heißt `y > floor_y`.
- `var position := Vector3.ZERO`, `var velocity := Vector3.ZERO`, `var mass := 1.0`, `var friction := 0.5`, `var bounce := 0.0`, `var on_floor := false`, `const GRAVITY := 9.81`
- `func apply_impulse(impulse: Vector3) -> void`: `velocity += impulse / mass` (bei `mass <= 0` nichts)
- `func step(dt: float, floor_y: float, gravity: float = GRAVITY) -> void`:
  1. `velocity.y -= gravity * dt`, dann `position += velocity * dt`
  2. ist `position.y <= floor_y`: `position.y = floor_y`; ist `velocity.y < 0`: `velocity.y = -velocity.y * bounce`, und ist danach `absf(velocity.y) < 0.05`, `velocity.y = 0.0`; `on_floor = true`. Sonst `on_floor = false`
  3. ist `on_floor`: die waagerechte Geschwindigkeit `Vector2(velocity.x, velocity.z)` mit `move_toward(Vector2.ZERO, friction * gravity * dt)` verringern und zurückschreiben
- `func run(seconds: float, floor_y: float, hz: int = 120) -> void`

## Tests
`tests/test_body_3d.gd`:
- `test_faellt`: Start `(0, 10, 0)`, `run(0.5, -100.0)` → `position.y` ungefähr 8.77 (Toleranz 0.05)
- `test_landet`: Start `(0, 5, 0)`, `run(3.0, 0.0)` → `position.y` 0.0, `on_floor` wahr
- `test_impuls`: `mass = 4.0`, `apply_impulse(Vector3(0, 0, 8))` → `velocity.z` 2.0
- `test_reibung`: auf dem Boden, `velocity = Vector3(3, 0, 4)`, `run(2.0, 0.0)` → `velocity.x` und `velocity.z` 0.0
- `test_rueckprall`: `bounce = 0.5`, Start `(0, 2, 0)`, schrittweise bis `on_floor` (höchstens 1000 Schritte) → `velocity.y > 0`

Review (19.10.2026): gemergt.
