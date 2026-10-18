---
id: T-0365
title: Spieltest „leerzustaende“ – keine Profile, Matches, Nachrichten, unvollständiges Treffen
project: sparring
priority: 3
after: T-0345
---
## Ziel
Meilenstein „Abnahme“ (Lastenheft, Soll: „Verständliche Leerzustände für keine weiteren Profile, keine Matches und keine Nachrichten sowie Hinweise bei unvollständigen Treffvorschlägen“): Ein Spieltest ruft alle Leerzustände auf, prüft die Hinweise und macht Bildschirmfotos. Der Hub führt Spieltests aus; die Agents schreiben sie nur.

## Dateien
- `playtests/leerzustaende.gd` – neu

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"` (in `_init()`), `describe()` liefert `"Leerzustände und Hinweis bei unvollständigem Treffvorschlag"`. Vorlage: `playtests/start.gd`.
- Eigene Datei `const STORE := "user://spieltest_leer.json"`: zu Beginn von `run()` löschen, falls vorhanden, dann `scene.use_store(STORE)`; am Ende löschen. Nie `user://sparring.json` anfassen.
- Ablauf, zwischen den Schritten `await wait(0.3)`:
  1. `scene.tab_buttons["matches"].pressed.emit()` → `check((scene.screen as MatchesScreen).empty_label.visible, "Hinweis: noch keine Matches")`; `shot("keine_matches")`
  2. Als Sam: `scene._on_switched("p02")`; `scene.state.like("p01")`; `scene._on_switched("p01")`; Entdecken-Reiter; `like_button` einmal (Match mit Sam), dann `pass_button` sechsmal → `check((scene.screen as DiscoverScreen).empty_label.visible, "Hinweis: keine weiteren Profile")`; `shot("keine_profile")`
  3. Matches-Reiter, `rows["m1"].pressed.emit()` → `check((scene.screen as ChatScreen).empty_label.visible, "Hinweis: noch keine Nachrichten")`; `shot("keine_nachrichten")`
  4. Im Chat `meeting_button.pressed.emit()` → `var ms := scene.screen as MeetingScreen`; `check(ms.status_label.text == "Noch kein Treffvorschlag.", "Hinweis: noch kein Treffvorschlag")`
  5. Nur `ms.place_edit.text = "Stadtpark"`, `ms.propose_button.pressed.emit()` → `check(ms.error_label.text.contains("Datum fehlt"), "Hinweis bei unvollständigem Vorschlag")`, `check(scene.state.meetings.get_meeting("m1").is_empty(), "Unvollständiger Vorschlag nicht gespeichert")`; `shot("treffen_unvollstaendig")`
- Keine Wartezeiten über 1 Sekunde.

## Tests
- Keine Unit-Tests; `verify.cmd` lädt die Datei mit und meldet Skriptfehler. Ausgeführt im Review (`hub\tools\spieltest.ps1 -Projekt sparring -Test leerzustaende`).
