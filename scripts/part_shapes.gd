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
