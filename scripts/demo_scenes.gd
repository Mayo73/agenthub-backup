class_name DemoScenes
extends RefCounted
## Vorführszenen für die Abnahme. Start mit "-- --szene=<name>".
## Lagen relativ zur Spielerzelle bei (0, 0) mit Blick nach rechts. "ai": [Art, Lage, Blickwinkel],
## "food": [Nahrungsart, Lage], "parts": [Teil, Lage in Zellradien] zusätzlich zum Startaufbau.

const SCENES := {
	"jagd": {"text": "Ein Schnapper jagt die kleine Spielerzelle.", "stage": 0, "diet": Diet.PFLANZENFRESSER, "parts": [], "ai": [["schnapper", Vector2(250, 0), PI]], "food": []},
	"flucht": {"text": "Ein Blasenling flieht vor der großen Spielerzelle.", "stage": 3, "diet": Diet.FLEISCHFRESSER, "parts": [], "ai": [["blasenling", Vector2(150, 0), PI]], "food": []},
	"nahrung": {"text": "Ein Blasenling schwimmt zur Pflanzennahrung.", "stage": 0, "diet": Diet.PFLANZENFRESSER, "parts": [], "ai": [["blasenling", Vector2(0, 250), 0.0]], "food": [[Diet.PFLANZE, Vector2(150, 250)]]},
	"stachel": {"text": "Der Stachel vorn verletzt die Weidezelle bei Berührung.", "stage": 2, "diet": Diet.PFLANZENFRESSER, "parts": [["stachel", Vector2(1, 0)]], "ai": [["weidezelle", Vector2(90, 0), 0.0]], "food": []},
	"gift": {"text": "Beim Schwimmen hinterlässt die Giftdrüse Wolken.", "stage": 2, "diet": Diet.PFLANZENFRESSER, "parts": [["gift", Vector2(-1, 0)]], "ai": [["blasenling", Vector2(-80, 0), 0.0]], "food": []},
	"elektro": {"text": "Das Elektroorgan entlädt sich bei nahen Gegnern.", "stage": 1, "diet": Diet.PFLANZENFRESSER, "parts": [["elektro", Vector2(0, 0.5)]], "ai": [["schnapper", Vector2(60, 0), PI]], "food": []},
	"tempo": {"text": "Zwei Geißeln: deutlich schneller als der Startaufbau.", "stage": 1, "diet": Diet.PFLANZENFRESSER, "parts": [["geissel", Vector2(-1, 0.25)], ["geissel", Vector2(-1, -0.25)]], "ai": [], "food": []},
	"wendigkeit": {"text": "Wimpern: engere Kurven als der Startaufbau.", "stage": 1, "diet": Diet.PFLANZENFRESSER, "parts": [["wimpern", Vector2(0, 1)], ["wimpern", Vector2(0, -1)]], "ai": [], "food": []},
}


static func names() -> Array[String]:
	var out: Array[String] = []
	for n: String in SCENES:
		out.append(n)
	return out


static func exists(scene_name: String) -> bool:
	return SCENES.has(scene_name)


static func data(scene_name: String) -> Dictionary:
	return SCENES.get(scene_name, {})


## Szenenname aus den Startargumenten ("--szene=jagd" ergibt "jagd"); "" ohne oder bei unbekannter Szene.
static func requested(args: PackedStringArray) -> String:
	for a in args:
		if a.begins_with("--szene="):
			var n := a.substr(8)
			return n if exists(n) else ""
	return ""


## Startaufbau passend zur Ernährung der Szene plus deren Teile.
static func build_for(scene_name: String) -> CellBuild:
	var d := data(scene_name)
	var b := CellBuild.starter(str(d.get("diet", Diet.PFLANZENFRESSER)))
	for p: Array in d.get("parts", []):
		b.add_part(p[0], p[1])
	return b
