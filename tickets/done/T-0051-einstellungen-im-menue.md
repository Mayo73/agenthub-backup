---
id: T-0051
title: Einstellungen-Knopf im Hauptmenü freischalten
project: drift
priority: 5
after: T-0037, T-0050
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Der bisher ausgegraute Knopf „Einstellungen“ im Hauptmenü öffnet das Einstellungsmenü. Beim Start des Hauptmenüs werden die gespeicherten Einstellungen (Lautstärke, Vollbild) angewendet.

## Dateien
- `scenes/main_menu.tscn`
- `scripts/main_menu.gd`
- `tests/test_main_menu.gd`

## Akzeptanzkriterien
- `scenes/main_menu.tscn`: im Block `[node name="Settings" …]` die Zeile `disabled = true` entfernen. Sonst nichts an der Szene ändern.
- `scripts/main_menu.gd`:
  - `const SETTINGS_SCENE := "res://scenes/settings_menu.tscn"`
  - `var settings_path := UserSettings.DEFAULT_PATH`
  - in `_ready()` als erste Zeile: `UserSettings.load_from(settings_path).apply()`
  - in `_ready()` vor `start_button.grab_focus()`: `settings_button.pressed.connect(open_settings)`
  - `func open_settings() -> void:` `get_tree().change_scene_to_file(SETTINGS_SCENE)`

## Tests
In `tests/test_main_menu.gd`:
- In `test_knoepfe` die Zeile, die prüft, dass `menu.settings_button.disabled` wahr ist, ersetzen durch `check(not menu.settings_button.disabled, "Einstellungen-Knopf ist freigeschaltet")`. Sonst keine bestehenden Tests ändern.
- In `teardown()` zusätzlich `AudioServer.set_bus_volume_db(0, 0.0)`.
- Neue Methode `test_einstellungen_verbunden`: `menu.settings_button.pressed.is_connected(menu.open_settings)` ist wahr und `ResourceLoader.exists(menu.SETTINGS_SCENE)` ist wahr. `open_settings()` **nicht** aufrufen.

Review (16.10.2026): gemergt.
