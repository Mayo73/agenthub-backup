class_name SpeciesCatalog
extends RefCounted
## Die acht anderen Zellarten im Ökosystem, verteilt über die fünf Größenabschnitte.

## stage = Größenabschnitt (0 bis 4, Radius wie CellProgress.RADII), speed in Pixeln pro Sekunde,
## damage = Bissschaden, behavior = Verhaltensmuster (wird später ausgebaut).
const SPECIES := {
		"blasenling": {"name": "Blasenling", "stage": 0, "diet": Diet.PFLANZENFRESSER, "behavior": "scheu", "speed": 110.0, "hp": 20.0, "damage": 0.0, "color": Color(0.66, 0.9, 0.63), "pattern": "keins", "stretch": 1.0},
		"schnapper": {"name": "Schnapper", "stage": 1, "diet": Diet.FLEISCHFRESSER, "behavior": "jaeger", "speed": 150.0, "hp": 40.0, "damage": 15.0, "color": Color(0.91, 0.51, 0.23), "pattern": "streifen", "stretch": 1.3},
		"stachelkugel": {"name": "Stachelkugel", "stage": 1, "diet": Diet.PFLANZENFRESSER, "behavior": "stachel", "speed": 60.0, "hp": 50.0, "damage": 10.0, "color": Color(0.79, 0.71, 0.35), "pattern": "punkte", "stretch": 0.9},
		"giftling": {"name": "Giftling", "stage": 2, "diet": Diet.ALLESFRESSER, "behavior": "gift", "speed": 100.0, "hp": 60.0, "damage": 8.0, "color": Color(0.61, 0.35, 0.71), "pattern": "flecken", "stretch": 1.1},
		"zitterzelle": {"name": "Zitterzelle", "stage": 2, "diet": Diet.FLEISCHFRESSER, "behavior": "elektro", "speed": 130.0, "hp": 60.0, "damage": 12.0, "color": Color(0.95, 0.88, 0.35), "pattern": "streifen", "stretch": 1.4},
		"weidezelle": {"name": "Weidezelle", "stage": 3, "diet": Diet.PFLANZENFRESSER, "behavior": "herde", "speed": 90.0, "hp": 120.0, "damage": 0.0, "color": Color(0.37, 0.7, 0.63), "pattern": "flecken", "stretch": 1.2},
		"hornjaeger": {"name": "Hornjäger", "stage": 3, "diet": Diet.FLEISCHFRESSER, "behavior": "jaeger", "speed": 170.0, "hp": 120.0, "damage": 25.0, "color": Color(0.75, 0.22, 0.17), "pattern": "punkte", "stretch": 1.4},
		"riesenschlund": {"name": "Riesenschlund", "stage": 4, "diet": Diet.FLEISCHFRESSER, "behavior": "lauerer", "speed": 80.0, "hp": 300.0, "damage": 40.0, "color": Color(0.42, 0.2, 0.51), "pattern": "flecken", "stretch": 0.85},
	}


## Alle IDs in der Reihenfolge der Tabelle.
static func ids() -> Array[String]:
	var result: Array[String] = []
	for id: String in SPECIES:
		result.append(id)
	return result


static func exists(id: String) -> bool:
	return SPECIES.has(id)


static func data(id: String) -> Dictionary:
	return SPECIES.get(id, {})


static func name_of(id: String) -> String:
	return data(id).get("name", "")


static func radius_of(id: String) -> float:
	if not exists(id):
		return 0.0
	return CellProgress.radius_for_stage(SPECIES[id]["stage"])


## Alle IDs, deren Größenabschnitt höchstens 1 von stage abweicht.
static func ids_near_stage(stage: int) -> Array[String]:
	var result: Array[String] = []
	for id in ids():
		if absi(int(SPECIES[id]["stage"]) - stage) <= 1:
			result.append(id)
	return result


## Aussehen einer Art (Farbe, Muster, Streckung); Standardaussehen bei unbekannter ID.
static func look_of(id: String) -> CellLook:
	var look := CellLook.new()
	if not exists(id):
		return look
	var d := data(id)
	look.color = d["color"]
	look.set_pattern(str(d.get("pattern", "keins")))
	look.set_stretch(float(d.get("stretch", 1.0)))
	return look
