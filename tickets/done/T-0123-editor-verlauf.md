---
id: T-0123
title: Rückgängig und Wiederholen im Editor (EditorHistory)
project: zellenphase
priority: 3
---
## Ziel
Im Zelleditor lassen sich Änderungen rückgängig machen und wiederholen (Lastenheft, Soll). Die Klasse speichert unabhängige Kopien des Zellaufbaus.

## Dateien
- `scripts/editor_history.gd`: neu
- `tests/test_editor_history.gd`: neu

## Akzeptanzkriterien
`scripts/editor_history.gd` genau so:
```gdscript
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
```

## Tests
`tests/test_editor_history.gd` mit `extends "res://tests/base_test.gd"`, `var h: EditorHistory`, `var b: CellBuild`, `setup()`: `h = EditorHistory.new()`, `b = CellBuild.starter(Diet.PFLANZENFRESSER)`.
- `test_leer`: `h.can_undo()` falsch; `h.undo(b) == null` wahr; `h.redo(b) == null` wahr
- `test_rueckgaengig`: `h.record(b)`, `b.add_part("kiefer", Vector2(0.9, 0.3))`, `var back := h.undo(b)` → `back.parts.size()` ist 2; `h.can_redo()` wahr; `var fwd := h.redo(back)` → `fwd.parts.size()` ist 3; `h.can_undo()` wahr
- `test_neue_aenderung_leert_redo`: `h.record(b)`, `b.add_part("kiefer", Vector2(0.9, 0.3))`, `var back := h.undo(b)`, `h.record(back)` → `h.can_redo()` falsch
- `test_grenze`: 60-mal `h.record(b)`; dann `var n := 0` und `while h.can_undo():` mit `h.undo(b)` und `n += 1` → `n` ist 50
- `test_leeren`: `h.record(b)`, `h.clear()` → `h.can_undo()` falsch

Review (16.10.2026): gemergt.
