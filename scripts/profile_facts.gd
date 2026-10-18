class_name ProfileFacts
extends RefCounted


## Statistische Texte zu Gewichtsklasse, Tagen und Ausrüstung eines Profils erstellen.

## Text zur Gewichtsklasse
static func weight_text(p: SparProfile) -> String:
	return "Gewicht: " + p.weight_name()


## Text zu den Trainingstagen
static func days_text(p: SparProfile) -> String:
	var days := p.days
	if days.is_empty():
		return "Verfügbar: nach Absprache"
	if days.size() == SparProfile.DAYS.size():
		return "Verfügbar: täglich"
	return "Verfügbar: " + ", ".join(days)


## Text zur Ausrüstung
static func equipment_text(p: SparProfile) -> String:
	var equip := p.equipment
	if equip.is_empty():
		return "Ausrüstung: keine eigene"
	return "Ausrüstung: " + ", ".join(equip)


## Alle drei Texte zusammen (Gewicht, Verfügbarkeit, Ausrüstung)
static func all_text(p: SparProfile) -> String:
	return weight_text(p) + "\n" + days_text(p) + "\n" + equipment_text(p)


## Gemeinsame Tage zweier Profile finden (in Reihenfolge von SparProfile.DAYS)
static func common_days(a: SparProfile, b: SparProfile) -> Array[String]:
	var result := [] as Array[String]
	for day in SparProfile.DAYS:
		if a.days.has(day) and b.days.has(day):
			result.append(day)
	return result


## Text zu den gemeinsamen Tagen
static func common_days_text(a: SparProfile, b: SparProfile) -> String:
	var common := common_days(a, b)
	if common.is_empty():
		return "Keine gemeinsamen Tage – sprecht euch ab."
	return "Gemeinsame Tage: " + ", ".join(common)
