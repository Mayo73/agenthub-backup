class_name NameUniquifier
extends RefCounted
## Einzigartige Namenerstellung für Objekte.
## Statische Methode zur Extraktion des Basisnamens ohne Anhängselziffern.
## @param name: Der Originalname, z.B. "Gegner12" oder "Kiste07"
## @return: Der Basisname ohne Ziffern; wenn leer oder nur Zahlen → "Knoten"
static func base_name(name: String) -> String:
	var s: String = name
	# Ziffern am Ende entfernen (Prüfe ob Zeichen '0' bis '9')
	while s.length() > 0:
		var ch: String = s.substr(s.length() - 1, 1)
		if not (ch >= "0" and ch <= "9"):
			break
		s = s.substr(0, s.length() - 1)
	if s.is_empty():
		return "Knoten"
	return s


## Erzeugt einen eindeutigen Namen basierend auf einer Liste belegter Namen.
## @param name: Der gewünschte Name
## @param taken: Array aller bereits belegten Namen
## @return: Ein freier Name, der nicht in `taken` enthalten ist
static func unique(name: String, taken: Array) -> String:
	# Leerer Name oder nur Ziffern → Basisname "Knoten"
	var basis: String
	if name.is_empty():
		basis = "Knoten"
	else:
		basis = base_name(name)

	# Prüfe ob Basisname bereits belegt ist (wenn Input-Name nicht leer war, prüfe originalen Namen)
	var pruefname: String = name if not name.is_empty() else basis
	var belegt: bool = false
	for t in taken:
		if str(t) == pruefname:
			belegt = true
			break

	# Falls Basisname (bei leerem Input) belegt, oder Input-Name belegt → hochzählen
	if name.is_empty() or belegt:
		var n: int = 2
		while true:
			var candidate: String = basis + str(n)
			var already: bool = false
			for t in taken:
				if str(t) == candidate:
					already = true
					break
			if not already:
				return candidate
			n += 1

	# Input-Name ist frei → direkt zurückgeben
	return name
