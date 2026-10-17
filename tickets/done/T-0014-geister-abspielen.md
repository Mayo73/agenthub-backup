---
id: T-0014
title: Geisterauto – Aufnahme abspielen (GhostLap)
project: drift
priority: 3
after: T-0013
---
## Ziel
`GhostLap` (aus T-0013) soll für jeden Zeitpunkt der Runde sagen, wo das Geisterauto ist. Zwischen zwei Proben wird linear übergeblendet, damit das Geisterauto flüssig fährt.

## Dateien
- `scripts/ghost_lap.gd`: zwei neue Funktionen (Rest nicht ändern)
- `tests/test_ghost_lap.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `func position_at(time: float) -> Vector2`:
  - leer → `Vector2.ZERO`
  - `time <= times[0]` → `positions[0]`; `time >= duration()` → letzte Position
  - sonst die Probe `i` suchen mit `times[i] <= time < times[i + 1]` (einfache Schleife genügt) und `positions[i].lerp(positions[i + 1], (time - times[i]) / (times[i + 1] - times[i]))` zurückgeben
- `func heading_at(time: float) -> float`: genauso, aber mit `headings` und `lerp_angle(headings[i], headings[i + 1], t)`; leer → `0.0`

## Tests
In `tests/test_ghost_lap.gd` anhängen. In jedem neuen Test zuerst dieselbe Aufnahme: `ghost.record(0.0, Vector2(0, 0), 0.0)`, `ghost.record(0.1, Vector2(10, 0), 0.0)`, `ghost.record(0.2, Vector2(10, 20), 1.0)`.
- `test_position_leer`: auf einem frischen `GhostLap.new()` ist `position_at(1.0)` `Vector2.ZERO` und `heading_at(1.0)` 0.0
- `test_position_auf_probe`: `position_at(0.1)` ist `Vector2(10, 0)`
- `test_position_dazwischen`: `position_at(0.05)` ist ungefähr `Vector2(5, 0)` und `position_at(0.15)` ungefähr `Vector2(10, 10)`, jeweils geprüft mit `check(ghost.position_at(…).distance_to(…) < 0.01, …)`
- `test_position_vor_und_nach`: `position_at(-1.0)` ist `Vector2(0, 0)`, `position_at(5.0)` ist `Vector2(10, 20)`
- `test_richtung_dazwischen`: `check(absf(ghost.heading_at(0.15) - 0.5) < 0.001, …)`

Review (16.10.2026): gemergt.
