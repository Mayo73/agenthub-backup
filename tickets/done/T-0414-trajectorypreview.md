---
id: T-0414
title: TrajectoryPreview – Flugbahn-Vorschau bis zum ersten Treffer
project: hub-engine
priority: 3
after: T-0381
---
## Ziel
Meilenstein „Ballistik“ (Muss 6: sichtbare Flugbahn-Vorschau): Punkte einer 2D-Flugbahn berechnen, die am ersten Hindernis endet, damit Editor und Agenten die Bahn anzeigen bzw. abfragen können.

## Dateien
- `core/trajectory_preview.gd` – neu, Klasse `TrajectoryPreview`
- `tests/test_trajectory_preview.gd` – neu

## Akzeptanzkriterien
`class_name TrajectoryPreview`, `extends RefCounted`, nur statische Funktionen. Nutzt `Ballistics.position_2d` (`core/ballistics.gd`) und `SweepHit.first_hit` (`core/sweep_hit.gd`), beide vorher lesen.
- `static func preview_2d(start: Vector2, velocity: Vector2, walls: Array[Rect2], duration: float, hz: int = 30, gravity: float = 9.81) -> Dictionary`:
  - Punkte zu den Zeiten `i / float(hz)` für `i = 0 … roundi(duration * hz)` über `Ballistics.position_2d`
  - zwischen zwei aufeinanderfolgenden Punkten `SweepHit.first_hit(p_vorher, p, walls)` prüfen; beim ersten Treffer dessen `position` als letzten Punkt anhängen und abbrechen
  - Rückgabe `{"points": PackedVector2Array, "hit": Dictionary}` (`hit` ist der Treffer mit `index`, `position`, `normal`, oder `{}`)
- `static func to_array(points: PackedVector2Array) -> Array`: `[[x, y], …]` für JSON-Ausgabe

## Tests
`tests/test_trajectory_preview.gd`:
- `test_ohne_wand`: `preview_2d(Vector2.ZERO, Vector2(10, 0), [], 1.0)` → 31 Punkte, `hit` leer
- `test_wand`: Wand `Rect2(5, -10, 1, 20)`, `preview_2d(Vector2.ZERO, Vector2(10, 0), walls, 2.0)` → `hit["index"]` 0, letzter Punkt hat `x` ungefähr 5.0 (Toleranz 0.01), weniger als 61 Punkte
- `test_schwerkraft`: ohne Wand, Geschwindigkeit `(0, 0)`, 1 s → letzter Punkt `y` ungefähr 4.905
- `test_array`: `to_array(PackedVector2Array([Vector2(1, 2)]))` ist `[[1.0, 2.0]]`

Review (19.10.2026): gemergt, nachgebessert: Hilfsdatei run_tests_simple.gd entfernt.
