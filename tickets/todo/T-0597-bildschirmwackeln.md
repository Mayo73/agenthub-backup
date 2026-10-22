---
id: T-0597
title: ScreenShake2D – Bildschirmwackeln mit Abklingen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“: Kamerawackeln bei Treffern oder Explosionen, das von selbst abklingt und mit Seed wiederholbar ist (für Tests).

## Dateien
- `core/screen_shake_2d.gd` – neu, Klasse `ScreenShake2D`
- `tests/test_screen_shake_2d.gd` – neu

## Akzeptanzkriterien
`class_name ScreenShake2D`, `extends RefCounted`.
- `var trauma := 0.0` (0 bis 1), `var decay := 1.5` (Abbau pro Sekunde), `var max_offset := 8.0` (Pixel)
- `func _init(max_px: float = 8.0, decay_rate: float = 1.5) -> void`
- `func add(amount: float) -> void`: `trauma = clampf(trauma + amount, 0.0, 1.0)`
- `func step(dt: float) -> void`: `trauma = maxf(trauma - decay * dt, 0.0)`
- `func offset(seed_value: int) -> Vector2`: `var s: float = trauma * trauma`; `var rng := RandomNumberGenerator.new()`, `rng.seed = seed_value`; Ergebnis `Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * max_offset * s`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Vektoren mit `is_equal_approx` vergleichen. Kein `assert`, kein `print`. Einrückung nur mit Tabs.

## Tests
`tests/test_screen_shake_2d.gd`, jeweils `ScreenShake2D.new()`:
- `test_begrenzt`: `add(0.5)`, `add(0.8)` → `trauma` 1.0; `step(0.4)` → `trauma` etwa 0.4; `step(10.0)` → 0.0
- `test_ruhe`: ohne Trauma ist `offset(3)` gleich `Vector2.ZERO`
- `test_wiederholbar`: `add(1.0)`: `offset(3)` zweimal gleich; Beträge von x und y je höchstens 8.0
- `test_quadratisch`: `add(0.5)`: für die Seeds 1 bis 20 sind `absf(o.x)` und `absf(o.y)` jeweils höchstens 2.0001
