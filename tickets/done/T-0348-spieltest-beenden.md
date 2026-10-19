---
id: T-0348
title: Spieltest „beenden“ – unbeteiligte Person, Absage und Beenden aus beiden Perspektiven
project: sparring
priority: 3
after: T-0345
---
## Ziel
Meilenstein „Abnahme“ (Abnahmekriterien 5 und 7): Ein Spieltest prüft wie ein Nutzer, dass eine unbeteiligte Testperson den Chat zweier anderer nicht sieht, dass eine Absage und das Beenden eines Matches aus beiden Perspektiven sichtbar sind und dass danach keine Nachrichten oder Treffvorschläge mehr gehen. Der Hub führt Spieltests aus; die Agents schreiben sie nur.

## Dateien
- `playtests/beenden.gd` – neu

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"`, `describe()` liefert `"Unbeteiligte, Absage und Beenden aus beiden Perspektiven"`. Vorlage für den Aufbau: `playtests/start.gd`.
- Der Test benutzt **nur** die eigene Datei `const STORE := "user://spieltest_beenden.json"`: zu Beginn `DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))` (falls vorhanden), dann `scene.use_store(STORE)`. Nie `user://sparring.json` anfassen.
- Ablauf in `run()` (zwischen den Schritten jeweils `await wait(0.3)`), Knöpfe per `pressed.emit()`:
  1. Match vorbereiten: als p01 `scene.state.like("p02")`, `scene._on_switched("p02")`, `scene.state.like("p01")`, `scene.save()`. `check(scene.state.book.is_active("m1"), "Match m1 besteht")`
  2. Als Sam (p02): `scene.show_chat("m1")`, `input.text = "Hallo Alex"`, `send_button` → `check(scene.state.chat.count_for("m1") == 1, "Nachricht gesendet")`
  3. Unbeteiligt: `scene._on_switched("p03")`, `scene.show_screen("matches")` → `check(scene.state.my_matches().is_empty(), "Mira hat kein Match")`; `check((scene.screen as MatchesScreen).empty_label.visible, "Mira sieht den Leerzustand statt des Chats")`; `shot("unbeteiligt")`
  4. Treffen: `scene._on_switched("p01")`, `scene.show_meeting("m1")`, Felder füllen (Ort „Stadtpark, Wiese am Teich“, Datum „24.10.2026“, Uhrzeit „10:30“, Form Index 1), `propose_button`; dann `scene._on_switched("p02")`, `scene.show_meeting("m1")`, `cancel_button` → `check((scene.screen as MeetingScreen).status_label.text.begins_with("Abgesagt von dir"), "Sam sieht die eigene Absage")`
  5. Absage aus der anderen Perspektive: `scene._on_switched("p01")`, `scene.show_meeting("m1")` → `check((scene.screen as MeetingScreen).status_label.text.begins_with("Abgesagt von Sam"), "Alex sieht die Absage von Sam")`; `shot("absage")`
  6. Beenden: `scene.show_chat("m1")`, `end_button`, `dialog.ok_button` → `check(not scene.state.book.is_active("m1"), "Match beendet")`
  7. Andere Perspektive: `scene._on_switched("p02")`, `scene.show_chat("m1")` → `check((scene.screen as ChatScreen).closed_label.text.begins_with("Beendet von Alex"), "Sam sieht, dass Alex beendet hat")`; `check((scene.screen as ChatScreen).send_button.disabled, "Senden gesperrt")`; `check(not scene.state.send_message("m1", "Noch da?"), "keine neue Nachricht möglich")`; `check(not scene.state.propose_meeting("m1", {"place": "Park", "date": "25.10.2026", "time": "11:00", "form": "Drills"}).is_empty(), "kein neuer Treffvorschlag möglich")`; `shot("beendet")`
  8. Aufräumen: Datei `STORE` löschen.
- Kein Netzwerk, keine Wartezeiten über 1 Sekunde.

## Tests
- Keine Unit-Tests; `verify.cmd` lädt die Datei mit und meldet Skriptfehler. Ausgeführt wird der Spieltest im Review (`hub\tools\spieltest.ps1 -Projekt sparring -Test beenden`).

Review (19.10.2026): gemergt, nachgebessert: nie gesetzte Variable state und nicht existierende Felder von Main (input, send_button, end_button, dialog) ersetzt.
