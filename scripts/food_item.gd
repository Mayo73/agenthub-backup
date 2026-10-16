class_name FoodItem
extends RefCounted
## Ein Nahrungsstück: Sorte (Diet.PFLANZE oder Diet.FLEISCH), Lage, Nährwert, Radius.

var kind: String
var position: Vector2
var value: int
var radius: float


func _init(p_kind: String = Diet.PFLANZE, p_position: Vector2 = Vector2.ZERO, p_value: int = 1, p_radius: float = 5.0) -> void:
	kind = p_kind
	position = p_position
	value = p_value
	radius = p_radius
