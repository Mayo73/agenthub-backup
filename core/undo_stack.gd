class_name UndoStack
extends RefCounted

## Modell, das rückgängig/wiederholt werden soll
var model: SceneModel
## Liste der Schnappschüsse für Rückgängig
var undo_list: Array[Dictionary] = []
## Liste der Schnappschüsse für Wiederholen
var redo_list: Array[Dictionary] = []
## Checkpoints: {name: snapshot_dictionary}
var checkpoints: Dictionary = {}

const LIMIT := 100


func _init(scene: SceneModel) -> void:
	model = scene


## Vor einer Änderung aufrufen; legt aktuellen Stand auf undo_list, leert redo_list
func record() -> void:
	var snapshot: Dictionary = model.to_dict().duplicate(true)
	undo_list.append(snapshot)
	if undo_list.size() > LIMIT:
		undo_list.pop_front()
	redo_list.clear()


## Gibt true zurück, wenn Rückgängig möglich ist
func can_undo() -> bool:
	return undo_list.size() > 0


## Gibt true zurück, wenn Wiederholen möglich ist
func can_redo() -> bool:
	return redo_list.size() > 0


## Führt Rückgängig aus, gibt true bei Erfolg, false wenn nichts zu tun ist
func undo() -> bool:
	if not can_undo():
		return false
	var current_snapshot: Dictionary = model.to_dict().duplicate(true)
	redo_list.append(current_snapshot)
	var previous_snapshot: Dictionary = undo_list.pop_back()
	model.load_from(previous_snapshot)
	return true


## Führt Wiederholen aus, gibt true bei Erfolg, false wenn nichts zu tun ist
func redo() -> bool:
	if not can_redo():
		return false
	var current_snapshot: Dictionary = model.to_dict().duplicate(true)
	undo_list.append(current_snapshot)
	var next_snapshot: Dictionary = redo_list.pop_back()
	model.load_from(next_snapshot)
	return true


## Legt einen benannten Checkpoint an
func checkpoint(name: String) -> void:
	var snapshot: Dictionary = model.to_dict().duplicate(true)
	checkpoints[name] = snapshot


## Wiederherstellung eines Checkpoints, gibt true bei Erfolg, false bei unbekanntem Namen
func restore(name: String) -> bool:
	if not checkpoints.has(name):
		return false
	record()
	var snapshot: Dictionary = checkpoints[name]
	model.load_from(snapshot)
	return true


## Gibt sortierte Liste aller Checkpoint-Namen zurück
func checkpoint_names() -> Array[String]:
	var names: Array[String] = []
	for key in checkpoints.keys():
		names.append(key)
	names.sort()
	return names
