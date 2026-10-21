---
id: T-0481
title: Spieltest „design_leer“ – Leerzustände und Dialog
project: sparring
priority: 2
after: T-0473, T-0474, T-0475, T-0476, T-0477, T-0478, T-0480
---
## Ziel
Auftrag „Modernes Design“ (M9): Material für die Sichtprüfung der Leerzustände, des Rückfrage-Dialogs und der Perspektivleiste.

## Dateien
- `playtests/design_leer.gd` – neu (Vorlagen: `playtests/leerzustaende.gd`, `playtests/zuruecksetzen.gd`, `playtests/karten.gd` lesen)

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"`, `describe()` „Leerzustände und Dialog im neuen Stil“, eigene Speicherdatei `user://spieltest_design_leer.json` (am Anfang und Ende löschen wie in `karten.gd`, `scene.use_store(...)`).
- Ablauf, nach jedem Schritt `await wait(0.3)`:
  1. Reiter Matches öffnen; ist `(scene.screen as MatchesScreen).empty_label.visible`, dann `check((scene.screen as MatchesScreen).empty_icon.visible, "Symbol bei leerer Matchliste")` und `shot("matches_leer")`.
  2. Reiter Entdecken öffnen, alle Kandidaten mit `(scene.screen as DiscoverScreen).decide_pass()` überspringen, bis `current()` null ist (höchstens 20 Mal); `check(... .empty_icon.visible, "Symbol bei leerem Entdecken")`, `shot("entdecken_leer")`.
  3. Reiter Profil öffnen, `reset_button.pressed.emit()`, `check(dialog.visible, "Dialog offen")`, `shot("dialog")`, dann `dialog.cancel_button.pressed.emit()`.

Review (20.10.2026): gemergt.
