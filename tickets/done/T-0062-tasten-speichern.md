---
id: T-0062
title: Geänderte Tasten in den Einstellungen speichern
project: drift
priority: 3
after: T-0049, T-0061
---
## Ziel
`UserSettings` merkt sich geänderte Tasten, speichert sie mit den übrigen Einstellungen und wendet sie an.

## Dateien
- `scripts/user_settings.gd`
- `tests/test_user_settings.gd`: `teardown()` ergänzen und Tests anhängen, bestehende Tests nicht ändern

## Akzeptanzkriterien
- Neue Variable (unter `var fullscreen`): `var keys := {}  # Aktion → physical_keycode, nur geänderte Tasten`
- `save()`: Das gespeicherte Dictionary bekommt zusätzlich den Eintrag `"keys": keys`
- `load_from()`: direkt nach dem Einlesen von `fullscreen` zusätzlich (den Namen der Instanz übernehmen, falls sie dort nicht `settings` heißt):
```gdscript
		var k: Variant = d.get("keys", {})
		if k is Dictionary:
			for action in k:
				settings.keys[str(action)] = int(k[action])
```
- `apply()`: am Ende zusätzlich `Controls.setup()` und `Controls.apply_bindings(keys)`
- Sonst nichts ändern.

## Tests
In `tests/test_user_settings.gd`:
- in `teardown()` zusätzlich `Controls.reset_defaults()`
- `test_tasten_speichern`: `var s := UserSettings.new()`, `s.keys = {"gas": KEY_I}`, `s.save(TEST_PATH)`; `var l := UserSettings.load_from(TEST_PATH)` → `l.keys.has("gas")` ist wahr und `l.keys["gas"]` ist `KEY_I`
- `test_tasten_anwenden`: `var s := UserSettings.new()`, `s.keys = {"gas": KEY_I}`, `s.apply()` → `Controls.key_for("gas")` ist `KEY_I`
- `test_ohne_tasten`: `UserSettings.new().keys.is_empty()` ist wahr

Review (16.10.2026): gemergt.
