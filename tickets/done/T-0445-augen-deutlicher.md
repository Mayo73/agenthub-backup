---
id: T-0445
title: Augenstufen deutlich sichtbar machen (P-0011, Variante A)
project: zellenphase
priority: 4
---
## Ziel
Entscheidung aus P-0011: Jede Augenstufe soll sichtbar mehr Sicht bringen; bisher verringerte die erste Stufe den Nebel nur um etwa 30 %, kaum zu sehen. Dazu ein Spieltest, der für jede Stufe ein Bild mit gleicher Kamera, Tiefe und demselben entfernten Felsen macht.

## Dateien
- `scripts/fish_abilities.gd` – Sichtweite
- `tests/test_fish_abilities.gd` – erwartete Werte anpassen
- `playtests/fisch_augen.gd` – neu

## Akzeptanzkriterien
- `FishAbilities.sight(b)`: Sichtweite `20.0 + 22.0 * b.level("augen")` (Stufe 0: 20 m, 1: 42 m, 2: 64 m, 3: 86 m). Den Kommentar darüber anpassen.
- In `tests/test_fish_abilities.gd` die Erwartungen für `sight` auf die neuen Werte ändern (keine Tests löschen; der Testname bleibt)
- `playtests/fisch_augen.gd` (`scene_path = "res://scenes/fish.tscn"`, Vorlage `playtests/fisch_entwicklung.gd`): `describe()` „Fischphase: jede Augenstufe lichtet den Nebel sichtbar“. Ablauf: `scene.intro.close()`; den Fisch an `Vector3(0, -40, 0)` setzen und ausrichten wie in der Vorlage; einen Felsen als Ziel 45 m vor den Fisch setzen (`MeshInstance3D` mit `FishModel.sphere(1.0)`, Größe 4 m, Material `FishTextures.rock_material()`, in `scene.world`); `scene.hud.clear_message()`; dann für Stufe 0 bis 3: `measure("nebel_%d" % stufe, scene.water.environment.fog_density)`, `shot("stufe_%d" % stufe)`, dann die Augen um eine Stufe verbessern (`scene.progress.dna = 50`, `scene.evolve.open(...)`, `buttons["augen"].pressed.emit()`, `close()`, `clear_message()`, `await wait(0.1)`). Prüfen: Die Nebeldichte von Stufe 1 ist höchstens halb so groß wie bei Stufe 0.

## Tests
- `tests/test_fish_abilities.gd`: Sichtweite für Stufe 0 und 3 wie oben

Review (20.10.2026): gemergt, nachgebessert: Spieltest griff auf scene.buttons statt scene.evolve.buttons zu, Fels lag am Boden statt 45 m vor dem Fisch und wurde vor dem Einhängen positioniert.
