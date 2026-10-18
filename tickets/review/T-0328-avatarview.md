---
id: T-0328
title: AvatarView – selbst gezeichneter Avatar mit Initialen
project: sparring
priority: 3
after: T-0322
---
## Ziel
Meilenstein „Demodaten und Profil“: Jede Testperson bekommt einen eigenen, selbst gezeichneten Avatar (Lastenheft: eigene oder frei lizenzierte Avatare, keine Bilddateien von außen): ein farbiger Kreis mit den Initialen.

## Dateien
- `scripts/avatar_view.gd` – neu, Klasse `AvatarView`
- `tests/test_avatar_view.gd` – neu

## Akzeptanzkriterien
`class_name AvatarView`, `extends Control`:
- `var profile: SparProfile = null`
- `var diameter := 160.0` – setzt in `_init()` und in `set_diameter()` `custom_minimum_size = Vector2(diameter, diameter)`
- `func set_diameter(d: float) -> void`
- `func set_profile(p: SparProfile) -> void`: merkt sich das Profil und ruft `queue_redraw()`
- `func shown_initials() -> String`: `profile.initials()` oder `"?"` ohne Profil
- `func ring_color() -> Color`: `profile.color.lightened(0.3)` oder `UiStyle.MUTED` ohne Profil
- `_draw()`: Kreis mit Radius `diameter / 2` in der Mitte von `custom_minimum_size`, Farbe `profile.color` (ohne Profil `UiStyle.CARD`); Ring mit `draw_arc(..., 0, TAU, 48, ring_color(), 4.0)`; Initialen zentriert mit `ThemeDB.fallback_font`, Schriftgröße `int(diameter * 0.38)`, Farbe `UiStyle.TEXT` (`draw_string` mit `HORIZONTAL_ALIGNMENT_CENTER` und Breite `diameter`).
- Keine Bilddateien, keine Nodes als Kinder.

## Tests
`tests/test_avatar_view.gd`: In `setup()` `view = AvatarView.new()` und an `(Engine.get_main_loop() as SceneTree).root` hängen, in `teardown()` `view.free()`.
- `test_initialen`: ohne Profil `shown_initials()` „?“; mit `DemoData.profiles()[0]` „A“
- `test_groesse`: Standard `custom_minimum_size` ist `Vector2(160, 160)`; `set_diameter(96)` → `Vector2(96, 96)`
- `test_ringfarbe`: ohne Profil `UiStyle.MUTED`; mit Profil `profile.color.lightened(0.3)`
