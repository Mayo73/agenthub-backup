---
id: T-0118
title: Spielstand als JSON (SaveGame)
project: zellenphase
priority: 5
after: T-0103, T-0105
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Der Spielstand (DNA, Wachstum, Größenabschnitt, Gesundheit, Zellaufbau, Freischaltungen) lässt sich als JSON-Datei speichern und wieder laden. Das automatische Speichern kommt in einem späteren Ticket.

## Dateien
- `scripts/save_game.gd`: neu
- `tests/test_save_game.gd`: neu

## Akzeptanzkriterien
`scripts/save_game.gd` genau so:
```gdscript
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
```

## Tests
`tests/test_save_game.gd` mit `extends "res://tests/base_test.gd"` und `const PATH := "user://test_spielstand.json"`; `teardown()`: `if FileAccess.file_exists(PATH): DirAccess.remove_absolute(PATH)` (auf zwei Zeilen).
- `test_hin_und_zurueck`: `var p := CellProgress.new()`, `p.eat(12)`; `var h := CellHealth.new()`, `h.damage(30.0)`; `var b := CellBuild.starter(Diet.FLEISCHFRESSER)`, `b.add_part("geissel", Vector2(-1, 0.25), 0.5)`; `var u := PartUnlocks.new()`, `u.unlock("geissel")`. `SaveGame.write_file(PATH, SaveGame.to_dict(p, h, b, u))` wahr; `var d := SaveGame.read_file(PATH)`; neue Objekte `p2`, `h2`, `u2`; `SaveGame.apply(d, p2, h2, u2)` wahr → `p2.dna` 12, `p2.growth` 2, `p2.stage` 1, `h2.hp` 70.0, `u2.is_unlocked("geissel")` wahr, `u2.unlocked.size()` 4; `var b2 := SaveGame.read_build(d)` → `b2.parts.size()` 3, `b2.parts[2]["id"]` ist `"geissel"`, `b2.parts[2]["pos"]` ist (-1, 0.25), `b2.parts[2]["angle"]` ist 0.5, `b2.parts[0]["id"]` ist `"kiefer"`
- `test_fehlende_datei`: `SaveGame.read_file("user://gibtsnicht_123.json").is_empty()` wahr
- `test_falsche_version`: `var p := CellProgress.new()`, `p.eat(3)`; `SaveGame.apply({"version": 99, "dna": 50}, p, CellHealth.new(), PartUnlocks.new())` falsch; `p.dna` ist 3
- `test_unbekannte_teile_ignoriert`: `var u := PartUnlocks.new()`; `SaveGame.apply({"version": 1, "unlocked": ["filtermaul", "gibtsnicht", "filtermaul"]}, CellProgress.new(), CellHealth.new(), u)` wahr → `u.unlocked.size()` ist 1

Review (16.10.2026): gemergt.
