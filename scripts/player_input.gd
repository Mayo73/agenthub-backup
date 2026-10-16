class_name PlayerInput
extends RefCounted
## Wunschrichtung der Spielerzelle aus Tasten und Maus.

## Liegt der Mauszeiger näher als das an der Zelle, bleibt sie stehen (kein Zittern).
const DEAD_ZONE := 12.0


## keys: Richtung aus WASD/Pfeiltasten. mouse_held: Maustaste gedrückt.
## mouse_world und cell_pos in Weltkoordinaten. Ergebnis hat Länge 1 oder ist Vector2.ZERO
## (bei Tasten auch kürzer, z. B. bei halb gedrücktem Gamepad).
static func wish(keys: Vector2, mouse_held: bool, mouse_world: Vector2, cell_pos: Vector2) -> Vector2:
	if mouse_held:
		var offset := mouse_world - cell_pos
		if offset.length() < DEAD_ZONE:
			return Vector2.ZERO
		return offset.normalized()
	if keys.length() > 1.0:
		return keys.normalized()
	return keys
