---
id: T-0549
title: ShapeOverlap2D – Überlappung von Kreisen und Rechtecken
project: hub-engine
priority: 4
---
## Ziel
Muss 5 „passende Kollisionsformen“: einfache Überlappungsprüfungen mit Eindringtiefe für Kreise und Rechtecke, z. B. für Trigger, Treffer und Tests ohne Szenenbaum.

## Dateien
- `core/shape_overlap_2d.gd` – neu, Klasse `ShapeOverlap2D`
- `tests/test_shape_overlap_2d.gd` – neu

## Akzeptanzkriterien
`class_name ShapeOverlap2D`, `extends RefCounted`, nur statische Funktionen.
- `static func circles(c1: Vector2, r1: float, c2: Vector2, r2: float) -> float`: Eindringtiefe `r1 + r2 - c1.distance_to(c2)`, wenn größer 0, sonst 0.0 (Berühren zählt nicht)
- `static func rects(a: Rect2, b: Rect2) -> Vector2`: kleinste Verschiebung, die `a` aus `b` herausschiebt. `ox = minf(a.end.x, b.end.x) - maxf(a.position.x, b.position.x)`, `oy` genauso mit y; ist `ox <= 0` oder `oy <= 0` → `Vector2.ZERO`. Sonst entlang der kleineren Überlappung (bei Gleichheit x), Richtung weg von `b`: für x `Vector2(-ox, 0)`, wenn `a.get_center().x < b.get_center().x`, sonst `Vector2(ox, 0)`; für y entsprechend `Vector2(0, ±oy)`
- `static func circle_rect(c: Vector2, r: float, rect: Rect2) -> float`: nächster Punkt `c.clamp(rect.position, rect.end)`, Eindringtiefe `r - c.distance_to(naechster)`, wenn größer 0, sonst 0.0
- `static func point_in_circle(p: Vector2, c: Vector2, r: float) -> bool`: Abstand ≤ `r`

## Tests
`tests/test_shape_overlap_2d.gd`:
- `test_kreise`: `circles(Vector2(0, 0), 1.0, Vector2(1.5, 0), 1.0)` ungefähr 0.5; `circles(Vector2(0, 0), 1.0, Vector2(3, 0), 1.0)` 0.0
- `test_rechtecke`: `rects(Rect2(0, 0, 2, 2), Rect2(1.5, 0, 2, 2))` ist `Vector2(-0.5, 0)`; `rects(Rect2(0, 0, 1, 1), Rect2(5, 5, 1, 1))` ist `Vector2.ZERO`
- `test_rechtecke_y`: `rects(Rect2(0, 1.8, 2, 2), Rect2(0, 0, 2, 2))` ist ungefähr `Vector2(0, 0.2)`
- `test_kreis_rechteck`: `circle_rect(Vector2(3, 1), 1.5, Rect2(0, 0, 2, 2))` ungefähr 0.5; `circle_rect(Vector2(5, 5), 1.0, Rect2(0, 0, 2, 2))` 0.0
- `test_punkt`: `point_in_circle(Vector2(1, 0), Vector2.ZERO, 1.0)` wahr, `point_in_circle(Vector2(1.1, 0), Vector2.ZERO, 1.0)` falsch

Review (21.10.2026): gemergt, nachgebessert: rects() schiebt bei gleicher Überlappung immer entlang x (vorher nur, wenn a links von b lag).
