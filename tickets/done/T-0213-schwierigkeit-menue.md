---
id: T-0213
title: Schwierigkeitsgrad im Einstellungsmenü wählen
project: zellenphase
priority: 3
after: T-0212
---
## Ziel
Im Einstellungsmenü gibt es unter der Auflösung eine Auswahl „Schwierigkeit“ mit Leicht, Normal und Schwer.

## Dateien
- `scripts/settings_menu.gd`
- `tests/test_settings_menu.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/settings_menu.gd`:
- Neue Variable direkt unter `var resolution_option: OptionButton`: `var difficulty_option: OptionButton`
- In `_init()` direkt nach der Zeile `box.add_child(resolution_option)`:
```gdscript
	_label("Schwierigkeit")
	difficulty_option = OptionButton.new()
	for n: String in Difficulty.NAMES:
		difficulty_option.add_item(n)
	box.add_child(difficulty_option)
```
- In `_init()` direkt nach der Zeile `resolution_option.item_selected.connect(_on_resolution)`: `difficulty_option.item_selected.connect(_on_difficulty)`
- Neue Funktion direkt unter `func _on_resolution(...)` (nach deren Rumpf, mit zwei Leerzeilen Abstand):
```gdscript
func _on_difficulty(i: int) -> void:
	if settings != null:
		settings.set_difficulty(i)
```
- In `show_settings(...)` direkt nach der Zeile `resolution_option.select(s.resolution_index)`: `difficulty_option.select(s.difficulty)`
- Sonst nichts ändern.

## Tests
In `tests/test_settings_menu.gd` anhängen (dort gibt es schon `menu` und `s`):
- `test_schwierigkeit_anzeige`: `s.set_difficulty(2)`, `menu.show_settings(s)` → `menu.difficulty_option.item_count` ist 3; `menu.difficulty_option.selected` ist 2; `menu.difficulty_option.get_item_text(0)` ist `"Leicht"`
- `test_schwierigkeit_waehlen`: `menu.show_settings(s)`, `menu.difficulty_option.item_selected.emit(0)` → `s.difficulty` ist 0

Review (17.10.2026): gemergt.
