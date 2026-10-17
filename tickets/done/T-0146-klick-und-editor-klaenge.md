---
id: T-0146
title: Klickklänge in Menüs und Klänge im Zelleditor
project: zellenphase
priority: 3
after: T-0145
---
## Ziel
Alle Menüknöpfe klicken hörbar, und Änderungen im Zelleditor (Teil einbauen, verschieben, drehen, entfernen) erzeugen einen Klang (Lastenheft „Audio“: Editoraktionen).

## Dateien
- `scripts/main.gd`
- `tests/test_main_klick.gd`: neu

## Akzeptanzkriterien
- Neue Funktion am Ende von `main.gd`:
```gdscript
## Hängt an alle Knöpfe unter node (rekursiv) einen Klick-Klang.
func add_click_sounds(node: Node) -> void:
	for child in node.get_children():
		if child is BaseButton:
			(child as BaseButton).pressed.connect(func() -> void: audio.play("klick"))
		add_click_sounds(child)
```
- Am Ende von `_ready()` (nach den Zeilen, die `audio` anlegen):
```gdscript
	add_click_sounds(main_menu)
	add_click_sounds(pause_menu)
	add_click_sounds(settings_menu)
```
- In `open_editor()` direkt nach `editor.finished.connect(close_editor)`:
```gdscript
	editor.canvas.changed.connect(func() -> void: audio.play("teil_setzen"))
	add_click_sounds(editor)
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_klick.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`.
- `test_menueknopf_klickt`: `main.pause_menu.settings_button.pressed.emit()` → `main.audio.last_played` ist `"klick"`
- `test_einstellungen_klicken`: `main.settings_menu.back_button.pressed.emit()` → `main.audio.last_played` ist `"klick"`
- `test_editor_klingt`: `main.open_editor()`, `main.editor.canvas.changed.emit()` → `main.audio.last_played` ist `"teil_setzen"`; dann `main.editor.redo_button.pressed.emit()` → `main.audio.last_played` ist `"klick"`. Zum Schluss `main.editor.cancel()`.

Review (16.10.2026): gemergt.
