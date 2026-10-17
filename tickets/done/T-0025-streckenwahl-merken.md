---
id: T-0025
title: Gewählte Strecke merken und im Rennen laden
project: drift
priority: 3
after: T-0022, T-0024
---
## Ziel
Das Menü soll später eine Strecke auswählen können. Dafür merkt sich eine kleine Klasse `GameSettings` die gewählte Strecke über den Szenenwechsel hinweg, und die Rennszene lädt beim Start genau diese Strecke.

## Dateien
- `scripts/game_settings.gd`: neu, beginnt mit `class_name GameSettings` und `extends RefCounted`
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/game_settings.gd`: `static var track_id: String = TrackCatalog.DEFAULT_ID`
- `scripts/main.gd`: in `_ready()` direkt nach `Controls.setup()` (also vor `car.track = track.path`) die Zeile `track.load_track(GameSettings.track_id)`. Sonst nichts ändern.

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_gewaehlte_strecke_wird_geladen` anhängen:
- `GameSettings.track_id` ist `TrackCatalog.DEFAULT_ID`
- `main.track.track_id` ist `GameSettings.track_id`
- `main.car.track == main.track.path` ist wahr

Review (16.10.2026): gemergt, nachgebessert: Fortsetzungszeilen im Test mit Leerzeichen statt Tabs eingerückt.
