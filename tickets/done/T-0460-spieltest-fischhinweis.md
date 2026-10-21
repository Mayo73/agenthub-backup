---
id: T-0460
title: Spieltest „fischhinweis“ – HUD und Editor zeigen den Weg zum Fisch
project: zellenphase
priority: 4
after: T-0438
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Ein Spieltest prüft wie ein Spieler, dass das HUD im letzten Größenabschnitt den Fortschritt der Teile zeigt und der Editor-Knopf „Zum Fisch entwickeln“ erst mit 6 Teilen frei wird.

## Dateien
- `playtests/fischhinweis.gd` – neuer Spieltest

## Akzeptanzkriterien
Vorher `playtests/_zelle.gd` (`start_game`), `playtests/editor.gd` (Editor über den Partner öffnen) und `scripts/fish_readiness.gd` lesen. Der Spieltest wird nicht von `verify.cmd` ausgeführt, sondern im Review.
- `extends "res://playtests/_zelle.gd"`, `describe()` liefert „Hinweis auf den Fisch im HUD und gesperrter Knopf im Editor“
- `await start_game()`; `check` `scene.hud.fish_label.visible` falsch
- letzten Abschnitt herstellen (`scene.progress.stage = CellProgress.STAGE_COUNT - 1`) und die ersten 5 Teile aus `PartCatalog.UNLOCK_ORDER` mit `scene.unlocks.unlock(...)` freischalten, `await wait(0.3)` → `check` `scene.hud.fish_label` sichtbar mit „Teile 5/8 – ab 6 kannst du im Editor zum Fisch werden“, `shot("hud_5")`
- Editor öffnen wie in `playtests/editor.gd` (Ladung geben, `rufen`, zum Partner steuern, auf `scene.editor_open` warten) → `check` `scene.editor.evolve_button.disabled` und `scene.editor.evolve_hint.text` „Noch 1 Teil finden“, `shot("editor_gesperrt")`, Editor mit `scene.editor.cancel()` schließen
- 6. Teil freischalten, `await wait(0.3)` → `check` HUD zeigt „Bereit: Im Editor kannst du zum Fisch werden“; Editor erneut öffnen → `check` Knopf nicht gesperrt, `shot("editor_frei")`, `cancel()`

Review (20.10.2026): gemergt.
