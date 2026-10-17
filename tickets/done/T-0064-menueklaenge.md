---
id: T-0064
title: Klickgeräusch in den Menüs
project: drift
priority: 5
after: T-0051, T-0054, T-0063
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Die Pfeilknöpfe im Hauptmenü und die Tastenknöpfe im Einstellungsmenü klicken hörbar.

## Dateien
- `scripts/main_menu.gd`
- `scripts/settings_menu.gd`
- `tests/test_main_menu.gd`: neuen Test anhängen, bestehende nicht ändern
- `tests/test_settings_menu.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- In **beiden** Skripten:
  - neue Variable `var click_player: AudioStreamPlayer`
  - neue Funktion am Ende der Datei:
```gdscript
func play_click() -> void:
	if click_player and click_player.is_inside_tree():
		click_player.play()
```
  - in `_ready()` als **erste** Zeilen:
```gdscript
	click_player = AudioStreamPlayer.new()
	click_player.name = "Click"
	click_player.stream = SoundBank.click()
	add_child(click_player)
```
- `main_menu.gd`: in `_ready()` vor `start_button.grab_focus()` die Knöpfe `track_prev`, `track_next`, `car_prev` und `car_next` jeweils zusätzlich mit `.pressed.connect(play_click)` verbinden
- `settings_menu.gd`: in `_build_key_rows()` direkt nach `button.pressed.connect(start_rebind.bind(action))` zusätzlich `button.pressed.connect(play_click)`
- Sonst nichts ändern.

## Tests
- `tests/test_main_menu.gd`, neue Methode `test_klick`: `menu.get_node("Click") is AudioStreamPlayer` ist wahr; `menu.click_player.stream is AudioStreamWAV` ist wahr; `menu.track_next.pressed.is_connected(menu.play_click)` ist wahr; `menu.car_prev.pressed.is_connected(menu.play_click)` ist wahr
- `tests/test_settings_menu.gd`, neue Methode `test_klick`: `menu.get_node("Click") is AudioStreamPlayer` ist wahr; `menu.key_buttons["gas"].pressed.is_connected(menu.play_click)` ist wahr

Review (16.10.2026): gemergt.
