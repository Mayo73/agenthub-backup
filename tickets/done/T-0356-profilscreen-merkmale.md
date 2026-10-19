---
id: T-0356
title: ProfileScreen – Merkmale bearbeiten
project: sparring
priority: 3
after: T-0335, T-0352, T-0355
---
## Ziel
Meilenstein „Profilmerkmale“: Im Profil-Reiter lassen sich Gewichtsklasse, Trainingstage und eigene Ausrüstung der aktiven Testperson bearbeiten und speichern.

## Dateien
- `scripts/profile_screen.gd` – neue Eingabefelder
- `tests/test_profile_screen.gd` – Tests anhängen

## Akzeptanzkriterien
In `ProfileScreen`, nach dem Feld `years_spin` und vor `bio_edit` (jeweils mit Beschriftung über `UiStyle.label(...)`):
- „Gewichtsklasse“: `var weight_picker: OptionButton` – Eintrag 0 „keine Angabe“, danach `SparProfile.WEIGHT_CLASSES`
- „Verfügbar an“: `var day_boxes: Dictionary` – Tag → `CheckBox` (Text = Tag), ein `CheckBox` je `SparProfile.DAYS` in einer `HFlowContainer`
- „Eigene Ausrüstung“: `var equipment_boxes: Dictionary` – Name → `CheckBox`, einer je `SparProfile.EQUIPMENT` in einer `HFlowContainer`
- `load_profile()`: zusätzlich `weight_picker.select(p.weight_class + 1)`; jede `CheckBox` mit `button_pressed = p.days.has(tag)` bzw. `p.equipment.has(name)`
- `form_values()` liefert zusätzlich `weight_class = weight_picker.selected - 1`, `days` und `equipment` (angehakte Einträge in der Reihenfolge der Konstanten).
- Speichern wie bisher über `ProfileForm.applied`; die bestehenden Tests bleiben grün.

## Tests
`tests/test_profile_screen.gd` anhängen (gleiches `setup()`):
- `test_merkmale_gefuellt`: Alex → `weight_picker.selected` 2, `day_boxes["Di"].button_pressed` wahr, `day_boxes["Mo"].button_pressed` falsch, `equipment_boxes["Matte"].button_pressed` wahr, `day_boxes.size()` 7, `equipment_boxes.size()` 5
- `test_merkmale_speichern`: `day_boxes["So"].button_pressed = true`, `day_boxes["Di"].button_pressed = false`, `weight_picker.select(0)`, `save_button.pressed.emit()` → `state.active().days` gleich `["Do", "Sa", "So"]`, `state.active().weight_class` -1
- `test_ausruestung_speichern`: `equipment_boxes["Pratzen"].button_pressed = true`, speichern → `state.active().equipment` gleich `["Mundschutz", "Matte", "Pratzen"]`
- `test_merkmale_andere_perspektive`: `state.switch_to("p02")`, neuen `ProfileScreen` bauen → `weight_picker.selected` 3, `day_boxes["Fr"].button_pressed` wahr (danach freigeben)

Review (18.10.2026): gemergt.
