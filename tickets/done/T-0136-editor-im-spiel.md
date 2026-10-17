---
id: T-0136
title: Zelleditor im Spiel öffnen und Umbau übernehmen
project: zellenphase
priority: 3
after: T-0135, T-0133, T-0134
---
## Ziel
Erreicht die Zelle ihren Partner, öffnet sich der Zelleditor; die Spielwelt ist so lange verborgen. Nach dem Bestätigen übernimmt die Spielerzelle Aufbau und Aussehen (Tempo, Ernährung und Darstellung ändern sich), nach dem Abbrechen bleibt alles wie vorher. Danach geht das Spiel weiter (Abnahmekriterium 8).

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variable direkt unter `var editor_open := false`: `var editor: CellEditor`
- Die Funktion `open_editor()` (mit ihrem Kommentar) ersetzen durch genau diese zwei Funktionen:
```gdscript
## Öffnet den Zelleditor; die Welt ist so lange verborgen und angehalten.
func open_editor() -> void:
	editor_open = true
	player.input_enabled = false
	mate.finish()
	world.visible = false
	hud.visible = false
	editor = CellEditor.new()
	editor.name = "Editor"
	add_child(editor)
	editor.open(player.build, unlocks, progress, progress.stage)
	editor.set_look(player.look)
	editor.finished.connect(close_editor)


## Übernimmt das Ergebnis des Editors und kehrt ins Spiel zurück.
func close_editor(build: CellBuild) -> void:
	player.set_build(build)
	if editor.confirmed:
		player.set_look(editor.look)
	remove_child(editor)
	editor.queue_free()
	editor = null
	world.visible = true
	hud.visible = true
	editor_open = false
	player.input_enabled = true
	hud.show_progress(progress)
```
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` anhängen:
- `test_editor_oeffnen`: `main.open_editor()` → `main.editor is CellEditor` wahr; `main.editor.get_parent() == main` wahr; `main.world.visible` falsch; `main.hud.visible` falsch
- `test_editor_abbrechen`: `main.open_editor()`, `main.editor.cancel()` → `main.editor_open` falsch; `main.editor == null` wahr; `main.world.visible` wahr; `main.player.input_enabled` wahr; `main.player.build.parts.size()` ist 2
- `test_editor_umbau`: `main.progress.dna = 30`, `main.unlocks.unlock("geissel")`, `main.open_editor()`, `main.editor.panel.select("geissel")`, `main.editor.canvas.click(Vector2(752, 696))`, `main.editor.confirm()` → `main.player.build.parts.size()` ist 4; `main.progress.dna` ist 0; `main.player.motion.max_speed` ist 310.0 (220 + 60 für die erste Geißel + 30 für die zweite)
- `test_aussehen_uebernommen`: `main.open_editor()`, `main.editor.set_color(Color.RED)`, `main.editor.confirm()` → `main.player.look.color.is_equal_approx(Color.RED)` wahr
- `test_aussehen_abbrechen`: `main.open_editor()`, `main.editor.set_color(Color.RED)`, `main.editor.cancel()` → `main.player.look.color.is_equal_approx(CellLook.DEFAULT_COLOR)` wahr

Review (16.10.2026): gemergt.
