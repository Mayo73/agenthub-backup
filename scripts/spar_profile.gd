class_name SparProfile
extends RefCounted

## Liste der Trainingsstufen
const LEVELS: Array[String] = ["Einsteiger", "Fortgeschritten", "Erfahren"]

## Profil-ID
var id := ""
## Vollname
var name := ""
## Kampfsportart
var art := ""
## Level (0 = Einsteiger, 1 = Fortgeschritten, 2 = Erfahren)
var level := 0
## Trainingsjahre
var years := 0
## Alter
var age := 18
## Biografie / Beschreibung
var bio := ""
## Avatar-Farbe
var color := Color(0.5, 0.5, 0.5)


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
		"color": color.to_html(false)
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

	return profile


## Profil kopieren (über Serialisierung)
func duplicate_profile() -> SparProfile:
	return from_dict(to_dict())
