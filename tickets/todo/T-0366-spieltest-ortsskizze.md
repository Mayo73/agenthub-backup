---
id: T-0366
title: Spieltest „ortsskizze“ – Skizze folgt dem Ort im Treffvorschlag
project: sparring
priority: 3
after: T-0359
---
## Ziel
Meilenstein „Ortsskizze“: Ein Spieltest öffnet den Treffen-Bildschirm, tippt verschiedene Orte ein und prüft, dass die schematische Skizze mitwechselt. Die Bildschirmfotos dienen der Sichtprüfung. Der Hub führt Spieltests aus; die Agents schreiben sie nur.

## Dateien
- `playtests/ortsskizze.gd` – neu

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"` (in `_init()`), `describe()` liefert `"Ortsskizze im Treffvorschlag"`. Vorlage: `playtests/start.gd`.
- Eigene Datei `const STORE := "user://spieltest_ortsskizze.json"`: zu Beginn von `run()` löschen, falls vorhanden, dann `scene.use_store(STORE)`; am Ende löschen. Nie `user://sparring.json` anfassen.
- Ablauf, zwischen den Schritten `await wait(0.3)`:
  1. Match p01/p02 über den Zustand (`like("p02")`, `switch_to("p02")`, `like("p01")`), dann `scene._on_switched("p01")`
  2. Matches-Reiter, `rows["m1"]` antippen, im Chat `meeting_button` → `var ms := scene.screen as MeetingScreen`
  3. `check(ms.place_view.kind == "Draußen", "Ohne Ort neutrale Skizze")`; `check(ms.days_label.text != "", "Gemeinsame Tage angezeigt")`
  4. Für jedes Paar aus `[["Stadtpark, Wiese am Teich", "Park"], ["Strand am Badesee", "Strand"], ["Sportplatz an der Schule", "Sportplatz"], ["Waldweg am Hügel", "Wald"]]`: `ms.place_edit.text = ort`, `ms.place_edit.text_changed.emit(ort)`, `await wait(0.2)`, `check(ms.place_view.kind == art, "Skizze %s" % art)`, `shot("skizze_" + art.to_lower())`
- Keine Wartezeiten über 1 Sekunde.

## Tests
- Keine Unit-Tests; `verify.cmd` lädt die Datei mit und meldet Skriptfehler. Ausgeführt im Review (`hub\tools\spieltest.ps1 -Projekt sparring -Test ortsskizze`).
