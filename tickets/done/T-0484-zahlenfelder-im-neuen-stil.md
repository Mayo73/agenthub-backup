---
id: T-0484
title: Zahlenfelder (Alter, Trainingsjahre) im neuen Stil
project: sparring
priority: 2
---
## Ziel
Auftrag „Modernes Design“ (M9), Befund aus den Spieltestbildern: Die Felder „Alter“ und „Trainingsjahre“ im Profil sind noch Godots Standard-Zahlenfelder mit winziger Schrift. Sie sollen aussehen wie die übrigen Eingabefelder.

## Dateien
- `scripts/ui_style.gd` – neue statische Funktion `style_spin` (direkt nach `style_input` einfügen)
- `scripts/profile_screen.gd` – beide Zahlenfelder gestalten
- `tests/test_ui_style.gd`, `tests/test_profile_screen.gd` – Tests ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- `static func style_spin(s: SpinBox) -> void` mit `##`-Kommentar: `s.custom_minimum_size = Vector2(0, 72)`, dann `style_input(s.get_line_edit())`, dazu `s.get_line_edit().alignment = HORIZONTAL_ALIGNMENT_LEFT`.
- `profile_screen.gd`: direkt nach dem Anlegen von `age_spin` und `years_spin` jeweils `UiStyle.style_spin(...)` aufrufen.

## Tests
- `tests/test_ui_style.gd`, `test_style_spin`: `var s := SpinBox.new()`, `UiStyle.style_spin(s)` → `s.custom_minimum_size.y` 72, `(s.get_line_edit().get_theme_stylebox("focus") as StyleBoxFlat).border_color == UiStyle.ACCENT`; danach `s.free()`.
- `tests/test_profile_screen.gd`, `test_zahlenfelder_gestaltet`: nach dem Aufbau (wie in den anderen Tests) ist `screen.age_spin.custom_minimum_size.y` 72 und `screen.years_spin.custom_minimum_size.y` 72.

Review (20.10.2026): nicht gemergt, überholt durch den Neustart von Sparring als React-Native-App (Rückmeldung vom 20.10.2026). Branch als godot/T-0484 erhalten.
