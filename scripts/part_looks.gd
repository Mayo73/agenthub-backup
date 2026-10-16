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
