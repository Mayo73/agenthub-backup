class_name FoodField
extends RefCounted
## Verteilt Nahrungsstücke im Wasser und findet das nächste Stück einer Sorte.

const PLANT_VALUE := 1
const MEAT_VALUE := 2
const PLANT_RADIUS := 5.0
const MEAT_RADIUS := 6.0

var items: Array[FoodItem] = []
var rng := RandomNumberGenerator.new()


func _init(seed_value: int = 1) -> void:
	rng.seed = seed_value


func add_item(kind: String, pos: Vector2) -> FoodItem:
	var value := PLANT_VALUE
	var radius := PLANT_RADIUS
	if kind == Diet.FLEISCH:
		value = MEAT_VALUE
		radius = MEAT_RADIUS
	var item := FoodItem.new(kind, pos, value, radius)
	items.append(item)
	return item


func spawn_around(center: Vector2, count: int, min_dist: float, max_dist: float, meat_share: float) -> void:
	for i: int in range(count):
		var angle := rng.randf() * PI * 2.0
		var dist := rng.randf_range(min_dist, max_dist)
		var position := center + Vector2.from_angle(angle) * dist
		var kind := Diet.PFLANZE
		if rng.randf() < meat_share:
			kind = Diet.FLEISCH
		add_item(kind, position)


func count_kind(kind: String) -> int:
	var cnt := 0
	for item in items:
		if item.kind == kind:
			cnt += 1
	return cnt


const INF_DIST := 999999.0

func nearest(pos: Vector2, kind: String, max_dist: float = INF_DIST) -> FoodItem:
	var result: FoodItem = null
	var best_dist := max_dist
	for item in items:
		if item.kind != kind:
			continue
		var d := pos.distance_to(item.position)
		if d <= best_dist:
			best_dist = d
			result = item
	return result


func remove_far(center: Vector2, max_dist: float) -> int:
	var to_remove := []
	for item in items:
		if center.distance_to(item.position) > max_dist:
			to_remove.append(item)
	for item in to_remove:
		items.erase(item)
	return to_remove.size()
