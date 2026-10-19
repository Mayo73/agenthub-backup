class_name CollisionLayers
extends RefCounted
## Benannte Kollisionsebenen für 2D-Spiele.
## Erstellt Bitmasken aus Ebenennamen und prüft Kollisionen wie Godot.

var names: Array[String] = ["Welt", "Spieler", "Gegner", "Projektile"]


func _init(layer_names: Array[String] = []) -> void:
	if not layer_names.is_empty():
		names = layer_names.duplicate()


func bit(layer_name: String) -> int:
	var index := names.find(layer_name)
	return 0 if index == -1 else 1 << index


func mask(layer_list: Array[String]) -> int:
	var m: int = 0
	for name in layer_list:
		m |= bit(name)
	return m


func unknown(layer_list: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for name in layer_list:
		if names.find(name) == -1:
			result.append(name)
	return result


static func collides(layer_a: int, mask_a: int, layer_b: int, mask_b: int) -> bool:
	return (layer_a & mask_b) != 0 or (layer_b & mask_a) != 0


func names_of(value: int) -> Array[String]:
	var result: Array[String] = []
	for i in range(names.size()):
		if value & (1 << i):
			result.append(names[i])
	return result
