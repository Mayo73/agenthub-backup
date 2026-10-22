---
id: T-0567
title: Abnahmetest Kriterium 7 – Flugbahn gegen die analytische Bahn (2D und 3D)
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Abnahme“, Kriterium 7: Ohne Luftwiderstand weicht die simulierte Bahn eines Projektils höchstens 0,15 Einheiten von der analytischen Bahn `p(t) = p0 + v0·t + ½·g·t²` ab, über 2 Sekunden bei 120 Schritten pro Sekunde. Nur ein neuer Test, keine Änderung am Kern.

## Dateien
- `tests/test_abnahme_flugbahn.gd` – neu

## Akzeptanzkriterien
Vorher `core/projectile_2d.gd` und `core/projectile_3d.gd` lesen. Festgeschrieben: 1 Einheit = 1 Meter, Schwerkraft 9.81 (2D nach +y, 3D nach −y), keine Wände (`var walls: Array[Rect2] = []`, `var boxes: Array[AABB] = []`), `lifetime = 10.0`, `dt = 1.0 / 120.0`, 240 Schritte mit `step(dt, walls)` bzw. `step(dt, boxes)`. Nach jedem Schritt `k` (1 bis 240, `t = k * dt`) den Abstand von `position` zur analytischen Position messen und den größten merken.

Hinweis Typen: Test erbt von `res://tests/base_test.gd` und nutzt `check`/`check_eq`. Lokale Variablen mit Typ (`var worst: float = 0.0`). Einrückung nur mit Tabs.

## Tests
`tests/test_abnahme_flugbahn.gd`:
- `test_bahn_2d`: `Projectile2D`, Start `Vector2.ZERO`, `velocity = Vector2(20, -15)`; analytisch `Vector2(20 * t, -15 * t + 0.5 * 9.81 * t * t)`; größte Abweichung `<= 0.15` (`check` mit der Abweichung in der Meldung, z. B. `"Abweichung %.4f" % worst`)
- `test_bahn_3d`: `Projectile3D`, Start `Vector3(0, 1, 0)`, `velocity = Vector3(10, 12, -5)`; analytisch `Vector3(10 * t, 1 + 12 * t - 0.5 * 9.81 * t * t, -5 * t)`; größte Abweichung `<= 0.15`
- `test_noch_aktiv`: nach den 240 Schritten ist `alive` in beiden Fällen `true` (es wurde wirklich 2 Sekunden lang gemessen)

Review (21.10.2026): gemergt.
