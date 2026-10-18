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

	return result


## Die sechs Werte eines Profils als Dictionary zurückgeben
static func values_of(p: SparProfile) -> Dictionary:
	return {
		"name": p.name,
		"art": p.art,
		"level": p.level,
		"years": p.years,
		"age": p.age,
		"bio": p.bio
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

	return copy
