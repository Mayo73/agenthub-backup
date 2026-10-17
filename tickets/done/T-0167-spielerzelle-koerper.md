---
id: T-0167
title: Spielerzelle mit lebendigem Körper zeichnen
project: zellenphase
priority: 2
after: T-0166
---
## Ziel
Die Spielerzelle zeichnet ihren Körper mit `CellPainter` (Textur, Muster, wogende Membran) statt als einfarbiges Polygon. Dafür zählt sie die Zeit mit.

## Dateien
- `scripts/player_cell.gd`
- `tests/test_player_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/player_cell.gd`:
- Neue Variable direkt unter `var look := CellLook.new()`: `var time := 0.0` mit dem Kommentar `## Laufzeit für Animationen in Sekunden.` in der Zeile darüber
- In `drive(delta, wish)` als erste Zeile: `time += delta`
- In `_draw()` die Zeile `draw_colored_polygon(look.outline(radius), look.color)` ersetzen durch `CellPainter.draw_cell(self, Vector2.ZERO, look, radius, time)`
- Sonst nichts ändern.

## Tests
In `tests/test_player_cell.gd` anhängen:
- `test_zeit_laeuft`: `cell.drive(0.5, Vector2.ZERO)`, `cell.drive(0.25, Vector2.ZERO)` → `cell.time` ist 0.75
- `test_zeit_startet_bei_null`: `cell.time` ist 0.0

Review (16.10.2026): gemergt.
