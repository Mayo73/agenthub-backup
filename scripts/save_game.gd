class_name SaveGame
extends RefCounted
## Spielstand als JSON: Entwicklungsstand, DNA, Gesundheit, Zellaufbau und Freischaltungen.

const DEFAULT_PATH := "user://spielstand.json"
const VERSION := 1


static func build_to_array(build: CellBuild) -> Array:
	var result := []
	for p in build.parts:
		var pos: Vector2 = p["pos"]
		result.append({"id": p["id"], "x": pos.x, "y": pos.y, "angle": p["angle"]})
	return result


static func build_from_array(data: Array) -> CellBuild:
	var build := CellBuild.new()
	for entry in data:
		if entry is Dictionary:
			var pos := Vector2(float(entry.get("x", 0.0)), float(entry.get("y", 0.0)))
			build.add_part(str(entry.get("id", "")), pos, float(entry.get("angle", 0.0)))
	return build


static func to_dict(progress: CellProgress, health: CellHealth, build: CellBuild, unlocks: PartUnlocks) -> Dictionary:
	return {
		"version": VERSION,
		"dna": progress.dna,
		"growth": progress.growth,
		"stage": progress.stage,
		"hp": health.hp,
		"build": build_to_array(build),
		"unlocked": unlocks.unlocked.duplicate(),
	}


## Überträgt einen gelesenen Stand auf die Objekte. false (und keine Änderung), wenn die Version nicht passt.
static func apply(data: Dictionary, progress: CellProgress, health: CellHealth, unlocks: PartUnlocks) -> bool:
	if int(data.get("version", 0)) != VERSION:
		return false
	progress.dna = maxi(0, int(data.get("dna", 0)))
	progress.growth = maxi(0, int(data.get("growth", 0)))
	progress.stage = clampi(int(data.get("stage", 0)), 0, CellProgress.STAGE_COUNT - 1)
	health.hp = clampf(float(data.get("hp", health.max_hp)), 0.0, health.max_hp)
	unlocks.unlocked.clear()
	for id in data.get("unlocked", []):
		var s := str(id)
		if PartCatalog.exists(s) and not unlocks.unlocked.has(s):
			unlocks.unlocked.append(s)
	return true


static func read_build(data: Dictionary) -> CellBuild:
	return build_from_array(data.get("build", []))


static func write_file(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	return true


## Liest einen Spielstand; {} wenn die Datei fehlt oder kein JSON-Objekt enthält.
static func read_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return parsed
	return {}
