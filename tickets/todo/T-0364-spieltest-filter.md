---
id: T-0364
title: Spieltest „filter“ – Filter nach Sportart und Erfahrung
project: sparring
priority: 3
after: T-0338, T-0336
---
## Ziel
Meilenstein „Abnahme“ (Lastenheft, Soll: „Kampfsportart und Erfahrung als einfache Filter“, Leerzustand bei unpassendem Filter): Ein Spieltest setzt Filter im Entdecken-Bildschirm, prüft die gezeigten Profile und dass der Filter einen Neustart übersteht. Der Hub führt Spieltests aus; die Agents schreiben sie nur.

## Dateien
- `playtests/filter.gd` – neu

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"` (in `_init()`), `describe()` liefert `"Filter nach Sportart und Erfahrung, Leerzustand, Neustart"`. Vorlage: `playtests/start.gd`.
- Eigene Datei `const STORE := "user://spieltest_filter.json"`: zu Beginn von `run()` löschen, falls vorhanden, dann `scene.use_store(STORE)`; am Ende löschen. Nie `user://sparring.json` anfassen.
- Ablauf, zwischen den Schritten `await wait(0.3)`; `var d := scene.screen as DiscoverScreen` nach jedem Bildschirmwechsel neu holen:
  1. `d.set_filter(3, 0)` (Boxen) → `check(d.current().id == "p03", "Filter Boxen zeigt Mira")`; `shot("filter_boxen")`
  2. `d.set_filter(3, 1)` (Boxen, Einsteiger) → `check(d.empty_label.visible and d.empty_label.text.contains("Ändere den Filter"), "Leerzustand bei unpassendem Filter")`; `shot("filter_leer")`
  3. `d.set_filter(3, 0)`; Neustart: `await reload_scene()`, danach `scene.use_store(STORE)`; neu holen → `check(scene.state.filter.art == "Boxen", "Filter nach Neustart erhalten")`, `check(d.art_filter.selected == 3, "Auswahl zeigt den Filter")`
  4. `d.set_filter(0, 0)` → `check(d.current().id == "p02", "Ohne Filter wieder alle")`
- Keine Wartezeiten über 1 Sekunde.

## Tests
- Keine Unit-Tests; `verify.cmd` lädt die Datei mit und meldet Skriptfehler. Ausgeführt im Review (`hub\tools\spieltest.ps1 -Projekt sparring -Test filter`).
