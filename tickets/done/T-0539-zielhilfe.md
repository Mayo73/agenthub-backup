---
id: T-0539
title: AimSolver – Abschussrichtung für ein Ziel berechnen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Ballistik für Gegner und Zielhilfe): Bei fester Mündungsgeschwindigkeit die Richtung berechnen, mit der ein Geschoss unter Schwerkraft ein Ziel trifft (flache und steile Bahn). Prüfbar mit der vorhandenen `Ballistics`.

## Dateien
- `core/aim_solver.gd` – neu, Klasse `AimSolver`
- `tests/test_aim_solver.gd` – neu

## Akzeptanzkriterien
`class_name AimSolver`, `extends RefCounted`, nur statische Funktionen. Vorher `core/ballistics.gd` lesen (Konstante `GRAVITY`, `position_3d`).
- `static func angles(distance: float, height: float, speed: float, gravity: float = Ballistics.GRAVITY) -> Array[float]`: Abschusswinkel (Bogenmaß über der Waagerechten) nach `tan θ = (v² ± sqrt(v⁴ − g·(g·d² + 2·h·v²))) / (g·d)`. Ist der Ausdruck unter der Wurzel negativ → leere Liste (nicht erreichbar). Ergebnis aufsteigend sortiert (flache Bahn zuerst); ist die Wurzel 0, nur ein Winkel. `distance <= 0` → leere Liste
- `static func direction_3d(from: Vector3, to: Vector3, speed: float, high: bool = false, gravity: float = Ballistics.GRAVITY) -> Vector3`: waagerechte Entfernung `d` aus `x`/`z`, Höhe `h = to.y - from.y`; Winkel aus `angles` (flach = erster, `high` = letzter). Ergebnis ist der Geschwindigkeitsvektor mit Länge `speed`: normierte waagerechte Richtung zum Ziel · `cos θ` · `speed` plus `Vector3(0, sin θ · speed, 0)`. Nicht erreichbar → `Vector3.ZERO`
- `static func flight_time(distance: float, angle: float, speed: float) -> float`: `distance / (speed * cos(angle))`

## Tests
`tests/test_aim_solver.gd`:
- `test_zwei_bahnen`: `angles(20.0, 0.0, 20.0)` hat 2 Einträge, der erste kleiner als der zweite, und ihre Summe ist ungefähr `PI / 2` (Toleranz 0.001)
- `test_unerreichbar`: `angles(100.0, 0.0, 10.0)` ist leer; `direction_3d(Vector3.ZERO, Vector3(100, 0, 0), 10.0)` ist `Vector3.ZERO`
- `test_trifft`: `v = direction_3d(Vector3.ZERO, Vector3(12, 2, -9), 25.0)`; `v.length()` ungefähr 25.0; mit `t = flight_time(15.0, asin(v.y / 25.0), 25.0)` ist `Ballistics.position_3d(Vector3.ZERO, v, t).distance_to(Vector3(12, 2, -9))` kleiner als 0.01
- `test_steil`: `direction_3d(Vector3.ZERO, Vector3(12, 2, -9), 25.0, true).y` ist größer als das `y` der flachen Lösung

Review (21.10.2026): selbst umgesetzt. Der Agent scheiterte 5× (Tests ohne base_test.gd, falsches Vorzeichen unter der Wurzel); Claude hat AimSolver mit 4 Tests geschrieben.
