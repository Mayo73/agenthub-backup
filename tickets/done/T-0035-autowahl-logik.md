---
id: T-0035
title: Auto wechseln in GameSettings
project: drift
priority: 3
after: T-0027, T-0034
---
## Ziel
Wie die Strecke soll sich `GameSettings` auch das gewählte Auto über den Szenenwechsel hinweg merken und es wechseln können.

## Dateien
- `scripts/game_settings.gd`
- `tests/test_game_settings.gd`

## Akzeptanzkriterien
- `static var car_id: String = CarCatalog.DEFAULT_ID`
- `static func next_car() -> void:` setzt `car_id = step_id(CarCatalog.ids(), car_id, 1)`
- `static func previous_car() -> void:` setzt `car_id = step_id(CarCatalog.ids(), car_id, -1)`
- Alles andere in `game_settings.gd` bleibt unverändert.

## Tests
In `tests/test_game_settings.gd`: in `setup()` und `teardown()` zusätzlich die Zeile `GameSettings.car_id = CarCatalog.DEFAULT_ID`. Neue Methoden:
- `test_standardauto`: `GameSettings.car_id` ist `"allround"`
- `test_naechstes_auto`: `GameSettings.next_car()` → `"grip"`; noch einmal → `"drifter"`; noch einmal → `"allround"`
- `test_vorheriges_auto`: `GameSettings.previous_car()` → `"drifter"`

Review (16.10.2026): gemergt.
