---
id: T-0590
title: Abnahmetest Kriterium 6 in 3D – Schwerkraft, Boden, Impuls, Reibung, Rückprall, Trigger, Gruppen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Abnahme“, Kriterium 6 (3D): wie in 2D, mit `Body3D` und `TriggerZone3D`. Nur ein neuer Test, keine Änderung am Kern.

## Dateien
- `tests/test_abnahme_physik_3d.gd` – neu

## Akzeptanzkriterien
Vorher `core/body_3d.gd`, `core/trigger_zone_3d.gd` und `core/collision_layers.gd` lesen. In 3D zeigt y nach oben, der Boden ist die Ebene `y = floor_y`, Schwerkraft 9.81 nach −y, 120 Schritte pro Sekunde.

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Vektoren mit `is_equal_approx` vergleichen. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren.

## Tests
`tests/test_abnahme_physik_3d.gd`:
- `test_fallen`: `Body3D.new()` mit `position = Vector3(0, 10, 0)`, `run(1.0, -100.0)` → `position.y` zwischen 4.9 und 5.2, `absf(velocity.y + 9.81) < 0.01`, `on_floor` falsch
- `test_boden`: Start `Vector3(0, 2, 0)`, `run(2.0, 0.0)` → `position.y` ist 0.0, `on_floor` wahr, `velocity.y` ist 0.0
- `test_impuls`: `mass = 4.0`, `apply_impulse(Vector3(8, 0, -4))` → `velocity` ist `Vector3(2, 0, -1)`
- `test_reibung`: Start `Vector3.ZERO`, `velocity = Vector3(3, 0, 4)`, `friction = 0.5`, `run(0.5, 0.0)` → `velocity.x` zwischen 0.45 und 0.65, `velocity.z` zwischen 1.45 und 1.65
- `test_rueckprall`: `bounce = 0.5`, Start `Vector3(0, 1, 0)`, Boden 0.0; Schleife über höchstens 240 Schritte: `var v_vorher: float = absf(b.velocity.y)`, dann `b.step(1.0 / 120.0, 0.0)`; beim ersten Schritt mit `b.on_floor`: `b.velocity.y > 0.0` und `b.velocity.y / v_vorher` zwischen 0.45 und 0.6, dann abbrechen; prüfen, dass es zum Bodenkontakt kam
- `test_trigger`: `TriggerZone3D.new("ziel", AABB(Vector3.ZERO, Vector3(4, 4, 4)))`; `update(1, {"k": Vector3(1, 1, 1)})` liefert 1 Ereignis mit `type` „entered“, `update(2, {"k": Vector3(9, 1, 1)})` liefert 1 Ereignis mit `type` „exited“
- `test_gruppen`: `CollisionLayers.collides(1, 2, 2, 1)` wahr, `CollisionLayers.collides(1, 1, 2, 2)` falsch
