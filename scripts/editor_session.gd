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
