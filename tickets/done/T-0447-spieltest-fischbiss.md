---
id: T-0447
title: Spieltest „fisch_biss“ – Ablauf des Bisses nachweisen
project: zellenphase
priority: 4
---
## Ziel
Aus P-0011: Der rote Rand beim Biss ist optisch abgenommen, aber Dauer (0,4 s), Verblassen und Vorrang der Meldung (2 Sekunden) ließen sich am Einzelbild nicht prüfen. Ein Spieltest misst das und macht Bilder vorher, beim Biss und danach.

## Dateien
- `playtests/fisch_biss.gd` – neu (Vorlage `playtests/fisch_jagd.gd` und `scripts/fish_hud.gd` lesen)

## Akzeptanzkriterien
- `scene_path = "res://scenes/fish.tscn"`, `describe()` „Fischphase: Biss zeigt kurz einen roten Rand und eine vorrangige Meldung“
- Ablauf: `scene.intro.close()`, `scene.hud.clear_message()`, `await wait(0.2)`, `shot("vorher")`; `measure("rand_vorher", scene.hud.flash_rect.color.a)` (bzw. die Eigenschaft, die `flash()` setzt; vorher lesen); dann `scene.hud.flash()` und `scene.hud.show_message(FishHud.BITE_MESSAGE, 4.0, 1)` (Priorität wie in `fish_main.gd` beim Biss; dort nachsehen); `await wait(0.05)`, `shot("biss")`, Randstärke messen und prüfen, dass sie über 0.5 liegt; `scene.hud.show_message("Silberling gefressen!")` (gewöhnliche Meldung) → prüfen, dass `scene.hud.message_label.text` noch die Bissmeldung ist; `await wait(0.5)` → Randstärke messen, prüfen, dass sie 0 ist (Rand nach 0,4 s verblasst), `shot("danach")`; `await wait(2.0)`, eine gewöhnliche Meldung zeigen → jetzt ersetzt sie die Bissmeldung

Review (20.10.2026): gemergt, nachgebessert: Schwelle des Randes an den Höchstwert 0,35 angepasst, doppelte Bissmeldung mit 4 s entfernt (Spieltest schlug fehl).
