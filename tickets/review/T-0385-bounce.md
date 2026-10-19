---
id: T-0385
title: Rückprall am Boden mit Energieverlust (2D und 3D)
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Ballistik und Testeingaben“ (Lastenheft Muss 6 „Rückprall“): Ein Körper fällt unter Schwerkraft, prallt am Boden mit einem Rückprallfaktor ab und verliert dabei Energie. Reine Logik, deterministisch bei 120 Hz.

## Dateien
- `core/bounce.gd` – neu, Klasse `Bounce`
- `tests/test_bounce.gd` – neu

## Akzeptanzkriterien
`class_name Bounce`, `extends RefCounted`, nur statische Funktionen. 1 Einheit = 1 Meter. **2D: Schwerkraft nach +y, Boden ist `y = floor_y`, oberhalb heißt `y < floor_y`. 3D: Schwerkraft nach −y, Boden ist `y = floor_y`, oberhalb heißt `y > floor_y`.**
- `const GRAVITY := 9.81`, `const HZ := 120`, `const REST_SPEED := 0.05` (darunter bleibt der Körper liegen)
- `static func simulate_2d(start: Vector2, velocity: Vector2, floor_y: float, restitution: float, duration: float, hz: int = HZ, gravity: float = GRAVITY) -> Dictionary`:
  - `steps = roundi(duration * hz)`, `dt = 1.0 / hz`; je Schritt `v.y += gravity * dt`, dann `p += v * dt`
  - Ist danach `p.y > floor_y` (unter dem Boden): `p.y = floor_y`, `v.y = -v.y * restitution`, `bounces += 1`; ist dann `absf(v.y) < REST_SPEED`, `v.y = 0.0`
  - Rückgabe `{"points": PackedVector2Array (steps + 1 Punkte ab start), "bounces": int, "velocity": Vector2 (am Ende)}`
- `static func simulate_3d(...)` mit `Vector3`, gleichen Parametern, Schwerkraft `v.y -= gravity * dt`, unter dem Boden heißt `p.y < floor_y`, Rückgabe mit `PackedVector3Array`
- `static func peak_heights_2d(points: PackedVector2Array, floor_y: float) -> Array[float]`: Höhen über dem Boden (`floor_y - y`) an jedem lokalen Hochpunkt der Bahn: Punkt `i` (0 < i < size−1) mit `y[i] < y[i-1]` und `y[i] <= y[i+1]`, nur Höhen über 0.01

## Tests
`tests/test_bounce.gd`:
- `test_punkte`: `simulate_2d(Vector2(0, -5), Vector2.ZERO, 0.0, 0.5, 2.0)["points"].size()` 241
- `test_bleibt_ueber_boden`: 2D, Start (0, −5), Geschwindigkeit (3, 0), Boden 0, Faktor 0.7, 4 s → alle Punkte `y <= 0.0001`, `bounces >= 2`
- `test_energieverlust`: 2D, Start (0, −5), ruhend, Boden 0, Faktor 0.5, 6 s → `peak_heights_2d` mindestens 2 Werte; zweiter Hochpunkt kleiner als der erste; Verhältnis `zweiter / erster` zwischen 0.2 und 0.3 (ideal 0.25 = Faktor²)
- `test_kein_rueckprall`: Faktor 0.0, Start (0, −2), 2 s → letzter Punkt `y` 0 (Toleranz 0.001), `velocity.y` 0
- `test_3d`: Start (0, 3, 0), Geschwindigkeit (1, 0, 2), Boden 0, Faktor 0.6, 3 s → alle Punkte `y >= -0.0001`, `bounces >= 1`, letzter Punkt `x` etwa 3 und `z` etwa 6 (Toleranz 0.05)
