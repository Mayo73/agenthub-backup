---
id: T-0336
title: Reiter „Profil“ in der App, Zurücksetzen stellt die Testdaten wieder her
project: sparring
priority: 3
after: T-0332, T-0335
---
## Ziel
Meilenstein „Demodaten und Profil“: Der Reiter „Profil“ zeigt den echten `ProfileScreen`. Profiländerungen werden gespeichert (Abnahmekriterium 2); das bestätigte Zurücksetzen stellt den dokumentierten Ausgangszustand wieder her (Kriterium 9).

## Dateien
- `scripts/main.gd` – Einbau
- `tests/test_main.gd` – Tests anhängen (bestehende nicht ändern)

## Akzeptanzkriterien
- `_make_screen("profil")` liefert `ProfileScreen.new(state)`; dessen `changed` → `save` und `perspective.set_state(state)` (der Name in der Leiste ändert sich mit); dessen `reset_requested` → `reset_demo`.
- `func reset_demo() -> void`: `state = StateStore.reset(store_path)`, `perspective.set_state(state)`, `show_screen("entdecken")`.
- Alles Übrige aus T-0332 bleibt unverändert (Entdecken, Perspektivwechsel, `use_store`).

## Tests
`tests/test_main.gd` anhängen; wie in T-0332 in jedem neuen Test zuerst `main.use_store(TEST_PATH)` und am Ende `DirAccess.remove_absolute(TEST_PATH)`:
- `test_profil_ist_echt`: `main.show_screen("profil")` → `main.screen is ProfileScreen`
- `test_profil_wird_gespeichert`: Profil-Reiter zeigen, `(main.screen as ProfileScreen).name_edit.text = "Alexa"`, `save_button.pressed.emit()` → `StateStore.load_state(TEST_PATH).profile("p01").name` „Alexa“; `main.perspective.picker.get_item_text(0)` beginnt mit „Du bist: Alexa“
- `test_zuruecksetzen`: als p01 `main.state.like("p02")`, `main.save()`; Profil-Reiter, `reset_button.pressed.emit()`, `dialog.ok_button.pressed.emit()` → `main.state.book.likes` leer, `main.current_screen` „entdecken“, `StateStore.load_state(TEST_PATH).book.likes` leer

Review (19.10.2026): gemergt, nachgebessert: Demo-Leiste zeigt den geänderten Namen jetzt auch ohne Neuladen; Test nutzt like("p02").
