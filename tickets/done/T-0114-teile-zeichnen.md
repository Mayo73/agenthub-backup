---
id: T-0114
title: Eingebaute Teile an der Spielerzelle zeichnen (PartShapes)
project: zellenphase
priority: 3
after: T-0107
---
## Ziel
Die Spielerzelle zeigt ihre eingebauten Teile als einfache Formen (Platzhalter): Maul und Augen vorn, Antriebe als Schwanz nach außen, Waffen als Spitzen nach außen. Stachelspitzen liegen genau dort, wo `WeaponRules` trifft.

## Dateien
- `scripts/part_shapes.gd`: neu
- `scripts/player_cell.gd`
- `tests/test_part_shapes.gd`: neu

## Akzeptanzkriterien
- `scripts/part_shapes.gd` genau so:
```gdscript
class_name PartShapes
extends RefCounted
## Platzhalter-Formen der Teile in Zellradien. Die Spitze bzw. Vorderseite zeigt nach +x.

const COLORS := {
	"maul": Color(0.1, 0.3, 0.3),
	"antrieb": Color(0.9, 0.95, 1.0, 0.8),
	"waffe": Color(0.95, 0.55, 0.2),
	"auge": Color(1.0, 1.0, 1.0),
}


static func shape(id: String) -> PackedVector2Array:
	match PartCatalog.category_of(id):
		"maul":
			return PackedVector2Array([Vector2(0.25, 0), Vector2(0, 0.2), Vector2(-0.1, 0), Vector2(0, -0.2)])
		"antrieb":
			return PackedVector2Array([Vector2(0, 0.08), Vector2(-0.9, 0), Vector2(0, -0.08)])
		"waffe":
			return PackedVector2Array([Vector2(0, 0.15), Vector2(0.6, 0), Vector2(0, -0.15)])
		"auge":
			return PackedVector2Array([Vector2(0.12, 0), Vector2(0, 0.12), Vector2(-0.12, 0), Vector2(0, -0.12)])
	return PackedVector2Array()


static func color_of(id: String) -> Color:
	return COLORS.get(PartCatalog.category_of(id), Color.WHITE)


## Form eines eingebauten Teils in Pixeln relativ zur Zellmitte (ohne die Drehung der Zelle).
## Waffen zeigen von der Mitte durch ihre Lage nach außen, Antriebe hängen nach außen,
## Maul und Augen sind um ihren Winkel "angle" gedreht.
static func placed(part: Dictionary, radius: float) -> PackedVector2Array:
	var id: String = part["id"]
	var pos: Vector2 = part["pos"]
	var angle: float = part["angle"]
	var category := PartCatalog.category_of(id)
	if category == "waffe" and pos != Vector2.ZERO:
		angle = pos.angle()
	elif category == "antrieb" and pos != Vector2.ZERO:
		angle = pos.angle() + PI
	var result := PackedVector2Array()
	for p in shape(id):
		result.append(pos * radius + (p * radius).rotated(angle))
	return result
```
- `scripts/player_cell.gd`: `_draw()` ersetzen durch:
```gdscript
func _draw() -> void:
	for part in build.parts:
		if PartCatalog.category_of(part["id"]) == "antrieb":
			draw_colored_polygon(PartShapes.placed(part, radius), PartShapes.color_of(part["id"]))
	draw_circle(Vector2.ZERO, radius, COLOR)
	for part in build.parts:
		if PartCatalog.category_of(part["id"]) != "antrieb":
			draw_colored_polygon(PartShapes.placed(part, radius), PartShapes.color_of(part["id"]))
```
  Die Konstante `MOUTH_COLOR` bleibt stehen. Sonst nichts an `player_cell.gd` ändern.

## Tests
`tests/test_part_shapes.gd` mit `extends "res://tests/base_test.gd"`:
- `test_formen`: `PartShapes.shape("kiefer").size()` ist 4; `shape("geissel").size()` ist 3; `shape("gibtsnicht").size()` ist 0
- `test_farben`: `PartShapes.color_of("stachel")` ist gleich `Color(0.95, 0.55, 0.2)` (Vergleich mit `is_equal_approx`, Ergebnis mit `check` prüfen)
- `test_auge_vorn`: `PartShapes.placed({"id": "knopfauge", "pos": Vector2(0.4, 0), "angle": 0.0}, 10.0)[0]` ist (5.2, 0)
- `test_stachel_nach_aussen`: `PartShapes.placed({"id": "stachel", "pos": Vector2(-1, 0), "angle": 0.0}, 10.0)[1].is_equal_approx(Vector2(-16, 0))` wahr
- `test_geissel_haengt_nach_aussen`: `PartShapes.placed({"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}, 10.0)[1].is_equal_approx(Vector2(-19, 0))` wahr

Review (16.10.2026): gemergt.
