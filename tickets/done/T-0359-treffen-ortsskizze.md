---
id: T-0359
title: MeetingScreen – Ortsskizze und gemeinsame Tage anzeigen
project: sparring
priority: 3
after: T-0345, T-0353, T-0352, T-0370
---
## Ziel
Meilenstein „Ortsskizze“: Im Treffen-Bildschirm erscheint unter dem Ortsfeld die schematische Ortsskizze (`PlaceView`, T-0358), die beim Tippen mitwechselt. Außerdem zeigt der Bildschirm die gemeinsamen Trainingstage beider Personen (`ProfileFacts`, T-0353) als Hilfe für die Terminwahl.

## Dateien
- `scripts/meeting_screen.gd` – zwei neue Elemente
- `tests/test_meeting_screen.gd` – Tests anhängen

## Akzeptanzkriterien
In `MeetingScreen`:
- `var days_label: Label` direkt nach `hint_label`: `UiStyle.label(ProfileFacts.common_days_text(state.active(), <andere Person>), UiStyle.SIZE_SMALL, UiStyle.MUTED)`
- `var place_view: PlaceView` direkt nach `place_edit` (Breite `SIZE_EXPAND_FILL`)
- `place_edit.text_changed` → `place_view.set_place(new_text)`
- `load_meeting()` ruft am Ende `place_view.set_place(place_edit.text)` auf (auch ohne Vorschlag, dann „Draußen“).
- Alles Übrige bleibt unverändert; die bestehenden Tests bleiben grün.

## Tests
`tests/test_meeting_screen.gd` anhängen (gleiches `setup()` mit Match „m1“ zwischen p01 Alex und p02 Sam):
- `test_skizze_anfang`: `place_view.kind` „Draußen“
- `test_skizze_folgt_eingabe`: `place_edit.text = "Stadtpark"`, `place_edit.text_changed.emit("Stadtpark")` → `place_view.kind` „Park“
- `test_skizze_aus_vorschlag`: `fill()` mit `place_edit.text = "Strand am Badesee"`, `propose()`; `state.switch_to("p02")`, neuen `MeetingScreen` für „m1“ bauen → dessen `place_view.kind` „Strand“ (danach freigeben)
- `test_gemeinsame_tage`: Alex (Di, Do, Sa) und Sam (Mo, Mi, Fr) → `days_label.text` „Keine gemeinsamen Tage – sprecht euch ab.“
- `test_reihenfolge`: `place_view.get_index()` ist `place_edit.get_index() + 1` (gleicher Eltern-Container)

Review (19.10.2026): gemergt.
