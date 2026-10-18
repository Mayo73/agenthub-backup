class_name FishSpecies
extends RefCounted
## Arten der Fischphase. size: Größe wie FishPlayer.size (1 = Spielerfisch am Anfang); speed in m/s;
## bite: Bissschaden (0 = beißt nicht); behavior: "schwarm", "scheu" oder "jaeger"; food: Nahrungswert beim Fressen;
## sight: Sichtweite in Metern.

const DATA := {
		"silberling": {"name": "Silberling", "size": 0.6, "speed": 6.0, "hp": 20.0, "bite": 0.0, "behavior": "schwarm", "color": Color(0.78, 0.84, 0.92), "food": 4, "sight": 12.0},
		"grasfisch": {"name": "Grasfisch", "size": 1.0, "speed": 4.5, "hp": 40.0, "bite": 0.0, "behavior": "scheu", "color": Color(0.42, 0.7, 0.36), "food": 7, "sight": 10.0},
		"kugelfisch": {"name": "Kugelfisch", "size": 0.8, "speed": 3.5, "hp": 30.0, "bite": 0.0, "behavior": "scheu", "color": Color(0.93, 0.74, 0.3), "food": 6, "sight": 8.0},
		"laternenfisch": {"name": "Laternenfisch", "size": 0.7, "speed": 5.0, "hp": 25.0, "bite": 0.0, "behavior": "scheu", "color": Color(0.25, 0.85, 0.95), "food": 10, "sight": 9.0, "glow": true},
		"zackenbarsch": {"name": "Zackenbarsch", "size": 1.8, "speed": 7.0, "hp": 90.0, "bite": 15.0, "behavior": "jaeger", "color": Color(0.55, 0.32, 0.25), "food": 12, "sight": 18.0},
	}


static func ids() -> Array[String]:
	var out: Array[String] = []
	for id: String in DATA:
		out.append(id)
	out.sort()
	return out


static func has(id: String) -> bool:
	return DATA.has(id)


## Werte einer Art; leeres Dictionary bei unbekannter Art.
static func data(id: String) -> Dictionary:
	return DATA.get(id, {})


## Körperradius in Metern (halbe Größe).
static func radius(id: String) -> float:
	return float(data(id).get("size", 1.0)) * 0.5


static func is_predator(id: String) -> bool:
	return float(data(id).get("bite", 0.0)) > 0.0
