---
id: T-0538
title: CharacterMotor3D – Laufen und Springen in 3D
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (steuerbare Spielfigur im 3D-Referenzspiel): Bewegungslogik einer Figur am Boden: Eingabe relativ zur Blickrichtung, beschleunigen, bremsen, springen. Wie `PlatformerMotor` in 2D, aber mit −y als unten.

## Dateien
- `core/character_motor_3d.gd` – neu, Klasse `CharacterMotor3D`
- `tests/test_character_motor_3d.gd` – neu

## Akzeptanzkriterien
`class_name CharacterMotor3D`, `extends RefCounted`. Schwerkraft 9,81 nach −y.
- `var max_speed := 5.0`, `var accel := 25.0`, `var decel := 30.0`, `var jump_speed := 5.0`, `var gravity := 9.81`, `var velocity := Vector3.ZERO`, `var on_floor := false`
- `static func wish_direction(input: Vector2, yaw: float) -> Vector3`: `input.y` ist vorwärts, `input.x` rechts. „Vorne“ bei `yaw` ist `Vector3(sin(yaw), 0, -cos(yaw))`, „rechts“ ist `Vector3(cos(yaw), 0, sin(yaw))`. Ergebnis `vorne * input.y + rechts * input.x`, auf Länge höchstens 1 begrenzt (`limit_length(1.0)`)
- `func step(input: Vector2, yaw: float, jump: bool, dt: float, floor_now: bool) -> Vector3`:
  1. `on_floor = floor_now`
  2. waagerecht mit `var flat := Vector2(velocity.x, velocity.z)`: Ziel `Vector2(wish.x, wish.z) * max_speed`; bei Eingabe (`input != Vector2.ZERO`) `flat = flat.move_toward(ziel, accel * dt)`, sonst `flat = flat.move_toward(Vector2.ZERO, decel * dt)`; danach `velocity.x = flat.x`, `velocity.z = flat.y`
  3. am Boden und `jump` → `velocity.y = jump_speed`; sonst am Boden und `velocity.y < 0` → `velocity.y = 0`; nicht am Boden → `velocity.y -= gravity * dt`
  4. `velocity` zurückgeben
- `func horizontal_speed() -> float`: Länge von `Vector2(velocity.x, velocity.z)`

## Tests
`tests/test_character_motor_3d.gd`:
- `test_richtung`: `wish_direction(Vector2(0, 1), 0.0)` ungefähr `Vector3(0, 0, -1)`; `wish_direction(Vector2(1, 0), 0.0)` ungefähr `Vector3(1, 0, 0)`; `wish_direction(Vector2(1, 1), 0.0).length()` ungefähr 1.0
- `test_beschleunigen`: 1 s lang (120 Schritte mit `dt = 1.0 / 120.0`, `floor_now` true) mit `Vector2(0, 1)` → `horizontal_speed()` ungefähr 5.0 und `velocity.z` < 0
- `test_bremsen`: danach 60 Schritte ohne Eingabe → `horizontal_speed()` 0.0
- `test_sprung`: am Boden `step(Vector2.ZERO, 0.0, true, 1.0 / 120.0, true)` → `velocity.y` 5.0; danach Schritte in der Luft (`floor_now` false) zählen, bis `velocity.y` < 0 → Anzahl Schritte / 120 ungefähr 5.0 / 9.81 (Toleranz 0.02)

Review (21.10.2026): gemergt, nachgebessert: am Boden wirkte bei velocity.y = 0 trotzdem Schwerkraft; behoben, test_bremsen beschleunigt vorher, neuer Test test_am_boden_ruhig.
