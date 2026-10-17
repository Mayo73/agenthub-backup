---
id: T-0178
title: Vorführszenen für die Abnahme (DemoScenes)
project: zellenphase
priority: 2
---
## Ziel
Die Abnahmekriterien 5 und 6 verlangen reproduzierbare Spielsituationen: Verfolgung, Flucht und Nahrungssuche sowie Stachel, Gift, Elektroorgan, Tempo und Wendigkeit. Diese Klasse beschreibt die Szenen; gestartet werden sie später mit `-- --szene=<name>`.

## Dateien
- `scripts/demo_scenes.gd`: neu
- `tests/test_demo_scenes.gd`: neu

## Akzeptanzkriterien
`scripts/demo_scenes.gd` genau so:
```gdscript
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
```

## Tests
`tests/test_demo_scenes.gd` mit `extends "res://tests/base_test.gd"`:
- `test_acht_szenen`: `DemoScenes.names().size()` ist 8; `DemoScenes.exists("gift")` wahr; `DemoScenes.exists("quatsch")` falsch
- `test_vollstaendig`: für jeden Namen `n` aus `DemoScenes.names()` hat `DemoScenes.data(n)` die Schlüssel `"text"`, `"stage"`, `"diet"`, `"parts"`, `"ai"` und `"food"` (je ein `check` mit `has`)
- `test_gueltige_ids`: für jede Szene: jede Art in `"ai"` (Eintrag `[0]`) besteht `SpeciesCatalog.exists(...)`, jedes Teil in `"parts"` (Eintrag `[0]`) besteht `PartCatalog.exists(...)`
- `test_argumente`: `DemoScenes.requested(PackedStringArray(["--szene=gift"]))` ist `"gift"`; `DemoScenes.requested(PackedStringArray(["--szene=quatsch"]))` ist `""`; `DemoScenes.requested(PackedStringArray([]))` ist `""`
- `test_aufbau`: `DemoScenes.build_for("tempo").parts.size()` ist 4; `DemoScenes.build_for("jagd").parts.size()` ist 2; `DemoScenes.build_for("flucht").mouths()[0]` ist `"kiefer"`

Review (17.10.2026): gemergt.
