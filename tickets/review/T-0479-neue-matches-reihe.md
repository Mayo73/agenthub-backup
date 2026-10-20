---
id: T-0479
title: Reihe „Neue Matches“ über der Matchliste
project: sparring
priority: 2
after: T-0474
---
## Ziel
Auftrag „Modernes Design“ (M9): Wie in modernen Dating-Apps stehen Matches ohne Nachrichten oben als Reihe großer runder Porträts mit Namen. Ein Tipp öffnet den Chat.

## Dateien
- `scripts/matches_screen.gd`
- `tests/test_matches_screen.gd` – Tests ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- Neue Variablen: `var new_section: VBoxContainer`, `var new_row: HBoxContainer`, `var new_buttons: Dictionary = {}` (Match-ID → Button).
- `new_section` steht in `box` direkt nach `title_label` und enthält `UiStyle.label("Neue Matches", UiStyle.SIZE_SMALL, UiStyle.MUTED)` und eine `ScrollContainer` (`vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED`, `custom_minimum_size = Vector2(0, 150)`) mit `new_row` (`separation` `UiStyle.GAP`).
- `refresh()` leert `new_row` und `new_buttons` (wie `list`) und legt für jedes Match aus `state.my_matches()` ohne `ended_by` und mit `state.chat.last_message(id).is_empty()` einen Eintrag an: `Button` mit `flat = true`, `custom_minimum_size = Vector2(112, 140)`, darin ein `VBoxContainer` (`mouse_filter = Control.MOUSE_FILTER_IGNORE`) mit `AvatarView` (`set_diameter(96)`, Profil der anderen Person, `mouse_filter` IGNORE) und `UiStyle.label(<Name>, UiStyle.SIZE_SMALL)` (`horizontal_alignment` CENTER, `mouse_filter` IGNORE). `pressed` ist mit `open_chat.emit.bind(id)` verbunden.
- `new_section.visible = not new_buttons.is_empty()`.
- Die Liste darunter bleibt unverändert (auch neue Matches stehen weiterhin dort).

## Tests
- `test_neue_matches_reihe`: nach `make_match("p01", "p02")` und `build()` → `new_buttons.has(<id>)`, `new_section.visible` wahr.
- `test_neue_matches_nach_nachricht`: Match herstellen, eine Nachricht senden (wie in `test_letzte_nachricht`), `build()` → `new_buttons` leer, `new_section.visible` falsch.
- `test_neue_matches_oeffnet_chat`: Match herstellen, `build()`, `open_chat` mit einer Funktion verbinden, die `received_id` setzt, `new_buttons[<id>].pressed.emit()` → `received_id` ist die Match-ID.
- `test_ohne_matches_keine_reihe`: ohne Match → `new_section.visible` falsch.
