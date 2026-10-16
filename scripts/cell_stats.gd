class_name CellStats
extends RefCounted
## Werte einer Zelle aus Aufbau (CellBuild) und Größenabschnitt.

const BASE_SPEED := 220.0
const SPEED_PER_STAGE := 30.0
const BASE_TURN := 6.0
const MIN_TURN := 2.0


static func max_speed(build: CellBuild, stage: int) -> float:
	return BASE_SPEED + SPEED_PER_STAGE * stage + bonus(build, "speed")


static func turn_rate(build: CellBuild) -> float:
	return maxf(MIN_TURN, BASE_TURN + bonus(build, "turn"))


## Ernährung aus den Mundwerkzeugen; "" ohne Maul.
static func diet(build: CellBuild) -> String:
	return Diet.from_mouths(build.mouths())


## Summe eines Werts (Schlüssel aus PartCatalog.PARTS) über alle Teile.
## Jedes weitere Teil derselben Art wirkt nur halb so stark wie das vorige.
static func bonus(build: CellBuild, key: String) -> float:
	var total := 0.0
	var seen := {}
	for p in build.parts:
		var id: String = p["id"]
		var n: int = seen.get(id, 0)
		total += float(PartCatalog.data(id)[key]) * pow(0.5, n)
		seen[id] = n + 1
	return total
