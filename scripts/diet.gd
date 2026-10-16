class_name Diet
extends RefCounted
## Nahrungsarten, Ernährungsarten und die Mundwerkzeuge, die sie bestimmen.

const PFLANZE := "pflanze"
const FLEISCH := "fleisch"

const PFLANZENFRESSER := "pflanzenfresser"
const FLEISCHFRESSER := "fleischfresser"
const ALLESFRESSER := "allesfresser"

## IDs der Mundwerkzeuge (Teile)
const FILTERMAUL := "filtermaul"
const KIEFER := "kiefer"
const RUESSEL := "ruessel"


static func can_eat(diet: String, food_kind: String) -> bool:
	if diet == PFLANZENFRESSER:
		return food_kind == PFLANZE
	if diet == FLEISCHFRESSER:
		return food_kind == FLEISCH
	if diet == ALLESFRESSER:
		return food_kind == PFLANZE or food_kind == FLEISCH
	return false


## Ernährungsart aus den eingebauten Mundwerkzeugen. Leer, wenn keins dabei ist.
static func from_mouths(mouths: Array[String]) -> String:
	var plant := mouths.has(FILTERMAUL) or mouths.has(RUESSEL)
	var meat := mouths.has(KIEFER) or mouths.has(RUESSEL)
	if plant and meat:
		return ALLESFRESSER
	if plant:
		return PFLANZENFRESSER
	if meat:
		return FLEISCHFRESSER
	return ""
