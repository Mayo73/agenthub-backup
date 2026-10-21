class_name ChunkStreamer
extends Node3D
## Hält die 5 × 5 Kacheln um den Fisch als ChunkView-Kinder vor:
## neue werden angelegt, nicht mehr gebrauchte entfernt.

var chunks := WorldChunks.new()
var floor: SeafloorHeight
## Kachel (Vector2i) → ChunkView
var views: Dictionary = {}


func _init(p_floor: SeafloorHeight) -> void:
	floor = p_floor
	name = "Chunks"


func follow(center: Vector3) -> void:
	var change := chunks.update(center)
	for c: Vector2i in change["load"]:
		var view := ChunkView.new(c, floor)
		add_child(view)
		views[c] = view
	for c: Vector2i in change["unload"]:
		var view: ChunkView = views.get(c)
		if view != null:
			remove_child(view)
			view.queue_free()
		views.erase(c)


func view_count() -> int:
	return views.size()


func has_chunk(c: Vector2i) -> bool:
	return views.has(c)
