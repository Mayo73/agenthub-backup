---
id: T-0333
title: ConfirmDialog – Rückfrage vor Zurücksetzen, Beenden und Blockieren
project: sparring
priority: 3
---
## Ziel
Meilenstein „Demodaten und Profil“: Folgenreiche Aktionen (Demo zurücksetzen, Match beenden, Blockieren) brauchen eine deutliche Rückfrage (Lastenheft: „nach Bestätigung die ursprünglichen Testdaten wiederherstellen“). Ein kleiner, wiederverwendbarer Dialog im Code, ohne Godot-`ConfirmationDialog` (der lässt sich in Tests schlecht bedienen).

## Dateien
- `scripts/confirm_dialog.gd` – neu, Klasse `ConfirmDialog`
- `tests/test_confirm_dialog.gd` – neu

## Akzeptanzkriterien
`class_name ConfirmDialog`, `extends Control`:
- `signal confirmed`
- `signal cancelled`
- In `_init()`: `set_anchors_preset(Control.PRESET_FULL_RECT)`, `mouse_filter = Control.MOUSE_FILTER_STOP`, `visible = false`. Kinder im Code:
  - `var shade: ColorRect` – ganze Fläche (`PRESET_FULL_RECT`), Farbe `Color(0, 0, 0, 0.6)`
  - `var box: PanelContainer` – `UiStyle.panel(UiStyle.CARD, 24)`, mittig (`set_anchors_preset(Control.PRESET_CENTER)`), `custom_minimum_size = Vector2(600, 0)`
  - darin eine `VBoxContainer` mit `var question_label: Label` (`UiStyle.label("", UiStyle.SIZE_NORMAL)`) und einer `HBoxContainer` mit `var cancel_button: Button` (`UiStyle.button("Abbrechen")`) und `var ok_button: Button` (`UiStyle.button("Ja", UiStyle.PASS)`), beide `SIZE_EXPAND_FILL`
- `func ask(question: String, ok_text: String = "Ja") -> void`: `question_label.text = question`, `ok_button.text = ok_text`, `visible = true`
- `ok_button.pressed` → `visible = false`, dann `confirmed.emit()`
- `cancel_button.pressed` → `visible = false`, dann `cancelled.emit()`
- Farben nur über `UiStyle` (Ausnahme: die Abdunklung `Color(0, 0, 0, 0.6)`).

## Tests
`tests/test_confirm_dialog.gd`: in `setup()` `dialog = ConfirmDialog.new()` an `(Engine.get_main_loop() as SceneTree).root` hängen, `teardown()` `dialog.free()`. Zähler über Signale mit Lambdas (`dialog.confirmed.connect(func(): ok_count += 1)`), Zähler als Klassenvariablen `var ok_count := 0`, `var cancel_count := 0`, in `setup()` auf 0 setzen.
- `test_anfangs_unsichtbar`: `dialog.visible` falsch
- `test_fragen`: `ask("Demo zurücksetzen?", "Zurücksetzen")` → `visible` wahr, `question_label.text` „Demo zurücksetzen?“, `ok_button.text` „Zurücksetzen“
- `test_bestaetigen`: `ask("X?")`, `ok_button.pressed.emit()` → `ok_count` 1, `cancel_count` 0, `visible` falsch
- `test_abbrechen`: `ask("X?")`, `cancel_button.pressed.emit()` → `cancel_count` 1, `ok_count` 0, `visible` falsch
- `test_standardtext`: `ask("X?")` → `ok_button.text` „Ja“

Review (18.10.2026): gemergt.
