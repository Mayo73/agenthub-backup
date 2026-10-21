---
id: T-0499
title: Spring2D – Feder zwischen zwei 2D-Körpern
project: hub-engine
priority: 4
---
## Ziel
Lastenheft „Soll“: „Gelenke und verbundene Körper, einfache Seil-/Federbeispiele“. Eine Feder verbindet zwei `Body2D` und zieht sie auf ihre Ruhelänge, mit Dämpfung.

## Dateien
- `core/spring_2d.gd` – neu, Klasse `Spring2D`
- `tests/test_spring_2d.gd` – neu

## Akzeptanzkriterien
`class_name Spring2D`, `extends RefCounted`. Vorher `core/body_2d.gd` lesen (`position`, `velocity`, `mass`, `apply_impulse`).
- `var a: Body2D`, `var b: Body2D` (`b` darf `null` sein, dann ist `anchor` der feste Punkt), `var anchor := Vector2.ZERO`, `var rest_length := 1.0`, `var stiffness := 50.0`, `var damping := 2.0`
- `func _init(body_a: Body2D, body_b: Body2D = null, length: float = 1.0) -> void`
- `func other_point() -> Vector2`: `b.position` oder `anchor`
- `func force_on_a() -> Vector2`: `d = other_point() - a.position`; ist `d` (fast) null → `Vector2.ZERO`; sonst Federkraft `stiffness * (d.length() - rest_length) * d.normalized()` minus Dämpfung `damping * (a.velocity - (b.velocity wenn b sonst Vector2.ZERO))` entlang der Richtung (nur der Anteil in Richtung `d.normalized()`)
- `func apply(dt: float) -> void`: `a.apply_impulse(force_on_a() * dt)`, bei `b` zusätzlich `b.apply_impulse(-force_on_a() * dt)` (dieselbe Kraft vor dem Anwenden berechnen)
- `func length() -> float`: aktueller Abstand

## Tests
`tests/test_spring_2d.gd`:
- `test_ruhe`: `a` bei `(0, 0)`, `b` bei `(1, 0)`, Ruhelänge 1 → `force_on_a()` ist `Vector2.ZERO`
- `test_zieht`: `b` bei `(3, 0)` → `force_on_a().x` > 0, `y` 0
- `test_drueckt`: `b` bei `(0.5, 0)` → `force_on_a().x` < 0
- `test_pendelt_ein`: `a` frei bei `(0, 2)`, fester Punkt `(0, 0)`, Ruhelänge 1, 10 s lang je Schritt 1/120 s `spring.apply(dt)` und Position `a.position += a.velocity * dt` (ohne Schwerkraft) → `length()` ungefähr 1.0 (Toleranz 0.05)
- `test_impuls_beidseitig`: zwei gleich schwere Körper bei `(0, 0)` und `(3, 0)`, ein `apply(0.1)` → `a.velocity.x` > 0, `b.velocity.x` < 0, Beträge ungefähr gleich

Review (21.10.2026): gemergt.
