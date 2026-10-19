---
id: T-0342
title: Reiter „Matches“ und Chat in der App
project: sparring
priority: 3
after: T-0336, T-0368, T-0341
---
## Ziel
Meilenstein „Demochat“: Der Reiter „Matches“ zeigt den echten `MatchesScreen`; ein Tippen auf ein Match öffnet den `ChatScreen`, „Zurück“ führt zur Liste. Jede Änderung wird gespeichert (Abnahmekriterien 3, 5, 7, 9).

## Dateien
- `scripts/main.gd` – Einbau
- `tests/test_main.gd` – Tests anhängen (bestehende nicht ändern)

## Akzeptanzkriterien
- `_make_screen("matches")` liefert `MatchesScreen.new(state)`; `open_chat` → `show_chat`.
- `func show_chat(match_id: String) -> void`: wie `show_screen`, aber mit `ChatScreen.new(state, match_id)`; `current_screen = "chat"`; der Reiter „Matches“ bleibt als aktiv markiert (`disabled`), die anderen nicht. `changed` → `save`, `back` → `show_screen("matches")`. Merkt sich `var chat_id := match_id`.
- `_on_switched`: Ist gerade `"chat"` offen, nach dem Wechsel `show_screen("matches")` statt den Chat neu zu bauen (die neue Person ist vielleicht nicht beteiligt).
- `DiscoverScreen.matched` → nichts weiter (Hinweis zeigt der Bildschirm selbst).

## Tests
`tests/test_main.gd` anhängen; in jedem neuen Test zuerst `main.use_store(TEST_PATH)`, am Ende `DirAccess.remove_absolute(TEST_PATH)`. Match p01/p02 über `main.state` erzeugen (als p01 `like("p02")`, `switch_to("p02")`, `like("p01")`, `switch_to("p01")`), dann `main.save()`.
- `test_matches_ist_echt`: `main.show_screen("matches")` → `main.screen is MatchesScreen`, `rows.size()` 1
- `test_chat_oeffnen_und_zurueck`: Matches zeigen, `(main.screen as MatchesScreen).rows["m1"].pressed.emit()` → `main.screen is ChatScreen`, `main.current_screen` „chat“; `back_button.pressed.emit()` → `main.screen is MatchesScreen`
- `test_nachricht_gespeichert`: Chat „m1“ öffnen (`main.show_chat("m1")`), `input.text = "Hallo"`, `send_button.pressed.emit()` → `StateStore.load_state(TEST_PATH).chat.count_for("m1")` 1
- `test_wechsel_im_chat`: `main.show_chat("m1")`, `main._on_switched("p03")` → `main.current_screen` „matches“, `(main.screen as MatchesScreen).rows.size()` 0

Review (19.10.2026): selbst umgesetzt (Agent scheiterte fünfmal an Signal-Verbindung und erfundenen Eigenschaften), 4 Tests, Sparring 203 Tests grün.
