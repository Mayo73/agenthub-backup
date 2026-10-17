---
id: T-0169
title: KI-Zellen mit Aussehen ihrer Art zeichnen
project: zellenphase
priority: 2
after: T-0166, T-0168
---
## Ziel
KI-Zellen werden statt als einfarbige Kreise mit `CellPainter` gezeichnet: Textur in der Farbe ihrer Art, Muster, Streckung und wogende Membran. Die Stachelkugel bekommt sichtbare Stacheln.

## Dateien
- `scripts/ai_cell.gd`
- `tests/test_ai_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/ai_cell.gd`:
- Neue Variablen direkt unter `var wish := Vector2.ZERO`:
```gdscript
var look := CellLook.new()
var behavior := ""
## Laufzeit für Animationen in Sekunden.
var time := 0.0
```
- In `setup(id, pos)` direkt nach der Zeile `color = d["color"]` zwei Zeilen:
```gdscript
	look = SpeciesCatalog.look_of(id)
	behavior = d["behavior"]
```
- In `drive(delta)` als erste Zeile: `time += delta`
- `_draw()` ganz ersetzen durch:
```gdscript
func _draw() -> void:
	if behavior == "stachel":
		for spike in spike_shapes():
			draw_colored_polygon(spike, color.darkened(0.3))
	CellPainter.draw_cell(self, Vector2.ZERO, look, radius, time)
	draw_circle(Vector2(radius * 0.8 * look.stretch, 0), radius * 0.22, color.darkened(0.5))


## Acht Stacheln rundum (Dreiecke), Spitzen bei 1,5 Radien.
func spike_shapes() -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	for i in 8:
		var a := TAU * i / 8.0
		var dir := Vector2.from_angle(a)
		var side := dir.orthogonal() * radius * 0.18
		out.append(PackedVector2Array([dir * radius * 0.8 + side, dir * radius * 1.5, dir * radius * 0.8 - side]))
	return out
```
- Sonst nichts ändern.

## Tests
In `tests/test_ai_cell.gd` anhängen; jeder Test legt seine Zelle selbst an und gibt sie am Ende mit `free()` frei:
- `test_aussehen_der_art`: `var c := AiCell.new()`, `c.setup("schnapper", Vector2.ZERO)` → `c.look.pattern` ist `"streifen"`; `c.look.stretch` ist 1.3; `c.behavior` ist `"jaeger"`
- `test_stacheln`: `var c := AiCell.new()`, `c.setup("stachelkugel", Vector2.ZERO)` → `c.spike_shapes().size()` ist 8; `c.spike_shapes()[0][1].is_equal_approx(Vector2(c.radius * 1.5, 0))` wahr
- `test_zeit`: `var c := AiCell.new()`, `c.setup("blasenling", Vector2.ZERO)`, `c.drive(0.5)` → `c.time` ist 0.5

Review (16.10.2026): gemergt.
