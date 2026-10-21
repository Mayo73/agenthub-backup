---
id: T-0500
title: Chat – „Treffen“ hervorheben, Beenden und Blockieren zurückhaltender
project: sparring
priority: 2
after: T-0484
---
## Ziel
Befund aus P-0014: Im Chatkopf dominieren „Match beenden“ und „Blockieren“ als große rote Knöpfe direkt nebeneinander. „Treffen“ ist die normale nächste Aktion und soll vorne und farbig stehen; die beiden anderen bleiben gut auffindbar, aber zurückhaltend (dunkle Fläche, rote Schrift), mit sichtbarem Abstand.

## Dateien
- `scripts/chat_screen.gd`
- `tests/test_chat_screen.gd` – Test ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- Die bisherige lokale Variable `action_hbox` wird zur Variable `var action_row: HBoxContainer` (vorher lesen; überall ersetzen) mit `add_theme_constant_override("separation", UiStyle.GAP)`.
- `meeting_button` ist das **erste** Kind von `action_row` (vor `end_button` und `block_button`), weiter `UiStyle.button("Treffen", UiStyle.ACCENT)`.
- `end_button` = `UiStyle.button("Match beenden", UiStyle.RAISED)` und `block_button` = `UiStyle.button("Blockieren", UiStyle.RAISED)`, jeweils danach `add_theme_color_override("font_color", UiStyle.PASS)`. Mindesthöhe 56 bleibt.
- Signale, Texte und das Sperren der Knöpfe bei beendeten Matches bleiben unverändert.

## Tests
`tests/test_chat_screen.gd`, `test_aktionen_gewichtet`: `screen.action_row.get_child(0) == screen.meeting_button`; `screen.action_row.get_theme_constant("separation") == UiStyle.GAP`; `screen.end_button.get_theme_color("font_color") == UiStyle.PASS`; `(screen.end_button.get_theme_stylebox("normal") as StyleBoxFlat).bg_color == UiStyle.RAISED`.

Review (20.10.2026): nicht gemergt, überholt durch den Neustart von Sparring als React-Native-App (Rückmeldung vom 20.10.2026). Branch als godot/T-0500 erhalten.
