---
id: T-0344
title: MeetingScreen – Treffen draußen vorschlagen, zustimmen, absagen
project: sparring
priority: 3
after: T-0343
---
## Ziel
Meilenstein „Treffen vereinbaren“ (Lastenheft „Treffen vereinbaren“, „Soll: Intensität und Regeln, Hinweise bei unvollständigen Vorschlägen“): Ein Formular für Outdoor-Ort, Datum, Uhrzeit, Trainingsform, Intensität und Regeln. Beide müssen zustimmen; jede Änderung verlangt neue Zustimmung (Abnahmekriterium 6); absagen geht jederzeit (Kriterium 7). Einbau folgt in T-0345.

## Dateien
- `scripts/meeting_screen.gd` – neu, Klasse `MeetingScreen`
- `tests/test_meeting_screen.gd` – neu

## Akzeptanzkriterien
`class_name MeetingScreen`, `extends Control`:
- `signal changed`, `signal back`
- `var state: AppState`, `var match_id := ""`
- `func _init(app_state: AppState, id: String) -> void`: im Code eine `ScrollContainer` (`PRESET_FULL_RECT`) mit `VBoxContainer`:
  - `var back_button: Button` (`UiStyle.button("‹ Zurück zum Chat")`)
  - `var title_label: Label`: `"Treffen mit %s" % <Name der anderen Person>`, `UiStyle.SIZE_TITLE`
  - `var hint_label: Label`: `"Nur draußen, freiwillig und ohne Gym-Buchung. Ort als Text, keine Standortfreigabe."`, `UiStyle.SIZE_SMALL`, Farbe `UiStyle.MUTED`
  - `var status_label: Label` (Text aus `MeetingStatus.text`) und `var summary_label: Label` (Text aus `MeetingStatus.summary`, Farbe `UiStyle.ACCENT`)
  - Felder mit Beschriftung: `var place_edit: LineEdit` („Ort draußen“, Platzhalter „z. B. Stadtpark, Wiese am Teich“), `var date_edit: LineEdit` („Datum“, Platzhalter „TT.MM.JJJJ“), `var time_edit: LineEdit` („Uhrzeit“, Platzhalter „HH:MM“), `var form_picker: OptionButton` („Trainingsform“, Einträge `MeetingBook.FORMS`), `var intensity_picker: OptionButton` („Intensität“, Einträge `MeetingBook.INTENSITIES`, vorausgewählt „mittel“), `var rules_edit: LineEdit` („Gemeinsame Regeln“, Platzhalter „z. B. kein Kopfkontakt, Tap = sofort Stopp“)
  - `var error_label: Label` (Farbe `UiStyle.PASS`)
  - `var propose_button: Button` (`UiStyle.button("Vorschlagen", UiStyle.ACCENT)`), `var approve_button: Button` (`UiStyle.button("Zustimmen", UiStyle.LIKE)`), `var cancel_button: Button` (`UiStyle.button("Absagen", UiStyle.PASS)`)
  - danach `load_meeting()` und `refresh()`
- `func load_meeting() -> void`: gibt es einen Vorschlag, die Felder daraus füllen (Pickers per `select`).
- `func details() -> Dictionary`: `place`, `date`, `time`, `form` (Text des gewählten Eintrags), `intensity`, `rules` aus den Feldern.
- `func refresh() -> void`: `status_label.text`, `summary_label.text`; `approve_button.visible = MeetingStatus.can_approve(...)`; `cancel_button.visible = MeetingStatus.can_cancel(...)`; `propose_button.disabled = not state.can_write(match_id)`; Text von `propose_button` „Vorschlagen“ ohne bestehenden Vorschlag, sonst „Änderung vorschlagen“.
- `func propose() -> bool`: `var problems := state.propose_meeting(match_id, details())`; sind es Probleme: `error_label.text = "\n".join(problems)`, `false`. Sonst `error_label.text = ""`, `refresh()`, `changed.emit()`, `true`.
- `approve_button.pressed` → `state.approve_meeting(match_id)`, `refresh()`, `changed.emit()`
- `cancel_button.pressed` → `state.cancel_meeting(match_id)`, `refresh()`, `changed.emit()`
- `propose_button.pressed` → `propose`; `back_button.pressed` → `back.emit()`

## Tests
`tests/test_meeting_screen.gd`: in `setup()` `state = AppState.demo()` mit Match p01/p02 (wie in T-0343), Bildschirm `MeetingScreen.new(state, "m1")` an `(Engine.get_main_loop() as SceneTree).root`; `teardown()` `screen.free()`. Hilfsfunktion `fill()` setzt `place_edit.text = "Stadtpark"`, `date_edit.text = "24.10.2026"`, `time_edit.text = "10:30"`, `form_picker.select(1)` („Drills“).
- `test_anfang`: `status_label.text` „Noch kein Treffvorschlag.“, `approve_button.visible` falsch, `cancel_button.visible` falsch, `title_label.text` „Treffen mit Sam“
- `test_unvollstaendig`: nur `place_edit.text = "Stadtpark"`, `propose()` falsch → `error_label.text` enthält „Datum fehlt oder ist ungültig“; kein Vorschlag gespeichert
- `test_vorschlagen`: `fill()`, `propose_button.pressed.emit()` → `status_label.text` „Wartet auf die Zustimmung von Sam.“, `propose_button.text` „Änderung vorschlagen“, `changed` einmal
- `test_zustimmen_andere_seite`: als p01 vorschlagen; `state.switch_to("p02")`, neuen Bildschirm bauen → Felder gefüllt (`place_edit.text` „Stadtpark“), `approve_button.visible` wahr; `approve_button.pressed.emit()` → `state.meeting_confirmed("m1")` wahr, Text enthält „freiwillig“ (danach freigeben)
- `test_aenderung_verlangt_zustimmung`: bestätigen wie oben; als p02 `time_edit.text = "11:00"`, `propose()` → `state.meeting_confirmed("m1")` falsch
- `test_absagen`: vorschlagen, `cancel_button.pressed.emit()` → `status_label.text` „Abgesagt von dir.“
- `test_beendet`: `state.end_match("m1")`, `refresh()` → `propose_button.disabled` wahr

Review (19.10.2026): selbst umgesetzt (Agent scheiterte fünfmal an Parse-Fehlern), 7 Tests, 172 grün.
