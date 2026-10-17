class_name FishStart
extends RefCounted
## Übergang von der Zellenphase in die Fischphase: Die Teile der Zelle bestimmen den ersten Fisch.

## Welches Teil der Zelle zu welchem Bauteil des Fischs wird.
const PART_MAP := {
	"geissel": "schwanz",
	"duese": "schwanz",
	"wimpern": "flossen",
	"kiefer": "kiefer",
	"stachel": "stacheln",
	"knopfauge": "augen",
	"stielauge": "augen",
}
## Höchste Stufe, die ein Bauteil aus der Zelle mitbringt.
const MAX_START_LEVEL := 2

## Übergabe zwischen den Szenen: main.gd setzt beides vor dem Szenenwechsel, FishMain liest es.
static var pending_build: FishBuild = null
static var pending_dna := 0


## Erster Fisch aus Aufbau, Aussehen und Ernährung der Zelle. Je passendem Teil eine Stufe, höchstens MAX_START_LEVEL.
static func from_cell(build: CellBuild, look: CellLook, diet: String) -> FishBuild:
	var fish := FishBuild.new()
	fish.color = look.color
	fish.diet = diet
	for part: Dictionary in build.parts:
		var slot: String = PART_MAP.get(part["id"], "")
		if slot != "" and fish.level(slot) < MAX_START_LEVEL:
			fish.levels[slot] = fish.level(slot) + 1
	return fish


## Zeilen für den Übergangsbildschirm: Ernährung, dann jedes Bauteil mit Stufe über 0 (z. B. "Schwanzflosse: Stufe 2").
static func summary_lines(fish: FishBuild) -> Array[String]:
	var lines: Array[String] = ["Ernährung: " + EndScreen.diet_name(fish.diet)]
	for slot: String in FishBuild.SLOTS:
		if fish.level(slot) > 0:
			lines.append("%s: Stufe %d" % [FishBuild.NAMES[slot], fish.level(slot)])
	return lines


## Soll das Spiel direkt in der Fischphase starten? (Startargument "--fisch", zum Ausprobieren.)
static func requested(args: PackedStringArray) -> bool:
	return args.has("--fisch")


## Setzt die Übergabe zurück (nach dem Lesen und in Tests).
static func clear() -> void:
	pending_build = null
	pending_dna = 0
