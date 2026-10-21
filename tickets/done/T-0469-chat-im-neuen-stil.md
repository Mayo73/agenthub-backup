---
id: T-0469
title: Chat mit Sprechblasen und rundem Zurück-Knopf
project: sparring
priority: 2
after: T-0466
---
## Ziel
Auftrag „Modernes Design“ (M9): Nachrichten erscheinen als Sprechblasen (eigene violett rechts, fremde dunkel links), das Eingabefeld ist abgerundet, der Kopf ruhiger.

## Dateien
- `scripts/chat_screen.gd`
- `tests/test_chat_screen.gd` – Tests ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- In `refresh()` entsteht jede Nachricht mit `UiStyle.bubble(msg["text"], msg["from"] == state.active_id)` statt `UiStyle.label(...)`. Es bleibt ein `Label` als direktes Kind von `messages_box` (die bestehenden Tests prüfen `horizontal_alignment`).
- `messages_box` hat `separation` 10 und `size_flags_horizontal = Control.SIZE_EXPAND_FILL`; die `ScrollContainer` hat `horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED`.
- `back_button` = `UiStyle.round_button("‹", UiStyle.TEXT, 64)` (Variable und Signal bleiben).
- `title_label` mit `UiStyle.SIZE_TITLE`, `size_flags_horizontal = Control.SIZE_EXPAND_FILL`; `header` hat `separation` `UiStyle.GAP`.
- `UiStyle.style_input(input)` nach dem Anlegen des Eingabefelds.
- `send_button` = `UiStyle.round_button("➤", UiStyle.ACCENT, 72)`.

## Tests
- `test_sprechblasen`: als p01 eine Nachricht in „m1“ senden, `refresh()` → `messages_box.get_child(0)` ist `Label` mit `(get_theme_stylebox("normal") as StyleBoxFlat).bg_color == UiStyle.ACCENT`; nach `state.switch_to("p02")` und `refresh()` ist `bg_color` `UiStyle.RAISED`.
- `test_runde_knoepfe`: `back_button.text` „‹“, `send_button.text` „➤“, `send_button.custom_minimum_size.x` 72.
Review (20.10.2026): gemergt.
