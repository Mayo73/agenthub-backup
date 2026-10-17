---
id: T-0162
title: Titelbild im Hauptmenü (MainMenu)
project: zellenphase
priority: 5
after: A-0011
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Das Hauptmenü zeigt das mit Higgsfield erzeugte Titelbild `assets/ui/titelbild.png` (1920 × 1080) als Hintergrund über der einfarbigen Fläche.

## Dateien
- `scripts/main_menu.gd`
- `tests/test_main_menu_bild.gd`: neu

## Akzeptanzkriterien
In `scripts/main_menu.gd`:
- Unter `signal quit_game`: `const TITLE_TEXTURE: Texture2D = preload("res://assets/ui/titelbild.png")`
- Neue Variable unter `var box: VBoxContainer`: `var title_image: TextureRect`
- In `_init()` direkt nach `add_child(background)`:
```gdscript
	title_image = TextureRect.new()
	title_image.name = "TitleImage"
	title_image.texture = TITLE_TEXTURE
	title_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	title_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_image)
```
- Sonst nichts ändern.

## Tests
`tests/test_main_menu_bild.gd` mit `extends "res://tests/base_test.gd"`, `var menu: MainMenu`; `setup()`: `menu = MainMenu.new()`; `teardown()`: `menu.free()`.
- `test_bild`: `menu.title_image.texture != null` wahr; `menu.title_image.texture.get_width()` ist 1920
- `test_reihenfolge`: `menu.get_child(1) == menu.title_image` wahr (Bild liegt über dem Hintergrund, unter den Knöpfen); `menu.get_child(2) == menu.box` wahr
- `test_klicks_gehen_durch`: `menu.title_image.mouse_filter == Control.MOUSE_FILTER_IGNORE` wahr; `menu.box.get_child_count()` ist 6

Review (16.10.2026): gemergt.
