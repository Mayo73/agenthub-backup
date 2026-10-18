---
id: T-0266
title: Entwicklungsmenü in der Fischszene (Taste E)
project: zellenphase
priority: 4
after: T-0264, T-0265, T-0261
---
## Ziel
In der Fischphase öffnet die Taste E das Entwicklungsmenü. Solange es offen ist, schwimmt der Fisch nicht. Jede Verbesserung zeigt sich sofort am Modell und in der Bewegung.

## Dateien
- `scripts/controls.gd`
- `scripts/fish_main.gd`
- `scripts/fish_hud.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/controls.gd`: `"entwickeln"` ans Ende von `ACTIONS`; in `setup()` als letzte Zeile `_add("entwickeln", [KEY_E], [])`.
- `scripts/fish_hud.gd`: `HELP` auf `"W / linke Maustaste: schwimmen · A/D: drehen · Leertaste: auftauchen · Umschalt: abtauchen · E: Entwicklung"` ändern.
- `scripts/fish_main.gd`:
  - Variable `var evolve: EvolveMenu` unter `var food_view: FishFoodView`.
  - In `_ready()` direkt vor `intro = FishIntro.new()`:
```gdscript
	evolve = EvolveMenu.new()
	evolve.name = "Evolve"
	add_child(evolve)
	evolve.upgraded.connect(_on_upgraded)
```
  - In `_physics_process(delta)` als erste Zeilen:
```gdscript
	if Input.is_action_just_pressed("entwickeln"):
		toggle_evolve()
	if evolve.visible:
		return
```
  - Neue Funktionen am Ende der Datei:
```gdscript
## Öffnet oder schließt das Entwicklungsmenü.
func toggle_evolve() -> void:
	if evolve.visible:
		evolve.close()
	else:
		evolve.open(player.build, progress)


## Nach einer Verbesserung: Aussehen und Fähigkeiten neu, Anzeige aktualisieren.
func _on_upgraded(slot: String) -> void:
	player.set_build(player.build)
	hud.show_progress(progress)
	hud.show_message("%s verbessert!" % FishBuild.NAMES[slot])
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen:
- `test_entwicklung_knoten`: `fish.get_node("Evolve") is EvolveMenu` wahr; `fish.evolve.visible` falsch; `InputMap.has_action("entwickeln")` wahr
- `test_umschalten`: `fish.toggle_evolve()` → `fish.evolve.visible` wahr; noch einmal → falsch
- `test_verbessern_wirkt`: `fish.progress.dna = 20`; `fish.toggle_evolve()`; `fish.evolve.try_upgrade("schwanz")` → `fish.player.build.level("schwanz")` ist 1; `fish.player.motion.max_speed` ist 10.0; `fish.progress.dna` ist 10; `fish.hud.dna_label.text` ist `"DNA: 10"`
- `test_kein_schwimmen_im_menue`: `fish.toggle_evolve()`; `var vorher: Vector3 = fish.player.motion.position`; `fish.player.motion.velocity = Vector3(0, 0, -5)`; `fish._physics_process(0.5)` → `fish.player.motion.position` ist unverändert `vorher`

Review (17.10.2026): gemergt.
