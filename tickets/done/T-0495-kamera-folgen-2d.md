---
id: T-0495
title: FollowCamera2D – 2D-Kamera folgt der Spielfigur mit Grenzen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Muss 3: „Kamera in 2D“; 2D-Referenzspiel): Eine Kamera, die der Spielfigur weich folgt, eine Totzone in der Mitte hat und nicht über die Levelgrenzen hinaus zeigt.

## Dateien
- `core/follow_camera_2d.gd` – neu, Klasse `FollowCamera2D`
- `tests/test_follow_camera_2d.gd` – neu

## Akzeptanzkriterien
`class_name FollowCamera2D`, `extends RefCounted`.
- `var position := Vector2.ZERO` (Mitte des Bildes), `var view_size := Vector2(20, 11.25)` (sichtbarer Bereich in Einheiten), `var dead_zone := Vector2(2, 1.5)` (halbe Breite/Höhe der Totzone), `var smoothing := 8.0` (pro Sekunde, 0 = sofort), `var bounds := Rect2()` (leer = keine Grenzen)
- `func desired(target: Vector2) -> Vector2`: liegt `target` innerhalb der Totzone um `position`, bleibt die Achse unverändert; sonst wird die Achse so verschoben, dass `target` genau am Rand der Totzone liegt
- `func clamp_to_bounds(p: Vector2) -> Vector2`: bei leeren Grenzen unverändert; sonst so, dass das sichtbare Rechteck (Mitte `p`, Größe `view_size`) in `bounds` liegt; ist `bounds` kleiner als `view_size` in einer Achse, dort die Mitte von `bounds`
- `func update(target: Vector2, dt: float) -> Vector2`: Ziel = `clamp_to_bounds(desired(target))`; bei `smoothing <= 0` sofort dorthin, sonst `position = position.lerp(ziel, clampf(smoothing * dt, 0.0, 1.0))`; gibt `position` zurück
- `func visible_rect() -> Rect2`: Rechteck mit Mitte `position` und Größe `view_size`
- `func to_dict()` / `static func from_dict(d)`

## Tests
`tests/test_follow_camera_2d.gd` (Kamera mit `smoothing = 0.0`):
- `test_totzone`: `update(Vector2(1, 0.5), 0.1)` → `position` bleibt `Vector2.ZERO`
- `test_folgen`: `update(Vector2(5, 0), 0.1)` → `position.x` 3.0 (Ziel am Rand der Totzone)
- `test_grenzen`: `bounds = Rect2(0, 0, 100, 20)`, `update(Vector2(-50, 0), 0.1)` → `position.x` 10.0 (halbe Bildbreite)
- `test_kleines_level`: `bounds = Rect2(0, 0, 10, 5)` → `clamp_to_bounds(Vector2(40, 40))` ist `Vector2(5, 2.5)`
- `test_weich`: mit `smoothing = 5.0`, `update(Vector2(12, 0), 0.1)` → `position.x` ungefähr 5.0 (halber Weg zu 10)

Review (2026-10-21): gemergt, nachgebessert: Grenzen je Achse (bisher Level-Mitte in beiden Achsen, sobald eine zu klein war), to_dict speichert Vektoren JSON-fähig als [x, y] (2 neue Tests).
