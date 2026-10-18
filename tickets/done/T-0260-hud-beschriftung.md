---
id: T-0260
title: HUD beschriftet Wachstum und Gesundheit
project: zellenphase
priority: 4
---
## Ziel
Beim Ansehen (P-0004) war der rote Balken unter „Größe“ ohne Bezeichnung und konnte als Wachstum missverstanden werden. Beide Balken bekommen eine Beschriftung davor: „Wachstum“ über dem Wachstumsbalken, „Gesundheit“ über dem Gesundheitsbalken.

## Dateien
- `scripts/hud.gd`
- `tests/test_hud.gd`

## Akzeptanzkriterien
- In `scripts/hud.gd` zwei neue Variablen unter `var health_bar: ProgressBar`: `var growth_caption: Label` und `var health_caption: Label`.
- Neue Hilfsfunktion in `scripts/hud.gd`:
```gdscript
## Kleine Beschriftung über einem Balken.
func make_caption(caption_name: String, text: String) -> Label:
	var l := Label.new()
	l.name = caption_name
	l.text = text
	l.add_theme_font_size_override("font_size", 18)
	box.add_child(l)
	return l
```
- In `_init()`: direkt vor `growth_bar = ProgressBar.new()` die Zeile `growth_caption = make_caption("GrowthCaption", "Wachstum")`; direkt vor `health_bar = ProgressBar.new()` die Zeile `health_caption = make_caption("HealthCaption", "Gesundheit")`.
- Die Reihenfolge in `box` ist danach: Dna, GrowthCaption, Growth, Stage, HealthCaption, Health.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_hud.gd` anhängen (Aufbau wie die vorhandenen Tests der Datei):
- `test_beschriftungen`: `hud.growth_caption.text` ist `"Wachstum"`; `hud.health_caption.text` ist `"Gesundheit"`
- `test_reihenfolge`: `hud.growth_caption.get_index() + 1 == hud.growth_bar.get_index()` wahr; `hud.health_caption.get_index() + 1 == hud.health_bar.get_index()` wahr

Review (17.10.2026): gemergt.
