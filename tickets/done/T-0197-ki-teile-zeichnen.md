---
id: T-0197
title: KI-Zellen zeigen die Teile ihrer Art
project: zellenphase
priority: 3
after: T-0184, T-0196
---
## Ziel
KI-Zellen zeichnen statt des einfachen Maul-Kreises die Teile ihrer Art aus `SpeciesParts`: Antriebe unter dem Körper (die Geißel schlängelt sich), Maul und Waffen darüber.

## Dateien
- `scripts/ai_cell.gd`
- `tests/test_ai_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/ai_cell.gd`:
- Neue Funktion direkt über `func _draw()`:
```gdscript
## Sichtbare Teile der Art, an die Streckung des Körpers angepasst.
func visible_parts() -> Array:
	return SpeciesParts.placed_parts(species_id, look.stretch)


```
- In `_draw()` direkt vor der Zeile `CellPainter.draw_cell(self, Vector2.ZERO, look, radius, time)`:
```gdscript
	for part in visible_parts():
		if part["id"] == "geissel":
			draw_polyline(PartAnimation.place_points(PartAnimation.flagellum(time), part, radius), PartLooks.color("geissel"), maxf(1.5, radius * 0.1))
		elif PartCatalog.category_of(part["id"]) == "antrieb":
			draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))
```
- In `_draw()` die Zeile `draw_circle(Vector2(radius * 0.8 * look.stretch, 0), radius * 0.22, color.darkened(0.5))` ersetzen durch:
```gdscript
	for part in visible_parts():
		if PartCatalog.category_of(part["id"]) != "antrieb":
			draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))
```
- Sonst nichts ändern.

## Tests
In `tests/test_ai_cell.gd` anhängen; jeder Test legt seine Zelle selbst an und gibt sie am Ende mit `free()` frei:
- `test_teile_der_art`: `var c := AiCell.new()`, `c.setup("schnapper", Vector2.ZERO)` → `c.visible_parts().size()` ist 2; `(c.visible_parts()[0]["pos"] as Vector2).is_equal_approx(Vector2(1.3, 0))` wahr
- `test_giftling_teile`: `var c := AiCell.new()`, `c.setup("giftling", Vector2.ZERO)` → `c.visible_parts().size()` ist 3; `c.visible_parts()[1]["id"]` ist `"gift"`
- `test_kein_maulkreis`: `FileAccess.get_file_as_string("res://scripts/ai_cell.gd").contains("radius * 0.22")` falsch

Review (17.10.2026): gemergt, nachgebessert: Augen der KI-Zellen wiederhergestellt (versehentlich mit entfernt), Restdateien scripts/ai_cell_gd_part1.* gelöscht.
