---
id: T-0092
title: Acht Zellarten (SpeciesCatalog)
project: zellenphase
priority: 4
after: T-0084, T-0085
---
## Ziel
Ein Katalog der acht anderen Zellarten im Ökosystem, verteilt über die fünf Größenabschnitte. So werden frühere Bedrohungen später zu Beute.

## Dateien
- `scripts/species_catalog.gd`: neu
- `tests/test_species_catalog.gd`: neu

## Akzeptanzkriterien
`scripts/species_catalog.gd` mit `class_name SpeciesCatalog`, `extends RefCounted` und genau dieser Tabelle:
```gdscript
## stage = Größenabschnitt (0 bis 4, Radius wie CellProgress.RADII), speed in Pixeln pro Sekunde,
## damage = Bissschaden, behavior = Verhaltensmuster (wird später ausgebaut).
const SPECIES := {
	"blasenling": {"name": "Blasenling", "stage": 0, "diet": Diet.PFLANZENFRESSER, "behavior": "scheu", "speed": 110.0, "hp": 20.0, "damage": 0.0, "color": Color(0.66, 0.9, 0.63)},
	"schnapper": {"name": "Schnapper", "stage": 1, "diet": Diet.FLEISCHFRESSER, "behavior": "jaeger", "speed": 150.0, "hp": 40.0, "damage": 15.0, "color": Color(0.91, 0.51, 0.23)},
	"stachelkugel": {"name": "Stachelkugel", "stage": 1, "diet": Diet.PFLANZENFRESSER, "behavior": "stachel", "speed": 60.0, "hp": 50.0, "damage": 10.0, "color": Color(0.79, 0.71, 0.35)},
	"giftling": {"name": "Giftling", "stage": 2, "diet": Diet.ALLESFRESSER, "behavior": "gift", "speed": 100.0, "hp": 60.0, "damage": 8.0, "color": Color(0.61, 0.35, 0.71)},
	"zitterzelle": {"name": "Zitterzelle", "stage": 2, "diet": Diet.FLEISCHFRESSER, "behavior": "elektro", "speed": 130.0, "hp": 60.0, "damage": 12.0, "color": Color(0.95, 0.88, 0.35)},
	"weidezelle": {"name": "Weidezelle", "stage": 3, "diet": Diet.PFLANZENFRESSER, "behavior": "herde", "speed": 90.0, "hp": 120.0, "damage": 0.0, "color": Color(0.37, 0.7, 0.63)},
	"hornjaeger": {"name": "Hornjäger", "stage": 3, "diet": Diet.FLEISCHFRESSER, "behavior": "jaeger", "speed": 170.0, "hp": 120.0, "damage": 25.0, "color": Color(0.75, 0.22, 0.17)},
	"riesenschlund": {"name": "Riesenschlund", "stage": 4, "diet": Diet.FLEISCHFRESSER, "behavior": "lauerer", "speed": 80.0, "hp": 300.0, "damage": 40.0, "color": Color(0.42, 0.2, 0.51)},
}
```
Dazu diese Funktionen:
- `static func ids() -> Array[String]`: alle Schlüssel von `SPECIES` in der Reihenfolge der Tabelle
- `static func exists(id: String) -> bool`
- `static func data(id: String) -> Dictionary`: der Eintrag, bei unbekannter ID `{}`
- `static func name_of(id: String) -> String`: `"name"`, bei unbekannter ID `""`
- `static func radius_of(id: String) -> float`: `CellProgress.radius_for_stage(stage)`, bei unbekannter ID 0.0
- `static func ids_near_stage(stage: int) -> Array[String]`: alle IDs (Tabellenreihenfolge), deren `"stage"` höchstens 1 von `stage` abweicht

## Tests
`tests/test_species_catalog.gd` mit `extends "res://tests/base_test.gd"`:
- `test_acht_arten`: `SpeciesCatalog.ids().size()` ist 8; die acht Namen (`name_of`) sind alle verschieden und nicht leer
- `test_ernaehrung_gueltig`: für jede ID ist `data(id)["diet"]` eins von `Diet.PFLANZENFRESSER`, `Diet.FLEISCHFRESSER`, `Diet.ALLESFRESSER`
- `test_radius`: `radius_of("riesenschlund")` ist 60.0; `radius_of("schnapper")` ist 18.0; `radius_of("gibtsnicht")` ist 0.0; `data("gibtsnicht")` ist `{}`
- `test_jeder_abschnitt`: für jede Stufe 0 bis 4 gibt es mindestens eine Art mit genau dieser `"stage"`
- `test_nahe_abschnitte`: mit typisierten Arrays vergleichen: `ids_near_stage(0)` ist `["blasenling", "schnapper", "stachelkugel"]`; `ids_near_stage(4)` ist `["weidezelle", "hornjaeger", "riesenschlund"]`

Review (16.10.2026): von Claude selbst umgesetzt (Typfehler bei Array[String] in ids_near_stage, an dem der Agent fünfmal scheiterte); 5 Tests, Prüfung grün.
