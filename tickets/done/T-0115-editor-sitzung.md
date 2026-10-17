---
id: T-0115
title: Zelleditor-Sitzung mit DNA-Kosten (EditorSession)
project: zellenphase
priority: 3
after: T-0103, T-0105
---
## Ziel
Die Logik eines Editorbesuchs: Änderungen laufen auf einer Kopie des Aufbaus, nur freigeschaltete Teile lassen sich einbauen, die DNA-Kosten werden vorher angezeigt und erst beim Bestätigen verrechnet. Entfernte Teile bringen ihre Kosten zurück (wie bei Spore). Die DNA wird nie negativ.

## Dateien
- `scripts/editor_session.gd`: neu
- `tests/test_editor_session.gd`: neu

## Akzeptanzkriterien
`scripts/editor_session.gd` genau so:
```gdscript
class_name EditorSession
extends RefCounted
## Ein Besuch im Zelleditor. Änderungen laufen auf einer Kopie; DNA wird erst beim Bestätigen verrechnet.
## Entfernte Teile bringen ihre Kosten zurück (wie bei Spore).

var original: CellBuild
var working: CellBuild
var unlocks: PartUnlocks


func _init(build: CellBuild, p_unlocks: PartUnlocks) -> void:
	original = build
	working = build.copy()
	unlocks = p_unlocks


## Baut ein freigeschaltetes Teil ein und gibt seinen Index zurück, -1 wenn es gesperrt oder unbekannt ist.
func place(id: String, pos: Vector2, angle: float = 0.0) -> int:
	if not unlocks.is_unlocked(id):
		return -1
	return working.add_part(id, pos, angle)


## DNA-Kosten der Änderungen; negativ, wenn mehr entfernt als eingebaut wurde.
func cost() -> int:
	return working.total_cost() - original.total_cost()


## Ohne Maul kann die Zelle nicht fressen, deshalb ist so ein Aufbau ungültig.
func is_valid() -> bool:
	return not working.mouths().is_empty()


func can_confirm(dna: int) -> bool:
	return is_valid() and cost() <= dna


## Verrechnet die DNA und gibt den neuen Aufbau zurück.
## null, wenn es nicht geht; dann bleibt die DNA unverändert.
func confirm(progress: CellProgress) -> CellBuild:
	if not can_confirm(progress.dna):
		return null
	progress.dna -= cost()
	return working


## Verwirft alle Änderungen.
func cancel() -> CellBuild:
	return original
```

## Tests
`tests/test_editor_session.gd` mit `extends "res://tests/base_test.gd"`, `var s: EditorSession`, `setup()`: `s = EditorSession.new(CellBuild.starter(Diet.PFLANZENFRESSER), PartUnlocks.new())`.
- `test_gesperrt`: `s.place("geissel", Vector2(-1, 0))` ist -1; `s.cost()` ist 0
- `test_einbauen_kostet`: `s.place("kiefer", Vector2(0.9, 0.3))` ist 2; `s.cost()` ist 10; `s.unlocks.unlock("geissel")`; `s.place("geissel", Vector2(-1, 0))` ist 3; `s.cost()` ist 25; `s.original.parts.size()` ist weiterhin 2
- `test_bestaetigen`: wie oben Kiefer und Geißel einbauen (Kosten 25); `var p := CellProgress.new()`, `p.eat(20)` → `s.confirm(p) == null` wahr und `p.dna` ist 20; `p.eat(10)` → `s.confirm(p) == s.working` wahr und `p.dna` ist 5
- `test_rueckerstattung`: `s.working.remove_part(1)` (Knopfauge, 5 DNA) → `s.cost()` ist -5; `var p := CellProgress.new()`; `s.confirm(p) != null` wahr; `p.dna` ist 5
- `test_ohne_maul_ungueltig`: `s.working.remove_part(0)` → `s.is_valid()` falsch; `s.can_confirm(100)` falsch
- `test_abbrechen`: `s.place("kiefer", Vector2(0.9, 0.3))`; `s.cancel() == s.original` wahr; `s.cancel().parts.size()` ist 2

Review (16.10.2026): gemergt, nachgebessert: Tippfehler in Testmeldungen.
