---
id: T-0335
title: ProfileScreen – eigenes Demoprofil bearbeiten und Demo zurücksetzen
project: sparring
priority: 3
after: T-0326, T-0328, T-0333, T-0334
---
## Ziel
Meilenstein „Demodaten und Profil“: Im Reiter „Profil“ bearbeitet die aktive Testperson ihr Profil (Lastenheft: „Ein eigenes Demoprofil kann bearbeitet werden“) und kann die Demo nach Rückfrage auf die ursprünglichen Testdaten zurücksetzen (Lastenheft „Lokaler Zustand“, Abnahmekriterium 9). Den Einbau in `Main` macht T-0336.

## Dateien
- `scripts/profile_screen.gd` – neu, Klasse `ProfileScreen`
- `tests/test_profile_screen.gd` – neu

## Akzeptanzkriterien
`class_name ProfileScreen`, `extends Control`:
- `signal changed` – nach dem Speichern eines Profils
- `signal reset_requested` – nachdem das Zurücksetzen im Dialog bestätigt wurde
- `var state: AppState`
- `func _init(app_state: AppState) -> void`: Zustand merken, im Code anlegen (eine `ScrollContainer` mit `PRESET_FULL_RECT`, darin eine `VBoxContainer` mit `SIZE_EXPAND_FILL` in der Breite):
  - `var avatar: AvatarView` (Durchmesser 160, `SIZE_SHRINK_CENTER`)
  - `var demo_hint: Label` – Text `"Du bearbeitest das Demoprofil der aktiven Testperson."`, `UiStyle.SIZE_SMALL`, Farbe `UiStyle.DEMO`
  - `var name_edit: LineEdit` (`max_length = ProfileForm.NAME_MAX`)
  - `var art_picker: OptionButton` – ein Eintrag je `DemoData.ARTS` in dieser Reihenfolge
  - `var level_picker: OptionButton` – Einträge `SparProfile.LEVELS`
  - `var age_spin: SpinBox` (`min_value` 18, `max_value` 99) und `var years_spin: SpinBox` (`min_value` 0, `max_value` 60)
  - `var bio_edit: LineEdit` (`max_length = ProfileForm.BIO_MAX`)
  - `var error_label: Label` – Farbe `UiStyle.PASS`, zunächst leer
  - `var save_button: Button` (`UiStyle.button("Profil speichern", UiStyle.ACCENT)`)
  - `var reset_button: Button` (`UiStyle.button("Demo zurücksetzen", UiStyle.PASS)`)
  - `var dialog: ConfirmDialog` – als letztes Kind direkt am Bildschirm (nicht im Scroll-Bereich), damit es alles überdeckt
  - vor jedes Eingabefeld eine Beschriftung mit `UiStyle.label(...)` („Name“, „Kampfsportart“, „Erfahrung“, „Alter“, „Trainingsjahre“, „Über mich“)
- `func load_profile() -> void`: füllt alle Felder aus `state.active()` (Kampfsportart und Erfahrung per `select(...)`), `avatar.set_profile(state.active())`, `error_label.text = ""`. Am Ende von `_init()` aufrufen.
- `func form_values() -> Dictionary`: die sechs Werte aus den Feldern (`art` = Text des gewählten Eintrags, `level` = gewählter Index, `age`/`years` als `int`).
- `func save_profile() -> bool`: `var p := ProfileForm.applied(state.active(), form_values())`; bei `null`: `error_label.text = "\n".join(ProfileForm.errors(form_values()))`, `false`. Sonst `state.update_profile(p)`, `error_label.text = "Gespeichert."` mit Farbe `UiStyle.LIKE`, `avatar.set_profile(state.active())`, `changed.emit()`, `true`. (Bei Fehlern Farbe wieder `UiStyle.PASS`.)
- `save_button.pressed` → `save_profile`
- `reset_button.pressed` → `dialog.ask("Alle Profile, Matches, Nachrichten und Treffen auf die ursprünglichen Testdaten zurücksetzen?", "Zurücksetzen")`
- `dialog.confirmed` → `reset_requested.emit()`

## Tests
`tests/test_profile_screen.gd`: in `setup()` `state = AppState.demo()`, `screen = ProfileScreen.new(state)` an `(Engine.get_main_loop() as SceneTree).root` hängen; `teardown()` `screen.free()`.
- `test_felder_gefuellt`: `name_edit.text` „Alex“, `art_picker.get_item_text(art_picker.selected)` „Jiu-Jitsu“, `level_picker.selected` 1, `int(age_spin.value)` 29
- `test_speichern`: `name_edit.text = "Alexa"`, `save_button.pressed.emit()` → `state.active().name` „Alexa“, `error_label.text` „Gespeichert.“; Signal `changed` einmal (Zähler)
- `test_fehler_anzeigen`: `name_edit.text = ""`, `save_profile()` falsch → `error_label.text` enthält „Name fehlt“, `state.active().name` bleibt „Alex“, `changed` nicht ausgelöst
- `test_andere_perspektive`: `state.switch_to("p02")`, neuen `ProfileScreen` bauen → `name_edit.text` „Sam“ (danach freigeben)
- `test_zuruecksetzen_fragt`: `reset_button.pressed.emit()` → `dialog.visible` wahr, `reset_requested` noch nicht ausgelöst; `dialog.ok_button.pressed.emit()` → `reset_requested` genau einmal
- `test_zuruecksetzen_abbrechen`: `reset_button.pressed.emit()`, `dialog.cancel_button.pressed.emit()` → `reset_requested` nicht ausgelöst

Review (18.10.2026): gemergt.
