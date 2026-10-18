class_name ProfileForm
extends RefCounted

## Konstanten für Validierung
const NAME_MAX := 30
const BIO_MAX := 120
const AGE_MIN := 18
const AGE_MAX := 99
const YEARS_MAX := 60


## Fehler in den Eingaben prüfen
## values hat: name (String), art (String), level (int), years (int), age (int), bio (String)
## Fehlende Schlüssel zählen als leer bzw. -1
## Liefert Probleme auf Deutsch
static func errors(values: Dictionary) -> Array[String]:
	var result: Array[String] = []

	# name prüfen
	var name: String = ""
	if values.has("name"):
		name = values["name"]
	if typeof(name) != TYPE_STRING:
		name = ""
	name = name.strip_edges()
	if name.is_empty():
		result.append("Name fehlt")
	elif name.length() > NAME_MAX:
		result.append("Name ist zu lang (höchstens 30 Zeichen)")

	# art prüfen
	var art: String = ""
	if values.has("art"):
		art = values["art"]
	if typeof(art) != TYPE_STRING:
		art = ""
	if not DemoData.ARTS.has(art):
		result.append("Kampfsportart fehlt")

	# level prüfen
	var level: int = -1
	if values.has("level"):
		level = values["level"]
	if typeof(level) != TYPE_INT:
		level = -1
	if level < 0 or level > 2:
		result.append("Erfahrung fehlt")

	# age prüfen
	var age: int = -1
	if values.has("age"):
		age = values["age"]
	if typeof(age) != TYPE_INT:
		age = -1
	if age < AGE_MIN:
		result.append("Nur Erwachsene: Alter mindestens 18")
	elif age > AGE_MAX:
		result.append("Alter ist ungültig")

	# years prüfen
	var years: int = -1
	if values.has("years"):
		years = values["years"]
	if typeof(years) != TYPE_INT:
		years = -1
	if years < 0 or years > YEARS_MAX:
		result.append("Trainingsjahre sind ungültig")

	# bio prüfen
	var bio: String = ""
	if values.has("bio"):
		bio = values["bio"]
	if typeof(bio) != TYPE_STRING:
		bio = ""
	bio = bio.strip_edges()
	if bio.length() > BIO_MAX:
		result.append("Text ist zu lang (höchstens 120 Zeichen)")

	# weight_class prüfen (nach den bisherigen Prüfungen)
	var weight_class: int = -1
	if values.has("weight_class"):
		weight_class = values["weight_class"]
	if typeof(weight_class) != TYPE_INT:
		weight_class = -1
	elif weight_class >= SparProfile.WEIGHT_CLASSES.size():
		result.append("Gewichtsklasse ist ungültig")

	# days prüfen (nach den bisherigen Prüfungen)
	if values.has("days"):
		var days: Variant = values["days"]
		if typeof(days) == TYPE_ARRAY:
			for day in days:
				if typeof(day) != TYPE_STRING or not SparProfile.DAYS.has(day):
					result.append("Unbekannter Trainingstag")
					break

	# equipment prüfen (nach den bisherigen Prüfungen)
	if values.has("equipment"):
		var equipment: Variant = values["equipment"]
		if typeof(equipment) == TYPE_ARRAY:
			for eq in equipment:
				if typeof(eq) != TYPE_STRING or not SparProfile.EQUIPMENT.has(eq):
					result.append("Unbekannte Ausrüstung")
					break

	return result


## Die neun Werte eines Profils als Dictionary zurückgeben
static func values_of(p: SparProfile) -> Dictionary:
	return {
		"name": p.name,
		"art": p.art,
		"level": p.level,
		"years": p.years,
		"age": p.age,
		"bio": p.bio,
		"weight_class": p.weight_class,
		"days": p.days.duplicate(),
		"equipment": p.equipment.duplicate()
	}


## Werte in ein Profil übernehmen oder null bei Fehlern
## Gibt eine Kopie mit neuen Werten (Texte mit strip_edges()) zurück.
## id und color bleiben wie im Original, das Original bleibt unverändert.
static func applied(p: SparProfile, values: Dictionary) -> SparProfile:
	var errs := errors(values)
	if not errs.is_empty():
		return null

	var copy := p.duplicate_profile()

	copy.name = values.get("name", "").strip_edges()
	copy.art = values.get("art", "")
	copy.level = int(values.get("level", 0))
	copy.years = int(values.get("years", 0))
	copy.age = int(values.get("age", 18))
	copy.bio = values.get("bio", "").strip_edges()

	# weight_class übernehmen, wenn vorhanden
	if values.has("weight_class"):
		var wc_val: Variant = values["weight_class"]
		if typeof(wc_val) == TYPE_INT:
			copy.weight_class = int(wc_val)

	# days übernehmen: ohne Doppelte, in Reihenfolge von DAYS
	if values.has("days"):
		var raw_days: Variant = values["days"]
		if typeof(raw_days) == TYPE_ARRAY:
			var seen: Dictionary
			for day in raw_days:
				if typeof(day) == TYPE_STRING and SparProfile.DAYS.has(day):
					seen[day] = true
			var new_days: Array[String] = []
			for d in SparProfile.DAYS:
				if seen.has(d):
					new_days.append(d)
			copy.days = new_days

	# equipment übernehmen: ohne Doppelte, in Reihenfolge von EQUIPMENT
	if values.has("equipment"):
		var raw_eq: Variant = values["equipment"]
		if typeof(raw_eq) == TYPE_ARRAY:
			var seen_equip: Dictionary
			for eq in raw_eq:
				if typeof(eq) == TYPE_STRING and SparProfile.EQUIPMENT.has(eq):
					seen_equip[eq] = true
			var new_equipment: Array[String] = []
			for e in SparProfile.EQUIPMENT:
				if seen_equip.has(e):
					new_equipment.append(e)
			copy.equipment = new_equipment

	return copy
