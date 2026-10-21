---
id: T-0482
title: Spieltest „neue_matches“
project: sparring
priority: 2
after: T-0479, T-0480
---
## Ziel
Auftrag „Modernes Design“ (M9): Ein Spieltest prüft die Reihe „Neue Matches“ und die Zahl im Reiter wie ein Nutzer.

## Dateien
- `playtests/neue_matches.gd` – neu (Vorlage: `playtests/ablauf.gd` und `playtests/karten.gd` lesen)

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"`, `describe()` „Neue Matches oben und Zahl im Reiter“, eigene Speicherdatei `user://spieltest_neue_matches.json` (Anfang und Ende löschen, `scene.use_store(...)`).
- Ablauf (nach jedem Schritt `await wait(0.3)`): wie in `ablauf.gd` ein Match zwischen zwei Testpersonen herstellen, aber **ohne** Nachricht; danach `scene.tab_buttons["matches"].pressed.emit()` (verlässt einen ggf. offenen Match-Bildschirm oder Chat); `check(scene.screen is MatchesScreen, "Matches offen")`; `check(not (scene.screen as MatchesScreen).new_buttons.is_empty(), "Neues Match oben")`; `check(" · " in scene.tab_buttons["matches"].text, "Zahl im Reiter")`; `shot("neue_matches")`; den ersten Knopf aus `new_buttons` drücken, `check(scene.screen is ChatScreen, "Chat offen")`.

Review (20.10.2026): gemergt, nachgebessert: new_buttons ist ein Dictionary, Zugriff über values()[0] (Skriptfehler im Spieltest).
