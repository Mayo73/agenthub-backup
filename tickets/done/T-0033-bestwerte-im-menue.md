---
id: T-0033
title: Bestwerte der gewählten Strecke im Hauptmenü
project: drift
priority: 3
after: T-0028, T-0030
---
## Ziel
Unter der Streckenwahl im Hauptmenü stehen Bestzeit und Punkterekord der gewählten Strecke, z. B. `Bestzeit 1:35.50  ·  Rekord 800 Punkte`.

## Dateien
- `scenes/main_menu.tscn`
- `scripts/main_menu.gd`
- `tests/test_main_menu.gd`: neuen Test anhängen

## Akzeptanzkriterien
- `scenes/main_menu.tscn`: direkt **nach** dem Block `[node name="TrackNext" …]` (vor `[node name="Start" …]`) einfügen:
  ```
  [node name="TrackBest" type="Label" parent="Buttons"]
  layout_mode = 2
  theme_override_colors/font_color = Color(0.75, 0.9, 1, 1)
  theme_override_font_sizes/font_size = 18
  text = "Bestzeit –"
  horizontal_alignment = 1
  ```
- `scripts/main_menu.gd`:
  - `var highscore_path := HighscoreTable.DEFAULT_PATH`
  - `@onready var track_best: Label = $Buttons/TrackBest`
  - neue Funktion:
    ```gdscript
    func update_best_label() -> void:
    	var table := HighscoreTable.load_from(highscore_path)
    	var id := GameSettings.track_id
    	track_best.text = "Bestzeit %s  ·  Rekord %d Punkte" % [LapTimer.format_time(table.best_time(id)), table.best_points(id)]
    ```
  - `update_track_label()` ruft als letzte Zeile `update_best_label()` auf.

## Tests
In `tests/test_main_menu.gd` neue Methode `test_bestwerte_anzeigen`:
- `var path := "user://test_menu_bestenliste.json"`; `var table := HighscoreTable.new()`, `table.submit("hafen", 95.5, 800)`, `table.save(path)`
- `GameSettings.track_id = "hafen"`, `menu.highscore_path = path`, `menu.update_track_label()` → `menu.track_best.text` ist `"Bestzeit 1:35.50  ·  Rekord 800 Punkte"`
- `GameSettings.track_id = "altstadt"`, `menu.update_track_label()` → `menu.track_best.text` ist `"Bestzeit –  ·  Rekord 0 Punkte"`
- am Ende die Datei löschen: `DirAccess.remove_absolute(ProjectSettings.globalize_path(path))`

Review (16.10.2026): gemergt.
