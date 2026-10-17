---
id: T-0089
title: HUD mit DNA, Wachstum und Größe
project: zellenphase
priority: 4
after: T-0088
---
## Ziel
Oben links zeigt das HUD die DNA, einen Balken für das Wachstum bis zur nächsten Größe und den Größenabschnitt („Größe 2/5“).

## Dateien
- `scripts/hud.gd`: neu
- `scripts/main.gd`
- `tests/test_hud.gd`: neu
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/hud.gd` genau so:
```gdscript
class_name Hud
extends CanvasLayer
## Anzeige über dem Spiel. Die Knoten werden in _init angelegt, damit Tests ohne Szene auskommen.

var box: VBoxContainer
var dna_label: Label
var growth_bar: ProgressBar
var stage_label: Label


func _init() -> void:
	box = VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(24, 24)
	add_child(box)
	dna_label = Label.new()
	dna_label.name = "Dna"
	dna_label.add_theme_font_size_override("font_size", 28)
	box.add_child(dna_label)
	growth_bar = ProgressBar.new()
	growth_bar.name = "Growth"
	growth_bar.custom_minimum_size = Vector2(260, 18)
	growth_bar.max_value = 100.0
	growth_bar.show_percentage = false
	box.add_child(growth_bar)
	stage_label = Label.new()
	stage_label.name = "Stage"
	stage_label.add_theme_font_size_override("font_size", 22)
	box.add_child(stage_label)


func show_progress(progress: CellProgress) -> void:
	dna_label.text = "DNA: %d" % progress.dna
	growth_bar.value = progress.growth_ratio() * 100.0
	stage_label.text = "Größe %d/%d" % [progress.stage + 1, CellProgress.STAGE_COUNT]
```
- `scripts/main.gd`: neue Variable unter `var food_view: FoodView`: `var hud: Hud`. In `_ready()` am Ende:
```gdscript
	hud = Hud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.show_progress(progress)
```
  In `_process` als letzte Zeile: `hud.show_progress(progress)`

## Tests
- `tests/test_hud.gd` mit `extends "res://tests/base_test.gd"`, `var hud: Hud`; `setup()`: `hud = Hud.new()`; `teardown()`: `hud.free()`.
  - `test_fortschritt`: `var p := CellProgress.new()`, `p.eat(5)`, `hud.show_progress(p)` → `hud.dna_label.text` ist `"DNA: 5"`, `hud.growth_bar.value` ist 50.0, `hud.stage_label.text` ist `"Größe 1/5"`
  - `test_letzte_groesse`: `p.eat(100)`, `hud.show_progress(p)` → `hud.stage_label.text` ist `"Größe 5/5"`, `hud.growth_bar.value` ist 100.0
- `tests/test_main_wiring.gd`, neue Methode `test_hud`: `main.hud is Hud` ist wahr; `main.progress.eat(3)`, `main._process(0.016)` → `main.hud.dna_label.text` ist `"DNA: 3"`

Review (16.10.2026): gemergt.
