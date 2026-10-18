class_name DemoData
extends RefCounted

## Verfügbare Kampfsportarten
const ARTS: Array[String] = ["Jiu-Jitsu", "MMA", "Boxen", "Kickboxen", "Muay Thai", "Ringen", "Judo"]


## Acht fiktive Testpersonen als SparProfile zurückgeben
static func profiles() -> Array[SparProfile]:
	var result: Array[SparProfile] = []

	result.append(SparProfile.from_dict({
		"id": "p01",
		"name": "Alex",
		"art": "Jiu-Jitsu",
		"level": 1,
		"years": 4,
		"age": 29,
		"bio": "Trainiert regelmäßig draußen und mag ein lockeres Tempo.",
		"color": Color(0.20, 0.55, 0.85),
		"weight_class": 1,
		"days": ["Di", "Do", "Sa"],
		"equipment": ["Mundschutz", "Matte"]
	}))

	result.append(SparProfile.from_dict({
		"id": "p02",
		"name": "Sam",
		"art": "MMA",
		"level": 2,
		"years": 7,
		"age": 33,
		"bio": "Mag anspruchsvolle Einheiten und verschiedene Techniken.",
		"color": Color(0.85, 0.35, 0.25),
		"weight_class": 2,
		"days": ["Mo", "Mi", "Fr"],
		"equipment": ["Handschuhe", "Schienbeinschoner", "Mundschutz"]
	}))

	result.append(SparProfile.from_dict({
		"id": "p03",
		"name": "Mira",
		"art": "Boxen",
		"level": 1,
		"years": 3,
		"age": 26,
		"bio": "Freut sich auf Boxstunden mit guter Aufsicht von außen.",
		"color": Color(0.75, 0.30, 0.65),
		"weight_class": 0,
		"days": ["Sa", "So"],
		"equipment": ["Handschuhe", "Pratzen"]
	}))

	result.append(SparProfile.from_dict({
		"id": "p04",
		"name": "Jonas",
		"art": "Kickboxen",
		"level": 0,
		"years": 1,
		"age": 22,
		"bio": "Neu dabei und lernt gerne die Grundlagen draußen.",
		"color": Color(0.30, 0.70, 0.40),
		"weight_class": 1,
		"days": ["Mi", "Sa"],
		"equipment": []
	}))

	result.append(SparProfile.from_dict({
		"id": "p05",
		"name": "Lea",
		"art": "Jiu-Jitsu",
		"level": 2,
		"years": 9,
		"age": 35,
		"bio": "Erfahrene Practitionerin mit Fokus auf Technik.",
		"color": Color(0.90, 0.65, 0.20),
		"weight_class": 0,
		"days": ["Mo", "Do"],
		"equipment": ["Matte"]
	}))

	result.append(SparProfile.from_dict({
		"id": "p06",
		"name": "Deniz",
		"art": "Muay Thai",
		"level": 1,
		"years": 5,
		"age": 30,
		"bio": "Mag Muay-Thai-Einheiten und trainiert gerne draußen.",
		"color": Color(0.25, 0.65, 0.70),
		"weight_class": 1,
		"days": ["Di", "Fr", "So"],
		"equipment": ["Handschuhe", "Schienbeinschoner"]
	}))

	result.append(SparProfile.from_dict({
		"id": "p07",
		"name": "Kim",
		"art": "Ringen",
		"level": 0,
		"years": 2,
		"age": 24,
		"bio": "Einsteiger im Ringen mit Interesse an Bodenarbeit.",
		"color": Color(0.55, 0.45, 0.85),
		"weight_class": 2,
		"days": ["Sa"],
		"equipment": ["Mundschutz", "Matte"]
	}))

	result.append(SparProfile.from_dict({
		"id": "p08",
		"name": "Tarek",
		"art": "Boxen",
		"level": 2,
		"years": 11,
		"age": 38,
		"bio": "Langjähriger Boxer mit Fokus auf Kondition und Technik.",
		"color": Color(0.60, 0.60, 0.30),
		"weight_class": 2,
		"days": ["Mo", "Di", "Mi", "Do", "Fr"],
		"equipment": ["Handschuhe", "Mundschutz", "Pratzen"]
	}))

	return result


## IDs aller Profile in Reihenfolge zurückgeben
static func profile_ids() -> Array[String]:
	return ["p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08"]
