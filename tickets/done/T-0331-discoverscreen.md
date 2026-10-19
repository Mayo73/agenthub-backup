---
id: T-0331
title: DiscoverScreen – Profile ansehen, wischen oder per Knopf entscheiden
project: sparring
priority: 3
after: T-0326, T-0329, T-0330
---
## Ziel
Meilenstein „Swipe und Match“: Der Bildschirm „Entdecken“ zeigt die nächste Testperson als Karte. Interesse oder Überspringen geht per Wischen und über zwei sichtbare Knöpfe; beides löst dasselbe aus (Abnahmekriterium 4). Entsteht ein Match, erscheint ein Hinweis. Gibt es keine Profile mehr, erscheint ein verständlicher Leerzustand.

## Dateien
- `scripts/discover_screen.gd` – neu, Klasse `DiscoverScreen`
- `tests/test_discover_screen.gd` – neu

## Akzeptanzkriterien
`class_name DiscoverScreen`, `extends Control`:
- `signal changed` – nach jeder Änderung am Zustand
- `signal matched(match_id: String)` – wenn ein Match entsteht
- `var state: AppState`, `var gesture := SwipeGesture.new()`
- `func _init(app_state: AppState) -> void`: merkt sich den Zustand und legt im Code an (in einer `VBoxContainer` mit `PRESET_FULL_RECT`):
  - `var card: ProfileCard` (wächst senkrecht: `size_flags_vertical = SIZE_EXPAND_FILL`)
  - `var empty_label: Label` – Text `"Keine weiteren Testprofile. Wechsle die Testperson oder setze die Demo im Profil zurück."`, zentriert
  - `var match_label: Label` – zunächst unsichtbar, Farbe `UiStyle.LIKE`
  - eine `HBoxContainer` mit `var pass_button: Button` (`UiStyle.button("✕ Überspringen", UiStyle.PASS)`) und `var like_button: Button` (`UiStyle.button("♥ Interesse", UiStyle.LIKE)`), beide `SIZE_EXPAND_FILL`
- `func current() -> SparProfile`: erstes Profil aus `state.candidates()` oder `null`
- `func refresh() -> void`: zeigt `current()` in der Karte; ohne Profil: Karte unsichtbar, `empty_label` sichtbar, beide Knöpfe `disabled`. Mit Profil umgekehrt.
- `func decide_like() -> void`: ohne aktuelles Profil nichts tun; sonst `var id := state.like(current().id)`; ist `id` nicht leer: `match_label.text = "Match mit %s! Ihr könnt jetzt schreiben." % name`, sichtbar machen, `matched.emit(id)`; sonst `match_label` unsichtbar. Danach `changed.emit()` und `refresh()`.
- `func decide_pass() -> void`: `state.pass_on(current().id)`, `match_label` unsichtbar, `changed.emit()`, `refresh()`.
- Knöpfe: `like_button.pressed` → `decide_like`, `pass_button.pressed` → `decide_pass`.
- Wischen: `card.gui_input` verbinden. `InputEventScreenTouch` gedrückt → `gesture.begin(event.position)`, losgelassen → `gesture.finish()` auswerten (`LIKE` → `decide_like()`, `PASS` → `decide_pass()`); `InputEventScreenDrag` → `gesture.move(event.position)`. Während des Wischens Karte verschieben (`card.position.x` um `gesture.offset.x`) und neigen (`card.rotation = gesture.tilt()`), beim Loslassen zurücksetzen. (Maus funktioniert über `emulate_touch_from_mouse` automatisch.)
- Zusätzlich `func swipe(from: Vector2, to: Vector2) -> void` für Tests: `gesture.begin(from)`, `gesture.move(to)`, Ergebnis von `gesture.finish()` wie oben auswerten.
- `refresh()` am Ende von `_init()`.

## Tests
`tests/test_discover_screen.gd`: in `setup()` `state = AppState.demo()`, `screen = DiscoverScreen.new(state)`, an `(Engine.get_main_loop() as SceneTree).root` hängen; `teardown()` `screen.free()`.
- `test_erstes_profil`: `current().id` „p02“ (p01 ist die aktive Person), `card.visible` wahr
- `test_knopf_interesse`: `like_button.pressed.emit()` → `state.book.likes` enthält `"p01>p02"`, `current().id` „p03“
- `test_knopf_ueberspringen`: `pass_button.pressed.emit()` → `state.book.passes` enthält `"p01>p02"`
- `test_wischen_wie_knopf`: `swipe(Vector2(100, 600), Vector2(400, 610))` → `likes` enthält `"p01>p02"`; `swipe(Vector2(400, 600), Vector2(100, 600))` → `passes` enthält `"p01>p03"`; kurzes `swipe(Vector2(100,600), Vector2(150,600))` ändert nichts (`current().id` bleibt „p04“)
- `test_match_hinweis` (Kriterium 4, Jiu-Jitsu p01 und MMA p02): vorher `state.switch_to("p02")`, `state.like("p01")`, `state.switch_to("p01")`, neuen Bildschirm bauen; Signal `matched` mit Zähler verbinden; `like_button.pressed.emit()` → `match_label.visible` wahr, Text enthält „Sam“, Signal einmal ausgelöst
- `test_leerzustand`: siebenmal `pass_button.pressed.emit()` → `empty_label.visible` wahr, `card.visible` falsch, `like_button.disabled` wahr
- `test_signal_changed`: `changed` mit Zähler verbinden, einmal Interesse, einmal Überspringen → Zähler 2

Review (18.10.2026): gemergt, nachgebessert: run_tests.sh entfernt.
