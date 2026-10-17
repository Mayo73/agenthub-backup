---
id: T-0028
title: Streckenwahl im Hauptmenü
project: drift
priority: 2
after: T-0027
---
## Ziel
Im Hauptmenü steht zwischen Titel und „Rennen starten“ eine Zeile `<  Hafenring  >`. Mit den Pfeil-Knöpfen wechselt man die Strecke; „Rennen starten“ fährt dann auf der gewählten Strecke (das lädt `main.gd` schon aus `GameSettings.track_id`).

## Dateien
- `scenes/main_menu.tscn`
- `scripts/main_menu.gd`
- `tests/test_main_menu.gd`

## Akzeptanzkriterien
- `scenes/main_menu.tscn`:
  - Beim Node `Buttons` die Zeile `offset_top = -140.0` durch `offset_top = -200.0` und `offset_bottom = 140.0` durch `offset_bottom = 200.0` ersetzen.
  - Direkt **nach** dem Block `[node name="Title" …]` (vor `[node name="Start" …]`) einfügen:
    ```
    [node name="TrackRow" type="HBoxContainer" parent="Buttons"]
    layout_mode = 2
    alignment = 1
    theme_override_constants/separation = 12

    [node name="TrackPrev" type="Button" parent="Buttons/TrackRow"]
    layout_mode = 2
    theme_override_font_sizes/font_size = 24
    text = "<"

    [node name="TrackName" type="Label" parent="Buttons/TrackRow"]
    custom_minimum_size = Vector2(220, 0)
    layout_mode = 2
    theme_override_font_sizes/font_size = 24
    text = "Strecke"
    horizontal_alignment = 1

    [node name="TrackNext" type="Button" parent="Buttons/TrackRow"]
    layout_mode = 2
    theme_override_font_sizes/font_size = 24
    text = ">"
    ```
- `scripts/main_menu.gd`:
  - `@onready var track_prev: Button = $Buttons/TrackRow/TrackPrev`, `@onready var track_name: Label = $Buttons/TrackRow/TrackName`, `@onready var track_next: Button = $Buttons/TrackRow/TrackNext`
  - in `_ready()` vor `start_button.grab_focus()`: `track_prev.pressed.connect(_on_track_prev)`, `track_next.pressed.connect(_on_track_next)`, `update_track_label()`
  - `func update_track_label() -> void:` `track_name.text = TrackCatalog.name_of(GameSettings.track_id)`
  - `func _on_track_prev() -> void:` `GameSettings.previous_track()`, dann `update_track_label()`
  - `func _on_track_next() -> void:` `GameSettings.next_track()`, dann `update_track_label()`

## Tests
In `tests/test_main_menu.gd`:
- In `teardown()` als erste Zeile `GameSettings.track_id = TrackCatalog.DEFAULT_ID` einfügen (sonst nichts an bestehenden Tests ändern).
- Neue Methode `test_streckenwahl`: `GameSettings.track_id = TrackCatalog.DEFAULT_ID`, `menu.update_track_label()` → `menu.track_name.text` ist `"Hafenring"`; `menu.track_next.pressed.emit()` → `GameSettings.track_id` ist `"altstadt"` und `menu.track_name.text` ist `"Altstadtkurs"`; `menu.track_prev.pressed.emit()` zweimal → `GameSettings.track_id` ist `"kurvenring"` und `menu.track_name.text` ist `"Kurvenring"`

Review (16.10.2026): gemergt.
