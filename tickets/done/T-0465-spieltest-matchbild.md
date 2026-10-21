---
id: T-0465
title: Spieltest „matchbild“ – Match-Bildschirm und Weg in den Chat
project: sparring
priority: 2
after: T-0464
---
## Ziel
Auftrag „Modernes Design“ (M9): Ein Spieltest spielt ein Match wie ein Mensch durch: Interesse geben, „Match!“-Bildschirm erscheint, „Nachricht schreiben“ führt in den Chat. Die Bilder dienen später als Material zum Ansehen.

## Dateien
- `playtests/matchbild.gd` – neuer Spieltest (Vorlage: `playtests/wischen.gd`)

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"`, `describe()` liefert „Match-Bildschirm und Weg in den Chat“.
- Eigene Speicherdatei `const STORE := "user://spieltest_matchbild.json"`: am Anfang löschen, falls vorhanden, dann `scene.use_store(STORE)`; am Ende wieder löschen.
- Ablauf in `run()`:
  1. `scene.state.switch_to("p02")`, `scene.state.like("p01")`, `scene.state.switch_to("p01")`, `scene.show_screen("entdecken")`, `await wait(0.3)`.
  2. `(scene.screen as DiscoverScreen).like_button.pressed.emit()`, dann `await until(func() -> bool: return (scene.screen as DiscoverScreen).match_overlay.visible, 2.0, "Match-Bildschirm erscheint")`.
  3. `check(...)`, dass `match_overlay.text_label.text` „Sam“ enthält; `shot("match")`, danach `await wait(0.3)` (das Bild entsteht erst im nächsten Frame).
  4. `match_overlay.write_button.pressed.emit()`, `await wait(0.3)`, `check(scene.current_screen == "chat", "Nachricht schreiben öffnet den Chat")`; `shot("chat")`.
- Der Spieltest wird vom Review ausgeführt (`hub\tools\spieltest.ps1 -Projekt sparring -Test matchbild`); `verify.cmd` muss trotzdem grün bleiben (das Skript muss fehlerfrei laden).

## Tests
Keine Unit-Tests; der Spieltest selbst ist die Prüfung.

Review (20.10.2026): gemergt.
