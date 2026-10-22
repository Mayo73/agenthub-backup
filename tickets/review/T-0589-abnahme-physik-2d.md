---
id: T-0589
title: Abnahmetest Kriterium 6 in 2D – Schwerkraft, Boden, Impuls, Reibung, Rückprall, Trigger, Gruppen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Abnahme“, Kriterium 6 (2D): Körper fallen unter Schwerkraft, landen auf dem Boden und reagieren auf Impulse; Reibung, Rückprall, Trigger und Kollisionsgruppen sind geprüft. Nur ein neuer Test, keine Änderung am Kern.

## Dateien
- `tests/test_abnahme_physik_2d.gd` – neu

## Akzeptanzkriterien
Vorher `core/body_2d.gd`, `core/physics_world_2d.gd` und `core/trigger_zone.gd` lesen. In 2D wächst y nach unten, Schwerkraft 9.81, 120 Schritte pro Sekunde (`run(sekunden, floor_y)`).

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Vektoren mit `is_equal_approx` vergleichen. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren.

## Tests
`tests/test_abnahme_physik_2d.gd`:
- `test_fallen`: `Body2D.new()` (Start `Vector2.ZERO`), `run(1.0, 100.0)` → `position.y` zwischen 4.8 und 5.1, `absf(velocity.y - 9.81) < 0.01`, `on_floor` falsch
- `test_boden`: neuer Körper, `run(2.0, 1.0)` → `position.y` ist 1.0, `on_floor` wahr, `velocity.y` ist 0.0
- `test_impuls`: `mass = 2.0`, `apply_impulse(Vector2(4, -6))` → `velocity` ist `Vector2(2, -3)`; ein Körper mit `mass = 0.0` bleibt nach `apply_impulse(Vector2(4, 0))` bei `Vector2.ZERO`
- `test_reibung`: `position = Vector2(0, 1)`, `velocity = Vector2(5, 0)`, `friction = 0.5`, `run(0.5, 1.0)` → `velocity.x` zwischen 2.4 und 2.7; derselbe Aufbau mit `friction = 0.0` → `velocity.x` ist 5.0
- `test_rueckprall`: `bounce = 0.5`, Start `Vector2.ZERO`, Boden 1.0; Schleife über höchstens 240 Schritte: `var v_vorher: float = b.velocity.y`, dann `b.step(1.0 / 120.0, 1.0)`; beim ersten Schritt mit `b.on_floor` prüfen: `b.velocity.y < 0.0` und `absf(b.velocity.y) / v_vorher` zwischen 0.45 und 0.6, dann abbrechen. Zusätzlich prüfen, dass es überhaupt zum Bodenkontakt kam
- `test_trigger`: `var z := TriggerZone.new("ziel", Rect2(0, 0, 10, 10))`; `z.update(1, {"a": Vector2(5, 5)})` liefert 1 Ereignis mit `type` „entered“; `z.update(2, {"a": Vector2(20, 5)})` liefert 1 Ereignis mit `type` „exited“; danach `is_inside("a")` falsch
- `test_gruppen`: `PhysicsWorld2D.new()`, `add_static("wand", Rect2(-10, 5, 20, 2), 1, 1)`, Körper `a` mit `add_body("a", a, 1, 1)` und `b` mit `add_body("b", b, 2, 2)` (beide Start `Vector2.ZERO`), `run(2.0)` → in `world.contacts` gibt es mindestens einen Eintrag mit `body` „a“ und `static` „wand“ und keinen mit `body` „b“; `a.position.y < 5.0`, `b.position.y > 7.0`
