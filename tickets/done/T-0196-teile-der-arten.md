---
id: T-0196
title: Sichtbare Teile für jede Zellart (SpeciesParts)
project: zellenphase
priority: 3
after: T-0185
---
## Ziel
Die KI-Zellen sollen ihre Teile zeigen wie im Vorbild: Pflanzenfresser mit Filtermaul, Jäger mit Kiefer, der Giftling mit Giftdrüsen, die Zitterzelle mit Elektroorgan usw. `SpeciesParts` legt fest, welche Teile jede Art trägt (nur Darstellung). Gezeichnet wird in einem Folgeticket.

## Dateien
- `scripts/species_parts.gd`: neu
- `tests/test_species_parts.gd`: neu

## Akzeptanzkriterien
`scripts/species_parts.gd` genau so:
```gdscript
class_name SpeciesParts
extends RefCounted
## Sichtbare Teile der KI-Arten (nur Darstellung; Werte und Verhalten stehen im SpeciesCatalog).
## Lage in Zellradien wie in CellBuild, (0, 0) = Zellmitte, Blickrichtung +x.

const PARTS := {
	"blasenling": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(-1, 0), "angle": 0.0}],
	"schnapper": [{"id": "kiefer", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}],
	"stachelkugel": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}],
	"giftling": [{"id": "ruessel", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "gift", "pos": Vector2(-0.5, 0.45), "angle": 0.0}, {"id": "gift", "pos": Vector2(-0.5, -0.45), "angle": 0.0}],
	"zitterzelle": [{"id": "kiefer", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "elektro", "pos": Vector2(-0.4, 0), "angle": 0.0}, {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}],
	"weidezelle": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(0, 1), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(0, -1), "angle": 0.0}],
	"hornjaeger": [{"id": "kiefer", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "stachel", "pos": Vector2(0.7, 0.7), "angle": 0.0}, {"id": "stachel", "pos": Vector2(0.7, -0.7), "angle": 0.0}, {"id": "duese", "pos": Vector2(-1, 0), "angle": 0.0}],
	"riesenschlund": [{"id": "kiefer", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "geissel", "pos": Vector2(-0.7, 0.7), "angle": 0.0}, {"id": "geissel", "pos": Vector2(-0.7, -0.7), "angle": 0.0}],
}


## Teile einer Art; leer bei unbekannter ID.
static func parts_of(id: String) -> Array:
	return PARTS.get(id, [])


## Kopien der Teile, deren Lage mit der Streckung des Körpers mitgeht (wie CellLook.outline).
static func placed_parts(id: String, stretch: float) -> Array:
	var out := []
	for part: Dictionary in parts_of(id):
		var copy := part.duplicate()
		var pos: Vector2 = part["pos"]
		copy["pos"] = Vector2(pos.x * stretch, pos.y / stretch)
		out.append(copy)
	return out
```

## Tests
`tests/test_species_parts.gd` mit `extends "res://tests/base_test.gd"`:
- `test_alle_arten`: für jede ID aus `SpeciesCatalog.ids()`: `SpeciesParts.parts_of(id).size() >= 1` wahr; jedes Teil `p` darin: `PartCatalog.exists(p["id"])` wahr
- `test_maul_passt`: für jede ID aus `SpeciesCatalog.ids()` genau ein Teil mit `PartCatalog.category_of(p["id"]) == "maul"`; dessen ID ist `"filtermaul"`, wenn `SpeciesCatalog.data(id)["diet"] == Diet.PFLANZENFRESSER`, `"kiefer"` bei `Diet.FLEISCHFRESSER` und `"ruessel"` bei `Diet.ALLESFRESSER`
- `test_unbekannt`: `SpeciesParts.parts_of("gibtsnicht").size()` ist 0; `SpeciesParts.placed_parts("gibtsnicht", 1.0).size()` ist 0
- `test_gestreckt`: `var p := SpeciesParts.placed_parts("schnapper", 1.3)` → `(p[0]["pos"] as Vector2).is_equal_approx(Vector2(1.3, 0))` wahr; `SpeciesParts.placed_parts("weidezelle", 1.25)[1]["pos"].is_equal_approx(Vector2(0, 0.8))` wahr
- `test_original_bleibt`: `SpeciesParts.placed_parts("schnapper", 2.0)` aufrufen → `(SpeciesParts.parts_of("schnapper")[0]["pos"] as Vector2).is_equal_approx(Vector2(1, 0))` wahr

Review (17.10.2026): gemergt.
