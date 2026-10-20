---
id: T-0471
title: Profil-Bildschirm mit großem Porträt
project: sparring
priority: 2
after: T-0466
---
## Ziel
Auftrag „Modernes Design“ (M9): Das eigene Profil beginnt mit einem großen Porträt wie auf der Karte und zeigt Name und Alter groß; die Felder sind abgerundet.

## Dateien
- `scripts/profile_screen.gd`
- `tests/test_profile_screen.gd` – Tests ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- `vbox` liegt in einem `MarginContainer` mit `UiStyle.GAP` Rand auf allen Seiten (Kind der `ScrollContainer`, `size_flags_horizontal = Control.SIZE_EXPAND_FILL`), `vbox` hat `separation` 12.
- `avatar`: `set_fill(true)`, `shade = true`, `custom_minimum_size = Vector2(0, 360)`, `size_flags_horizontal = Control.SIZE_EXPAND_FILL` (statt Durchmesser 160).
- Neue Variable `var name_label: Label` = `UiStyle.overlay_label("", UiStyle.SIZE_HERO)` direkt nach dem Avatar; zeigt nach dem Füllen der Felder „<Name>, <Alter>“ des aktiven Profils (gleiche Stelle, an der `name_edit` gefüllt wird).
- `name_edit`, `bio_edit` mit `UiStyle.style_input(...)`; `art_picker`, `level_picker`, `weight_picker` mit `UiStyle.style_option(...)`.

## Tests
- `test_grosses_portraet`: `avatar.shade` wahr, `avatar.custom_minimum_size.y` 360.
- `test_name_gross`: nach dem Aufbau mit dem Demozustand (aktive Person „p01“) ist `name_label.text` „<name>, <age>“ von `state.profile("p01")`.