class_name Iso
extends RefCounted
## Isometrische Darstellung (2:1). Die Spiellogik rechnet in Weltkoordinaten von oben,
## nur die Darstellung wird schräg projiziert: Der Knoten "World" in main.tscn bekommt TRANSFORM.

## Welt -> Bildschirm: Welt-x zeigt nach rechts unten, Welt-y nach links unten.
const TRANSFORM := Transform2D(Vector2(1.0, 0.5), Vector2(-1.0, 0.5), Vector2.ZERO)


static func to_screen(world: Vector2) -> Vector2:
	return TRANSFORM * world


static func to_world(screen: Vector2) -> Vector2:
	return TRANSFORM.affine_inverse() * screen
