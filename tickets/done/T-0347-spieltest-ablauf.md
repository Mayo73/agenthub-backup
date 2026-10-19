---
id: T-0347
title: Spieltest „ablauf“ – Profil, Swipe, Match, Chat, Treffen, Neustart
project: sparring
priority: 3
after: T-0345
---
## Ziel
Meilenstein „Abnahme“ (Abnahmekriterien 3, 5, 6, 8, 9): Ein Spieltest bedient die ganze App wie ein Nutzer – zwei Testpersonen matchen sich, schreiben, vereinbaren ein Treffen, und nach einem Neustart ist alles noch da. Er macht dabei Bildschirmfotos aller Bildschirme. Der Hub führt Spieltests aus; die Agents schreiben sie nur.

## Dateien
- `playtests/ablauf.gd` – neu

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"`, `describe()` liefert `"Kompletter Ablauf: Swipe, Match, Chat, Treffen, Neustart"`. Vorlage für den Aufbau: `playtests/start.gd`.
- Der Test benutzt **nur** die eigene Datei `const STORE := "user://spieltest_ablauf.json"`: zu Beginn `DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))` (falls vorhanden), dann `scene.use_store(STORE)`. Nie `user://sparring.json` anfassen.
- Ablauf in `run()` (zwischen den Schritten jeweils `await wait(0.3)`), alle Knöpfe per `pressed.emit()`:
  1. Entdecken als Alex (p01): `shot("entdecken")`; `(scene.screen as DiscoverScreen).swipe(Vector2(100, 600), Vector2(450, 610))` → `check(scene.state.book.likes.has("p01>p02"), "Wischen nach rechts bekundet Interesse")`; `check(scene.state.my_matches().is_empty(), "Einseitiges Interesse ergibt kein Match")`
  2. Wechsel zu Sam: `scene._on_switched("p02")`; im Entdecken-Bildschirm so oft `pass_button` drücken, bis `current().id == "p01"` (höchstens 8-mal), dann `like_button` → `check(not scene.state.my_matches().is_empty(), "Gegenseitiges Interesse ergibt ein Match")`; `check((scene.screen as DiscoverScreen).match_label.visible, "Match-Hinweis sichtbar")`; `shot("match")`
  3. Matches-Reiter: `scene.tab_buttons["matches"].pressed.emit()`, `shot("matches")`; die Zeile „m1“ antippen → `check(scene.screen is ChatScreen, "Chat öffnet sich")`; Nachricht „Hallo Alex, Lust auf Drills im Park?“ senden; `shot("chat")`
  4. Treffen: `meeting_button` → `MeetingScreen`; Ort „Stadtpark, Wiese am Teich“, Datum „24.10.2026“, Uhrzeit „10:30“, Form Index 1, Regeln „Tap = sofort Stopp“; `propose_button`; `shot("treffen")`
  5. Wechsel zu Alex (`scene._on_switched("p01")`), Matches → „m1“ → Treffen → `approve_button` → `check(scene.state.meeting_confirmed("m1"), "Treffen von beiden bestätigt")`; `shot("bestaetigt")`
  6. Neustart: `await reload_scene()`, danach `scene.use_store(STORE)` → `check(scene.state.book.matches.size() == 1, "Match nach Neustart erhalten")`, `check(scene.state.chat.count_for("m1") == 1, "Nachricht nach Neustart erhalten")`, `check(scene.state.meeting_confirmed("m1"), "Treffen nach Neustart bestätigt")`
  7. Aufräumen: Datei `STORE` löschen.
- Kein Netzwerk, keine Wartezeiten über 1 Sekunde.

## Tests
- Keine Unit-Tests; `verify.cmd` lädt die Datei mit und meldet Skriptfehler. Ausgeführt wird der Spieltest im Review (`hub\tools\spieltest.ps1 -Projekt sparring -Test ablauf`).

Review (19.10.2026): gemergt, nachgebessert: lud eine zweite Hauptszene, übersprang die Match-Prüfung still und griff auf einen freigegebenen Bildschirm zu.
