---
id: T-0168
title: Muster und Körperform für jede Zellart (SpeciesCatalog)
project: zellenphase
priority: 2
---
## Ziel
Die acht Zellarten sollen sich nicht nur in der Farbe unterscheiden (Lastenheft „mindestens acht erkennbar verschiedene Gegner-/Beutetypen“). Jede Art bekommt ein Muster und eine Streckung; daraus entsteht ein `CellLook`.

## Dateien
- `scripts/species_catalog.gd`
- `tests/test_species_look.gd`: neu

## Akzeptanzkriterien
In `scripts/species_catalog.gd`:
- Jeder Eintrag in `SPECIES` bekommt am Ende (nach `"color": …`) zwei Schlüssel `"pattern"` und `"stretch"`, genau diese Werte:
  - `blasenling`: `"pattern": "keins", "stretch": 1.0`
  - `schnapper`: `"pattern": "streifen", "stretch": 1.3`
  - `stachelkugel`: `"pattern": "punkte", "stretch": 0.9`
  - `giftling`: `"pattern": "flecken", "stretch": 1.1`
  - `zitterzelle`: `"pattern": "streifen", "stretch": 1.4`
  - `weidezelle`: `"pattern": "flecken", "stretch": 1.2`
  - `hornjaeger`: `"pattern": "punkte", "stretch": 1.4`
  - `riesenschlund`: `"pattern": "flecken", "stretch": 0.85`
- Neue Funktion am Ende:
```gdscript
## Aussehen einer Art (Farbe, Muster, Streckung); Standardaussehen bei unbekannter ID.
static func look_of(id: String) -> CellLook:
	var look := CellLook.new()
	if not exists(id):
		return look
	var d := data(id)
	look.color = d["color"]
	look.set_pattern(str(d.get("pattern", "keins")))
	look.set_stretch(float(d.get("stretch", 1.0)))
	return look
```
- Sonst nichts ändern (die übrigen Werte bleiben gleich).

## Tests
`tests/test_species_look.gd` mit `extends "res://tests/base_test.gd"`:
- `test_schnapper`: `var l := SpeciesCatalog.look_of("schnapper")` → `l.pattern` ist `"streifen"`; `l.stretch` ist 1.3; `l.color.is_equal_approx(SpeciesCatalog.data("schnapper")["color"])` wahr
- `test_unbekannt`: `var l := SpeciesCatalog.look_of("gibtsnicht")` → `l.pattern` ist `"keins"`; `l.stretch` ist 1.0
- `test_alle_gueltig`: für jede ID aus `SpeciesCatalog.ids()`: `CellLook.PATTERNS.has(SpeciesCatalog.data(id)["pattern"])` wahr und `SpeciesCatalog.look_of(id).stretch` gleich `float(SpeciesCatalog.data(id)["stretch"])`
- `test_verschieden`: die Texte `str(data["pattern"]) + str(data["stretch"])` aller Arten als Schlüssel in ein Dictionary schreiben → `size()` mindestens 7

Review (16.10.2026): gemergt, nachgebessert: Einrückung der Tabelle wiederhergestellt.
