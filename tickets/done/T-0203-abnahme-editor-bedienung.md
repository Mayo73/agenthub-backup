---
id: T-0203
title: Abnahmetest – Teil platzieren, verschieben, drehen, entfernen; Vorschau und Kosten
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 9: Ein Test umfasst Platzieren, Verschieben, Drehen und Entfernen eines Teils sowie eine Änderung von Körperform und Farbe. Vorschau, Kosten und fertige Zelle müssen übereinstimmen. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_abnahme_editor_bedienung.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_abnahme_editor_bedienung.gd` anlegen. Keine Datei unter `scripts/` ändern.
- Kopf: `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, `main.progress.dna = 50`, `main.unlocks.unlock("geissel")`, `main.open_editor()`, `main.editor.canvas.symmetry = false`; `teardown()`: `main.free()`.
- Die Editor-Ansicht rechnet Bildschirmpunkte mit `CellEditorCanvas.CENTER` (960, 540) und `CellEditorCanvas.SCALE` (260) in Zellradien um: (752, 696) ist (-0,8; 0,6), (830, 670) ist (-0,5; 0,5), (752, 384) ist (-0,8; -0,6).
- Hilfsfunktion (nicht `test_` benennen) `func _place_one() -> void:` ruft `main.editor.panel.select("geissel")` und `main.editor.canvas.click(Vector2(752, 696))` auf.
- Hilfsfunktion `func _select(index: int) -> void:` setzt `main.editor.canvas.place_id = ""` und `main.editor.canvas.selected = index`.

## Tests
- `test_platzieren`: `_place_one()` → `main.editor.session.working.parts.size()` ist 3; `main.editor.canvas.selected` ist 2; `(main.editor.session.working.parts[2]["pos"] as Vector2).is_equal_approx(Vector2(-0.8, 0.6))` wahr
- `test_verschieben`: `_place_one()`, `_select(2)`, `main.editor.canvas.begin_drag()`, `main.editor.canvas.drag_to(Vector2(830, 670))`, `main.editor.canvas.end_drag()` → `(main.editor.session.working.parts[2]["pos"] as Vector2).is_equal_approx(Vector2(-0.5, 0.5))` wahr
- `test_drehen`: `_place_one()`, `_select(2)`, `var a0: float = main.editor.session.working.parts[2]["angle"]`, `main.editor.canvas.rotate_selected(EditorPlacement.ANGLE_STEP)` → `main.editor.session.working.parts[2]["angle"]` ist `EditorPlacement.snap_angle(a0 + EditorPlacement.ANGLE_STEP)`
- `test_entfernen`: `_place_one()`, dann `main.editor.panel.select("geissel")`, `main.editor.canvas.click(Vector2(752, 384))` → `main.editor.session.working.parts.size()` ist 4; `_select(3)`, `main.editor.canvas.remove_selected()` → `main.editor.session.working.parts.size()` ist 3
- `test_alles_zusammen`: in einem Test `_place_one()`; verschieben wie in `test_verschieben`; drehen wie in `test_drehen`; zweite Geißel bei (752, 384) einbauen und mit `_select(3)` und `remove_selected()` wieder entfernen; dann `main.editor.set_color(Color.RED)` und `main.editor.set_stretch(1.3)`. Prüfen:
  - `var cost: int = main.editor.session.cost()` → `cost` ist 15; `main.editor.panel.cost_label.text` ist `"Kosten: %d DNA" % cost`
  - `main.editor.panel.preview_label.text` ist `"\n".join(PackedStringArray(EditorPreview.lines(main.editor.session.original, main.editor.session.working, main.progress.stage)))`
  - `var erwartet: CellBuild = main.editor.session.working.copy()`, dann `main.editor.confirm()` → `main.progress.dna` ist 35; `main.player.build.parts.size()` ist 3; `(main.player.build.parts[2]["pos"] as Vector2).is_equal_approx(Vector2(-0.5, 0.5))` wahr; `main.player.build.parts[2]["angle"]` ist `erwartet.parts[2]["angle"]`; `main.player.motion.max_speed` ist `CellStats.max_speed(erwartet, main.progress.stage)`; `main.player.look.color.is_equal_approx(Color.RED)` wahr; `var l := CellLook.new()`, `l.set_stretch(1.3)`, `main.player.look.stretch` ist `l.stretch`

Review (17.10.2026): gemergt. Hinweis: Der Agent hat zusätzlich in scripts/main.gd `player.look.copy()` übergeben; harmlos (CellEditor.set_look kopiert ohnehin), deshalb belassen.
