---
id: T-0449
title: Spieltest „fisch_menue_aktiv“ – Entwicklungsmenü mit bezahlbaren Knöpfen
project: zellenphase
priority: 4
---
## Ziel
Aus P-0011: Das Entwicklungsmenü wurde nur mit grauen Knöpfen (DNA 0) angesehen; Klickverhalten und Aussehen eines bezahlbaren Knopfs fehlen. Der Spieltest bedient das Menü mit genug DNA und macht Bilder.

## Dateien
- `playtests/fisch_menue_aktiv.gd` – neu (Vorlage `playtests/fisch_entwicklung.gd`, `scripts/evolve_menu.gd` lesen)

## Akzeptanzkriterien
- `scene_path = "res://scenes/fish.tscn"`, `describe()` „Fischphase: bezahlbare Verbesserungen sind aktiv und wirken“
- Ablauf: `scene.intro.close()`; `scene.progress.dna = 40`; `await tap("entwickeln")`; prüfen, dass `scene.evolve.buttons["schwanz"].disabled` falsch ist; `shot("bezahlbar")`; Knopf „schwanz“ drücken → `scene.player.build.level("schwanz")` um 1 höher, `scene.progress.dna` um die Kosten (`FishUpgrades.COSTS[0]`) kleiner; `shot("nach_kauf")`; so lange weiter kaufen, bis die DNA nicht mehr reicht → dann ist der Knopf `disabled`; `await tap("entwickeln")` schließt das Menü

Review (20.10.2026): gemergt.
