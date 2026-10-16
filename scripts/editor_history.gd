class_name EditorHistory
extends RefCounted
## Rückgängig und Wiederholen im Zelleditor. Speichert unabhängige Kopien des Aufbaus.

const MAX_STEPS := 50

var _undo: Array[CellBuild] = []
var _redo: Array[CellBuild] = []


## Merkt sich den Zustand VOR einer Änderung. Eine neue Änderung leert die Wiederholen-Liste.
func record(before: CellBuild) -> void:
	_undo.append(before.copy())
	if _undo.size() > MAX_STEPS:
		_undo.remove_at(0)
	_redo.clear()


func can_undo() -> bool:
	return not _undo.is_empty()


func can_redo() -> bool:
	return not _redo.is_empty()


## Gibt den vorigen Zustand zurück und merkt sich current zum Wiederholen; null, wenn es keinen gibt.
func undo(current: CellBuild) -> CellBuild:
	if _undo.is_empty():
		return null
	_redo.append(current.copy())
	return _undo.pop_back()


## Gegenstück zu undo(); null, wenn es nichts zu wiederholen gibt.
func redo(current: CellBuild) -> CellBuild:
	if _redo.is_empty():
		return null
	_undo.append(current.copy())
	return _redo.pop_back()


func clear() -> void:
	_undo.clear()
	_redo.clear()
