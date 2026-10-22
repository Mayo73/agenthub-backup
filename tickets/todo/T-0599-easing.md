---
id: T-0599
title: Easing – Übergangskurven für Animationen und Kamerafahrten
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“: Gängige Übergangskurven als reine Funktionen, damit Animationen, Kamerafahrten und Oberflächen weich ein- und auslaufen.

## Dateien
- `core/easing.gd` – neu, Klasse `Easing`
- `tests/test_easing.gd` – neu

## Akzeptanzkriterien
`class_name Easing`, `extends RefCounted`, nur statische Funktionen. Jede Kurve begrenzt `t` zuerst mit `clampf(t, 0.0, 1.0)`.
- `static func linear(t: float) -> float`: `t`
- `static func quad_in(t: float) -> float`: `t * t`
- `static func quad_out(t: float) -> float`: `1.0 - (1.0 - t) * (1.0 - t)`
- `static func quad_in_out(t: float) -> float`: `t < 0.5` → `2.0 * t * t`, sonst `1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0`
- `static func cubic_out(t: float) -> float`: `1.0 - pow(1.0 - t, 3.0)`
- `static func apply(curve: String, t: float) -> float`: `"linear"`, `"quad_in"`, `"quad_out"`, `"quad_in_out"`, `"cubic_out"`; unbekannt → `linear`
- `static func interpolate(a: float, b: float, t: float, curve: String = "linear") -> float`: `lerpf(a, b, apply(curve, t))`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Kein `assert`, kein `print`. Einrückung nur mit Tabs.

## Tests
`tests/test_easing.gd`:
- `test_kurven`: `quad_in(0.5)` 0.25, `quad_out(0.5)` 0.75, `cubic_out(0.5)` 0.875
- `test_in_out`: `quad_in_out(0.25)` 0.125, `quad_in_out(0.75)` 0.875, `quad_in_out(0.5)` 0.5
- `test_grenzen`: `quad_in(2.0)` 1.0, `linear(-1.0)` 0.0, `cubic_out(1.0)` 1.0
- `test_auswahl`: `apply("unbekannt", 0.3)` 0.3, `apply("quad_in", 0.5)` 0.25; `interpolate(10.0, 20.0, 0.5, "quad_in")` 12.5
