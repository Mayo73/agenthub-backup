---
id: T-0186
title: Spielerzelle und Editor zeichnen Teile mit PartLooks
project: zellenphase
priority: 3
after: T-0177, T-0185
---
## Ziel
Spielerzelle und Zelleditor zeichnen die Teile mit ihren eigenen Formen und Farben aus `PartLooks` statt mit den Platzhaltern aus `PartShapes`.

## Dateien
- `scripts/player_cell.gd`
- `scripts/cell_editor_canvas.gd`
- `tests/test_teile_aussehen.gd`: neu

## Akzeptanzkriterien
- `scripts/player_cell.gd`, in `_draw()`:
  - `PartShapes.color_of(part["id"])` überall durch `PartLooks.color(part["id"])` ersetzen
  - `PartShapes.placed(part, radius)` überall durch `PartLooks.placed(part, radius)` ersetzen
- `scripts/cell_editor_canvas.gd`, in `_draw()`:
  - `PartShapes.placed(part, SCALE)` durch `PartLooks.placed(part, SCALE)` ersetzen
  - `PartShapes.color_of(part["id"])` durch `PartLooks.color(part["id"])` ersetzen
- Danach kommt `PartShapes` in beiden Dateien nicht mehr vor. Sonst nichts ändern.

## Tests
`tests/test_teile_aussehen.gd` mit `extends "res://tests/base_test.gd"`:
- `test_spielerzelle`: `var src := FileAccess.get_file_as_string("res://scripts/player_cell.gd")` → `src.contains("PartShapes")` falsch; `src.contains("PartLooks.placed(part, radius)")` wahr
- `test_editor`: `var src := FileAccess.get_file_as_string("res://scripts/cell_editor_canvas.gd")` → `src.contains("PartShapes")` falsch; `src.contains("PartLooks.placed(part, SCALE)")` wahr

Review (17.10.2026): gemergt.
