---
id: T-0363
title: Spieltest „blockieren“ – keine Kontaktmöglichkeit mehr
project: sparring
priority: 3
after: T-0342
---
## Ziel
Meilenstein „Abnahme“ (Lastenheft, Soll: „Blockieren einer Testperson ausprobieren können; danach erscheinen keine weiteren Kontaktmöglichkeiten zu dieser Person“): Ein Spieltest blockiert aus dem Chat heraus und prüft beide Perspektiven. Der Hub führt Spieltests aus; die Agents schreiben sie nur.

## Dateien
- `playtests/blockieren.gd` – neu

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"` (in `_init()`), `describe()` liefert `"Blockieren beendet jeden Kontakt, aus beiden Perspektiven"`. Vorlage: `playtests/start.gd`.
- Eigene Datei `const STORE := "user://spieltest_blockieren.json"`: zu Beginn von `run()` löschen, falls vorhanden, dann `scene.use_store(STORE)`; am Ende löschen. Nie `user://sparring.json` anfassen.
- Ablauf, zwischen den Schritten `await wait(0.3)`:
  1. Match p01/p02 direkt über den Zustand: `scene.state.like("p02")`, `scene.state.switch_to("p02")`, `scene.state.like("p01")`, dann `scene._on_switched("p01")` (speichert und baut neu auf)
  2. `scene.tab_buttons["matches"].pressed.emit()`; `(scene.screen as MatchesScreen).rows["m1"].pressed.emit()` → `var chat := scene.screen as ChatScreen`; `check(chat != null, "Chat geöffnet")`
  3. `chat.block_button.pressed.emit()`; `check(chat.dialog.visible, "Rückfrage vor dem Blockieren")`; `shot("rueckfrage")`; `chat.dialog.ok_button.pressed.emit()`
  4. `check(scene.state.book.is_blocked("p01", "p02"), "Sam ist blockiert")`, `check(chat.closed_label.visible, "Chat zeigt, dass kein Kontakt mehr möglich ist")`, `check(chat.send_button.disabled, "Senden gesperrt")`; `shot("blockiert")`
  5. `scene._on_switched("p02")`; Ids aus `scene.state.candidates()` sammeln → `check(not ids.has("p01"), "Alex erscheint bei Sam nicht mehr unter Entdecken")`; `check(not scene.state.can_write("m1"), "Sam kann Alex nicht mehr schreiben")`
  6. Als p02 `scene.tab_buttons["entdecken"].pressed.emit()`; `shot("entdecken_sam")`
- Keine Wartezeiten über 1 Sekunde.

## Tests
- Keine Unit-Tests; `verify.cmd` lädt die Datei mit und meldet Skriptfehler. Ausgeführt im Review (`hub\tools\spieltest.ps1 -Projekt sparring -Test blockieren`).
