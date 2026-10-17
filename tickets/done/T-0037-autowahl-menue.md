---
id: T-0037
title: Autowahl im Hauptmenü
project: drift
priority: 3
after: T-0033, T-0035
---
## Ziel
Unter den Bestwerten der Strecke steht im Hauptmenü eine Zeile `<  Allrounder  >`, mit der man das Auto wählt.

## Dateien
- `scenes/main_menu.tscn`
- `scripts/main_menu.gd`
- `tests/test_main_menu.gd`

## Akzeptanzkriterien
- `scenes/main_menu.tscn`:
  - Beim Node `Buttons` die Zeile `offset_top = -200.0` durch `offset_top = -240.0` und `offset_bottom = 200.0` durch `offset_bottom = 240.0` ersetzen.
  - Direkt **nach** dem Block `[node name="TrackBest" …]` (vor `[node name="Start" …]`) einfügen:
    ```
    [node name="CarRow" type="HBoxContainer" parent="Buttons"]
    layout_mode = 2
    alignment = 1
    theme_override_constants/separation = 12

    [node name="CarPrev" type="Button" parent="Buttons/CarRow"]
    layout_mode = 2
    theme_override_font_sizes/font_size = 24
    text = "<"

    [node name="CarName" type="Label" parent="Buttons/CarRow"]
    custom_minimum_size = Vector2(220, 0)
    layout_mode = 2
    theme_override_font_sizes/font_size = 24
    text = "Auto"
    horizontal_alignment = 1

    [node name="CarNext" type="Button" parent="Buttons/CarRow"]
    layout_mode = 2
    theme_override_font_sizes/font_size = 24
    text = ">"
    ```
- `scripts/main_menu.gd`:
  - `@onready var car_prev: Button = $Buttons/CarRow/CarPrev`, `@onready var car_name: Label = $Buttons/CarRow/CarName`, `@onready var car_next: Button = $Buttons/CarRow/CarNext`
  - in `_ready()` vor `start_button.grab_focus()`: `car_prev.pressed.connect(_on_car_prev)`, `car_next.pressed.connect(_on_car_next)`, `update_car_label()`
  - `func update_car_label() -> void:` setzt `car_name.text = CarCatalog.name_of(GameSettings.car_id)` und `car_name.modulate = CarCatalog.color_of(GameSettings.car_id).lightened(0.3)`
  - `func _on_car_prev() -> void:` `GameSettings.previous_car()`, dann `update_car_label()`
  - `func _on_car_next() -> void:` `GameSettings.next_car()`, dann `update_car_label()`

## Tests
In `tests/test_main_menu.gd`:
- In `teardown()` als erste Zeile zusätzlich `GameSettings.car_id = CarCatalog.DEFAULT_ID` einfügen.
- Neue Methode `test_autowahl`: `GameSettings.car_id = CarCatalog.DEFAULT_ID`, `menu.update_car_label()` → `menu.car_name.text` ist `"Allrounder"`; `menu.car_next.pressed.emit()` → `GameSettings.car_id` ist `"grip"` und `menu.car_name.text` ist `"Grip-Coupé"`; `menu.car_prev.pressed.emit()` zweimal → `GameSettings.car_id` ist `"drifter"` und `menu.car_name.text` ist `"Drift-Kombi"`

Review (16.10.2026): gemergt.
