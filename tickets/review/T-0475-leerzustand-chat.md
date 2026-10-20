---
id: T-0475
title: Leerzustand im Chat mit Symbol
project: sparring
priority: 2
after: T-0469, T-0473
---
## Ziel
Auftrag „Modernes Design“ (M9): Ein Chat ohne Nachrichten zeigt eine große Sprechblase über „Noch keine Nachrichten. Schreib die erste!“.

## Dateien
- `scripts/chat_screen.gd`
- `tests/test_chat_screen.gd` – Test ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- Neue Variable `var empty_icon: Label` = `UiStyle.empty_icon("💬")`, direkt vor `empty_label` in `layout` eingefügt.
- `empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER`.
- In `refresh()` wird `empty_icon.visible` an denselben Stellen und auf denselben Wert gesetzt wie `empty_label.visible`.

## Tests
- `test_leer_mit_symbol`: Chat eines frischen Matches ohne Nachrichten (aufbauen wie in den bestehenden Tests der Datei) → `empty_icon.visible` wahr; nach dem Senden einer Nachricht (wie in `test_senden`) → `empty_icon.visible` falsch.
