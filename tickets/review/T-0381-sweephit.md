---
id: T-0381
title: SweepHit – Treffer schneller Projektile an dünnen Wänden ohne Durchtunneln
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Ballistik und Testeingaben“ (Lastenheft Muss 6, Abnahmekriterium 8): Statt nur Positionen zu prüfen, wird die Strecke zwischen zwei Simulationsschritten gegen Wände geprüft. So verfehlt ein schnelles Projektil keine dünne Wand.

## Dateien
- `core/sweep_hit.gd` – neu, Klasse `SweepHit`
- `tests/test_sweep_hit.gd` – neu

## Akzeptanzkriterien
`class_name SweepHit`, `extends RefCounted`, nur statische Funktionen:
- `static func segment_rect(from: Vector2, to: Vector2, rect: Rect2) -> Dictionary`: Strecke gegen achsenparalleles Rechteck (Slab-Verfahren). Kein Treffer → `{}`; sonst `{"t": float (0..1, erster Eintritt), "position": Vector2, "normal": Vector2}`. Die Normale zeigt aus der getroffenen Seite heraus, z. B. `Vector2(-1, 0)` für die linke Seite, `Vector2(0, -1)` für die obere. Startet die Strecke im Rechteck: `t` 0 und Normale `-(to - from).normalized()`.
- `static func first_hit(from: Vector2, to: Vector2, walls: Array[Rect2]) -> Dictionary`: der Treffer mit dem kleinsten `t` über alle Wände, zusätzlich `"index": int`; `{}` ohne Treffer
- `static func reflect(velocity: Vector2, normal: Vector2, restitution: float) -> Vector2`: `velocity.bounce(normal) * restitution`

## Tests
`tests/test_sweep_hit.gd`:
- `test_duenne_wand`: `segment_rect(Vector2(0, 0), Vector2(10, 0), Rect2(5, -5, 0.02, 10))` → `t` 0.5, `position.x` 5, `normal` `Vector2(-1, 0)`
- `test_vorbei`: Strecke (0, 10) → (10, 10) gegen dieselbe Wand → `{}` (leer)
- `test_oben`: Strecke (5, -10) → (5, 0) gegen `Rect2(0, -2, 10, 1)` → `normal` `Vector2(0, -1)`, `t` 0.8
- `test_erste_wand`: Wände `Rect2(6, -1, 0.1, 2)` und `Rect2(3, -1, 0.1, 2)`, Strecke (0, 0) → (10, 0) → `index` 1, `position.x` 3
- `test_hundert_versuche`: 100 Versuche; Versuch `i` mit Tempo `50.0 + i * 4.5`, Wandstärke `0.01 + (i % 5) * 0.01`, Winkel `deg_to_rad(-60.0 + (i % 13) * 10.0)`, `v = Vector2(cos(w), sin(w)) * tempo`. Start (0, 0), Wand `Rect2(20, -50, stärke, 100)`. Mit `dt = 1.0 / 120.0` bis zu 120 Schritte fliegen (ohne Schwerkraft), je Schritt `segment_rect(p, p + v * dt, wand)`; beim ersten Treffer `treffer += 1` und abbrechen, sonst `p += v * dt`. Erwartung `treffer` 100
- `test_rueckprall`: `reflect(Vector2(10, 0), Vector2(-1, 0), 0.5)` → `Vector2(-5, 0)`
