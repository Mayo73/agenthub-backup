---
id: T-0185
title: Eigene Form und Farbe für jedes Teil (PartLooks)
project: zellenphase
priority: 3
---
## Ziel
Die Teile sind noch Platzhalter: alle Mäuler, alle Antriebe und alle Waffen sehen gleich aus. `PartLooks` gibt jedem Teil eine eigene Form und Farbe (Lastenheft: „alle sichtbaren Platzhalter ersetzen“). `PartShapes` bleibt unverändert.

## Dateien
- `scripts/part_looks.gd`: neu
- `tests/test_part_looks.gd`: neu

## Akzeptanzkriterien
`scripts/part_looks.gd` genau so:
```gdscript
class_name PartLooks
extends RefCounted
## Eigene Form und Farbe für jedes Teil (ersetzt die Platzhalter aus PartShapes).
## Punkte in Zellradien, Vorderseite nach +x; Antriebe hängen wie in PartShapes nach -x.

const COLORS := {
	"filtermaul": Color(0.35, 0.75, 0.55),
	"kiefer": Color(0.85, 0.8, 0.65),
	"ruessel": Color(0.8, 0.45, 0.55),
	"geissel": Color(0.9, 0.95, 1.0, 0.85),
	"wimpern": Color(0.85, 0.95, 1.0, 0.7),
	"duese": Color(0.55, 0.65, 0.85),
	"stachel": Color(0.95, 0.85, 0.6),
	"gift": Color(0.55, 0.85, 0.25),
	"elektro": Color(0.4, 0.75, 1.0),
	"knopfauge": Color(1.0, 1.0, 1.0),
	"stielauge": Color(1.0, 1.0, 1.0),
}

const SHAPES := {
	"filtermaul": [Vector2(0.05, 0.22), Vector2(0.28, 0.3), Vector2(0.18, 0.0), Vector2(0.28, -0.3), Vector2(0.05, -0.22), Vector2(-0.08, 0.0)],
	"kiefer": [Vector2(0.0, 0.2), Vector2(0.35, 0.16), Vector2(0.12, 0.04), Vector2(0.12, -0.04), Vector2(0.35, -0.16), Vector2(0.0, -0.2), Vector2(-0.08, 0.0)],
	"ruessel": [Vector2(0.0, 0.1), Vector2(0.55, 0.05), Vector2(0.6, 0.0), Vector2(0.55, -0.05), Vector2(0.0, -0.1)],
	"geissel": [Vector2(0.0, 0.08), Vector2(-0.9, 0.0), Vector2(0.0, -0.08)],
	"wimpern": [Vector2(0.0, 0.3), Vector2(-0.18, 0.3), Vector2(-0.18, -0.3), Vector2(0.0, -0.3)],
	"duese": [Vector2(0.0, 0.12), Vector2(-0.35, 0.2), Vector2(-0.35, -0.2), Vector2(0.0, -0.12)],
	"stachel": [Vector2(0.0, 0.1), Vector2(0.7, 0.0), Vector2(0.0, -0.1)],
}

## Runde Teile: Radius in Zellradien.
const ROUND := {"gift": 0.2, "elektro": 0.22, "knopfauge": 0.12, "stielauge": 0.12}
const ROUND_POINTS := 8


## Umriss eines Teils; leer bei unbekannter ID.
static func shape(id: String) -> PackedVector2Array:
	if SHAPES.has(id):
		return PackedVector2Array(SHAPES[id])
	if ROUND.has(id):
		var out := PackedVector2Array()
		for i in ROUND_POINTS:
			out.append(Vector2.from_angle(TAU * i / ROUND_POINTS) * float(ROUND[id]))
		return out
	return PackedVector2Array()


static func color(id: String) -> Color:
	return COLORS.get(id, Color.WHITE)


## Setzt Punkte (in Zellradien) an ein eingebautes Teil, Ergebnis in Pixeln relativ zur Zellmitte.
## Waffen zeigen von der Mitte durch ihre Lage nach außen, Antriebe hängen nach außen,
## Maul und Augen sind um ihren Winkel "angle" gedreht (wie PartShapes.placed).
static func place(points: PackedVector2Array, part: Dictionary, radius: float) -> PackedVector2Array:
	var pos: Vector2 = part["pos"]
	var angle: float = part["angle"]
	var category := PartCatalog.category_of(part["id"])
	if category == "waffe" and pos != Vector2.ZERO:
		angle = pos.angle()
	elif category == "antrieb" and pos != Vector2.ZERO:
		angle = pos.angle() + PI
	var out := PackedVector2Array()
	for p in points:
		out.append(pos * radius + (p * radius).rotated(angle))
	return out


## Form eines eingebauten Teils in Pixeln relativ zur Zellmitte.
static func placed(part: Dictionary, radius: float) -> PackedVector2Array:
	return place(shape(part["id"]), part, radius)
```

## Tests
`tests/test_part_looks.gd` mit `extends "res://tests/base_test.gd"`:
- `test_alle_teile`: für jede ID aus `PartCatalog.ids()`: `PartLooks.shape(id).size() >= 3` wahr und `PartLooks.COLORS.has(id)` wahr
- `test_unbekannt`: `PartLooks.shape("gibtsnicht").size()` ist 0; `PartLooks.color("gibtsnicht") == Color.WHITE` wahr
- `test_maeuler_verschieden`: `PartLooks.shape("filtermaul").size()` ist 6; `PartLooks.shape("kiefer").size()` ist 7; `PartLooks.shape("ruessel").size()` ist 5
- `test_rund`: `var g := PartLooks.shape("gift")` → `g.size()` ist 8; `g[0].is_equal_approx(Vector2(0.2, 0))` wahr
- `test_farbe`: `PartLooks.color("gift").is_equal_approx(Color(0.55, 0.85, 0.25))` wahr
- `test_stachel_nach_aussen`: `var p := PartLooks.placed({"id": "stachel", "pos": Vector2(0, 1), "angle": 0.0}, 10.0)` → `p[1].is_equal_approx(Vector2(0, 17))` wahr
- `test_duese_haengt_nach_aussen`: `var p := PartLooks.placed({"id": "duese", "pos": Vector2(-1, 0), "angle": 0.0}, 10.0)` → `p[1].is_equal_approx(Vector2(-13.5, 2.0))` wahr
- `test_maul_gedreht`: `var p := PartLooks.placed({"id": "ruessel", "pos": Vector2(1, 0), "angle": PI / 2.0}, 10.0)` → `p[2].is_equal_approx(Vector2(10, 6))` wahr

Review (17.10.2026): gemergt.
