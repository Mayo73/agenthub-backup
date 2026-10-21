---
id: T-0472
title: Spieltest „design“ – alle Bildschirme im neuen Stil
project: sparring
priority: 2
after: T-0465, T-0467, T-0468, T-0469, T-0470, T-0471
---
## Ziel
Auftrag „Modernes Design“ (M9): Ein Spieltest öffnet nacheinander Matches, Chat, Treffen und Profil und macht je ein Bild. Er liefert das Material, mit dem das neue Design geprüft wird.

## Dateien
- `playtests/design.gd` – neu (Vorlage: `playtests/karten.gd` und `playtests/ablauf.gd` lesen)

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"`, `describe()` „Alle Bildschirme im neuen Stil“, eigene Speicherdatei `user://spieltest_design.json` (am Anfang und Ende löschen wie in `karten.gd`, `scene.use_store(...)`).
- Ablauf: Wie in `playtests/ablauf.gd` ein Match zwischen zwei Testpersonen herstellen und eine Nachricht senden; dann `scene.tab_buttons["matches"].pressed.emit()`, `check(scene.screen is MatchesScreen, "Matches offen")`, `shot("matches")`; Zeile des Matches drücken, `check(scene.screen is ChatScreen, "Chat offen")`, `shot("chat")`; `(scene.screen as ChatScreen).meeting_button.pressed.emit()`, `check(scene.screen is MeetingScreen, "Treffen offen")`, `shot("treffen")`; `scene.tab_buttons["profil"].pressed.emit()`, `check(scene.screen is ProfileScreen, "Profil offen")`, `shot("profil")`. Nach jedem Schritt `await wait(0.3)`.
Review (20.10.2026): gemergt.
