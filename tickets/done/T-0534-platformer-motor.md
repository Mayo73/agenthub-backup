---
id: T-0534
title: PlatformerMotor – Laufen und Springen mit Nachsprungzeit
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Lastenheft: steuerbare Spielfigur): Die Bewegungslogik einer Jump-and-Run-Figur: beschleunigen, bremsen, springen, mit kurzer Nachsprungzeit nach dem Verlassen einer Kante und gemerktem Sprungknopf kurz vor der Landung.

## Dateien
- `core/platformer_motor.gd` – neu, Klasse `PlatformerMotor`
- `tests/test_platformer_motor.gd` – neu

## Akzeptanzkriterien
`class_name PlatformerMotor`, `extends RefCounted`. Achsen wie im Projekt: +y ist unten, Schwerkraft 9,81.
- `var max_speed := 5.0`, `var accel := 30.0`, `var decel := 40.0`, `var jump_speed := 6.0`, `var coyote_time := 0.1`, `var buffer_time := 0.1`, `var gravity := 9.81`
- `var velocity := Vector2.ZERO`, `var on_floor := false`, `var _since_floor := 999.0`, `var _since_jump := 999.0`
- `func press_jump() -> void`: `_since_jump = 0.0`
- `func step(dir: float, dt: float, floor_now: bool) -> Vector2`, in dieser Reihenfolge:
  1. `on_floor = floor_now`; am Boden `_since_floor = 0.0`, sonst `_since_floor += dt`
  2. waagerecht: bei `dir != 0` `velocity.x = move_toward(velocity.x, clampf(dir, -1, 1) * max_speed, accel * dt)`, sonst `move_toward(velocity.x, 0, decel * dt)`
  3. Sprung, wenn `_since_jump <= buffer_time` und `_since_floor <= coyote_time`: `velocity.y = -jump_speed`, `_since_jump = 999.0`, `_since_floor = 999.0`
  4. sonst: am Boden und `velocity.y > 0` → `velocity.y = 0`; nicht am Boden → `velocity.y += gravity * dt`
  5. erst jetzt `_since_jump += dt`, dann `velocity` zurückgeben

## Tests
`tests/test_platformer_motor.gd` (jeweils neuer Motor, `dt` = 1.0 / 120):
- `test_beschleunigen`: 120 Schritte `step(1, dt, true)` → `velocity.x` ungefähr 5.0; danach 120 Schritte `step(0, dt, true)` → ungefähr 0
- `test_springen`: `press_jump()`, `step(0, dt, true)` → `velocity.y` ungefähr −6
- `test_nachsprung`: ein Schritt `step(0, dt, true)`, dann 6 Schritte `step(0, dt, false)`, dann `press_jump()` und `step(0, dt, false)` → `velocity.y` ungefähr −6. Neuer Motor mit 24 Schritten in der Luft statt 6 → kein Sprung (`velocity.y > 0`)
- `test_gemerkt`: in der Luft `press_jump()`, 6 Schritte `step(0, dt, false)`, dann `step(0, dt, true)` → `velocity.y` ungefähr −6
- `test_schwerkraft`: 120 Schritte `step(0, dt, false)` → `velocity.y` ungefähr 9.81

Review (21.10.2026): gemergt.
