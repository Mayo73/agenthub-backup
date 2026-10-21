---
id: T-0501
title: Chat – Leerzustand mit flachem Symbol, mittig im Nachrichtenbereich
project: sparring
priority: 2
after: T-0500
---
## Ziel
Befund aus P-0014: Das glänzende Sprechblasen-Emoji im leeren Chat passt nicht zu den flachen Symbolen der anderen Leerzustände (Herz, Stern), und Symbol und Hinweis sitzen ganz unten direkt über der Eingabe. Sie sollen flach sein und mittig im freien Nachrichtenbereich stehen.

## Dateien
- `scripts/chat_screen.gd`
- `tests/test_chat_screen.gd` – Test ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- `empty_icon = UiStyle.empty_icon("✉")` statt `"💬"`.
- Neue Variablen `var messages_scroll: ScrollContainer` (die bisherige lokale `scroll` mit `messages_box`, überall ersetzen) und `var empty_box: VBoxContainer`.
- `empty_box`: `alignment = BoxContainer.ALIGNMENT_CENTER`, `size_flags_vertical = Control.SIZE_EXPAND_FILL`, `separation` `UiStyle.GAP`; enthält `empty_icon` und `empty_label` (statt sie direkt in `layout` einzuhängen). `empty_box` steht in `layout` direkt nach `messages_scroll`.
- In `refresh()`: ohne Nachrichten `empty_box.visible = true` und `messages_scroll.visible = false`, mit Nachrichten umgekehrt. `empty_icon.visible` und `empty_label.visible` weiter wie bisher setzen (bestehende Tests prüfen sie).

## Tests
`tests/test_chat_screen.gd`, `test_leerzustand_mittig`: leerer Chat → `screen.empty_icon.text` „✉“, `screen.empty_icon.get_parent() == screen.empty_box`, `screen.empty_box.visible` wahr, `screen.messages_scroll.visible` falsch, `screen.empty_box.size_flags_vertical == Control.SIZE_EXPAND_FILL`; nach dem Senden einer Nachricht (wie in den anderen Tests) und `refresh()` → `empty_box.visible` falsch, `messages_scroll.visible` wahr.

Review (20.10.2026): nicht gemergt, überholt durch den Neustart von Sparring als React-Native-App (Rückmeldung vom 20.10.2026). Branch als godot/T-0501 erhalten.
