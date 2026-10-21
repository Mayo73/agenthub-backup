---
id: T-0448
title: Spieltest „zeitstrahl“ – Taste T zeigt die Entwicklung
project: zellenphase
priority: 4
after: T-0430
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: Ein Spieltest prüft wie ein Spieler, dass Taste T den Zeitstrahl mit allen bisherigen Schritten zeigt, und liefert ein Bild davon.

## Dateien
- `playtests/zeitstrahl.gd` – neu (Vorlage `playtests/fressen_wachsen.gd` und `playtests/editor.gd` lesen)

## Akzeptanzkriterien
- `scene_path = "res://scenes/main.tscn"`, `describe()` „Zellenphase: Taste T zeigt den Entwicklungszeitstrahl“
- Ablauf: Partie starten wie in der Vorlage; die Zelle zweimal wachsen lassen (wie in `fressen_wachsen.gd`, oder `scene.eat_value(...)` so oft aufrufen, bis zwei neue Abschnitte erreicht sind); einmal den Editor öffnen und bestätigen; `await tap_key(KEY_T, false)`; `check(scene.timeline_view.visible, …)`; `check(scene.timeline_view.item_count() >= 4, "Start, zwei Größen und Editor")`; `shot("leiste")`; `await tap_key(KEY_T, false)`; `check(not scene.timeline_view.visible, …)`

Review (20.10.2026): gemergt, nachgebessert: Wachstum über eat_value, Editor über den Partner geöffnet und bestätigt (Spieltest schlug fehl).
