---
id: T-0134
title: Spielerzelle zeichnet Farbe und Körperform (CellLook)
project: zellenphase
priority: 3
after: T-0116
---
## Ziel
Die Spielerzelle bekommt ein Aussehen (`CellLook`) und zeichnet ihren Körper mit dessen Umriss und Farbe statt als Kreis. So wirken Änderungen aus dem Zelleditor später auch im Spiel.

## Dateien
- `scripts/player_cell.gd`
- `tests/test_player_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/player_cell.gd`:
  - neue Variable direkt unter `var stage := 0`: `var look := CellLook.new()`
  - neue Funktion direkt unter `set_build`:
```gdscript
## Übernimmt ein neues Aussehen (Farbe, Muster, Streckung), z. B. nach dem Zelleditor.
func set_look(p_look: CellLook) -> void:
	look = p_look
	queue_redraw()
```
  - in `_draw()` die Zeile `draw_circle(Vector2.ZERO, radius, COLOR)` ersetzen durch `draw_colored_polygon(look.outline(radius), look.color)`
  - Sonst nichts an `player_cell.gd` ändern (die Konstante `COLOR` bleibt stehen).

## Tests
In `tests/test_player_cell.gd` anhängen:
- `test_aussehen_start`: `cell.look.color.is_equal_approx(CellLook.DEFAULT_COLOR)` wahr; `cell.look.pattern` ist `"keins"`
- `test_aussehen_setzen`: `var l := CellLook.new()`, `l.set_stretch(1.5)`, `cell.set_look(l)` → `cell.look == l` wahr; `cell.look.outline(cell.radius)[0].is_equal_approx(Vector2(18, 0))` wahr (Radius 12 mal Streckung 1,5)
- `test_aussehen_bleibt_beim_wachsen`: `var l := CellLook.new()`, `l.color = Color.RED`, `cell.set_look(l)`, `cell.set_stage(2)` → `cell.look.color.is_equal_approx(Color.RED)` wahr

Review (16.10.2026): gemergt.
