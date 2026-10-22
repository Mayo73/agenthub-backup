---
id: T-0579
title: Parallax – Hintergrundebenen mit Tiefenwirkung
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Ebenen, Kamera): Hintergrundebenen bewegen sich langsamer als die Kamera und wiederholen sich nahtlos.

## Dateien
- `core/parallax.gd` – neu, Klasse `Parallax`
- `tests/test_parallax.gd` – neu

## Akzeptanzkriterien
`class_name Parallax`, `extends RefCounted`, nur statische Funktionen.
- `static func scroll(camera: Vector2, factor: Vector2) -> Vector2`: `Vector2(-camera.x * factor.x, -camera.y * factor.y)`
- `static func wrap(x: float, width: float) -> float`: `width <= 0` → `x`; sonst `fposmod(x, width)`
- `static func tiles_needed(view_width: float, tile_width: float) -> int`: `tile_width <= 0` → 0; sonst `ceili(view_width / tile_width) + 1`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr; Vektoren mit `is_equal_approx`). Einrückung nur mit Tabs.

## Tests
`tests/test_parallax.gd`:
- `test_scroll`: `scroll(Vector2(100, 50), Vector2(0.5, 0.0))` ist `Vector2(-50, 0)`; `scroll(Vector2(100, 50), Vector2(1, 1))` ist `Vector2(-100, -50)`
- `test_wrap`: `wrap(-30.0, 100.0)` ist 70.0; `wrap(250.0, 100.0)` ist 50.0; `wrap(5.0, 0.0)` ist 5.0
- `test_kacheln`: `tiles_needed(1280.0, 512.0)` ist 4; `tiles_needed(1024.0, 512.0)` ist 3; `tiles_needed(100.0, 0.0)` ist 0

Review (21.10.2026): gemergt, nachgebessert: ceili statt ceilf.
