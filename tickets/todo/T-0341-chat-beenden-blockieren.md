---
id: T-0341
title: Im Chat Match beenden oder Testperson blockieren, jeweils mit Rückfrage
project: sparring
priority: 3
after: T-0333, T-0340
---
## Ziel
Meilenstein „Demochat“ (Lastenheft „Freiwilligkeit“ und „Soll: Blockieren“): Im Chat kann die aktive Testperson das Match beenden oder die andere Person blockieren. Beides fragt vorher nach. Danach sind keine neuen Nachrichten oder Treffanfragen möglich (Abnahmekriterium 7).

## Dateien
- `scripts/chat_screen.gd` – Knöpfe und Dialog ergänzen
- `tests/test_chat_screen.gd` – Tests anhängen (bestehende nicht ändern)

## Akzeptanzkriterien
- Neue Variablen: `var end_button: Button` (`UiStyle.button("Match beenden", UiStyle.PASS)`), `var block_button: Button` (`UiStyle.button("Blockieren", UiStyle.PASS)`) in einer eigenen `HBoxContainer` direkt unter dem Kopf; `var dialog: ConfirmDialog` als letztes Kind direkt am Bildschirm.
- `var pending := ""` – welche Aktion der Dialog bestätigt („beenden“ oder „blockieren“)
- `end_button.pressed` → `pending = "beenden"`, `dialog.ask("Match mit %s beenden? Danach sind keine Nachrichten und Treffen mehr möglich." % other().name, "Beenden")`
- `block_button.pressed` → `pending = "blockieren"`, `dialog.ask("%s blockieren? Ihr seht euch danach nicht mehr unter „Entdecken“." % other().name, "Blockieren")`
- `dialog.confirmed` → bei „beenden“ `state.end_match(match_id)`, bei „blockieren“ `state.block(other().id)`; dann `pending = ""`, `refresh()`, `changed.emit()`
- `dialog.cancelled` → `pending = ""`
- `refresh()`: `end_button.disabled` und `block_button.disabled`, wenn `not state.can_write(match_id)`
- Ist das Match beendet, zeigt `closed_label` zusätzlich, wer es beendet hat: `"Beendet von %s. …"` mit dem Namen aus `ended_by` (der restliche Text wie bisher), bei der aktiven Person „Beendet von dir. …“

## Tests
`tests/test_chat_screen.gd` anhängen (gleiches `setup()`, Match „m1“ zwischen p01 und p02):
- `test_beenden_fragt`: `end_button.pressed.emit()` → `dialog.visible` wahr, Match noch aktiv
- `test_beenden`: `end_button.pressed.emit()`, `dialog.ok_button.pressed.emit()` → `state.book.is_active("m1")` falsch, `closed_label.visible` wahr, Text beginnt mit „Beendet von dir.“, `end_button.disabled` wahr
- `test_beenden_andere_seite`: beenden wie oben, `state.switch_to("p02")`, neuen `ChatScreen` für „m1“ bauen → `closed_label.text` beginnt mit „Beendet von Alex.“ (danach freigeben)
- `test_abbrechen`: `end_button.pressed.emit()`, `dialog.cancel_button.pressed.emit()` → Match weiter aktiv
- `test_blockieren`: `block_button.pressed.emit()`, `dialog.ok_button.pressed.emit()` → `state.book.is_blocked("p01","p02")` wahr, `state.can_write("m1")` falsch; `changed` ausgelöst
