---
id: T-0175
title: Zelleditor mit Hintergrundbild und lebendigem Zellkörper
project: zellenphase
priority: 2
after: T-0166, A-0013
---
## Ziel
Der Zelleditor zeigt das Higgsfield-Bild `assets/ui/editor_hintergrund.png` (Petrischale) als Hintergrund, und die Zellansicht zeichnet den Körper mit `CellPainter` (Textur, Muster, Membranrand). So sieht man Farbe, Muster und Form schon im Editor wie später im Spiel.

## Dateien
- `scripts/cell_editor.gd`
- `scripts/cell_editor_canvas.gd`
- `tests/test_cell_editor_optik.gd`: neu

## Akzeptanzkriterien
- `scripts/cell_editor.gd`:
  - Unter der Zeile `const COLORS := […]`: `const BACKGROUND_TEXTURE: Texture2D = preload("res://assets/ui/editor_hintergrund.png")`
  - Neue Variable direkt unter `var symmetry_button: CheckButton`: `var background_image: TextureRect`
  - In `_init()` direkt nach `view_layer.add_child(background)`:
```gdscript
	background_image = TextureRect.new()
	background_image.name = "BackgroundImage"
	background_image.texture = BACKGROUND_TEXTURE
	background_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view_layer.add_child(background_image)
```
- `scripts/cell_editor_canvas.gd`, in `_draw()` den Block
```gdscript
	if look != null:
		var outline := PackedVector2Array()
		for p in look.outline(SCALE):
			outline.append(CENTER + p)
		draw_colored_polygon(outline, look.color)
	else:
```
  ersetzen durch
```gdscript
	if look != null:
		CellPainter.draw_cell(self, CENTER, look, SCALE, 0.0)
	else:
```
  (die Zeile `draw_circle(CENTER, SCALE, BODY_COLOR)` im `else`-Zweig bleibt).
- Sonst nichts an beiden Dateien ändern.

## Tests
`tests/test_cell_editor_optik.gd` mit `extends "res://tests/base_test.gd"`, `var editor: CellEditor`; `setup()`: `editor = CellEditor.new()`; `teardown()`: `editor.free()`.
- `test_hintergrundbild`: `editor.background_image.texture != null` wahr; `editor.background_image.texture.get_width()` ist 1920; `editor.background_image.mouse_filter == Control.MOUSE_FILTER_IGNORE` wahr
- `test_reihenfolge`: `editor.view_layer.get_child(1) == editor.background_image` wahr; `editor.view_layer.get_child(2) == editor.canvas` wahr

Review (16.10.2026): gemergt.
