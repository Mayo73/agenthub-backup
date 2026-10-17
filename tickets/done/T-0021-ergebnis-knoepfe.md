---
id: T-0021
title: Ergebnisbildschirm mit „Nochmal“ und „Zum Menü“
project: drift
priority: 3
after: T-0020
---
## Ziel
Nach dem Ziel erscheinen unter dem Ergebnis zwei Knöpfe: „Nochmal“ startet ein neues Rennen, „Zum Menü“ wechselt ins Hauptmenü. Die Enter-Taste funktioniert weiterhin.

## Dateien
- `scenes/main.tscn`: neue Nodes unter `HUD` ganz am Ende anhängen
- `scripts/hud.gd`: Signale und Knöpfe
- `scripts/main.gd`: Signale verbinden

## Akzeptanzkriterien
- `scenes/main.tscn`: ganz am Ende der Datei anhängen (keine neue `ext_resource`, sonst nichts ändern):
  ```
  [node name="ResultButtons" type="HBoxContainer" parent="HUD"]
  visible = false
  anchors_preset = 8
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -200.0
  offset_top = 130.0
  offset_right = 200.0
  offset_bottom = 180.0
  alignment = 1
  theme_override_constants/separation = 24

  [node name="Again" type="Button" parent="HUD/ResultButtons"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 24
  text = "Nochmal"

  [node name="Menu" type="Button" parent="HUD/ResultButtons"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 24
  text = "Zum Menü"
  ```
- `scripts/hud.gd`:
  - oben `signal again_pressed` und `signal menu_pressed`
  - `@onready var result_buttons: HBoxContainer = $ResultButtons`, `@onready var again_button: Button = $ResultButtons/Again`, `@onready var menu_button: Button = $ResultButtons/Menu`
  - neue `func _ready() -> void:` `again_button.pressed.connect(again_pressed.emit)` und `menu_button.pressed.connect(menu_pressed.emit)`
  - in `show_race` am Ende:
    ```gdscript
    var finished := race.phase == RaceState.Phase.FINISHED
    if finished and not result_buttons.visible:
    	again_button.grab_focus()
    result_buttons.visible = finished
    ```
- `scripts/main.gd`:
  - `const MENU_SCENE := "res://scenes/main_menu.tscn"` bei den Konstanten
  - am Ende von `_ready()`: `hud.again_pressed.connect(restart)` und `hud.menu_pressed.connect(go_to_menu)`
  - neue `func go_to_menu() -> void:` `get_tree().change_scene_to_file(MENU_SCENE)`

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_ergebnis_knoepfe` anhängen (bestehende nicht ändern, `go_to_menu()` nicht aufrufen):
- `main.hud.result_buttons.visible` ist falsch
- `main.race.phase = RaceState.Phase.FINISHED`, `main.hud.show_race(main.race, 10)` → `main.hud.result_buttons.visible` ist wahr
- `main.hud.again_pressed.is_connected(main.restart)` und `main.hud.menu_pressed.is_connected(main.go_to_menu)` sind wahr
- `main.hud.again_button.pressed.emit()` → `main.race.phase` ist `RaceState.Phase.COUNTDOWN`
- `ResourceLoader.exists(main.MENU_SCENE)` ist wahr

Review (16.10.2026): gemergt, nachgebessert: Fortsetzungszeilen im Test mit Leerzeichen statt Tabs eingerückt.
