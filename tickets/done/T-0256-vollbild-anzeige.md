---
id: T-0256
title: Vollbild im Einstellungsmenü mit sichtbarem Zustand
project: drift
priority: 2
---
## Ziel
Im Einstellungsmenü ist beim Kästchen „Vollbild“ nicht zu erkennen, ob es an oder aus ist (das Häkchen fehlt im Design). Der Text zeigt den Zustand künftig selbst: „Vollbild: An“ bzw. „Vollbild: Aus“.

## Dateien
- `scripts/settings_menu.gd`
- `tests/test_settings_menu.gd`

## Akzeptanzkriterien
- In `scripts/settings_menu.gd` eine statische Funktion (unter den Konstanten/Variablen, vor `_ready`):
```gdscript
## Beschriftung des Vollbild-Kästchens mit Zustand.
static func fullscreen_label(on: bool) -> String:
	return "Vollbild: An" if on else "Vollbild: Aus"
```
- In `_ready()` direkt nach `fullscreen_box.button_pressed = settings.fullscreen` die Zeile `fullscreen_box.text = fullscreen_label(settings.fullscreen)`.
- In `_on_fullscreen_toggled(on)` als erste Zeile `fullscreen_box.text = fullscreen_label(on)`.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_settings_menu.gd` anhängen:
- `test_vollbild_text`: `SettingsMenu`-Skript hat keinen `class_name`, deshalb über die Instanz: `menu.fullscreen_label(true)` ist `"Vollbild: An"`, `menu.fullscreen_label(false)` ist `"Vollbild: Aus"`; `menu.fullscreen_box.text` ist `"Vollbild: Aus"` (Startwert)
- `test_vollbild_umschalten`: `menu._on_fullscreen_toggled(true)` → `menu.fullscreen_box.text` ist `"Vollbild: An"`; danach `menu._on_fullscreen_toggled(false)` → `"Vollbild: Aus"`. Am Ende `DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)` aufrufen.

Review (17.10.2026): gemergt.
