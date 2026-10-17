---
id: T-0265
title: Entwicklungsmenü der Fischphase
project: zellenphase
priority: 4
after: T-0263
---
## Ziel
Meilenstein „Fischphase – Weiterentwicklung“: Ein Menü zeigt alle fünf Bauteile mit Stufe und Preis und lässt sie mit DNA verbessern. Eingebaut wird es in T-0266.

## Dateien
- `scripts/evolve_menu.gd` – neu
- `tests/test_evolve_menu.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/evolve_menu.gd`, beginnend mit:
```gdscript
class_name EvolveMenu
extends CanvasLayer
## Entwicklungsmenü der Fischphase: je Bauteil eine Zeile mit Stufe, Preis und Knopf "Verbessern".

signal upgraded(slot: String)
signal closed

var build: FishBuild
var progress: FishProgress
var title_label: Label
var dna_label: Label
var rows: VBoxContainer
## Bauteil -> Knopf "Verbessern"
var buttons := {}
## Bauteil -> Beschriftung der Zeile
var labels := {}
var close_button: Button


## Text einer Zeile, z. B. "Schwanzflosse: Stufe 1 → 2 (20 DNA)" oder "Augen: Stufe 3 (höchste Stufe)".
static func row_text(b: FishBuild, slot: String) -> String:
	var c := FishUpgrades.cost(b, slot)
	if c < 0:
		return "%s: Stufe %d (höchste Stufe)" % [FishBuild.NAMES[slot], b.level(slot)]
	return "%s: Stufe %d → %d (%d DNA)" % [FishBuild.NAMES[slot], b.level(slot), b.level(slot) + 1, c]
```
Dazu (selbst ausformulieren, Vorlage für den Aufbau: `scripts/fish_intro.gd`):
- `_init()`: `layer = 20`; halbdurchsichtiger dunkler Hintergrund (`ColorRect` über das ganze Bild, `Color(0.02, 0.12, 0.18, 0.88)`); ein `VBoxContainer` bei `Vector2(560, 160)`; darin `title_label` mit Text `"Entwicklung"` (Schriftgröße 44), `dna_label` (28), `rows` (`VBoxContainer`) und `close_button` mit Text `"Weiterschwimmen"` (Mindestgröße 400 × 56). Für jedes Bauteil aus `FishBuild.SLOTS` eine `HBoxContainer`-Zeile in `rows` mit einem `Label` (Mindestbreite 520, Schriftgröße 26) und einem `Button` mit Text `"Verbessern"`; beide in `labels[slot]` bzw. `buttons[slot]` ablegen; `pressed` des Knopfs ruft `try_upgrade(slot)` auf (z. B. `btn.pressed.connect(try_upgrade.bind(slot))`). `close_button.pressed` ruft `close()` auf. Am Ende `visible = false`.
- `open(b: FishBuild, p: FishProgress) -> void`: merkt sich beide, ruft `refresh()` auf, `visible = true`.
- `refresh() -> void`: `dna_label.text = "DNA: %d" % progress.dna`; für jedes Bauteil `labels[slot].text = row_text(build, slot)` und `buttons[slot].disabled = not FishUpgrades.can_upgrade(build, progress, slot)`.
- `try_upgrade(slot: String) -> bool`: ruft `FishUpgrades.upgrade(build, progress, slot)`; bei Erfolg `refresh()` und `upgraded.emit(slot)`; gibt das Ergebnis zurück.
- `close() -> void`: nur wenn sichtbar: `visible = false` und `closed.emit()`.

## Tests
Neue Datei `tests/test_evolve_menu.gd` (`extends "res://tests/base_test.gd"`), Variablen `menu`, `b`, `p`; in `setup()` `menu = EvolveMenu.new()`, `b = FishBuild.new()`, `p = FishProgress.new()`; `teardown()` `menu.free()`:
- `test_zeilentext`: `EvolveMenu.row_text(b, "schwanz")` ist `"Schwanzflosse: Stufe 0 → 1 (10 DNA)"`; nach dreimal `b.upgrade("augen")` ist `EvolveMenu.row_text(b, "augen")` gleich `"Augen: Stufe 3 (höchste Stufe)"`
- `test_neu_versteckt`: `menu.visible` falsch; `menu.buttons.size()` ist 5; `menu.title_label.text` ist `"Entwicklung"`
- `test_oeffnen`: `p.dna = 15`; `menu.open(b, p)` → sichtbar; `menu.dna_label.text` ist `"DNA: 15"`; `menu.buttons["schwanz"].disabled` falsch
- `test_zu_teuer_gesperrt`: `p.dna = 5`; `menu.open(b, p)` → `menu.buttons["kiefer"].disabled` wahr
- `test_verbessern`: `p.dna = 30`; `menu.open(b, p)`; Signal `upgraded` mit einem Array-Zähler verbinden; `menu.buttons["flossen"].pressed.emit()` → `b.level("flossen")` ist 1; `p.dna` ist 20; Signal einmal empfangen; `menu.labels["flossen"].text` ist `"Brustflossen: Stufe 1 → 2 (20 DNA)"`
- `test_schliessen`: `menu.open(b, p)`; Signal `closed` zählen; `menu.close_button.pressed.emit()` → unsichtbar, einmal empfangen; `menu.close()` noch einmal → weiterhin einmal
