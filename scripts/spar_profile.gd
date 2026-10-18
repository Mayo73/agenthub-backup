class_name SparProfile
extends RefCounted

## Liste der Trainingsstufen
const LEVELS: Array[String] = ["Einsteiger", "Fortgeschritten", "Erfahren"]
## Liste der Gewichtsklassen
const WEIGHT_CLASSES: Array[String] = ["Leicht (bis 66 kg)", "Mittel (66–84 kg)", "Schwer (über 84 kg)"]
## Liste der Wochentage als Kürzel
const DAYS: Array[String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
## Liste der verfügbaren Ausrüstungsgegenstände
const EQUIPMENT: Array[String] = ["Handschuhe", "Schienbeinschoner", "Mundschutz", "Matte", "Pratzen"]

## Profil-ID
var id: String = ""
## Vollname
var name: String = ""
## Kampfsportart
var art: String = ""
## Level (0 = Einsteiger, 1 = Fortgeschritten, 2 = Erfahren)
var level: int = 0
## Trainingsjahre
var years: int = 0
## Alter
var age: int = 18
## Biografie / Beschreibung
var bio: String = ""
## Avatar-Farbe
var color: Color = Color(0.5, 0.5, 0.5)
## Gewichtsklasse (-1 = keine Angabe, sonst Index in WEIGHT_CLASSES)
var weight_class: int = -1
## Trainingstage (nur Werte aus DAYS)
var days := [] as Array[String]
## Vorhandene Ausrüstung (nur Werte aus EQUIPMENT)
var equipment := [] as Array[String]


## Name der Gewichtsklasse zurückgeben oder "keine Angabe" bei ungültigem Index
func weight_name() -> String:
	if weight_class < 0 or weight_class >= WEIGHT_CLASSES.size():
		return "keine Angabe"
	return WEIGHT_CLASSES[weight_class]


## Name der Stufe zurückgeben (kann nicht aus den Bounds fallen)
func level_name() -> String:
	return LEVELS[clampi(level, 0, 2)]


## Initialen: erster Buchstabe jedes Wortes, groß, max 2 Zeichen
func initials() -> String:
	if name.is_empty():
		return "?"

	var parts := name.split(" ")
	var result := ""

	for part in parts:
		if not part.is_empty():
			result += part[0].to_upper()
			if result.length() >= 2:
				break

	if result.is_empty():
		return "?"

	return result.substr(0, 2)


## Profil als Dictionary serialisieren
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"art": art,
		"level": level,
		"years": years,
		"age": age,
		"bio": bio,
		"color": color.to_html(false),
		"weight_class": weight_class,
		"days": days.duplicate(),
		"equipment": equipment.duplicate()
	}


## Profil aus Dictionary deserialisieren
static func from_dict(d: Dictionary) -> SparProfile:
	var profile := SparProfile.new()

	profile.id = d.get("id", "")
	profile.name = d.get("name", "")
	profile.art = d.get("art", "")
	profile.level = int(d.get("level", 0))
	profile.years = int(d.get("years", 0))
	profile.age = int(d.get("age", 18))

	var color_html: Variant = d.get("color", "")
	if typeof(color_html) == TYPE_STRING and not color_html.is_empty():
		profile.color = Color.html(color_html)
	else:
		profile.color = Color(0.5, 0.5, 0.5)

	profile.bio = d.get("bio", "")

	# weight_class: -1 wenn fehlt, außerhalb 0–2 oder nicht-Int → -1
	var wc_raw: Variant = d.get("weight_class", -1)
	if typeof(wc_raw) == TYPE_INT and wc_raw >= 0 and wc_raw < profile.WEIGHT_CLASSES.size():
		profile.weight_class = int(wc_raw)
	else:
		profile.weight_class = -1

	# days: nur bekannte Werte, ohne Doppelte, sortiert in DAYS-Reihenfolge
	var raw_days: Variant = d.get("days", [])
	if typeof(raw_days) == TYPE_ARRAY:
		var seen := {}  # Dictionary[String, bool]
		for item in raw_days:
			if typeof(item) == TYPE_STRING and profile.DAYS.has(item):
				if not seen.has(item):
					seen[item] = true
		var sorted_days: Array[String] = []
		for day in profile.DAYS:
			if seen.has(day):
				sorted_days.append(day)
		profile.days = sorted_days

	# equipment: nur bekannte Werte, ohne Doppelte, sortiert in EQUIPMENT-Reihenfolge
	var raw_equipment: Variant = d.get("equipment", [])
	if typeof(raw_equipment) == TYPE_ARRAY:
		var seen_equip := {}  # Dictionary[String, bool]
		for item in raw_equipment:
			if typeof(item) == TYPE_STRING and profile.EQUIPMENT.has(item):
				if not seen_equip.has(item):
					seen_equip[item] = true
		var sorted_equipment: Array[String] = []
		for equip in profile.EQUIPMENT:
			if seen_equip.has(equip):
				sorted_equipment.append(equip)
		profile.equipment = sorted_equipment

	return profile


## Profil kopieren (über Serialisierung)
func duplicate_profile() -> SparProfile:
	return from_dict(to_dict())
