class_name SaveSlots
extends RefCounted
## Drei lokale Spielstände: Dateipfade und Kurzbeschreibung für das Auswahlmenü.

const COUNT := 3
const PREFIX := "user://spielstand_"


## Pfad des Platzes slot (1 bis COUNT, wird begrenzt).
static func path_for(slot: int, prefix: String = PREFIX) -> String:
	return "%s%d.json" % [prefix, clampi(slot, 1, COUNT)]


## Kurzbeschreibung, z. B. "Größe 3 · 42 DNA · Pflanzenfresser"; "Leer", wenn kein Spielstand da ist.
static func summary(path: String) -> String:
	var data := SaveGame.read_file(path)
	if data.is_empty():
		return "Leer"
	return "Größe %d · %d DNA · %s" % [int(data.get("stage", 0)) + 1, int(data.get("dna", 0)), EndScreen.diet_name(str(data.get("diet", "")))]


## Nummer des ersten belegten Platzes (1 bis COUNT), 0 wenn alle leer sind.
static func first_used(prefix: String = PREFIX) -> int:
	for slot in range(1, COUNT + 1):
		if FileAccess.file_exists(path_for(slot, prefix)):
			return slot
	return 0
