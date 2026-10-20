---
id: T-0474
title: Leerzustand der Matchliste mit Symbol
project: sparring
priority: 2
after: T-0468, T-0473
---
## Ziel
Auftrag „Modernes Design“ (M9): Ohne Matches zeigt die Matchliste ein großes Herz über dem Hinweistext.

## Dateien
- `scripts/matches_screen.gd`
- `tests/test_matches_screen.gd` – Test ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- Neue Variable `var empty_icon: Label` = `UiStyle.empty_icon("♥")`, in `box` direkt vor `empty_label` (also nach `title_label`).
- Am Ende von `refresh()`: `empty_icon.visible = matches.is_empty()` (wie `empty_label`).
- `empty_label.text` bleibt genau gleich.

## Tests
- `test_leer_mit_symbol`: mit `AppState.demo()` ohne Match → `empty_icon.visible` wahr und `empty_icon.text` „♥“; nach `make_match("p01", "p02")` und `screen.refresh()` → `empty_icon.visible` falsch.
