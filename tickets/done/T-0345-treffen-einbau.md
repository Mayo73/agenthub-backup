---
id: T-0345
title: Treffen aus dem Chat öffnen, Stand des Treffens im Chat
project: sparring
priority: 3
after: T-0342, T-0344
---
## Ziel
Meilenstein „Treffen vereinbaren“: Im Chat führt ein Knopf „Treffen“ zum `MeetingScreen`; der Chat zeigt den Stand des Treffens in einer Zeile. Jede Änderung wird gespeichert (Abnahmekriterien 6 und 9).

## Dateien
- `scripts/chat_screen.gd` – Knopf und Statuszeile
- `scripts/main.gd` – `show_meeting`
- `tests/test_chat_screen.gd`, `tests/test_main.gd` – Tests anhängen (bestehende nicht ändern)

## Akzeptanzkriterien
- `scripts/chat_screen.gd`:
  - `signal open_meeting(match_id: String)`
  - `var meeting_button: Button` (`UiStyle.button("Treffen", UiStyle.ACCENT)`) in der Knopfzeile von T-0341, `pressed` → `open_meeting.emit(match_id)`
  - `var meeting_label: Label` unter der Knopfzeile, Text `MeetingStatus.text(state, match_id)`, Farbe `UiStyle.MUTED`; wird in `refresh()` aktualisiert
  - `meeting_button` bleibt auch bei beendetem Match benutzbar (dort lässt sich der Stand ansehen und absagen)
- `scripts/main.gd`:
  - `func show_meeting(match_id: String) -> void`: wie `show_chat`, aber `MeetingScreen.new(state, match_id)`, `current_screen = "treffen"`, Reiter „Matches“ aktiv markiert; `changed` → `save`, `back` → `show_chat(match_id)`
  - in `show_chat`: `open_meeting` → `show_meeting`
  - `_on_switched`: auch bei `"treffen"` nach dem Wechsel `show_screen("matches")`

## Tests
- `tests/test_chat_screen.gd` anhängen:
  - `test_treffen_knopf`: Signal `open_meeting` merken, `meeting_button.pressed.emit()` → ID „m1“
  - `test_treffen_status`: ohne Vorschlag `meeting_label.text` „Noch kein Treffvorschlag.“; als p01 gültig `state.propose_meeting(...)`, `refresh()` → „Wartet auf die Zustimmung von Sam.“
- `tests/test_main.gd` anhängen (wie in T-0342 mit `use_store(TEST_PATH)` und Match p01/p02):
  - `test_treffen_oeffnen`: `main.show_chat("m1")`, `(main.screen as ChatScreen).meeting_button.pressed.emit()` → `main.screen is MeetingScreen`, `current_screen` „treffen“; `back_button.pressed.emit()` → `main.screen is ChatScreen`
  - `test_treffen_gespeichert`: `main.show_meeting("m1")`, Felder füllen (Ort „Stadtpark“, „24.10.2026“, „10:30“, Form Index 1), `propose_button.pressed.emit()` → `StateStore.load_state(TEST_PATH).meetings.get_meeting("m1")["place"]` „Stadtpark“

Review (19.10.2026): selbst umgesetzt (Code des Agents übernommen, Test mit ungültiger Trainingsform korrigiert, Main-Tests ergänzt), Commit in main.
