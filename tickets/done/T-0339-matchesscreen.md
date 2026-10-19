---
id: T-0339
title: MatchesScreen – Liste der Matches der aktiven Testperson
project: sparring
priority: 3
after: T-0326, T-0328
---
## Ziel
Meilenstein „Swipe und Match“: Der Reiter „Matches“ listet alle Matches der aktiven Testperson mit Avatar, Name, Kampfsportart und letzter Nachricht. Beendete Matches bleiben sichtbar und sind als beendet markiert (Abnahmekriterium 7). Ohne Matches erscheint ein Leerzustand (Lastenheft „Soll“). Ein Tippen öffnet den Chat (Einbau in T-0342).

## Dateien
- `scripts/matches_screen.gd` – neu, Klasse `MatchesScreen`
- `tests/test_matches_screen.gd` – neu

## Akzeptanzkriterien
`class_name MatchesScreen`, `extends Control`:
- `signal open_chat(match_id: String)`
- `var state: AppState`
- `var rows: Dictionary = {}` – Match-ID → `Button` der Zeile
- `func _init(app_state: AppState) -> void`: im Code eine `ScrollContainer` (`PRESET_FULL_RECT`) mit `var list: VBoxContainer` (Breite `SIZE_EXPAND_FILL`) und `var empty_label: Label` mit Text `"Noch keine Matches. Bekunde unter „Entdecken“ Interesse – ein Match entsteht, wenn es beide wollen."`; dann `refresh()`.
- `static func row_text(state: AppState, m: Dictionary) -> String`: Name und Sportart der anderen Person (`MatchBook.other(m, state.active_id)`), Zeilenumbruch, dann
  - bei beendetem Match: `"Match beendet"`
  - sonst die letzte Nachricht `"Du: <Text>"` bzw. `"<Name>: <Text>"`, Text auf 40 Zeichen gekürzt (bei Kürzung „…“ anhängen)
  - ohne Nachrichten: `"Noch keine Nachrichten"`
  Beispiel: `"Sam · MMA\nNoch keine Nachrichten"`
- `func refresh() -> void`: Liste leeren (`free()` der alten Kinder), für jedes Match aus `state.my_matches()` eine Zeile: `HBoxContainer` mit `AvatarView` (Durchmesser 72, Profil der anderen Person) und einem `Button` (`UiStyle.button(row_text(...))`, `SIZE_EXPAND_FILL`, linksbündig über `alignment = HORIZONTAL_ALIGNMENT_LEFT`); beendete Zeilen mit `modulate = Color(1, 1, 1, 0.6)`. `button.pressed` → `open_chat.emit(<Match-ID>)`. `rows` neu füllen. `empty_label.visible` genau dann, wenn es keine Matches gibt.

## Tests
`tests/test_matches_screen.gd`: in `setup()` `state = AppState.demo()`; Hilfsfunktion `func make_match(a: String, b: String) -> String` (als `a` liken, `switch_to(b)`, `like(a)` zurückgeben, dann `switch_to(a)`); Bildschirm erst im Test bauen, an `(Engine.get_main_loop() as SceneTree).root` hängen, am Ende `free()`.
- `test_leerzustand`: ohne Matches `empty_label.visible` wahr, `rows` leer
- `test_eine_zeile`: `make_match("p01","p02")` → als p01 `rows.size()` 1, Text der Zeile „Sam · MMA\nNoch keine Nachrichten“, `empty_label.visible` falsch
- `test_beide_seiten`: `make_match("p01","p02")`, `state.switch_to("p02")` → Zeile zeigt „Alex · Jiu-Jitsu“
- `test_letzte_nachricht`: Match, als p01 `send_message("m1", "Hallo Sam")` → `row_text` endet mit „Du: Hallo Sam“; als p02 endet er mit „Alex: Hallo Sam“
- `test_kuerzen`: Nachricht aus 50 „a“ → `row_text` endet mit 40 „a“ und „…“
- `test_beendet`: Match, `end_match("m1")` → Zeile sichtbar, Text endet mit „Match beendet“
- `test_tippen_oeffnet_chat`: Match, Signal `open_chat` merken, `rows["m1"].pressed.emit()` → empfangene ID „m1“

Review (18.10.2026): nach 5 Versuchen fehlgeschlagen; mit genaueren Hinweisen neu eingeplant als T-0368.
