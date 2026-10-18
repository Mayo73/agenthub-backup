---
id: T-0338
title: Filter im Bildschirm „Entdecken“ mit passendem Leerzustand
project: sparring
priority: 3
after: T-0331, T-0337
---
## Ziel
Meilenstein „Swipe und Match“: Oben im Bildschirm „Entdecken“ lassen sich Kampfsportart und Erfahrung wählen (Lastenheft „Soll“). Findet der Filter niemanden mehr, erscheint ein eigener, verständlicher Leerzustand (Lastenheft „Soll“: Leerzustände).

## Dateien
- `scripts/discover_screen.gd` – Filterleiste einbauen
- `tests/test_discover_screen.gd` – Tests anhängen (bestehende nicht ändern)

## Akzeptanzkriterien
- Neue Variablen und Bedienelemente, als **erstes** Kind der vorhandenen `VBoxContainer` eine `HBoxContainer` mit:
  - `var art_filter: OptionButton` – Eintrag 0 „Alle Sportarten“, danach `DemoData.ARTS` in Reihenfolge; `SIZE_EXPAND_FILL`
  - `var level_filter: OptionButton` – Eintrag 0 „Jede Erfahrung“, danach `SparProfile.LEVELS`; `SIZE_EXPAND_FILL`
  - Auswahl beim Aufbau aus `state.filter` übernehmen
- `func set_filter(art_index: int, level_index: int) -> void`: `state.filter.art` = `""` bei Index 0, sonst `DemoData.ARTS[art_index - 1]`; `state.filter.level` = `level_index - 1`; beide `OptionButton` entsprechend `select(...)`; `match_label` unsichtbar; `changed.emit()`; `refresh()`.
- `art_filter.item_selected` und `level_filter.item_selected` rufen `set_filter(art_filter.selected, level_filter.selected)`.
- `refresh()`: Gibt es kein Profil mehr **und** ist `state.filter.is_active()`, lautet `empty_label.text` `"Keine Testprofile für „%s“. Ändere den Filter." % state.filter.describe()`; ohne aktiven Filter der bisherige Text aus T-0331.

## Tests
`tests/test_discover_screen.gd` anhängen (gleiches `setup()`):
- `test_filter_boxen`: `set_filter(3, 0)` (Index 3 = „Boxen“) → `current().id` „p03“; `state.filter.art` „Boxen“
- `test_filter_leer`: `set_filter(3, 1)` (Boxen, Einsteiger) → `empty_label.visible` wahr, Text enthält „Ändere den Filter“ und „Boxen · Einsteiger“
- `test_filter_aufheben`: `set_filter(3, 1)`, dann `set_filter(0, 0)` → `current().id` „p02“, `card.visible` wahr
- `test_filter_signal`: `changed` mit Zähler verbinden, `set_filter(2, 0)` → Zähler 1
- `test_filter_aus_zustand`: `state.filter.art = "MMA"`, neuen Bildschirm bauen → `art_filter.selected` 2 (danach freigeben)
