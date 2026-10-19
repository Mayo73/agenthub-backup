---
id: T-0340
title: ChatScreen – Demochat zwischen den beiden Testpersonen eines Matches
project: sparring
priority: 3
after: T-0326, T-0328
---
## Ziel
Meilenstein „Demochat“: Nach dem Match tauschen die beiden Testpersonen lokal Nachrichten aus (Lastenheft „Demochat“, Abnahmekriterium 5). In einem beendeten Match lassen sich keine neuen Nachrichten schreiben (Kriterium 7). Ohne Nachrichten erscheint ein Leerzustand.

## Dateien
- `scripts/chat_screen.gd` – neu, Klasse `ChatScreen`
- `tests/test_chat_screen.gd` – neu

## Akzeptanzkriterien
`class_name ChatScreen`, `extends Control`:
- `signal changed` – nach dem Senden
- `signal back`
- `var state: AppState`, `var match_id := ""`
- `func _init(app_state: AppState, id: String) -> void`: im Code eine `VBoxContainer` (`PRESET_FULL_RECT`) mit:
  - Kopf: `HBoxContainer` mit `var back_button: Button` (`UiStyle.button("‹ Zurück")`), `var avatar: AvatarView` (Durchmesser 64) und `var title_label: Label` (Name und Sportart der anderen Person, `"Sam · MMA"`)
  - `var demo_hint: Label`: `"Demochat: Nachrichten bleiben auf diesem Gerät, es wird nichts verschickt."`, `UiStyle.SIZE_SMALL`, Farbe `UiStyle.DEMO`
  - `ScrollContainer` (`SIZE_EXPAND_FILL` senkrecht) mit `var messages_box: VBoxContainer`
  - `var empty_label: Label`: `"Noch keine Nachrichten. Schreib die erste!"`, Farbe `UiStyle.MUTED`
  - `var closed_label: Label`: `"Dieses Match ist beendet. Neue Nachrichten und Treffen sind nicht mehr möglich."`, Farbe `UiStyle.PASS`
  - Eingabe: `HBoxContainer` mit `var input: LineEdit` (`SIZE_EXPAND_FILL`, `max_length = ChatLog.MAX_LENGTH`, `placeholder_text = "Nachricht schreiben …"`) und `var send_button: Button` (`UiStyle.button("Senden", UiStyle.ACCENT)`)
  - danach `refresh()`
- `func other() -> SparProfile`: die andere Person des Matches
- `func refresh() -> void`: `messages_box` leeren und je Nachricht aus `state.chat.messages_for(match_id)` ein `Label` (`UiStyle.label`) anlegen: eigene (`from == state.active_id`) rechtsbündig (`horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT`) in Farbe `UiStyle.ACCENT`, fremde linksbündig in `UiStyle.TEXT`; Text der Nachricht. `empty_label.visible` = keine Nachrichten. `var writable := state.can_write(match_id)`: `input.editable` und `not send_button.disabled` gleich `writable`, `closed_label.visible = not writable`.
- `func send() -> bool`: `state.send_message(match_id, input.text)`; bei Erfolg `input.text = ""`, `refresh()`, `changed.emit()`, `true`; sonst `false`.
- `send_button.pressed` → `send`; `input.text_submitted` → `send`; `back_button.pressed` → `back.emit()`

## Tests
`tests/test_chat_screen.gd`: in `setup()` `state = AppState.demo()` und Match p01/p02 erzeugen (als p01 `like("p02")`, `switch_to("p02")`, `like("p01")`, `switch_to("p01")`); Bildschirm `ChatScreen.new(state, "m1")` an `(Engine.get_main_loop() as SceneTree).root` hängen; `teardown()` `screen.free()`.
- `test_kopf`: `title_label.text` „Sam · MMA“, `empty_label.visible` wahr, `closed_label.visible` falsch
- `test_senden`: `input.text = "Hallo Sam"`, `send_button.pressed.emit()` → `state.chat.count_for("m1")` 1, `input.text` „“, `messages_box.get_child_count()` 1, `empty_label.visible` falsch, `changed` einmal ausgelöst
- `test_leer_nicht_senden`: `input.text = "  "`, `send()` falsch, keine Nachricht
- `test_eigene_rechts`: als p01 eine Nachricht senden, dann `state.switch_to("p02")`, `refresh()` → das Label hat `horizontal_alignment` LEFT; zurück zu p01, `refresh()` → RIGHT
- `test_beendet`: `state.end_match("m1")`, `refresh()` → `closed_label.visible` wahr, `send_button.disabled` wahr, `input.editable` falsch; `input.text = "x"`, `send()` falsch
- `test_zurueck`: Signal `back` mit Zähler, `back_button.pressed.emit()` → 1

Review (18.10.2026): nach 5 Versuchen fehlgeschlagen; mit genaueren Hinweisen neu eingeplant als T-0369.
